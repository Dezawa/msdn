# -*- coding: utf-8 -*-
module HospitalHelper
  def input_busho_month
    HtmlDate.new(:month,"年月",:size => 7,:tform => "%Y/%m").
      edit_field(@Domain,@controller,@controller) +  
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
   row = "<tr>"
   lbl_idx=0
   list.each_with_index{|style,idx|
     case style
     when Integer   ;
       (1..style).each{
         row += "<td rowspan=2>#{@labels[lbl_idx].label}</td>"
         lbl_idx += 1
       }
     when Array; 
       row += "<td colspan=#{style[0]}>#{style[1]}</td>"
       lbl_idx += style[0]
     end
   }
   row += "</tr>\n"
   lbl_idx=0
   list.each_with_index{|style,idx|
     case style
     when Integer   ;        lbl_idx += style
     when Array; 
       (1..style[0]).each{
         row += "<td>#{@labels[lbl_idx].label}</td>"
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
      "<td #{color}>#{nurce.send sym}</td>"}.join
  end
  def day_total
    
    [["日勤",:daytime,"1"],["準夜",:night,"2"],["深夜",:midnight,"3"]].map{|lbl,sym,shift|
      "<tr><td>　</td><td>#{lbl}</td>"+
      (1..@month.end_of_month.day).map{|day|
        sum = total(@nurces,day,sym)
        color = @assign.short?(day,shift) ?  "bgcolor='#ff70b0'" : "" 
        "<td #{color}>"+ sum.to_s + "</td>"
      }.join + "</tr>\n"
    }.join
  end
  def total(nurces,day,sym)
    nurces.inject(0){|sum,nurce| 
      sum + (nurce.monthly.days[day].kinmucode_id ? nurce.monthly.days[day].send(sym) : 0 )}
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
    case show_or_edit
    when :show ;hospital_define_show 
    when :edit ;hospital_define_edit 
    end
  end
  def hospital_define_show
    html = "<hr>\n#{@instances.size}<table border=1>\n<tr>" +
      %w(項目 値 コメント _ 項目 値).map{ |l| "<td>#{l}</td>"}.join+"\n"

    body = ""
    @ItemsDefine.each_with_index{ |html_cell,idx|
      body += "<tr><td>#{html_cell.label}</td>" +
      "<td>#{@instances[html_cell.symbol].value}</td>"+
      "<td>#{@instances[html_cell.symbol].comment}</td><td></td>"+
      hospital_define2_show(idx) +
      "</tr>\n"
    }
    html + body + "</table>\n"
  end

  def hospital_define2_show(idx)
    body = ""
    html_cells = @ItemsDefine2[idx]
    return body unless html_cells
    body += "<td>" + 
      html_cells.map{ |html_cell| html_cell.label }.join + "</td><td>"

    if html_cells.size == 1
      body += @instances[html_cells[0].symbol].value.to_s + "</td>"
    else
      body += @instances[html_cells[0].symbol].value.to_s + "年" +
        @instances[html_cells[1].symbol].value.to_s + "月～" +
        @instances[html_cells[2].symbol].value.to_s + "年" +
        @instances[html_cells[3].symbol].value.to_s + "月"
    end
    body
  end

  def hospital_define2_edit(idx)
    name = "hospital_define[%d][value]"
    body = ""
    html_cells = @ItemsDefine2[idx]
    return body unless html_cells
    body += "<td>" + 
      html_cells.map{ |html_cell| html_cell.label }.join + "</td><td>"

    if html_cells.size == 1
      obj = @instances[html_cells[0].symbol]
      body += html_cells[0].edit_field_with_id("hospital_define",obj,controller,
                                           :value => obj.value,:name => name%obj.id)
    else
      objs=[0,1,2,3].map{ |i| @instances[html_cells[i].symbol]}
      body += 
        html_cells[0].edit_field_with_id("hd",objs[0],controller,:value => objs[0].value,:name => name%objs[0].id) + "年" +
        html_cells[1].edit_field_with_id("hd",objs[1],controller,:value => objs[1].value,:name => name%objs[1].id) + "月～" +
        html_cells[2].edit_field_with_id("hd",objs[2],controller,:value => objs[2].value,:name => name%objs[2].id) + "年" +
        html_cells[3].edit_field_with_id("hd",objs[3],controller,:value => objs[3].value,:name => name%objs[3].id) + "月"
    end
    body
  end

  def hospital_define_edit
    html = "<hr>\n#{@instances.size}<table border=1>\n<tr>" +
      %w(項目 値 コメント _ 項目 値).map{ |l| "<td>#{l}</td>"}.join+"\n"

    body = ""
    name = "hospital_define[%d][value]"
    @ItemsDefine.each_with_index{ |html_cell,idx|
      obj = @instances[html_cell.symbol]
      body += "<tr><td>#{html_cell.label}</td>"+
      "<td>"+ html_cell.edit_field_with_id("hospital_define",obj,controller,
                                           :value => obj.value,:name => name%obj.id) + "</td><td>" +
      @LabelsDefine[2].edit_field_with_id("hospital_define",obj,controller) + "</td>"+
       "<td></td>" + hospital_define2_edit(idx)
      }.join("\n")+
      "</tr>\n"
    
    html + body + "</table>\n"
  end

  def assign_links
    @files.map{ |file|
      no = /_(\d{4})$/.match(file)[1]
      @no == no ? no.to_i.to_s :
      "<a href='show_result?mult=20&amp;no=#{no}'>#{no.to_i.to_s}</a>"
    }.join("\n")+
      ( @fine && @fine.size > 0 ? "終" :"" ) if @files
  end

  # build_models { daytype => [ shift1,2,3 ] }
  def show_needs(build_models)
    obj = build_models[2].first
    ret = @labels[0].td + @labels[0].disp_field( obj)+"</td>"
    [2,3].map{ |daytype| build_models[daytype].each{|obj| 
        @minmax_label.map{|html_cell| 
          next if html_cell.class==HtmlHidden || html_cell.class==HtmlPasswd ||  html_cell.field_disable(controller) 

          ret += html_cell.td + html_cell.disp_field( obj) +"</td>"
        }
      }
    }
    ret
  end

  def need_warn
    @warn.join("<br>")
  end

  def edit_needs(build_models)
    obj = build_models[2][0]
    ret = @labels[0].td + @labels[0].disp_field( obj)+"</td>"
    [2,3].map{ |daytype| build_models[daytype].each{|obj| 
        @minmax_label.map{|html_cell| 
          next if html_cell.class==HtmlHidden || html_cell.class==HtmlPasswd ||  html_cell.field_disable(controller) 

          ret += html_cell.td + html_cell.edit_field_with_id(@Domain, obj,controller) +"</td>"
        }
      }
    }
    ret
  end

end
