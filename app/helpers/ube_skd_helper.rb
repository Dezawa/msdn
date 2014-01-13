# -*- coding: utf-8 -*-
module UbeSkdHelper

  def table_of_buttom

    "   <tr><td>".html_safe+
      form_tag(:action => :input_result,:id=>@model.id)+submit_tag('実績コピペ ')+
      hidden_field(:ube_skd,:sort,:value => @sortkey)+"</form></td>\n".html_safe+
      "  <td>".html_safe+
      button_to('CSVダウンロード',:action=>:csv_download,:id=>@model.id)+
      "</td></tr>\n".html_safe+
      " <tr><td colspan=2 >".html_safe+
      form_tag( :action => :doc_out_all,:id=>@model.id )+submit_tag( '　月度割付図　')+
      "</form>\n  </td></tr>\n  <tr><td colspan=2 >".html_safe+
      form_tag( :action => :doc_out,:id=>@model.id )+submit_tag( '作業指示書')+
      "  <input type='hidden' name='show_edit' value='s'>\n".html_safe+ 
      "  <input type='text' name='doc_from' size=4> から\n".html_safe+
      "  <input type='text' name='doc_to' size=1 value=8>日間</form>\n".html_safe+
      "  </td></tr>\n  <tr><td></td></tr>\n".html_safe+
      "  <tr><td colspan=2 style='font-size:120%;'>立案期間　\n".html_safe+
      @model.skd_from.strftime('%Y-%m-%d').html_safe+"～".html_safe+ 
      @model.skd_to.strftime('%m-%d').html_safe +
      "</td></tr>\n".html_safe
  end

  #TimeLine
  def table_title
    "<table border =1 ><tr><td>".html_safe + 
      safe_join(@labels[0],"</td><td>".html_safe) +
      "</tr>\n".html_safe
  end

  def timeline_row(lbl)
    "<tr><td>".html_safe + lbl[0].html_safe  + "</td>".html_safe +
      "<td align=right>".html_safe+
      safe_join(lbl[1..5].map{|l|  @model[l] },"</td><td align=right>".html_safe ) +
      "</td>".html_safe+
      "<td>#{lbl[6]||'　'}</td>".html_safe
  end

  def timeline
      table_title +
      safe_join(@labels[1..-1].map{|lbl| timeline_row(lbl)
                },"</tr>\n".html_safe) +
      "</table>\n".html_safe
  end

  def runtimeline(edit=nil)
     "<table border =1 id='runtimeline'><tr><td>".html_safe +
      safe_join(@RunTimeLabels[0],"</td><td>".html_safe) +
      "</tr>\n".html_safe + #Label行
      ## @RunTimeLabels[1,2].map{|lbl|  dspline(lbl,edit,1)    }.join+
      #  @RunTimeLabels[3..-1].map{|lbl|  dspline(lbl,edit,1000) }.join+
      @RunTimeLabels[1..-1].map{|lbl|  dspline(lbl,edit)    }.join.html_safe+
      "</table>\n".html_safe
  end

  def dspline(lbl,edit,opt=nil)
    run = @model[lbl[1]] ? @model[lbl[1]].to_s.sub(/(\d+)(?=\d{3}$)/, '\\1,') : "　"
    curnt=@model[lbl[2]] ? @model[lbl[2]].to_s.sub(/(\d+)(?=\d{3}$)/, '\\1,') : "　"
    limit=@model[lbl[3]] ? @model[lbl[3]].to_s.sub(/(\d+)(?=\d{3}$)/, '\\1,') : "　"
      "<tr><td>" + lbl[0] +"</td><td align=right>"+ 
      (edit ? text_field(:ube_skd,lbl[1],:size=>5,:value=>run) : run) +
      "</td><td align=right>#{curnt}</td><td align=right>" +
      (lbl[3] && edit ? text_field(:ube_skd,lbl[3],:size=>5,:value=>limit) : limit ) +
      "</td><td>#{lbl[4]||'　'}</td></tr>"
  end

  def times_header(lbl)
    "<td colspan=8 align=center><nobr>#{lbl}/開始,終了</td>" 
  end
end
__END__
