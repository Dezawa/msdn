# -*- coding: utf-8 -*-
require 'menu'

module ActionButtonHelper
  include HtmlSafeTableItems
  
  def action_buttom_table(actionbuttoms=nil)
    return "" unless action_buttoms = actionbuttoms ||  @action_buttoms
    case action_buttoms.first
    when Integer ; action_buttom_table_sub(action_buttoms)
    when Array   ; action_buttoms.map{ |ab| action_buttom_table_sub(ab) }.join
    else         ; ""
    end.html_safe
  end

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

  # 追加、編集ボタンの表示
  def add_edit_buttoms(dom,arg={ })
    buttoms =  edit_buttoms(dom,arg)
    ("<table><tr><td>"+ buttoms + "</td></tr></table>").html_safe
  end


  def edit_buttoms(dom,arg={ })
    add_buttom(dom,arg)+edit_bottom(arg)
  end
  def add_buttom(dom,arg={ })
    option = { :action => (arg.delete(:add_action) || :add_on_table)}.merge(arg)
    (form_tag(option, :method => :get) + #:action => :add_on_table) + 
      "<input type='hidden' name='page' value='#{@page}'>".html_safe+
      submit_tag("追加")+
      text_field( dom, :add_no,:size=>2, :value => 1 ) +  "</form></td><td>".html_safe
     )
  end

  def edit_bottom(arg={ })
    action  =  (arg.delete(:edit_action) || :edit_on_table)
    button_to( '編集', { :action => action,:page => @page}.merge(arg),:method => :get )
  end

  def csv_up_buttom
    url = "/#{@Domain}/csv_upload"
    form_tag(url,:multipart => true,:method => :post)+
      submit_tag("CSVで登録")+file_field(@Domain, :csvfile)+"</form>".html_safe
  end

  def csv_out_buttom
    button_to( 'CSVダウンロード', { :action => :csv_out })
  end

  def upload_buttom(action,label)
    url = "/#{@Domain}/#{action}"
    form_tag(url,:multipart => true,:method => :post)+
      submit_tag(label)+file_field(@Domain, :uploadfile)+"</form>".html_safe
  end

  #action_buttomの列を作る
  #- ［［function,action,label],,,,]
  def action_buttom(buttom)
    function,action,label,opt,htmlopt = buttom
    case function
    when :form ;form_buttom(action,label,opt,htmlopt)
    when :popup ;popupform_buttom(action,label,opt,htmlopt)
    when :add_edit_buttoms ;edit_buttoms(@Domain) 
    when :add_buttom       ;add_buttom(@Domain)
    when :edit_bottom       ;edit_bottom(opt||{ })
    when :upload_buttom     ;upload_buttom(action,label)
    when :csv_up_buttom     ;csv_up_buttom
    when :csv_out           ;csv_out_buttom
    when :input_and_action  ;
      input_and_action(action,label,opt)
    when :select_and_action  ;
      select_and_action(action,label,opt)
    when nil; ""
    else function.to_s
    end.html_safe
  end

#  <input name="commit" type="submit"  value="%s" style="margin-top: -12px; left;"
  PopupHead =  %Q!<form action="/%s/%s">
  <input name="authenticity_token" type="hidden" value="%s" />
  <input name="commit" type="submit"  value="%s" style='margin-top: -12px; left;' 
!
  PopupWithOUTModel = %Q! onclick="window.open('/%s/%s', '%s', 'width=500,height=400 %s'); target='%s'">
!
  PopupWithModel = %Q!  onclick="window.open('/%s/%s?id=%d', '%s', 'width=500,height=400 %s'); target='%s'">
  <input id="%s_id" name="%s[id]" type="hidden" value="%d" />
