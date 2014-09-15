# -*- coding: utf-8 -*-
module UbeHolydayHelper
  def days_of_month_label(month)
    safe_join((1..month.end_of_month.day).map{|d| d.to_s.html_safe},"</td><td>".html_safe) 
  end
  def weekdays_of_month_label(month)
    safe_join((0..month.end_of_month.day-1).map{|d|
                 @wday[(month+d.day).wday].html_safe},"</td><td>".html_safe) 
  end

  # day is real_date - 1
  def holyday_select_box(tag_label,model,sym,choices,day)
    id = model.id ; index=day.to_s
    name    = "'#{tag_label}[#{id}][#{sym}][#{index}]'"
    html_id = "'#{tag_label}_#{id}_#{sym}_#{index}'"
    v=model[sym][day,1]

    html = "<select id=#{html_id} name=#{name}>".html_safe
    choices.each{|dsp,val|
      html += "<option value='#{val}' #{selectd?(val,v)} >#{dsp}".html_safe
    }
    html
  end
  def selectd?(val,v)
    val == v ? "selected='selected'" : ""
  end
end
