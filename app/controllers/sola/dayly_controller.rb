# -*- coding: utf-8 -*-
class Sola::DaylyController < Sola::Controller #ApplicationController
  include Actions
  include GraphController
  before_action :authenticate_user!, :except => :load_local_file
  before_filter :set_instanse_variable
  
  LabelsPeaks =
    [ HtmlDate.new(:month,"年月",:tform =>"%Y-%m")] +
      (1..31).map{ |day| HtmlNum.new(:peak_kw,day.to_s,:tform => "%5.2f")
  }
    
  LabelsMonthesIndex = 
    [ HtmlDate.new(:month,"年月",:tform =>"%Y-%m"),
      HtmlLink.new(:id,"",
                   :link => {:link_label => "表示", :url => "/sola/dayly/index_month",
                     :key => :month, :key_val => :month}), 
    ]
  OnClick=
    %Q!onClick="window.open('/sola/dayly/minute_graph','graph','width=300,height=300,scrollbars=yes');" target="graph"!
  MLink  = {:url => "/sola/dayly/minute_graph" ,:key => :id,:key_val => :id,:htmloption => OnClick}
  LabelsMonthIndex = 
    [ HtmlDate.new(:date,"年月日",:tform =>"%Y-%m-%d"),
      HtmlNum.new(:peak_kw,"ピーク<br>kW(分)",:tform => "%5.2f"),
      HtmlNum.new(:kwh_day,"発電量<br>kWh(日)",:tform => "%4.1f")
    ] +
    ("04".."20").map{ |kwh| HtmlNum.new("kwh#{kwh}",kwh,:tform => "%4.1f")} +
    [HtmlLink.new(:id,"",:link => { method: "minute_graph", :link_label => "分グラフ"}.merge(MLink))]

  def set_instanse_variable
    super
    @Model= Sola::Dayly
    @Domain= @Model.name.underscore
    @TYTLE = "太陽光発電 日データ"
    #@TYTLEpost = "#{@year}年度"
    @FindOption = {}
    @FindOrder = "date"


    #@Edit = true
    @Delete=true
  end

  def index
    #@page = params[:page] || 1 
    @MLink = OnClick
    @labels =LabelsPeaks # LabelsMonthesIndex
    @models_group_by = find_and.group_by{ |d| d.month }
    @TYTLE_post = "ピーク発電量"
    @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"],
                  [:popup,:peak_graph,"ピークグラフ",{:win_name => "default" }],
                  [:form,:index_day_total,"発電量一覧",method: :get]
                 ]
    @TableHeaderDouble = [1,[31,"日々のピーク発電量(kW)"]]
    #render  :file => 'application/index',:layout => 'application'    
  end

  def index_day_total
    #@page = params[:page] || 1 
    @MLink = OnClick
    @labels =LabelsPeaks # LabelsMonthesIndex
    @models_group_by = find_and.group_by{ |d| d.month }
    @TYTLE_post = "日 発電量"
     @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"],
                  [:popup,:peak_graph,"ピークグラフ",{:win_name => "default" }],
                  [:form,:index,"ピーク発電量",method: :get]
                 ]
   @TableHeaderDouble = [1,[31,"日々の発電量(kWh)"]]
    @method = :kwh_day
    @action = "show"
    render  :action => :index
  end

   def index_month
    month = params[:month]
    @page = params[:page] || 1 
    @TableHeaderDouble = [3,[19,"毎時発電量(kWh)"]]
    @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"]]
    @labels = LabelsMonthIndex
    @Show = true
    #@models = @Model.where(month: month)
    @FindWhere = {month: month}
    find_and
    render  :file => 'application/index',:layout => 'application'
  end

  def load
    logger.debug("Sola::DaylyCnrl load #{params[@Domain][:uploadfile]}")
    @Model.load_trz params[@Domain][:uploadfile]
    redirect_to :action => :index
  end
  def load_local_file
    @Model.load_trz params[:uploadfile]
    redirect_to :action => :index
  end

  def show
    @model = @Model.find params[:id]
  end

  def peak_graph
    @graph_file = "sola_peak"
    @graph_file_dir = Rails.root+"tmp" + "img"
    Sola::Dayly.peak_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end

  def minute_graph
    id = params[:id].to_i
    @model = @Model.find id
    @TableEdit = nil
    @TYTLEpost = @model.date.strftime("%Y-%m-%d")
    @graph_file = "sola_minute"
    @graph_file_dir = Rails.root+"tmp" + "img"
    @model.minute_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end

end
