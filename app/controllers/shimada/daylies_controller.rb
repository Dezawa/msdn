# -*- coding: utf-8 -*-
class Shimada::DayliesController <  Shimada::Controller
  Labels =
    [
     HtmlLink.new(:month,"月",tform: "%Y/%m",
                  link: {url: 'index_month/',key: :month,key_val: :month})
    ]
  LabelsIndexMonth=
    [ HtmlDate.new(:date,"月日",ro: true,tform: "%m/%d") ,
     HtmlText.new(:item_labels,"",ro: true)
    ] +
    (0..23).map{|hr| HtmlNum.new(("hour_html%02d"%hr).to_sym,"%d:00～"%hr,ro: true)}
  def set_instanse_variable
    super
    model Shimada::Dayly
    @TYTLE = "シマダヤ:月度データ"
    @TYTLE_post = "(#{@factory.name}工場)"
    @SortBy    = :month
  end

  def index
    @page = params[:page] || 1
    @labels = Labels
    #@factory_id  = session[:shimada_factory] = params[:id].to_i if  params[:factory_id]
    @TYTLE_post = "(#{@factory.name}工場)"
    @models = @Model.by_factory_id(@factory_id).order( "month desc" ).
      group(:month)
    logger.debug("##### Shimada::DayliesController @models.size=#{ @models.size }")
    render  :file => 'application/index',:layout => 'application'
  end

  def index_month
    model Shimada::Values
    month = Date.parse params[:month]
     @labels = LabelsIndexMonth
     @models = @Model.month(@factory_id, month)
     render  :file => 'application/index',:layout => 'application'
  end
end
