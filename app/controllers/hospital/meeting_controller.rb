# -*- coding: utf-8 -*-
class Hospital::MeetingController < Hospital::Controller
  before_filter :set_instanse_variable
  attr_accessor :month,:current_busho_id
  
  AssignCorrection = {
    #勤務区分、会議|出張,所要時間
    [1,true,1.0] => [["会1",32]],
    [1,true,1.5] => [["会□",31]],
    [2,true,1.0] => [["会1",7]],
    [2,true,1.5] => [["会",6]],
    [1,false,nil] => %w(出 出/1□ 1/出 出/G Z/出).zip([41,42,43,44,45]),
    [2,false,nil] => %w(出 出/1 1/出 出/G Z/出).zip([25,26,27,28,29])
  }

  def set_instanse_variable
    super
    @Model= Hospital::Meeting
    @TYTLE = "会議"
    @TYTLE_post_edit = @month.strftime("%Y/%m　")+@current_busho_id_name 
    @Domain= @Model.name.underscore
    @TableEdit = [[:add_edit_buttoms],[:form,:show_assign,"担当割振り"],
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

    @FindOption = ["busho_id = ? and month = ? ",
                                         @current_busho_id, @month]
    @Findorder = "start"
  end


  def update
    params[@Domain][:month]    = @month
    params[@Domain][:busho_id] = @current_busho_id
    params[@Domain][:start]    = make_datetime(params[@Domain][:startday],params[@Domain][:start])
    super
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
    @correction = AssignCorrection
    @nurces = Hospital::Nurce.all(:conditions=>["busho_id = ?",@current_busho_id])
    @meetings = @Model.
      all(:conditions => ["busho_id = ? and month = ? ",@current_busho_id,@month],
          :order => "start")
 end 
 def assign
    @correction = AssignCorrection
    @nurces = Hospital::Nurce.all(:conditions=>["busho_id = ?",@current_busho_id])
    @meetings = @Model.
      all(:conditions => ["busho_id = ? and month = ? ",@current_busho_id,@month],
          :order => "start"
          )
  end

  def make_datetime(day_str,time_string,opt = nil)
    begin
logger.debug("会議時間"+@month.strftime("%Y-%m-")+day_str +" "+time_string) 
      Time.parse(@month.strftime("%Y-%m-")+day_str +" "+time_string) 
    rescue 
      if opt
        Time.parse( opt+day_str +" "+time_string)
      else
        Time.parse(Time.now.strftime("%Y-%m-")+day_str +" "+time_string) 
      end
    end
  end
end
