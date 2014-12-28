# -*- coding: utf-8 -*-
class Sola::DaylyController < Sola::Controller #ApplicationController
  include Actions
  before_action :authenticate_user!, :except => :load_local_file
  before_filter :set_instanse_variable
  
  LabelsMonthesIndex = 
    [ HtmlDate.new(:month,"年月",:tform =>"%Y-%m"),
      HtmlLink.new(:id,"",
                   :link => {:link_label => "表示", :url => "/sola/dayly/index_month",
                     :key => :month, :key_val => :month}), 
    ]
  LabelsMonthIndex = 
    [ HtmlDate.new(:date,"年月日",:tform =>"%Y-%m-%d"),
      HtmlNum.new(:peak_kw,"ピーク<br>kW(分)",:tform => "%5.2f"),
      HtmlNum.new(:kwh_day,"発電量<br>kWh(日)",:tform => "%4.1f")
    ] +
    ("06".."18").map{ |kwh| HtmlNum.new("kwh#{kwh}",kwh,:tform => "%4.1f")}
  LabelsShow = 
    [ HtmlDate.new(:month,"年月日",:tform =>"%Y-%m-%d"),
      HtmlNum.new(:peak_kw,"ピーク"),
      HtmlNum.new(:kwh_day,"発電量")
    ] +
    ("06".."18").map{ |kwh| HtmlNum.new("kwh#{kwh}",kwh)}

  def set_instanse_variable
    super
    @Model= Sola::Dayly
    @Domain= @Model.name.underscore
    @TYTLE = "太陽光発電 日データ"
    #@TYTLEpost = "#{@year}年度"
    @FindOption = {}
    @TableEdit = true  #[[:edit_bottom]]
    #@Edit = true
    @Delete=true
  end

  def index
    #@page = params[:page] || 1 
    @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"]]
    @labels = LabelsMonthesIndex
    @models = find_and.group_by{ |d| d.month }
    @models = @models.values.map{ |daylies|daylies.first}
    render  :file => 'application/index',:layout => 'application'    
  end

  def index_month
    month = params[:month]
    @page = params[:page] || 1 
    @TableHeaderDouble = [3,[13,"毎時発電量(kWh)"]]
    @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"]]
    @labels = LabelsMonthIndex
    @Show = true
    #@models = @Model.where(month: month)
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


end
