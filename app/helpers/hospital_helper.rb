# -*- coding: utf-8 -*-
module HospitalHelper
  def input_busho_month
    HtmlDate.new(:month,"年月",:size => 7,:tform => "%Y/%m").
      edit_field(@Domain,self.controller,@controller) +  
      HtmlSelect.new(:current_busho_id,"部署", :correction => Hospital::Busho.names).
      edit_field(@Domain,@controller,@controller)
  end

  def input_busho
    HtmlSelect.new(:current_busho_id,"部署", :correction => Hospital::Busho.names).
      edit_field(@Domain,@controller,@controller)
  end

  def kinmucode_selector_for_meeting(domain,meeting,nurce)
    kinmukubun_id = nurce.kinmukubun_id
    kaigi         = meeting.kaigi
    length        = kaigi ? meeting.length : nil
    day    = meeting.day
    val  = nurce.monthly(@month).days[day].kinmucode_id
    kinmucode_id  = val ? val % 1000 : nil
    color_code    = val ? val/1000   : nil
    HtmlSelectWithBlank.new(day.to_sym ,"",
                   :correction => HospitalMeetingController::AssignCorrection[[kinmukubun_id,
                                                                               kaigi,length]]
                   ).
      edit_field_with_id(@Domain,nurce,@controller,:value => kinmucode_id,
                         :name => name(@Domain,nurce.id,meeting.id))
  end


  def kinmucode_selector(domain,day,nurce,monthly)
    kinmukubun_id = nurce.kinmukubun_id
    val  = monthly.days[day]
    kinmucode_id  = val ? val % 1000 : nil
    color_code    = val ? val/1000   : nil
    HtmlSelectWithBlank.new(day.to_sym ,"",
                   :correction => HospitalMonthlyController::AssignCorrection[kinmukubun_id]
                   ).
      edit_field_with_id(domain,nurce,@controller, :value => kinmucode_id,
                         :name => name(domain,nurce.id,day)) 
  end
 def kinmucode_selector_for_hope(domain,day,nurce,monthly)
    kinmukubun_id = nurce.kinmukubun_id
    kinmu  = monthly.days[day]
    kinmucode_id  = kinmu.kinmucode_id
    color_code    = kinmu.want
    HtmlSelectWithBlank.new(day.to_sym ,"",
                   :correction => Hospital::Kinmucode.code_for_hope(kinmukubun_id)
                   ).
      edit_field_with_id(domain,nurce,@controller, :value => kinmucode_id,
                         :name => name(domain,nurce.id,"day%02d"%day)) 
 end

 def kinmucode_header
   list = [5,[2,"勤務時間"],1,
           [9,"積算勤務日数"],[3,"所属部門勤務時間"],[3,"応援勤務時間"]
          ]
   row = "<tr>".html_safe
   lbl_idx=0
   list.each_with_index{|style,idx|
     case style
     when Integer   ;
       (1..style).each{
         row += "<td rowspan=2>#{@labels[lbl_idx].label}</td>".html_safe
         lbl_idx += 1
       }
     when Array; 
       row += "<td colspan=#{style[0]}>#{style[1]}</td>".html_safe
       lbl_idx += style[0]
     end
   }
   row += "</tr>\n".html_safe
   lbl_idx=0
   list.each_with_index{|style,idx|
     case style
     when Integer   ;        lbl_idx += style
     when Array; 
       (1..style[0]).each{
         row += "<td>#{@labels[lbl_idx].label}</td>".html_safe
         lbl_idx += 1
       }
     end
   }
   return row
   "<tr>"+"<td></td>"*5+"<td colspan=2>勤務時間</td><td></td>"+
     "<td colspan=9>積算勤務日数</td>"+
     "<td colspan=3>所属部門勤務時間(hr)</td>"+
     "<td colspan=3>応援勤務時間(hr)</td></tr>"+
     label_line_option 
 end
 
  def role_checkbox(domain,role,nurce,roles)
    name = "#{domain}[#{nurce.id}][#{role.id}]"
    id   = "#{domain}_#{nurce.id}_#{role.id}"
    checked = (roles[role.id] ? "checked='checked'" : "" )

    "<input #{checked} id='#{id}' name='#{name}' type='checkbox' value='1'  />"+
      "<input  id='#{id}' name='#{name}' type='hidden' value='0' />"
  end
  def nurce_total(nurce)
    [:shift1,:shift3,:shift2].zip([:code1,:code3,:code2]).map{|sym,code|
      color = nurce.send(sym)>nurce.limits[code] ? "bgcolor='#ff70b0'" : "" 
      "<td #{color}>#{nurce.send sym}</td>"}.join + 
    [:shift0,:nenkyuu].zip([:code0,:coden]).map{|sym,code|
      color = nurce.send(sym)<nurce.limits[code]? "bgcolor='#ff70b0'" : "" 
      "<td #{color}>#{nurce.send sym}</td>"}.join.html_safe
  end
  def day_total
    
    [["日勤",:daytime,1],["準夜",:night,2],["深夜",:midnight,3]].map{|lbl,sym,shift|
      "<tr><td>　</td><td>#{lbl}</td>"+
      (1..@month.end_of_month.day).map{|day|
        sum = total(@nurces,day,sym)
        color = @assign.short_role(day,shift).include?(2) ?  "bgcolor='#ff70b0'" : "" 
        "<td #{color}>"+ sum.to_s + "</td>"
      }.join + "</tr>\n"
    }.join.html_safe
  end
  def total(nurces,day,sym)
    nurces.inject(0){|sum,nurce| 
      sum + (nurce.monthly.days[day].kinmucode ? nurce.monthly.days[day].kinmucode.send(sym) : 0 )}
  end

  def what_day(date)
    (date.wday%6 == 0 || Holyday.holyday?(date)) ? 1 : 0
  end

  def day_bgcolor(day)
    if what_day(@month+(day-1).day) == 1
      "bgcolor='#ff70b0'"

    else
      ""
    end
  end

  def hospital_define(show_or_edit)
    html = hospital_define_table_title
    body = safe_join(@ItemsDefine.map{ |item|
                       sym = item.symbol.to_s
                       logger.debug "=== #{sym} #{@instances.map(&:attri).join(',')}"
                       model = @instances.select{ |inst| inst.attri == sym }.first
                       case show_or_edit 
                       when :show ;hospital_define_show_(model)
                       when :edit ;hospital_define_edit_(model,item)
                       end
                     })
    "<hr>\n#{@instances.size}<table border=1>\n<tr>".html_safe +
      html + body + "</table>\n".html_safe
  end

  def hospital_define_table_title
    (
      @LabelsDefine.map{|html_cell| 
       "<td>" + html_cell.label + help(html_cell.help) +
       "</td>\n" unless html_cell.class == HtmlHidden
     }.compact.join + "</tr>\n").html_safe 
  end

  def hospital_define_show_(model)
    ("<tr>" +
     @LabelsDefine.map{ |label|
       "<td>#{model.send(label.symbol)||'　'}</td>"  unless label.class == HtmlHidden
     }.compact.join + "</tr>\n").html_safe
  end


  def hospital_define_edit_(model,item)
    ("<tr>" +
      @LabelsDefine.map{ |label|
      next if label.class == HtmlHidden
      case label.symbol 
      when :value
        domain = :hospital_define
        id =     model.id
        index = "#{domain}_#{id}"
        name  = "#{domain}[#{id}]"
        option = { :index => index, :name => name ,:value => model.value}
        "<td>#{item.edit_field_with_id(domain,model,@controller,option)}</td>"
      else
        "<td>#{label.disp(model)}</td>"
      end
    }.compact.join + "</tr>\n</tr>\n").html_safe
  end

  def assign_links
    @files.map{ |file|
      no = /_(\d{4})$/.match(file)[1]
      @no == no ? no.to_i.to_s :
      "<a href='show_result?mult=20&amp;no=#{no}'>#{no.to_i.to_s}</a>"
    }.join("\n")+
      ( @fine && @fine.size > 0 ? "終" :"" ) if @files
  end
end
