# -*- coding: utf-8 -*-
class Sola::DaylyController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  before_filter :set_instanse_variable
  
  LabelsMonthesIndex = 
    [ HtmlDate.new(:month,"年月",:tform =>"%Y-%m"),
      HtmlLink.new(:id,"",
                   :link => {:link_label => "表示", :url => "/sola/dayly/index_month",
                     :key => :month, :key_val => :month}), 
    ]
  LabelsMonthIndex = 
    [ HtmlDate.new(:date,"年月日",:tform =>"%Y-%m-%d"),
      HtmlNum.new(:peak_kw,"ピーク"),
      HtmlNum.new(:kwh_day,"発電量")
    ] +
    ("06".."18").map{ |kwh| HtmlNum.new("kwh#{kwh}",kwh)}
  LabelsShow = 
    [ HtmlDate.new(:month,"年月日",:tform =>"%Y-%m-%d"),
      HtmlNum.new(:peak_kw,"ピーク"),
      HtmlNum.new(:kwh_day,"発電量")
    ] +
    ("06".."18").map{ |kwh| HtmlNum.new("kwh#{kwh}",kwh)}

  def set_instanse_variable
    @Model= Sola::Dayly
    @Domain= @Model.name.underscore
    @TYTLE = "太陽光発電 日データ"
    #@TYTLEpost = "#{@year}年度"
    #@labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption = {}
    @TableEdit = true  #[[:edit_bottom]]
    #@Edit = true
    @Delete=true
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    #@CSVatrs = Ube::Product::CSVatrs; @CSVlabels = Ube::Product::CSVlabels
    #@pageSession="UBpro_perpage"
    @Pagenation =  session[@PageSession] || (session[@PageSession] = 20)
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

  def index
    @TableEdit = [[ :upload_buttom,:load,"TRZファイル取り込み"]]
    @labels = LabelsMonthesIndex
    super
  end

  def index_month
    month = params[:month]
    @page = params[:page] || 1 
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


  def show
    @model = @Model.find params[:id]
  end


end