!


  def popupform_buttom(action,label,opt ={ },htmlopt={ })
    win_name = opt.delete(:win_name) || "new_win"
    scroll = opt.delete(:scroll) ? ", scrollbars=yes" : ""
    html = PopupHead%[@Domain,action,form_authenticity_token,label]
    if @model
      html += PopupWithModel%[@Domain,action,@model.id,win_name,scroll,win_name,@Domain,@Domain,@model.id] 
    else
      html += PopupWithOUTModel%[@Domain,action,win_name,scroll,win_name]
    end
    opt.each{ |k,v|  html += hidden_field(@Domain,k,:value => v) +"\n"  }
    html + "\n</form>"
  end

  def form_buttom(action,label,opt ={ },htmlopt={ })
    opt ||={ }
    opt,additional =
      case opt
      when Hash    ; [opt,nil]
      when Symbol  ; [{ },opt]
    end

    hidden = opt.delete(:hidden) if opt.class==Hash
    hidden_value = opt.delete(:hidden_value) if opt.class==Hash

    form_notclose = opt.delete(:form_notclose) if opt.class==Hash
    from_notclose = form_notclose ? "" : "</form>".html_safe
    case action
    when Symbol  ; form_tag({ :action => action} ,opt)
    when String  ; form_tag(action ,opt)
    end + 
      (if hidden; hidden_field(@Domain,hidden,:value => hidden_value)
       else;"";end
       )+
      "<input type='hidden' name='page' value='#{@page}'>".html_safe+
      (additional ?  send(additional) : "") +

      (submit_tag(label)+from_notclose).html_safe
  end

  def and_action(input,action,label,opt={ })
    scroll = opt.delete(:scroll) ? ", scrollbars=yes" : ""

    hidden = opt.delete(:hidden)
    hidden_value = opt.delete(:hidden_value)
    opt[:hidden] = (hidden ? hidden_field(@Domain,hidden,:value => hidden_value) : "").html_safe

    if win_name = opt[:popup]
      if @model ;and_input_with_model(input,action,label,opt)
      else  ; and_input_without_model(input,action,label,opt)

      end
    else
      and_input_no_popup(input,action,label,opt)
    end
  end

  def and_input_no_popup(input,action,label,opt)
      "<div>".html_safe+form_tag(:action => action) + 
        "<input type='hidden' name='page' value='#{@page}'>".html_safe+
        opt[:hidden] +
        submit_tag(label)+
        input +  "</form></div>".html_safe
  end

  def and_input_without_model(input,action,label,opt)
       fmt =
 "<div><form action='/%s/%s'>
  <input name='authenticity_token' type='hidden' value='%s' />
  <input name='commit' type='submit'  value='%s' style='margin-top: -12px; left;' onclick=\"newwindow=window.open('/%s/%s', '%s' , 'width=500,height=400%s'); target='%s'\">
" + input +  "</form></div>"
      fmt%[@Domain,action,form_authenticity_token,label,@Domain,action,win_name,scroll,win_name]
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

  def input_and_action(action,label,opt={ })
    opt ||= { }
    input =  text_field( @Domain,action,opt )
    and_action(input,action,label,opt)
  end

  def select_and_action(action,label,opt={ })
    opt ||= { }
    correction = opt.delete(:correction)
    input =   select(@Domain,action, correction, opt)
    #input =   select(action, correction, opt)
    and_action(input,action,label,opt)
  end

  def input_and_action_old(action,label,opt={ })
    scroll = opt.delete(:scroll) ? ", scrollbars=yes" : ""
    hidden = opt.delete(:hidden)
    hidden_value = opt.delete(:hidden_value)
    if win_name = opt[:popup]
      if @model
      fmt =
 "<div><form action='/%s/%s'>
  <input name='authenticity_token' type='hidden' value='%s' />
  <input id='%s_id' name='%s[id]' type='hidden' value='%d' />
  <input name='commit' type='submit'  value='%s' style='margin-top: -12px; left;' onclick=\"newwindow=window.open('/%s/%s', '%s' 'width=500,height=400%s'); target='%s'\">
" + text_field( @Domain,action,opt ) +  "</form></div>"
      fmt%[@Domain,action,form_authenticity_token,@Domain,@Domain,@model.id,label,@Domain,action,win_name,scroll,win_name]
      else
      fmt =
 "<div><form action='/%s/%s'>
  <input name='authenticity_token' type='hidden' value='%s' />
  <input name='commit' type='submit'  value='%s' style='margin-top: -12px; left;' onclick=\"newwindow=window.open('/%s/%s', '%s' , 'width=500,height=400%s'); target='%s'\">
" + text_field( @Domain,action,opt ) +  "</form></div>"
      fmt%[@Domain,action,form_authenticity_token,label,@Domain,action,win_name,scroll,win_name]
      end
    else
      "<div>"+form_tag(:action => action) + 
        "<input type='hidden' name='page' value='#{@page}'>"+
        (if hidden; hidden_field(@Domain,hidden,:value => hidden_value)
         else;"";end
         )+
        submit_tag(label)+
        text_field( @Domain,action,opt) +  "</form></div>"
    end
  end

  def action_buttoms(buttoms)
    ("<table><tr>"+
      buttoms.map{|buttom|
      "<td>"+action_buttom(buttom) + "</td>"
    }.join("\n") + "</tr></table>").html_safe
  end

end
