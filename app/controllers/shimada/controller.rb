# -*- coding: utf-8 -*-
# うどんのシマダヤ

class Shimada::Controller <  CommonController #ApplicationController
  include Actions
  include GraphController
  delegate :logger, :to=>"ActiveRecord::Base"
  #before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  #before_filter(:except => :error) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
   Links =
    [
     Menu.new(   "工場一覧"  ,"shimada/factory"    , :action => :index ) ,
     Menu.new(   "測定器一覧","shimada/instrument" , :action => :index) ,
     Menu.new(   "電池残量"  ,"status/tand_d" ,
              { :action => :list,:controller => "status/tand_d"}) ,
    ]

  def set_instanse_variable
    super
    @Links = Links
    if params[:factory_id]
      @factory_id = session[:shimada_factory] =  params[:factory_id].to_i
      @factory    = Shimada::Factory.find @factory_id
    else
     if (@factory_id = session[:shimada_factory]) &&  
       (@factory    = Shimada::Factory.find_by id: @factory_id)
     else
       @factory = Shimada::Factory.first #find_by(name: "GMC")
       @factory_id = @factory.id
     end
    end
  end

  def graph
    @model = @Model.find params[:id]
    Shimada::Graph.create(params[:type],@model)
  end
  def graph_dayly
    @model = @Model.find params[:id]
    option = {time_range:  :dayly,
              title: @factory.name + @model.date.strftime(" (%m月%d日)")
             }
    Shimada::Graph.create(params[:type],@model,option)
    render   :file => 'application/graph', :layout => "simple"
  end
  def graph_month
    month = Date.parse(params[:month])
    @models =
      case params[:type]
      when "temp_hyum" ;  
        @Model.by_factory_id(@factory_id).
          where(month: month,measurement_type:  Ondotori::TypeNameHash["温度"] )
      when "temp_vaper_power"
        Shimada::Dayly.by_factory_id(@factory_id).
          where(month: month)
      end
    option = {time_range:  :monthly,
              title: @factory.name + month.strftime(" (%Y年%m月度)")
             }
    Shimada::Graph.create(params[:type],@models,option).plot
    render   :file => 'application/graph', :layout => "simple"
  end
    
end
