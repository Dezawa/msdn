# -*- coding: utf-8 -*-
require 'menu'

# 画面でのアクションボタンを作るのに用いられる
#  使い方
#    1. action_buttoms @TableEdit
#    2. action_buttom_table(action_buttoms)
#  @TableEdit や action_buttoms の定義内容に応じたアクションボタン(群)を作る
module ActionButtonHelper
  include HtmlSafeTableItems

  # buttoms に定義されたボタン群を一行に並べて表示する
  def action_buttoms(buttoms)
    content_tag(:table){ content_tag(:tr){
        safe_join( buttoms.map{|buttom| content_tag(:td,action_buttom(buttom)) },
                  "\n")
      }
    }
  end

  # 多量のアクションボタンを表示する時に用いる
  # actionbuttoms の構造
  # 1.  [ 一行のボタン数 ,[ ボタン定義,ボタン定義,,, ]]
  # 2.  [ [ 一行のボタン数 ,[ ボタン定義,ボタン定義,,, ]],
  #       [ 一行のボタン数 ,[ ボタン定義,ボタン定義,,, ]] ]
  # 形式1の場合、定義されたボタンが複数行に渡って表示される。
  #        table 内に置くため、幅の異なるボタンがあると空白が大きくなる恐れあり
  # 形式2の場合、形式1 のボタン群が複数表示される。
  #        ボタン幅の似たもの同士を束ねるとよい
  def action_buttom_table(actionbuttoms=nil)
    return "" unless action_buttoms = actionbuttoms ||  @action_buttoms
    case action_buttoms.first
    when Integer ; action_buttom_table_sub(action_buttoms)
    when Array   ; safe_join(action_buttoms.map{ |ab| action_buttom_table_sub(ab)})
    else         ; ""
    end.html_safe
  end

  
  #buttom で定義されたaction_buttom を作る
  # buttom の構造 ［function,action,label] もしくは :symbol 
  # function で作るボタンの定義の仕方を決める
  #   :form :: 汎用。
  #   :popup :: 新しいwindowをpopupして結果をそちらにだす。
  #   :input_and_action :: 入力用エリアをもつアクションボタン
  #   :select_and_action :: 選択肢エリアをもつアクションボタン
  # 以降は特定用途のボタンにカスタマイズされている
  #   :add_buttom   :: add_on_table を呼び出す
  #   :edit_buttom  :: edit_on_table を呼び出す
  #   :add_edit_buttoms :: add_on_table,edit_on_table の両方のボタンを作る
  #   :upload_buttom    :: ファイルuploadボタン
  #   :csv_up_buttom    :: csvファイルuploadボタン
  #   :csv_out          :: csvファイルdownloadボタン
  #  これらに無い場合、functionを文字列に変換したものを表示する。
  def action_buttom(buttom)
