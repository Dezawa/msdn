# -*- coding: utf-8 -*-
# 標準的な一覧表を出力する場合の、各欄の情報
# symmbol :: 表示、入力する対象となる 属性のsymbol
# label :: 一覧の表示に使うラベル
# type :: 表示、入力の型。:ro,:text,:select,:date など
# correction :: 入力の型が select 系の場合の選択肢のArrayもしくはArrayを返すProc
# display :: 入力の型が関係のselectの場合、symbol(通常は関係のID)の代わりに表示する値を返すmethod
# size :: 入力が text_field系のときにとるべき幅
# allign :: 表示のときの配置。:left,:center,:right。defaultは:left
# comment :: 今は使ってない
#
# ====== 使い方
# HtmlCell.new(:symbol=>:lot_no,:label=>"ロット番号",,, ...... ) の様に初期化する


class HtmlCell
  #include CustumInitializers
  include ActionView::Helpers::FormHelper 
  include ActionView::Helpers::FormOptionsHelper
  delegate :logger, :to=>"ActiveRecord::Base"
  Attr_names = [:type,:correction,:display,:size,:cols, :rows, :align,:comment,:help,
                :tform,:include_blank,:link,:event,:link_label]
  attr_writer :field_disable,:ro
  attr_accessor :symbol,:label
  attr_accessor( *Attr_names )
  def initialize(sym,lbl=nil,args={})
    @symbol = sym
    @label  = lbl
      data =  {:type=>:text}.merge args
      (Attr_names+[:field_disable,:ro]).each do | attr_name|
        instance_variable_set "@#{attr_name}",data.delete(attr_name)
      end
    data.delete(nil)
    raise "HtmlCellの初期化で未定義の値が使われている #{data.keys.join(' ')}" if data.size>0
  end

  def field_disable(controller)
    case @field_disable
    when nil,false  ; nil
    when Symbol     ; controller.send  @field_disable
    else            ; true
    end
  end

  def ro(controller=nil)
    case @ro
    when nil,false  ; nil
    when Symbol     ; controller.send  @ro
    else            ; true
    end
  end

  def td(htmlopt="")
     htmlopt += align ? "align=#{align}" : ""
    "<td #{htmlopt}><nobr>".html_safe
  end

  def disp_field(object,htmlopt="")
    htmlopt += align ? "align=#{align}" : ""
    #(event ?  "<script>$('td').click(function () { alert('DDDDD');});</script>" : "" )+
    disp(object).to_s
  end
  def edit_field(domain,object,controller,opt={},htmlopt="")
    edit_field_(domain,object,false,controller,opt,htmlopt)
  end
  def edit_field_with_id(domain,object,controller,opt={},htmlopt="")
    edit_field_(domain,object,true,controller,opt,htmlopt)
  end

  def edit(domain,object,controller,opt)
        send("edit_#{type}",domain,object,opt)
  end




  def disp(object,htmlopt="")
    return object.send(display) if display
    #txt=object.send(symbol); txt.blank? || !txt ? "　" : object.send(symbol)
    case symbol
    when Symbol;    object.send(symbol).blank?  ? "　" : object.send(symbol)
    when String;    symbol
    when Proc  ;    symbol.call
    when NilClass ; ""
    end
  end
  def checked( obj,symbol,choice)
    {:checked => ( obj.send(symbol) == choice[-1] )}
  end

  private 

  def edit_field_(domain,object,with_id,controller,opt,htmlopt)
    if ro(controller) ;disp(object)
    else
      opt.merge!(:value=>  object.send(symbol)) rescue ""
      opt.merge!(:index => object.id) if with_id
      opt.merge!(:size  => size     ) if size
        edit(domain,object,controller,opt)
    end
  end

  def choices(object=nil)
    @choices ||=
      correction.class ==  Proc ? correction.call(object) : correction
  end
end

class HtmlCeckForSelect < HtmlCell
  def disp(object,htmlopt="")
    check_box(@Domain,symbol,:id => object.id,:name => "check_id[#{object.id}]")
  end
end

class HtmlText  < HtmlCell
  def edit_field_with_id(domain,object,controller,opt={},htmlopt="")
    if ro(controller) ;disp(object)
    else
      opt[:size] = size if size
      text_field_tag(opt.delete(:name) || "#{domain}[#{object.id}][#{symbol}]", 
                     value = (opt.delete(:value) || object.send(symbol)), opt) 
    end
  end
  def edit(domain,obj,controller,opt)
    text_field(domain,symbol,opt)
  end
end

class HtmlArea  < HtmlCell
  def ddisp(object,htmlopt="")
    text_area(object,symbol,{  readonly: 'readonly'})
  end
  def edit(domain,obj,controller,opt)
    text_area(domain,symbol,opt)
  end
end


class HtmlNum  < HtmlText
  def initialize(sym,lbl=nil,args={})
    super
    @align = :right
  end
  def disp(object,htmlopt="")
    val = super
    (val == "　" || val.blank?) ? "　" : (tform ? tform%val : val)
  end
end

