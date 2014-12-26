# -*- coding: utf-8 -*-
class Sola::DaylyController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  before_filter :set_instanse_variable
  
  LabelsMonthIndex = [ HtmlDate.new(:month,"年月",:tform =>"%Y-%m")]
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
    @Show   = true
    @labels = LabelsMonthIndex
    super
  end

  def load
logger.debug("Sola::DaylyCnrl load #{params[@Domain][:uploadfile]}")
    @Model.load_trz params[@Domain][:uploadfile]
    redirect_to :action => :index
  end

end
