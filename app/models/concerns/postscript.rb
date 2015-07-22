# -*- coding: utf-8 -*-
require 'nkf'

# より高級class PsGraph も参照のこと
# book = Postscript.new(opt={:macros => [:left] ,:paper => "A4p",:y0_is_up => false})
# book.色んな描画method; book.to_s で PSが得られる
# 紙サイズ A5,A4,A3,B4
# 印刷方向sufix landscape "l" ,portrate "p"
# 縦軸方向      
# 初期登録マクロ(定義不要だが取り込み必要)
#   :rectangre,  :centering,  :left,  :boxandline,  :boxandlinefill
# Page管理
#   close_preamble
#   new_page        :: ページトレーラーを挿入して bookに入れ、新しいページを用意する
#   close           :: ページトレーラーを挿入して bookに入れる。
#   to_s            :: PsHeader、book、PsTrailer を結合し PS文字列にする
#
# マクロ
#   define   :: PS に組み込むマクロを class Postscriptコマンドで定義する
#   set_macro_from_Macros_unless_include :: 組み込み定義済みのマクロを取り込む
#   add_macro :: 文字列で与えられたマクロを定義する
#
# PSコマンド記述
#   add       :: PS文字列で記述
#   repeat    :: PS語の repeat をclass Postscript語で記述する
#   forall    :: PS語の forall をclass Postscript語で記述する
#   gsave_restore    :: gsave grestore で囲まれたPS語をclass Postscript語で記述する
#   gsave_restore_if :: gsave grestore の前後にPS語をつける
#   gsave, grestore  :: PS語の gsave, grestore を挿入
#   ruby_array_to_ps_array ::
#   ruby_array_to_ps_array_doubl :: 
#   
# 座標変換
#   translate
#   scale
#   rotate
# 
# 描画
#   show
#   moveto
#   rmoveto
#   line
#   box_diagonal
#   boxandline
#   boxandlinefill
#   box
#   box_fill
#   stroke_fill
#   stroke
#   fill
#   line_width
#   nl
#   initclip
#   clip
#
# 文字描画#   
#   centering
#   string
#   set_font
#   font_setting
#   set_color_rgb
#   
# 高級  
#   show_labels :: 文字列のArryの内容を一定間隔で描画
#   multi_lines :: 指定回数の線を一定間隔で描画
#   
#   
#   
# 下請け
#   color2rgb
#   set__colo_rgb_hexstring
#   comment
#   
class Postscript
  Inch = 25.4 # mm
  Point   = 0.3527 # mm
  Paper = {
    "A5" => [421,595], "A4" => [595, 842],  "A3" => [842,1190],  "B4" => [729,1032]
  }
  
  Orientation = { "p" => "" , "l" => "%%Orientation: Landscape\n"}
  OrientTrans = { "p" => 1 , "l" => 1 }
  PageRotate  = { "p" => "" , "l" => "90 rotate\n" }
  Y0SCALE      = { true => " 1 -1 scale\n",false => "",nil => ""}
  Y0TRANS      = { true => 0, false => 1,nil => 1}
  StringShow  = { 
    true => "/string_show { gsave 1 -1 scale string show grestore} def\n",
    false => "/string_show { string show} def\n",nil => "/string_show {string show} def\n"}
  #PageTranslate  = { "p" => "" , "l" => "90 rotate\n" }
  Macros = {
    :rectangre => "/re { exch dup neg 3 1 roll 5 3 roll moveto 0 rlineto
      0 exch rlineto 0 rlineto closepath } bind def",
    :centering => "/centering { 1 dict begin /string exch def 
  string stringwidth pop neg 2 div 0 rmoveto 
  string_show  end } def",
    :right => "/right { 1 dict begin /string exch def 
  string stringwidth pop neg 0 rmoveto string_show  end } def",
    :left      => "/left { 1 dict begin /string exch def string_show end } def",
    :boxandline => "/boxandline { 
   dup 0 get aload pop pop  pop 3 2 roll
   %  100 200 [ [ 100 200 10 20] [ 150 200 10 30] [ 200 100 10 90]]
  { gsave 0.0 setlinewidth
    aload  7 1 roll pop 0.5 mul 3 -1 roll  add exch
    %  [100 200 10 20] 100 200 100 200
     moveto lineto stroke
    %  [100 200 10 20]
     aload 5 1 roll
    % [100 200 10 20] 100 200 10 20 
    re stroke
     % [100 200 10 20]
    aload pop   exch 0.5 mul 3 1 roll add  3 1 roll add exch
    % 100 200 10 20
    %           100 200 20 5     100 5 220     220 105 105 220
    grestore
  } forall pop pop
} def",
    :boxandlinefill => "/boxandlinefill
 { 3 dict begin /b exch def /g exch def /r exch def
   dup 0 get aload pop pop  pop 3 2 roll
   %  100 200 [ [ 100 200 10 20] [ 150 200 10 30] [ 200 100 10 90]]
  { gsave 0.0 setlinewidth
    aload  7 1 roll pop 0.5 mul 3 -1 roll  add exch
    %  [100 200 10 20] 100 200 100 200
     moveto lineto stroke
    %  [100 200 10 20]
     aload 5 1 roll
    % [100 200 10 20] 100 200 10 20 
    re gsave r g b  setrgbcolor fill grestore stroke
     % [100 200 10 20]
    aload pop   exch 0.5 mul 3 1 roll add  3 1 roll add exch
    % 100 200 10 20
    %           100 200 20 5     100 5 220     220 105 105 220
    grestore
  } forall pop pop
  end
} def",
    nil => nil
  }
  PsHeader = "%%!PS