class HtmlLink   < HtmlCell
  def initialize(sym,lbl=nil,args={})
    super
    @ro = true if @ro || link[:link_label].class == String
  end
  def edit(domain,object,controller,opt) 
    text_field(domain,symbol,opt)
  end
  def disp(object,htmlopt="")
    links = link.dup
    lbl = linklabel(object,links)
    url = links.delete(:url)
    if /%s/ =~ url
      url = url % object.prefix
    end
    
    key = links.delete(:key)
    key_val = links.delete(:key_val)
    params  = links.delete(:params)
    htmloption = links.delete(:htmloption)

    key_param = [(key && key_val) ?  "#{key}=#{object.send(key_val)}" : nil ]
    param = links.map{ |k,v| "#{k}=#{v}"}
    params = (params||[]).map{|arg| "#{arg}=#{object.send(arg)}"}
    params = (key_param+param+params).compact
    params = params.size>0 ? "?"+params.join("&") : ""
    
    id_or_key =  (key && key_val) ?  "" : "/#{object.id}"
    
    "<a href='#{url}#{id_or_key}#{params}' #{htmloption}>#{lbl}</a>".html_safe
  end

  def linklabel(object,links)
    links.delete(:link_label) || 
      if val = object.send(symbol) 
        tform ? val.str(tform) : val
      else
        ""
      end
  end
end

class HtmlPasswd < HtmlCell
  def disp(object) ;end
  def edit(domain,obj,controller,opt)
    password_field(domain,symbol,opt)
  end
end

class HtmlHidden < HtmlCell
  def disp(object)
    ""
  end
  def edit_field_(domain,object,with_id,controller,opt,htmlopt)
      opt.merge!(:value=>  object.send(symbol))
      opt.merge!(:index => object.id) if with_id
    hidden_field(domain,symbol,opt)
  end
end

class HtmlCheck < HtmlCell
  def disp(object,htmlopt="")
    if display ;      display[val]
    else
      val = object.send(symbol)
      
      val == true || (!val.blank? &&  val >0)  ? "■" :"□"
    end
  end

  def ddisplay(object)
    "　"
  end
  def edit(domain,object,controller,options = {}, html_options = {})
    options[:checked]  = (val=object[symbol]) == true || val  && val  > 0 
    if options[:index]
      id = options[:index]
      options[:id] = "#{domain}_#{id}[#{symbol}]"
      options[:name]="#{domain}[#{id}][#{symbol}]"
    end
    check_box(domain,symbol, options)#, html_options )#checked_value = "1", unchecked_value = "0") 
  end
end

class HtmlDate < HtmlCell
  def disp(object)
    datetime=object.send symbol
    datetime ? datetime.strftime(tform||"%y/%m/%d %H:%M") : "　"
  end
  def edit(domain,obj,controller,opt)
    if ro(controller) ; disp(obj)
    else
      str = obj.send(symbol) 
      str = str ? str.strftime(tform||"%y/%m/%d %H:%M"):""
      text_field(domain,symbol,opt.merge(:value=>str))
    end
  end
end

class HtmlResultTime < HtmlDate
  def initialize(sym,lbl=nil,args={})
    super
    self.tform = "%m/%d %H:%M"
   self.size = 7
  end
end

class HtmlPlanTime < HtmlResultTime
  def initialize(sym,lbl=nil,args={})
    super
    self.ro = true
  end
end


class HtmlSelect < HtmlCell
  def disp(object)
    if display ;      object.send display
    else
      choice = choices(object)||[]
      ch = object.send(symbol)
      if choice[0].class == Array
        ch = choice.rassoc(ch)
        ch = ch ? ch[0] : ""
      end
      ch.to_s
    end
  end

  def edit(domain,obj,controller,options)
    html_options={}
    if options[:index]
      id = options[:index] if options[:index]
      html_options[:name]= options[:name] || "#{domain}[#{id}][#{symbol}]"
      html_options[:id] = html_options[:name].gsub(/[\[\/]+/,"_").gsub(/\]/,"")
    end
 
    options[:include_blank] ||= include_blank

    options.merge!({ :selected=> options[:value] }) if options[:value]
    choice=choices(obj) || []
    #cc = (choice[0].class == Array) ? choice : (choice.map{|c| [c]} + [[value]]).uniq
    #choices(obj)
    select(domain,symbol,choice, options,html_options)
  end
end

class HtmlSelectWithBlank < HtmlSelect
  def initialize(sym,lbl=nil,args={})
    args.merge!(:include_blank => true)
    super
  end
end
class HtmlRadio  < HtmlSelect
  def edit(domain,obj,controller,options)
    return  choices(obj).map{|choice|
      radio_button(domain,symbol,choice[-1] ,
                   options.merge(checked obj,symbol,choice))+"#{choice[0]}"
    }.join.html_safe

    # html_options={}
    # if options[:index]
    #   id = options[:index] if options[:index]
    #   html_options[:name]="#{domain}[#{id}][#{symbol}]"
    #   html_options[:id] = html_options[:name].gsub(/[\[\/]+/,"_").gsub(/\]/,"")
    # end
    # if include = options[:include_blank]
    #   html_options[:include_blank]=include
    # end
    # value = options[:value]
    # #choice=choices(obj)
    # #cc = (choice[0].class == Array) ? choice : (choice.map{|c| [c]} + [[value]]).uniq
    # #choices(obj)
    # #select(domain,symbol,choices(obj), options.merge(:selected=>value),html_options)
    # choices(obj).map{|choice|
    #   radio_button(domain,symbol, choice[-1],:checked => obj[symbol] == choice[-1] ? "checked" : nil)+choice[0]
    # }.join("\n")
  end

  
end

