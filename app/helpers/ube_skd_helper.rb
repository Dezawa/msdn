# -*- coding: utf-8 -*-
module UbeSkdHelper

  def table_of_buttom

    "   <tr><td>"+
      form_tag(:action => :input_result,:id=>@model.id)+submit_tag('実績コピペ ')+
      hidden_field(:ube_skd,:sort,:value => @sortkey)+"</form></td>\n"+
      "  <td>"+button_to('CSVダウンロード',:action=>:csv_download,:id=>@model.id)+"</td></tr>\n"+
      " <tr><td colspan=2 >"+
      form_tag( :action => :doc_out_all,:id=>@model.id )+submit_tag( '　月度割付図　')+
      "</form>\n  </td></tr>\n  <tr><td colspan=2 >"+
      form_tag( :action => :doc_out,:id=>@model.id )+submit_tag( '作業指示書')+
      "  <input type='hidden' name='show_edit' value='s'>\n"+ 
      "  <input type='text' name='doc_from' size=4> から\n"+
      "  <input type='text' name='doc_to' size=1 value=8>日間</form>\n"+
      "  </td></tr>\n  <tr><td></td></tr>\n"+
      "  <tr><td colspan=2 style='font-size:120%;'>立案期間　\n"+
      @model.skd_from.strftime('%Y-%m-%d')+"～"+ @model.skd_to.strftime('%m-%d') +
      "</td></tr>\n"
  end

  #TimeLine
  def timeline
     "<table border =1 ><tr><td>" + @labels[0].join("</td><td>") +"</tr>\n" +
      @labels[1..-1].map{|lbl| 
      "<tr><td>" + lbl[0] +"</td><td align=right>"+ lbl[1..5].map{|l|  @model[l] }.join("</td><td align=right>")+"</td>"+
      "<td>#{lbl[6]||'　'}</td>"
    }.join("</tr>\n")+"</table>\n"
  end

  def runtimeline(edit=nil)
     "<table border =1 ><tr><td>" + @RunTimeLabels[0].join("</td><td>") +"</tr>\n" + #Label行
      #@RunTimeLabels[1,2].map{|lbl|  dspline(lbl,edit,1)    }.join+
      #@RunTimeLabels[3..-1].map{|lbl|  dspline(lbl,edit,1000) }.join+
      @RunTimeLabels[1..-1].map{|lbl|  dspline(lbl,edit)    }.join+
      "</table>\n"
  end

  def dspline(lbl,edit)
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