%%%%Pages: 0
%s%%%%BoundingBox: 0 0 %d %d
%%%%BeginSetup
[{
%%%%BeginFeature: *PageRegion %s
<</PageSize [%d %d]>> setpagedevice
%%%%EndFeature
} stopped cleartomark

%s
%%%%%%%
"

  EpsHeader = "%%!PS-Adobe-2.0 EPSF-2.0
%%%%BoundingBox: 0 1 %d %d
%%%%HiResBoundingBox: 0.000000 1.000000 %f %f
%%%%BeginSetup-%%EndComments
%% EPSF created by ps2eps 1.64
%%%%BeginProlog
save
countdictstack
mark
newpath
/showpage {} def
/setpagedevice {pop} def
%%%%EndProlog
%%%%Page 1 1
[{
%%%%BeginFeature: *PageRegion %s
<</PageSize [%d %d]>> setpagedevice
%%%%EndFeature
} stopped cleartomark
%s
%%%%%%%
"

  PsTrailer="\n%%Trailer%%EOF\n"
  EpsTrailer="\n%%Trailer
%%Trailer
cleartomark
countdictstack
exch sub { end } repeat
restore
%%EOF\n"

  PageHeaderTemplate="%%%%Page: %d %d\n%%%%BeginPageSetup\n\n%s%%%%EndPageSetup\n"
  PageTrailer = "showpage"

  #Gothic    = F_G = "/GothicBBB-Medium-EUC-H" 
  Gothic     = F_G = "/GothicBBB-Medium-UniJIS-UTF8-H"
  #Mincho    = F_M = "/Ryumin-Light-EUC-H"
  Mincho    = F_M = "/Ryumin-Light-UniJIS-UTF8-H"
  Helvetica = F_H = "/Helvetica"
  Roman     = F_R = "/Times-Roman"
  Bold      = F_B = "/Times-Bold"
  Courier   = F_C = "/Courier"

  Attr_names  = [ :paper,:y0_is_up ]
  attr_reader :paper, :orientation, :paperWidth , :paperHight, :orientation
  attr_reader :page,:pages,:ps_header  , :pageHight, :pageWidth,:option
  attr_reader :paper_setup,:scale   ,:point
  attr_reader :eps

  def initialize(args={})
    @option = { :macros => [:left] ,:paper => "A4p",:y0_is_up => false,
      :eps => false,:gscale => Pos.new(1.0,1.0)
    }.merge(args)
    Attr_names.each do | attr_name|
      instance_variable_set "@#{attr_name}",@option.delete(attr_name)
    end
    @page_no =0
    @page = []
    @pages = []
    @font = " /Helvetica "
    @point = 10
    @currentscale = Pos.new(1.0,1.0)
    setup_y0_is_up
    init_page
  end

  def close_preamble 
    @pages << @page if @page.size>0
    #@page_no += 1;
    #@page = [ PageHeaderTemplate % [@page_no,@page_no,@paper_setup] ]
    @page=[]
    self
  end

  def new_page
    if @page.size>1
      @page << PageTrailer
      @pages << @page 
    end
    @page_no += 1;
    @page = [ PageHeaderTemplate % [@page_no,@page_no,@paper_setup] ]
    self
  end

  def close
    if @page.size>0
      @page << PageTrailer
      @pages << @page
      @page = [@paper_setup] 
    end 
    self
  end

def to_s
  close
  @ps_header.sub(/%%Pages: 0/,"%%Pages: #{@page_no}") +
    @pages.map{|page| page.join(" ")}.join("\n") +
    (@eps ? EpsTrailer : PsTrailer)
end
def paper_offset(offset,unit)
    absolute_scale(unit).translate(offset).unabsolute_scale
end

###
def define(name,opt={},&block)
  @page << "/#{name} { "
  yield
  @page << " } def\n"
  self
end

###
def set_macro_from_Macros_unless_include(symbol_of_macroname)
  unless @option[:macros].include?(symbol_of_macroname)
    nl.add(Macros[symbol_of_macroname]).nl
    @option[:macros] << symbol_of_macroname
  end
  self
end

def add_macro(str)
  @ps_header += str
  self
end
def add(str)
  case str
  when String ;    @page << str 
  when Array  ;    @page += str
  else        ;    @page << str.to_s
  end
  self
end

def repeat(times,&block)
  @page << "#{times} {" ;   yield ;    @page << "} repeat\n"
  self
end
def forall(array,&block)
  @page << "[ (#{array.join(') (')}) ]\n {" ;   yield ;    @page << "} forall\n"
  self
end
def gsave_restore_if(bool,pre_proc,&block)
  if bool
    @page << "gsave" 
    @page << pre_proc
  end
  yield
  if bool
    @page << "grestore"
  end
  self 
end
def gsave_restore(&block)
  @page << "gsave" 
  yield
  @page << "grestore"
  self 
end

def gsave
  @page << "gsave" 
  self ;
end

def grestore; @page << "grestore";self ;end

########
def translate(xy,y=nil     )
  case xy
  when Array,Pos ; @page << "#{xy[0]} #{xy[1]} translate" # Pos
  else           ; @page << "#{xy} #{y} translate"
  end 
  self
end

def pos_unit(unit,scl=1.0)
  case unit
  when :mm ; Pos.new( 1/Point*scl,1/Point*scl)# Pos.new(1.0/Inch,1.0/Inch)
  when :m  ; Pos.new( 1000/Point*scl,1000/Point*scl)# Pos.new(1.0/Inch,1.0/Inch)
  else     ; Pos.new(1.0,1.0)
  end
end
def scale_unit(unit,scl=1.0)
  scale pos_unit(unit,scl)
end
def unscale_unit(unit,scl=1.0)
  scale(case unit

         when :mm ; Pos.new( scl*Point,scl*Point)# Pos.new(1.0/Inch,1.0/Inch)
         when :m  ; Pos.new( scl*Point/1000,scl*Point/1000)# Pos.new(1.0/Inch,1.0/Inch)
         else     ; Pos.new(1.0,1.0)
         end
         )
end

def scale(*sxy)
  #$stderr.puts sxy.first.x.class
  case sxy.first
  when Array,Integer,Float ; sx,sy = sxy
  when Pos  ; sx =sxy.first.x; sy = sxy.first.y
  end
  @scale = [sx.to_f,sy.to_f]
  @page << "%.3f %.3f scale" % [sx.to_f,sy.to_f]
  @current_scale=Pos.new(sx.to_f,sy.to_f)
  self
end
def absolute_scale(unit)
  new_scale= pos_unit(unit)
  @temp_scale = Pos.new(new_scale.x/@current_scale.x,new_scale.y/@current_scale.y )
  scale(@temp_scale)
  self
end

def unabsolute_scale
  scale(1.0/@temp_scale.x,1.0/@temp_scale.y )
end

def rotate(angle)
  @page << "#{angle} rotate" if angle != 0.0
  self
end

def moveto(x,y=nil)
  case x
  when Hash,Pos
    @page <<  "%.3f %.3f moveto " % [x[:x],x[:y]]  if x[:x] && x[:y]
  when Array
    @page <<  "%.3f %.3f moveto " % [x[0],x[1]]  if x[0] && x[1]
  else
    @page <<  "%.3f %.3f moveto " % [x,y] if x && y
  end
  self
end
def rmoveto(x,y=nil)
  case x
  when Hash,Pos
    @page <<  "%.3f %.3f rmoveto " % [x[:x],x[:y]]  if x[:x] && x[:y]
  when Array
    @page <<  "%.3f %.3f rmoveto " % [x[0],x[1]]  if x[0] && x[1]
  else
    @page <<  "%.3f %.3f rmoveto " % [x,y] if x && y
  end
  self
end
def newpath ; @page << "newpath" ;self;end

def lines(poses,opt={ })
  gsave_restore{ 
    line_width(opt[:size])
    moveto(poses[0])
    poses[1..-1].each{ |pos| lineto(pos[0],pos[1])}
    stroke
  }
  
end
def rlines(poses,opt={ })
  gsave_restore{ 
    line_width(opt[:size])
    moveto(poses[0])
    poses[1..-1].each{ |pos| rlineto(pos[0],pos[1])}
    stroke
  }
  
end

def line(x0,y0,x1,y1,opt={:size => nil,:scale =>Pos.new(1,1)})
  size,s = case opt
           when Hash     ; [opt[:size],opt[:scale]]
           when Numeric  ; [opt,Pos.new(1,1)]
           else          ; [nil,Pos.new(1,1)]
         end
  line_width(size)
  #s = opt[:scale] if opt.class == Hash
  @page << "%.3f %.3f moveto %.3f %.3f lineto stroke  \n" % [x0*s.x,y0*s.y,x1*s.x,y1*s.y] 
  self
end

def lineto(x0,y0,opt={:size => nil,:scale =>Pos.new(1,1)})
  line_width(opt[:size])
  s = opt[:scale]
  @page << "%.3f %.3f lineto "%[x0*s.x,y0*s.y] 
  self
end
def rlineto(x0,y0,opt={:size => nil,:scale =>Pos.new(1,1)})
  line_width(opt[:size])
  s = opt[:scale]
  @page << "%.3f %.3f rlineto "%[x0*s.x,y0*s.y] 
  self
end

def initclip ; @page << "initclip" ; self ; end
def clip(ary =nil)
  box(*ary)    if ary
  @page << "clip newpath"
  self
end

#def box_diagonal(x0,y0,x9,y9,size=nil)
def box_diagonal(*args)
  option = args.pop if args[-1].class == Hash
  args = args[0]
  case args.size
  when 4,5 ; x0,y0,x9,y9,size=args
  when 3   ; x0,y0 =args[0]; x9,y9 =args[1];size=args[2]
  when 2 
    case args[1]  
    when Array    ; x0,y0=args[0];x9,y9=args[1];size=nil
    else          ; x0,y0,x9,y9=args[0]; size=args[1]
    end
  end
  size = option[:size] || size
#pp 
  line_width(size)
  @page << "newpath %.3f %.3f %.3f %.3f re " % [x0,y0,x9-x0,y9-y0]
  stroke
  self
end

def boxandline(boxes)
  set_macro_from_Macros_unless_include(:boxandline)
  add(ruby_array_to_ps_array_doubl boxes).add("boxandline")
  self
end

def boxandlinefill(boxes,color)
  set_macro_from_Macros_unless_include(:boxandlinefill)
  add(ruby_array_to_ps_array_doubl boxes).add(color2rgb(color)).add("boxandlinefill")
  self
end

def ruby_array_to_ps_array(array)
  "[" + array.map{|v| v.is_a?(Numeric) ? v : "(#{v.to_s})"}.join(" ")+"]"
end
def ruby_array_to_ps_array_doubl(array_of_array)
  "[" + array_of_array.map{|array| ruby_array_to_ps_array(array)}.join(" ")+"]"
end


def box(*xywhs)
  case xywhs.size
  when 4,5 ; x,y,w,h,size = xywhs
  when 2,3 ; 
    if (xywhs[0].class == Array || xywhs[0].class == Pos) &&
        (xywhs[1].class == Array || xywhs[1].class == Pos)
      x = xywhs[0].x;y=xywhs[0].y;
      w = xywhs[1].x;
      h = xywhs[1].y;
      size=xywhs[3]
    else
      raise
    end
  else
    raise
  end
  line_width(size)
  @page << "newpath %.3f %.3f %.3f %.3f re " % [x,y,w,h]
  self
end
def box_stroke(x,y,w,h,size=nil)
  box(x,y,w,h,size).stroke
  self
end
def closepath; @page << "closepath ";self ;end


def box_string(str,*xywhs)
  box_stroke(*xywhs)

  case xywhs.size
  when 4,5 ; x,y,w,h,size = xywhs
  when 2,3 ; 
    if xywhs[0].class == Array &&  xywhs[1].class == Array 
      x,y = xywhs[0]; w,h = xywhs[1];size=xywhs[3]
    else
      raise
    end
  else
    raise
  end
  centering(str,:x => x+0.5*w,:y => y+0.1 )
end

def box_fill(*args)
  case args.size
  when 3,5 ; rgb = args.pop
  else     ; rgb = nil
  end

  box(*args).gsave
  if rgb
    gsave.set_color_rgb(rgb) 
  end
  fill
  grestore if rgb
  grestore.stroke
  self
end


def stroke_fill(rgb=nil)
  gsave
  if rgb
    set_color_rgb(rgb) 
  end
  fill.grestore.stroke
end

def nl; @page << "\n";self;end

def stroke
  @page << "stroke"
  self
end

def fill(rgb=nil)
  if rgb
    gsave.set_color_rgb(rgb) 
  end
  @page <<  "fill"
  grestore if rgb
  self

end

def line_width(size)
  @page << "#{size} setlinewidth " if size
  self
end

def centering(str,opt={})
  return unless str
  euc_str = euc(str.to_s)
  unless @option[:macros].include?(:centering)
    add(Macros[:centering]) ; @option[:macros]<<:centering
  end
  gsave.set_font(opt)            if opt[:font] || opt[:point]
  moveto(opt[:x],opt[:y])  if opt[:x] && opt[:y]
  #gsave.scale(1,-1) if @y0_is_up
  if opt[:tilt] && opt[:tilt] != 0
    @page << "gsave #{ opt[:tilt]} rotate  (#{euc_str}) centering grestore\n"  
  else
    @page << "(#{euc_str}) centering"
  end
  grestore if  opt[:font] || opt[:point]
  self
end


def right(str,opt={})
  return unless str
  euc_str = euc(str.to_s)
  unless @option[:macros].include?(:centering)
    add(Macros[:right]) ; @option[:macros]<<:right
  end
  set_font(opt)            if opt[:font] || opt[:point]
  moveto(opt[:x],opt[:y])  if opt[:x] && opt[:y]
  if opt[:tilt] && opt[:tilt] != 0
    @page << "gsave #{ opt[:tilt]} rotate  (#{euc_str}) centering grestore\n"  
  else
    @page << "(#{euc_str}) right"
  end
  self
end

def multiline_string(strs,opt={}) #x=nil,y=nil,point=10,font=nil,tilt=nil)
  return unless strs
  #strs = str.split(/[\n\r]+/)
  set_font(opt) if opt[:font] || opt[:point]
  x,y =  opt[:x] ,opt[:y]
  #pp [x,y]
  strs.each_line{ |str|
    moveto(x,y);y -= @point
    if opt[:tilt] && opt[:tilt] != 0
      @page << "gsave #{ opt[:tilt]}[:tilt]} rotate (#{str}) left grestore"  
    else
      #STDERR.puts  "gsave 1 -1 scale (#{str}) show grestore\n"
      @page <<  "(#{str}) left"
    end
  }
  self
end
def string(str,opt={}) #x=nil,y=nil,point=10,font=nil,tilt=nil)
  return unless str
  euc_str = euc(str.to_s)
  set_font(opt) if opt[:font] || opt[:point]
  moveto(opt[:x],opt[:y])  if opt[:x] && opt[:y]
  moveto(opt[:xy]) if opt[:xy]
  if opt[:tilt] && opt[:tilt] != 0
    @page << "gsave #{ opt[:tilt]} rotate (#{euc_str}) left grestore"  
  else
    #STDERR.puts  "gsave 1 -1 scale (#{euc_str}) show grestore\n"
    @page <<  "(#{euc_str}) left"
  end
  self
end
def show(opt={}) #x=nil,y=nil,point=10,font=nil,tilt=nil)
  set_font(opt) if opt[:font] || opt[:point]
  moveto(opt[:x],opt[:y])  if opt[:x] && opt[:y]
  if opt[:tilt]
    @page << "gsave #{ opt[:tilt]} rotate left grestore"  
  else
    #STDERR.puts  "gsave 1 -1 scale (#{euc str}) show grestore\n"
    @page <<  "left"
  end
  self
end

def set_font(opt={})
  @page << font_setting(opt) 
  self
end

def font_setting(opt)
  return "" if !( opt[:font] || opt[:point] || opt[:fontset])
  @font = opt[:font]  if opt[:font]
  @point      = opt[:point] if opt[:point]
  @font, @point    = opt[:fontset] if opt[:fontset]
  " #{@font} findfont #{@point} scalefont setfont "
end

def set_color_rgb(color)
  if color.class == Float
    @page <<  "%.3f setrgbcolor" % color 
  elsif color.class == Integer
    @page <<  "%.3f setgray" % color/255.0       
  else
    @page << color2rgb(color)<< " setrgbcolor "
  end
  self
end

def color2rgb(color)
  case color
  when String ;  return set__colo_rgb_hexstring(color)
  when Array  ;  color.map{|v| "%5.3f"% (v.to_i/255.0)}.join(" ")
  when Integer;  [16,8,0].map{|i|  "%5.3f"% (((color>>i) %256)/255.0)}.join(" ")
  end
end
def set__colo_rgb_hexstring(rgb)
  ("000000"+rgb) =~ /(..)(..)(..)$/
  [$1,$2 , $3].map{|v| "%5.3f"% (v.to_i(16)/255.0)}.join(" ") 
end


def comment(str)
  @page << "\n%#{str}\n"
  self
end

def show_labels(labels,origin,rmove,option={})
  gsave_restore{
    moveto(origin)
    forall(labels.map{|s| euc(s)}){ gsave_restore{show(option)};rmoveto(rmove)}
  }
  self
end
def multi_lines(x0,y0,x9,y9,rmove,times,opt={:size => nil,:scale => Pos.new(1,1)})
  gsave_restore{repeat(times){ line(x0,y0,x9,y9,opt).
      translate(rmove)}}
  self
end


#private
def euc(str) 
  str #NKF.nkf("-e",str)
end
def setup_y0_is_up
  if @y0_is_up
    "/y0_is_up { "
  else
  end
end

def init_page
  @paper,@orientation = @paper.rpartition(/[pl]/)
  @paperWidth, @paperHight  =  Paper[@paper]
  transe = case [ @y0_is_up,@orientation]
           when [ true     ,"l"] ;  0 
           when [ true     ,"p"] ;  @paperHight
           when [ false    ,"p"] ;  0
           when [ false    ,"l"] ;  -@paperWidth
           end
  #unless @y0_is_up
      @paper_setup = " %s\n 0.0 %.3f translate\n#{Y0SCALE[@y0_is_up]}" % [PageRotate[@orientation], transe ]
  #end
  @ps_header = 
    @eps ? 
  (EpsHeader % [(@eps[0]+0.5).to_i,(@eps[1]+0.5).to_i,
                @eps[0],@eps[1],
                @paper,@paperWidth , @paperHight,
                macros
               ] 
   ) :
    (PsHeader % [Orientation[@orientation],@paperWidth , @paperHight,
                 @paper,@paperWidth , @paperHight,
                 macros
                ]
     )
  @pageHight,@pageWidth = @orientation == "l" ? [@paperWidth , @paperHight] : [ @paperHight,@paperWidth]
end

def macros
  @option[:macros] =  Macros.keys.compact if @option[:macros] == :all ||  @option[:macros] == [:all]
  @option[:macros] = (@option[:macros] << :left).uniq
  StringShow[@y0_is_up]+@option[:macros].map{|m| Macros[m]}.join("\n")
end
def set_pages_to_header
  @page_header.sub!(/%%Pages: 0/,"%%Pages: #{@pane_no}")
  self
end  
end

##############################################################
# class PsGraph < Postscript
# 
# 
#    grid :: 引数 graphに従って グラフ用の升目を描く。graphは class Graph のインスタンス
#    draw :: clip窓のあるグラフを記述。
#    draw_scrolled_graph :: clip窓の中にスクロールされたグラフを記述
#    put_title ::
#    put_labels ::
# 
# 
# 
# 
# 
# 
# 
# 
##############################################################
class PsGraph < Postscript
  # graph :: 
  # flame_origin,      [x00,y00] current unit
  # axis_range,        [[x0,x9],[y0,y9]]
  # grid_start_delta,  [[xs,dx],[ys,dy]]
  # opt={})            :waku_line_width grid_line_width
  def grid( graph ,opt={})
    comment("frame_with_grid")
    gsave_restore{
      scale=graph.scale
      translate(graph.origin).nl

      line_width( opt[:waku_line_width] )  if opt[:waku_line_width] 
      box(0,0,graph.width.x*scale.x,graph.width.y*scale.y).stroke.nl
      line_width( opt[:grid_line_width] )  if opt[:grid_line_width]
      define(:line){line(graph.axis0.x,0,graph.axis0.x,graph.width.y,:scale => scale)}
      gsave_restore{repeat(((graph.width.x-graph.axis0.x)/graph.dgrid.x).ceil){ 
                      add(:line).translate(graph.dgrid.x*scale.x,0)
        }}
      nl

      define(:line){line(0,graph.axis0.y,graph.width.x,graph.axis0.y,:scale => scale)}
      gsave_restore{repeat(((graph.width.y-graph.axis0.y)/graph.dgrid.y).ceil){ 
                      add(:line).translate(0,graph.dgrid.y)
        }}
      nl
    }
    comment("end of frame_with_grid")
  end

    # 紙の大きさ       @paperWidth, @paperWidth  Land,Port によらず、用紙の大きさ                 原寸
    # ページの大きさ   @pageWidth ,@pageHight    Land,Port による。　用紙の大きさと同じ面積       原寸
    # グラフの原点     Graph # :origin,                                               原寸
    # グラフの大きさ。グラフタイトル、軸名称、軸値を含まない。ページをはみ出すかも
    #                  Graph # :x_width,:y_width,                                                 実寸
    #   原寸・実寸比           :x_scale, :y_scale      原寸 = 実寸 * scale
    # 原点の値、最初の目盛の値、目盛の幅　　　:axis0.x,:axis0.y　@x_grid0,@y_grid0　:dx,:dy       実寸
    # 軸タイトルの位置        x_title_pos、y_title_pos                                            原寸
    # グラフスクロールの枠　　win_x0,win_y0,win_width,win_hight                                   原寸
    # 目盛スクロールの幅      x_title_pos.y、y_title_pos.x                                        原寸
  def draw(graph,macro_xaxis,macro_yaxis,macro_grid,opt={})  
    delta_x = (graph.clip_width / (graph.dgrid.x*graph.scale.x)).to_i * (graph.dgrid.x*graph.scale.x)
    delta_y = (graph.clip_hight / (graph.dgrid.y*graph.scale.y)).to_i * (graph.dgrid.y*graph.scale.y)
    trans_y=0
    (0..(graph.width.y*graph.scale.y/delta_y).ceil-1).each{|y| trans_y=y*delta_y
      (0..graph.width.x*graph.scale.x).step(delta_x).each{|trans_x|
        new_page
        put_title(graph,:y).nl.put_title(graph,:x).nl
        initclip.clip(graph.clip_earia_of_xaxis).nl
        draw_scrolled_graph(graph,macro_xaxis,macro_yaxis,macro_grid,
                            trans_x,trans_y,opt)
      }
    }
  end

  def draw_scrolled_graph(graph,macro_xaxis,macro_yaxis,macro_grid,trans_x,trans_y,opt={})
    gsave_restore{initclip.clip(graph.clip_earia_of_xaxis).translate(-trans_x,0).add(macro_xaxis).nl}
    gsave_restore{initclip.clip(graph.clip_earia_of_yaxis).translate(0,-trans_y).add(macro_yaxis).nl}
    gsave_restore{initclip.clip(graph.clip_earia_of_grid).translate(-trans_x,-trans_y).add(macro_grid).nl}
  end

  def put_title(graph,xy,opt={})
    gsave_restore{
      translate(graph.origin).nl
      gsave_restore_if(graph.title_point[xy],
                       font_setting(:point=>graph.title_point[xy])){
        centering(graph.title[xy], :tilt => xy == :y ? 90 : 0 ,
                  :y => graph.title_pos[xy].y,:x => graph.title_pos[xy].x
                  )
      }
    }
    self
  end

  def put_labels(graph,xy)

    yx = xy == :x ? :y : :x
    gsave_restore{
      translate(graph.origin).nl
      posx,posy = 
      case xy
      when :x ;
        [(graph.axis0[:x]+graph.label_pos[:x][:x])*graph.scale[:x],
                graph.label_pos[:x][:y]]
      when :y 
        [(graph.axis0[:y]+graph.label_pos[:y][:x])*graph.scale[:y],
                graph.label_pos[:y][:y]]
      end
      moveto( :x => posx, :y => posy )
      
      forall(graph.labels[xy].map{|s| euc(s)}){
        gsave_restore{show(graph.label_option[xy])}
        rmoveto(yx => 0,xy => graph.dgrid[xy]*graph.scale[xy])
      }
    }
    self
  end
end


  # 紙の大きさ       @paperWidth, @paperWidth  Land,Port によらず、用紙の大きさ                 原寸
  # ページの大きさ   @pageWidth ,@pageHight    Land,Port による。　用紙の大きさと同じ面積       原寸
  # グラフの原点     Graph # :x_origin,:y_origin,                                               原寸
  # グラフの大きさ。グラフタイトル、軸名称、軸値を含まない。ページをはみ出すかも
  #                  Graph # :x_width,:y_width,                                                 実寸
  #   原寸・実寸比           :x_scale, :y_scale      原寸 = 実寸 * scale
  # 原点の値、最初の目盛の値、目盛の幅　　　:axis0.x,:axis0.y　@x_grid0,@y_grid0　:dx,:dy       実寸
  # 軸タイトルの位置        x_title_pos、y_title_pos                                            原寸
  # グラフスクロールの枠　　win_x0,win_y0,win_width,win_hight        原寸
  # 目盛スクロールの幅      x_title_pos.y、y_title_pos.x             原寸
  #pp [1,pdf.win_x0 ,pdf.win_y0,  ,pdf.win_width ,pdf.win_hight]
class Graph
  Attr_names  = [
                 :origin,:width,       # グラフ位置、大きさ
                 :axis0,:grid0,:dgrid, # 原点座標、最初の目盛,目盛 間隔
                 :scale,               # 倍率　　原寸 = 実寸 * scale
                 :axis_format,         # 軸の値が ?_axis_labels で与えられなかったとき使う
                 :label_option, :labels,            #
                 :title,:title_point,
                 :point
                ]

  Attr_Writers  = [:clip_earia_of_grid,      # grid部のclipエリア.[x,y,w,h]
                 :clip_earia_of_xaxis,:clip_earia_of_yaxis    # 軸目盛部のclipエリア
                  ]
            
  attr_accessor( *Attr_names )
  attr_accessor :scale
  attr_writer(   *Attr_Writers)
  def initialize(args={})
    @option = {
      :label_option =>{:x=>{},:y=>{} },
      :axis0  => Pos.new(0.0,0.0),
      :scale  => Pos.new(1.0,1.0)
    }.merge(args)
    (Attr_names+Attr_Writers+[:label_pos,:title_pos,:pdf]).
      each do | attr_name|
        instance_variable_set "@#{attr_name}",@option.delete(attr_name)
      end
    [@scale,@axis0,@grid0,@grid].each{|pos| next unless pos
      pos.to_f
    }
  end

  def clip_width
    @clip_earia_of_grid ? @clip_earia_of_grid[2] : @pdf.pageWidth - @origin.x - 15
  end
  def clip_hight
    @clip_earia_of_grid ? @clip_earia_of_grid[3] : @pdf.pageHight - @origin.y - 15
  end
  def clip_earia_of_grid
    @clip_earia_of_grid || [@origin.x,@origin.y,@pdf.pageWidth - @origin.x - 15,@pdf.pageHight - @origin.y - 15]
  end
  def clip_earia_of_xaxis
    @clip_earia_of_xaxis || [@origin.x,@origin.y,@pdf.pageWidth - @origin.x - 15,@title_pos.x.y]
  end
  def clip_earia_of_yaxis
    @clip_earia_of_yaxis || [@origin.x,@origin.y-10,@title_pos.y.x,@pdf.pageHight - @origin.y - 5]
  end
  def label_pos
    @label_pos ||= Pos.new(-5,-5)
  end
  def title_pos
    @title_pos ||= 
      { :x => Pos.new(width.x*0.5,- 10 - title_point.x*1.5),
      :y => Pos.new(- 10 - title_point.y*1.5,width.y*0.5)}
  end

  def labels
    return @labels if @labels && @labels[:x] && @labels[:y]
#STDERR.puts @dgrid.to_a.join "/"

    @labels ||= {}
    [[:x,0],[:y,1]].each{|xy,i|
      unless @labels[xy] 
        @labels[xy] = @labels[i] = 
          if @axis_format[xy]
            (@grid0[xy]..@width[xy]).step(@dgrid[xy]).map{|x| @axis_format[xy] % x } 
          else
            []
          end
      end
    }
    @labels
  end 

  def x_labels
    return labels[:x]
  end 

  def y_labels
    return labels[:y]
  end 

end

class Pos < Hash
  #attr_accessor :x,:y
  def initialize(*xy)
    super()
    case xy.size
    when 1 #Array,Pos
      self[:x]=xy[0][0]; self[:y]=xy[0][1]
    else
      self[:x]=xy[0]; self[:y]=xy[1]
    end
    self[0] =self[:x] ; self[1] =self[:y]
    
  end

  def self.[](*args)
    self.new(args)
  end

  def to_f ; self[:x] = self[:x].to_f; self[:y] = self[:y].to_f; self;end
  def x ; self[:x];end
  def y ; self[:y];end
  def *(other)
    ret = case other
    when Integer,Float ; self.class.new(x*other,y*other);
    when Pos,Array     ; self.class.new(x*other[0],y*other[1]);
    end
    ret
  end

  def +(other)
    self.class.new(self.x + other[0],self.y + other[1])
  end
end
