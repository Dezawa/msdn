# -*- coding: utf-8 -*-
module UbeChangeTimesHelper

  def chtime_write(ope_names,chtimes)
    
    #end
    #def chtime_row_write(ope_from,ope_names,chtimes)
    "<tr><td></td>"+
      ope_names.map{|ope_to| "<td>#{ope_to}</td>" }.join+"\n"+
      ope_names.map{|ope_from|
      "<tr><td>#{ope_from}</td>"+
      ope_names.map{|ope_to| chtime,id = chtimes[[ope_from,ope_to]]
        "<td align=right>#{chtime}</td>"
      }.join+"</tr>\n"
    }.join
  end
  def chtime_edit(ope_names,chtimes)
     "<tr><td></td>"+
      ope_names.map{|ope_to| "<td>#{ope_to}</td>" }.join+"\n"+
      ope_names.map{|ope_from|
      "<tr><td>#{ope_from}</td><td>"+
      ope_names.map{|ope_to| chtime,id = chtimes[[ope_from,ope_to]]
        chtime ? text_field(:changetime,:change_time,{:index => id,:value=> chtime,:size=>3 }) : ""
      }.join("</td><td>")+"</td></tr>\n"
    }.join  
  end
end
