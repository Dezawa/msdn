#!/usr/bin/ruby1.9
# -*- coding: utf-8 -*-
require 'pp'
#require 'my_csv'

module Ubr

#WithoutPull = true

LotAttrs = [:grade,:meigara_code,:meigara,:lot_no,:count,
            :packed_date,:hasuukubun,:unit,:paret,:dmy
           ]
SegAttrs = [:lot,:weight,:waku,:paret,:comment_urb,:comment_qa,:count,:cause,:pull,:order,:direction]

  Names = %w(等級 品目コード 品目名称 ロット№ 個数 数量 単位 置場 パレット 包装日 端数区分 物流注記 品質注記 降級原因 引当)
  Attrs = [:grade,:meigara_code,:meigara,:lot_no,:count,:weight,:unit,:waku,:paret,
           :packed_date,:hasuukubun,:comment_urb,:comment_qa,:cause,:pull,:order,:direction
          ]
Converter = [:str,:str,:str,:str,:int,:int,:str,:str,:str,:str,:str,:str]

  Name2Attr = Hash[*Names.zip(Attrs).flatten]

class Lot
  include CsvIo
  delegate :logger, :to=>"ActiveRecord::Base"
  SCMFILEBASE = File.join(Rails.root,"tmp","ubr","SCM在庫一覧")
  SCMFILE     =  SCMFILEBASE+".csv"
  attr_accessor :grade,:meigara_code,:meigara,:lot_no,:count,:unit,:packed_date,:qa,:paret
  attr_accessor :hasuukubun
  attr_writer :segments
  def initialize(arg={ })
    Attrs.each{|atr|
      case atr
      when :weight,:waku; next
      when :count ; instance_variable_set "@#{atr}",arg.delete(atr).to_i
      #when :packed_date ;
      #  @packed_date = Time.local(*arg.delete(:packed_date).split(/[^\d]/)) 
      else   
        val = (arg.delete(atr) || "").strip;
        instance_variable_set "@#{atr}",val
      end
    }
    #logger.debug("Lot.new  @meigara_code = #{ @meigara_code.class},'#{ @meigara_code}'")
    return nil unless @meigara_code && @meigara_code>""
    @meigara = Meigara.meigara_by_code[@meigara_code]
    unless @meigara
      @meigara = Meigara.add_meigara(@meigara_code,arg[:meigara])
      #pp [@meigara_code,lot_no,"Meigara Missing"]
    end
    wt    = arg.delete(:weight).to_f
    w=arg.delete(:waku)
    wk  = case w
          when Waku ; #puts w unless w
            w
          when String;
            if ww=Waku.by_name(w)#;puts ww# unless ww
              ww
            else 
              $WAKUMISSING ||= []
              $WAKUMISSING.push(w).uniq! 
              ww = Waku.new({:name => w })
            end
          else ;  pp [w,@meigara_code] ;raise "ありえない #{w} #{@meigara_code}"
          end
    @segments = [segment = LotSegment.new(self,wt,wk,@paret,@comment_urb,@comment_qa,
           @count,@cause,@pull,@order,@direction)]
    #@segments = [segment = LotSegment.new(self,wt,wk,SegAttrs.map{ |attr| self.send(attr)})]
    #begin
      wk.add segment
    #rescue
    #  $WAKUMISSING ||= []
    #  $WAKUMISSING.push(w).uniq!
    #  #pp [w,lot_no,"Waku missing"]
    #end
  end

  def add(segment) 
    @segments << segment #= LotSegment.new(self,lot.weight,wk))
    self
  end

  def delete(segment=nil,&block)
    unless block
      @segments.delete(segment)
    end
    self
  end

  # without_pull :: true     : 引き合い無いもの 
  #              :: :export  : 出荷
  #              :: false,nil: 引き合いあるもの
 def segments(without_pull=WithPull)
    case without_pull
    when OnlyExport  ;  @segments.dup.select{|seg| seg.pull?(OnlyExport)}
    when WithoutPull ;  @segments.dup.select{|seg| !seg.pull?}
    else             ;  @segments.dup
    end
  end

  def to_csv(without_pull = WithPull)
    segments.sort_by{|seg| pp seg unless seg.waku
      seg.waku.name}.
      map{|seg| seg.to_csv(without_pull) }.compact.join("\n")
  end

  def id ; [@meigara_code,@lot_no,@grade,@comment_qa] ;end
  def grade_comment_qa ; [ @grade,@comment_qa] ;end
  def niugoki ; self.meigara.niugoki ;end
  def keitai
    meigara_code[-2,2]
    #begin #if self.meigara.housou
    #  self.meigara.housou.keitai 
    #rescue #else
    #  logger.info("UBR::Lot#keitai  銘柄 #{@meigara_code},ロット #{ @lot_no} 包装未定義")
    #end
  end

  def stack_limit ; #@meigara.stack_limit ; end
    return 1 if Ubr::Const::Oneways.include?(meigara_code)
    case @paret
    when /11$/,/Y-14/ ; 2
    when /14$/ ; 3
    else       ; 1
    end
  end

  def dmy;end
  def kazu     ; @segments.inject(0){|p,lot_seg| p + lot_seg.kazu } ;end
  def paret_su ; @segments.inject(0){|p,lot_seg| p + lot_seg.paret_su } ;end

  def masu_su  ; @segments.inject(0){|p,lot_seg| p + lot_seg.need  } ;end
  def need     ; @segments.inject(0){|n,lot_seg| n + lot_seg.need }     ;end
  def weight   ; @segments ? @segments.inject(0){|w,lot_seg| w + (lot_seg ? lot_seg.weight : 0) } : 0  ;end
  def weight_class ; (self.weight/1000.0).ceil ;end
  def ton10_class ; (self.weight/10000.0).ceil ;end
  def comment_qa  ; @segments.map{ |seg| seg.comment_qa }.compact.join(",") ; end


  def ton      ; self.weight/1000.0 ;end

  def weight_without_pull
    @segments.inject(0){|w,lot_seg| w + (lot_seg.pull? ? 0 : lot_seg.weight) }
  end

  def packed
    Time.local(*packed_date.split(/[^\d]/)) rescue Time.local(1970,1,1)
  end

  def period(date=nil)
    date ? Time.local(*date.split(/[^\d]+/)) - packed :
      Time.now - packed
  end

  def waku     ; @segments.inject([]){|w,lot_seg| w << lot_seg.waku }   ;end
  def location ; @segments.inject([]){|w,lot_seg| w << lot_seg.waku.location }   ;end
  def grade1?  ; @grade <= "1" ; end
  # 0      1            2          3          4       5      6   7
  #"等級","品目コード","品目名称","ロット№","個数","数量","単位",,
  # 8       9       10        11        12          13        14
  #"置場","ﾊﾟﾚｯﾄ","包装日","端数区分","物流注記","品質注記","降級原因",
  #"引当","受注№","指図№"
  def self.create(line)
    if line.class == Hash 
      Lot.new(line) if line[:meigara_code]
    else
      case line
      when Hash; 
      when CSV::Row ,Array; line 
      when String   ;  CSV.parse_line(line)
      end
      return unless row[1] && row[2]
      arg={}
      Attrs.each_with_index{|atr,i| arg[atr]=row[i] }
      
      Lot.new(arg)
    end
  end

