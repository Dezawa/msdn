# -*- coding: utf-8 -*-
class Shimada::DayliesController <  Shimada::Controller
  include GraphController
  LabelsIndex =
    [
     HtmlLink.new(:month,"月",tform: "%Y/%m",
                  link: {url: 'index_month/',key: :month,key_val: :month}),
     HtmlLink.new(nil,"温湿度グラフ",
                  link: {url: 'graph_month/',key: :month,key_val: :month,
                         type: :temp_hyum,  link_label: "温湿度グラフ"}),
     HtmlLink.new(nil,"温湿度電力グラフ",
                  link: {url: 'graph_month/',key: :month,key_val: :month,
                         type: :temp_vaper_power,  link_label: "温湿度電力グラフ"})
    ]
  LabelsIndexMonth=
    [ HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                   link: {url: '/shimada/factory/data_graph_table',
                          key: :id,key_val: :factory_id,params: [:date]}) ,
     HtmlText.new(:item_labels,"",ro: true)
    ] +
    (0..23).map{|hr| HtmlNum.new(("hour_html%02d"%hr).to_sym,"%d:00～"%hr,ro: true)}
  def set_instanse_variable
    super
    model Shimada::Dayly
    @TYTLE = "シマダヤ"
    @TYTLE_post = "(#{@factory.name}工場)"
    @SortBy    = :month
  end

  def index
    @page = params[:page] || 1
    @labels = LabelsIndex
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

  def graph_temp_hyum_vaper
    date = params[:date]
    dailies = @Model.by_factory_id_order_instrument(@factory_id).
      where(date: date,measurement_type: Ondotori::TypeNameHash["温度"])
    option = { title:  "気温・湿度・蒸気圧  #{@factory.name} (#{date})"
             }
    optionST = Gnuplot::OptionST.
      new({},
          {common: {title:  "気温・湿度・蒸気圧  #{@factory.name} (#{date})"}  })
    Shimada::GraphTempHyumVaper.new(dailies,optionST).plot #@factory_id,date,@Model)
    render   :file => 'application/graph', :layout => "simple"
  end
  def show_img
    @TYTLE = "シマダヤ:"
    super
  end
  
  def show
    @model = @Model.find params[:id]
  end
end
