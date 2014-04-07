# -*- coding: utf-8 -*-
class Hospital::NeedController < Hospital::Controller
  before_filter :set_instanse_variable

  def set_instanse_variable
    @Model= Hospital::Need
    @TYTLE = "必要人数"
    @Domain= @Model.name.underscore
    @TableEdit = _TableAddEditChangeBusho
    @Edit = true
    @Delete=true
    @minmax_label = [ HtmlText.new(:minimun      ,"最小", :size => 3),
         HtmlText.new(:maximum      ,"最大", :size => 3,:event => true)
       ]
    @labels= 
      [ HtmlSelect.new(:role_id      ,"役割", :correction => Hospital::Role.names)] +
       #HtmlSelect.new(:daytype     ,"曜日",   :correction => Hospital::Const::Daytype),
       #HtmlSelect.new(:kinmucode_id ,"勤務コード",:correction => [1,2,3]),
       @minmax_label*6
    super

    @FindOption = {:conditions => ["busho_id = ? ",@current_busho_id]}
    @TYTLE_post_edit  = @current_busho_id_name 
    @TYTLEpost = @current_busho_id_name 
    @on_cell_edit = true
    @TableHeaderMulti =
      [[1,[6,"平日"],[6,"土日休"]],
       [1,[2,"日勤"],[2,"準夜"],[2,"深夜"],[2,"日勤"],[2,"準夜"],[2,"深夜"]]
      ]
  end

  def index
    @models = @Model.find_and_build @current_busho_id
  end

  def edit_on_table
    @models = @Model.find_and_build @current_busho_id
  end
    
  def update_on_table
    params[@Domain].each_pair{|i,model|
      model[:busho_id] = @current_busho_id
       # Time.parse(model[:datetime]) rescue Time.parse(Time.now.strftime("%Y-"+model[:datetime]))
      #model[:kaigi]    = (model[:kaigi].to_i == 1)
    }
    super
  end
    
end