end

#####################################################################################
#####################################################################################
class LotSegment
  @@Segments = []
  attr_accessor *SegAttrs
  #:weight,:waku,:paret,:comment_urb,:comment_qa,
  #         :cause,:pull,:order,:direction
  #attr_:paret_su
  def initialize(*arg)
#pp [lot,args]
    SegAttrs.each{|atr|
       instance_variable_set "@#{atr}",arg.shift
    }
    #@lot = arg_lot
    #@weight = arg_weight.to_f
    #@waku   = arg_waku
    @@Segments << self
  end

  
  delegate :logger, :to=>"ActiveRecord::Base"
  LotAttrs.each{|attr| define_method(attr.to_s) do  lot.send(attr)  end }
  def self.segments ; @@Segments ; end
  def waku_name     ; waku.name  ;end

  def paret_su ; 
    #logger.debug("lot_no=#{lot_no} @lot=#{@lot} @lot.meigara=#{@lot.meigara} #{@lot.meigara.hash}")
    #pp @lot unless @lot.meigara
    if  paret == "Y-14" && /^N/ =~ @lot.keitai
      # Y-14 は輸出用紙袋55袋積み
      
      #logger.debug("Y-14 は輸出用紙袋55袋積み @weight=#{@weight} unit_weight=#{@lot.meigara.unit_weight} #{(@weight.to_f/@lot.meigara.unit_weight/55).ceil}")
      (@weight.to_f/@lot.meigara.unit_weight/55).ceil
    else 
      (@weight.to_f/@lot.meigara.paret_weight).ceil
    end
  end

  def masu_su
    waku.dan3;waku.dan2;waku.dan1
    stack_limit;need;paret_su
  end
  def need     ; #pp [@weight,@lot.meigara.paret_weight,@lot.stack_limit]
    (paret_su.to_f/@lot.stack_limit).ceil    
  end
  def kazu ; count ;end #(@weight.to_f/@lot.meigara.housou.unit_weight).ceil ;end

  def pull?(exportonly = AllPull) 
    case exportonly
    when OnlyExport ; /出荷/ =~ @pull
    else            ; @pull > ""
    end
  end

  def to_csv(without_pull = WithPull)
    return nil if without_pull && pull?
    CSV.csvline(Attrs.map{|atr| send(atr)}) #unless ( without_pull && pull? )
  end

  # [code,grade] => [ segment,segment,,,]
  def group_by_code_grade
    @@segments.to_a.group_by{|id,lot| [id[0],id[2]] }
  end
end

end
