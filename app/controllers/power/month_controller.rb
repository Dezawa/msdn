# -*- coding: utf-8 -*-
class  Power::MonthController < CommonController #ApplicationController
  include Power::GraphMonthly
  before_filter :set_instanse_variable

  def set_instanse_variable
    super
    # @factory_id  = session[:shimada_factory] = params[:id] if  params[:id]
    #@labels = Labels_for_month_results
    @TableEdit  = [:csv_up_buttom ]
    @SortBy    = :month
  end


  def index
     @Show = true
     @page = params[:page] || 1 
     @FindOption = { :order => "month desc" }
    find_and
    render  :file => 'application/index',:layout => 'application'
  end

  DaylyLabels =
    [
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%y/%m/%d"),
      HtmlText.new(:week_day,"曜",:ro=>true,:size =>1),
    ] + 
      ("01".."24").map{ |h| 
        HtmlNum.new( "power#{h}".to_sym,h,:tform => "%.0f",:size => 3)
      }

  def show ;
    @model = @Model.find(params[:id])
    @page = params[:id]
    @models = @model.powers
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")

    @TableEdit  =  [[:form,:index,"一覧に戻る",{ :method => :get}],[:form,:edit_on_table,"編集",{ :method => :get}],
                    [:popup,:graph_month,"月度グラフ",{ :win_name => "graph","method" => :powers} ],
                    [:popup,:graph_month,"月度温度補正",{ :win_name => "graph","method" => :revise_by_temp} ],
                   ]

    @action_buttoms = nil; #Month_action_buttoms
    @labels = DaylyLabels
    @TableHeaderDouble = [2,[24,"時刻"]]

    @Show = @Edit = @Delete = nil
    @Graph = true
    #render :file => 'application/show',:layout => 'application'
  end

  def edit_on_table
    @labels = EditOnTable
    @model = @Model.find(params[:page])
    @models = @model.powers
    render  :file => 'application/edit_on_table',:layout => 'application'
  end

  def update_on_table
    @Model = Shimada::Power
    super
  end


  def line_num(month, run) ;  month.powers.select{ |p| p.lines == run } ;  end
  def shape(month, run)    ;  month.powers.select{ |p| p.shape == run } ;  end

  def show_jpeg
    graph_file = (params[:graph_file].blank? ? "power" : params[:graph_file])
    send_file Rails.root+"tmp/graph/jpeg/#{graph_file}.jpeg", :type => 'image/jpeg', :disposition => 'inline'
  end

  def csv_upload
    errors= @Model.csv_upload(params[@Domain][:csvfile])
    redirect_to :action => :index,:layout => "hospital_error_disp"
  end


end
