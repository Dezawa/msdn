# -*- coding: utf-8 -*-
class Shimada::FactoryController <  Shimada::Controller

  Labels = 
    [
     HtmlText.new(:name,"工場名",:size => 8 ),
     HtmlText.new(:weather_location,"気象予報エリア名",:size => 8),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/today",:link_label => "本日実績"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/tomorrow",:link_label => "明日予報"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/results",:link_label => "過去実績"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/analyze",:link_label => "分析"})
    ]
  def set_instanse_variable
    super
    @Model= Shimada::Factory
    @Domain= @Model.name.underscore
    @TYTLE = "但馬屋工場電力管理"
    @labels=Labels
    @TableEdit  = true
    @Show = @Delete = @Edir = true
    
  end

  def today
    factory = @Model.find params[:id]
    @power = Shimada::Power.find_by_month((Time.now-1.year))
  end

  def update_tomorrow
    line = params[:power][:line]
    tomorrow_graph(line)
  end

  def tomorrow
    factory = @Model.find params[:id]
    line = 3
    tomorrow_graph(line)
  end

  def tomorrow_graph(line)
    @today= Time.now.to_date
    @tomorrow = @today.tomorrow.to_date
    #month = tomorrow.beginning_of_month
    #shimada_month = Shimada::Month.find_or_create_by_month(month)
    @power = Shimada::Power.new(:date => @tomorrow,:line => line)
    #@power.month = shimada_month
    @date = @tomorrow
    @power.tomorrow_graph(line)
    forecast = Forecast.find_or_fetch(:maebashi,@tomorrow,@today)
    @temp = forecast.temperature
    @humi = forecast.humidity
    render :action => :tomorrow
  end

  def show_gif
    graph_file = params[:graph_file].blank? ? "tomorrow" : params[:graph_file]
    send_file RAILS_ROOT+"/tmp/shimada/giffiles/#{graph_file}.gif", :type => 'image/gif', :disposition => 'inline'
  end

end
