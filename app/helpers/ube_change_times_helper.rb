# -*- coding: utf-8 -*-
module UbeChangeTimesHelper

  def chtime_table(ope_names,chtimes,&block)
    html = "<tr><td></td>".html_safe
    ope_names.each{|ope_to| html += "<td>#{ope_to}</td>\n".html_safe }
    ope_names.each{|ope_from|
      html += "<tr><td>#{ope_from}</td>".html_safe
      ope_names.each{|ope_to| chtime,id = chtimes[[ope_from,ope_to]]
        html += (yield chtime,id).html_safe
      }
      html += "</tr>\n".html_safe
    }
    
  end

  def chtime_write(ope_names,chtimes)
    chtime_table(ope_names,chtimes){|chtime,id|
      "<td align=right>#{chtime}</td>"
    }
  end
  def chtime_edit(ope_names,chtimes)
    chtime_table(ope_names,chtimes){|chtime,id|
       chtime ? text_field(:changetime,:change_time,{:index => id,:value=> chtime,:size=>3 }) : ""
    }
  end

  def chtime_writed(ope_names,chtimes)
    html = "<tr><td></td>".html_safe
    ope_names.each{|ope_to| html += "<td>#{ope_to}</td>\n".safe }
    ope_names.each{|ope_from|
      html += "<tr><td>#{ope_from}</td>".safe
      ope_names.each{|ope_to| chtime,id = chtimes[[ope_from,ope_to]]
        html += "<td align=right>#{chtime}</td>".html_safe
      }
      html += "</tr>\n".html_safe
    }
  end
  def chtime_editd(ope_names,chtimes)
     html = "<tr><td></td>".html_safe
      ope_names.each{|ope_to| "<td>#{ope_to}</td>" }.join+"\n"+
      ope_names.map{|ope_from|
      "<tr><td>#{ope_from}</td><td>"+
      ope_names.map{|ope_to| chtime,id = chtimes[[ope_from,ope_to]]
        chtime ? text_field(:changetime,:change_time,{:index => id,:value=> chtime,:size=>3 }) : ""
      }.join("</td><td>")+"</td></tr>\n"
    }.join  
  end
end