#    logger.debug("=======ViewHelper #{self.class}/ #{self.class.name} /#{self.controller}")
    function,action,label,opt,htmlopt = buttom
    opt ||= {}
    htmlopt ||= {}
    case function
    when :form ;form_buttom(action,label,opt,htmlopt)
    when :popup ;popupform_buttom(action,label,opt,htmlopt)
    when :popup2 ;popupform_buttom(action,label,opt,htmlopt)
    when :add_edit_buttoms ;edit_buttoms(@Domain) 
    when :add_buttom       ;add_buttom(@Domain)
    when :edit_buttom       ;edit_buttom(opt||{ })
    when :upload_buttom     ;upload_buttom(action,label)
    when :csv_up_buttom     ;csv_up_buttom
    when :csv_out           ;csv_out_buttom
    when :input_and_action  ;
      logger.debug("##### input_and_action #{[action,label,opt,htmlopt].join(',')}")
      input_and_action(action,label,opt,htmlopt||{})
    when :select_and_action  ;
      select_and_action(action,label,opt)
    when nil; ""
    else function.to_s.html_safe
    end#.html_safe
  end

  ######################################
  
  def action_buttom_table_sub(action_buttoms=nil)
    return "" unless action_buttoms && action_buttoms.size > 0 
    clms_num =  action_buttoms.first
    action_buttoms = action_buttoms.last.dup
    th = "<table>\n" #<tr>"+"<td></td>"* clms +"</tr>\n"
    tb = "<tr>" +
      (0..action_buttoms.size-1).step(clms_num).
      map{ |c| 
      (1..clms_num).map{ |d|  
        buttom = action_buttoms.shift 
        "<td>"+action_buttom(buttom) + "</td>" if buttom}.compact.join
    }.join("</tr><tr>\n")
    th + tb + "</tr></table>"
  end

  def action_buttom_table_test
    return "" unless @action_buttoms
    clms,action_buttoms =  @action_buttoms
   html = 
      (0..action_buttoms.size-1).step(clms).
      map{ |c| 
      (1..clms).map{ |d|  
        buttom = action_buttoms.shift 
        action_buttom(buttom)  if buttom}.compact.join
    }.join
  end

  def table_edit
    case @TableEdit
    when TrueClass ; add_edit_buttoms(@Domain) 
    when String; @TableEdit 
    when Array ; action_buttoms @TableEdit 
    end
  end

  ############### action_buttom から呼ばれる ボタン作成機能 #####
  # アクションボタンを作る。page は必ず hidden で渡される
  # action :: @Domain の action へのlink を作る
  # opt    :: :hidden.:hidden_value => 渡すべきパラメータがある場合に指定
  #        :: :form_notclose        => </form> をつけない。値は何でもよい
  def form_buttom(action,label,opt ={ },htmlopt={ })
    opt ||={ }
    opt,additional =
      case opt
      when Hash    ; [opt,nil]
      when Symbol  ; [{ },opt]
    end

    hidden = opt_hidden(opt)
    form_close = opt_form_close(opt)
    
    case action
    when Symbol  ; form_tag({ :action => action} ,opt)
    when String  ; form_tag(action ,opt)
    end +  hidden + hidden_field_tag('page' ,@page ) +
      (additional ?  send(additional) : "") +
      (submit_tag(label)+form_close)#.html_safe
  end

  def opt_form_close(opt)
    opt.delete(:form_notclose) ? "" : tag("/form", nil, true)
  end
  
  def opt_hidden(opt)
    return "" unless hidden = opt.delete(:hidden)
    safe_join( hidden.map{|key,value| hidden_field(@Domain,key,:value => value) }
             )
  end

  # 追加、編集ボタンの表示
  def add_edit_buttoms(dom,arg={ })
    #buttoms =  edit_buttoms(dom,arg)
    content_tag(:table){ content_tag(:tr){
        content_tag(:td){add_buttom(dom,arg)} +  content_tag(:td){edit_buttom(arg)}
      }
    }
  end


  def edit_buttoms(dom,arg={ })
    add_buttom(dom,arg)+tag("/td", nil, true) +
      tag("td", nil, true) +edit_buttom(arg)
  end
  def add_buttom(dom,arg={ })
    option = { :action => (arg.delete(:add_action) || :add_on_table)}.merge(arg)
    form_tag(option){  
      hidden_field_tag('page' ,@page ) +  submit_tag("追加")+
        text_field( dom, :add_no,:size=>2, :value => 1 )
    } 
    
  end

  def edit_buttom(arg={ })
    action  =  (arg.delete(:edit_action) || :edit_on_table)
    button_to( '編集', { :action => action,:page => @page}.merge(arg),
              :method => :get )
  end

  def csv_up_buttom(opt={})
    url = "/#{@Domain}/csv_upload"
    form_tag(url,:multipart => true,:method => :post){ #+
      submit_tag("CSVで登録")+
        file_field(@Domain, :csvfile)
    }
  end

  def csv_out_buttom(opt={})
    button_to( 'CSVダウンロード', opt.merge({ :action => :csv_out }),:method => :get)
  end

  def upload_buttom(action,label)
    url = "/#{@Domain}/#{action}"
    form_tag(url,:multipart => true,:method => :post){
      submit_tag(label)+file_field(@Domain, :uploadfile)}
  end

  PopupWithOUTModel = %Q!window.open('/%s/%s', '%s', 'width=500,height=400 %s'); target='%s'!
  PopupWithModel = %Q!window.open('/%s/%s?id=%d', '%s', 'width=500,height=400 %s'); target='%s'
  <input id="%s_id" name="%s[id]" type="hidden" value="%d" />!


  def popupform_buttom(action,label,opt ={ },htmlopt={ })
    win_name = opt.delete(:win_name) || "new_win"
    domain = opt.delete(:controller)
    url_option = {domain: @Domain, action: action}
    url_option.merge!( {controller: domain} ) if domain
    scroll = opt.delete(:scroll) ? ", scrollbars=yes" : ""
    option =
    if @model
      PopupWithModel%[@Domain,action,@model.id,win_name,scroll,win_name,@Domain,@Domain,@model.id]
    else
      PopupWithOUTModel%[@Domain,action,win_name,scroll,win_name]
    end
    option += safe_join(opt.map{ |k,v| hidden_field(@Domain,k,:value => v) },"\n" )
    form_tag(url_option){ submit_tag(label,onclick: option)}
  end

  def and_action(input,action,label,opt={ },htmlopt={ })
    scroll = opt.delete(:scroll) ? ", scrollbars=yes" : ""

    hidden = opt.delete(:hidden)
    hidden_value = opt.delete(:hidden_value)
    opt[:hidden] = (hidden ? hidden_field(@Domain,hidden,:value => hidden_value) : "").html_safe

    if opt[:popup] #win_name = opt.delete(:popup)
      if @model ;and_input_with_model(input,action,label,opt)
      else  ; and_input_without_model(input,action,label,opt)
      end
    else
      and_input_no_popup(input,action,label,opt,htmlopt)
    end
  end

  def and_input_no_popup(input,action,label,opt,htmlopt={})
    content_tag(:div){
      form_tag(opt.merge({:action => action}),(htmlopt||{})){
        hidden_field_tag('page',@page) +
        opt[:hidden] + submit_tag(label)+  input
      }
    }
  end

  def and_input_without_model(input,action,label,opt)
    win_name = opt.delete(:popup)
    scroll = opt.delete(:scroll) ? ", scrollbars=yes" : ""
    option =  PopupWithOUTModel%[@Domain,action,win_name,scroll,win_name]
  #   fmt =
  #     "<div><form action='/%s/%s'>
  # <input name='authenticity_token' type='hidden' value='%s' />
  # <input name='commit' type='submit'  value='%s' style='margin-top: -12px; left;' onclick=\"newwindow=window.open('/%s/%s', '%s' , 'width=500,height=400'); target='%s'\">
  #   " + input +  "</form></div>"
  #   fmt%[@Domain,action,form_authenticity_token,label,@Domain,action,opt[:popup],opt[:popup]]
    content_tag(:div){
      form_tag(opt.merge({:action => action})){
        opt[:hidden] + submit_tag(label,onclick: option)+  input      
      }
    }
  end

  def and_input_with_model(input,action,label,opt)
      fmt =
 "<div><form action='/%s/%s'>
  <input name='authenticity_token' type='hidden' value='%s' />
  <input id='%s_id' name='%s[id]' type='hidden' value='%d' />
  <input name='commit' type='submit'  value='%s' style='margin-top: -12px; left;' onclick=\"newwindow=window.open('/%s/%s', '%s' 'width=500,height=400%s'); target='%s'\">
" + input +  "</form></div>"
      fmt%[@Domain,action,form_authenticity_token,@Domain,@Domain,@model.id,label,@Domain,action,win_name,scroll,win_name]
  end

  def input_and_action(action,label,opt={},htmlopt={})
    opt ||= { }
    input =  text_field( @Domain,action,opt )
    and_action(input,action,label,opt,htmlopt)
  end

  def select_and_action(action,label,opt={ })
    opt ||= { }
    correction = opt.delete(:correction)
    input =   select(@Domain,action, correction, opt)
    and_action(input,action,label,opt)
  end
end
