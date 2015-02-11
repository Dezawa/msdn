# -*- coding: utf-8 -*-
class Hospital::MeetingsController < Hospital::Controller
  before_filter :set_instanse_variable
  attr_accessor :month,:current_busho_id
 
  def set_instanse_variable
    super
    @Model= Hospital::Meeting
    @TYTLE = "会議"
    @TYTLE_post_edit = @month.strftime("%Y/%m　")+@current_busho_id_name 
    @Domain= @Model.name.underscore
    @TableEdit = [[:add_edit_buttoms],[:form,:show_assign,"担当割振り",:method => :get],
                  ["　　　"],
                  [:form,:set_busho_month,"部署・年月変更",:input_busho_month]]
    @Edit  = true
    @Delete= true
    @labels= [HtmlText.new(:name    ,"会議名"  ,:size => 7),
              HtmlRadio.new(:kaigi  ,"会議/出張",:correction => [["会",true],["出",false]]),
              HtmlText.new(:number  ,"番号"    ,:size => 3),
              HtmlText.new(:startday,"日",:size => 2),
              HtmlDate.new(:start   ,"開始時間",:size => 6,:tform => "%H:%M"),
              HtmlText.new(:length  ,"所要時間",:size => 3)
             ]

    @FindWhere = ["busho_id = ? and month = ? ", @current_busho_id, @month.to_date]
    @Findorder = "start"
  end


  def update
    params[@Domain][:month]    = @month
    params[@Domain][:busho_id] = @current_busho_id
    params[@Domain][:start]    = make_datetime(params[@Domain][:startday],params[@Domain][:start])
    super
  end
  def new_models
    super.each{ |meeting|
      meeting.month = @month 
      meeting.start = @month+16.hour
    }
  end
  def update_on_table
    params[@Domain].each_pair{|i,model|
      next if model[:name].blank? || model[:startday].blank?
      model[:month]    = @month
      model[:busho_id] = @current_busho_id
      model[:start]    = make_datetime(model[:startday],model[:start])
       # Time.parse(model[:datetime]) rescue Time.parse(Time.now.strftime("%Y-"+model[:datetime]))
      #model[:kaigi]    = (model[:kaigi].to_i == 1)
    }
    super
  end
  

 def update_assign
    params[@Domain].each_pair{|nurce_id,meetings|
     nurce=Hospital::Nurce.find(nurce_id)
     monthly=nurce.monthly(@month)
     meetings.each_pair{|meeting_id,code_id| meeting=Hospital::Meeting.find(meeting_id.to_i)
       monthly["day%02d"%meeting.day] = code_id.to_i+2000  rescue nil
     }
     monthly.save
   }
   redirect_to :action => :show_assign
 end

 def show_assign
    @nurces = Hospital::Nurce.where(["busho_id = ?",@current_busho_id])
    @meetings = @Model.
      where( ["busho_id = ? and month = ? ",@current_busho_id,@month]).order("start")
 end 
 def assign
    @nurces = Hospital::Nurce.where(["busho_id = ?",@current_busho_id])
    @meetings = @Model.
     where( ["busho_id = ? and month = ? ",@current_busho_id,@month]).
     order("start"  )
  end

  def make_datetime(day_str,time_string,opt = nil)
    begin
logger.debug("会議時間"+@month.strftime("%Y-%m-")+day_str +" "+time_string+" JST") 
      Time.parse(@month.strftime("%Y-%m-")+day_str +" "+time_string) 
    rescue 
      if opt
        Time.parse( opt+day_str +" "+time_string)
      else
        Time.parse(Time.now.strftime("%Y-%m-")+day_str +" "+time_string) 
      end
    end
  end
  def set_busho_month
    set_busho_month_sub
    redirect_to :action => :index
  end    
end
