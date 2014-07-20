# -*- coding: utf-8 -*-
class Shimada::FactoryController <  Shimada::Controller

  PopupToday = %Q!onClick="window.open('/shimada/factory/today','today','width=800,height=500,scrollbars=yes');" target="today"! 
  Labels = 
    [
     HtmlText.new(:name,"工場名",:size => 8 ),
     HtmlText.new(:weather_location,"気象予報エリア名",:size => 8),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/today",:link_label => "本日実績", :htmloption =>PopupToday}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/tomorrow",:link_label => "明日予報"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/index",:link_label => "過去実績"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/analyze",:link_label => "分析"})
    ]
  def set_instanse_variable
    super
    @Model= Shimada::Factory
    @Domain= @Model.name.underscore
    @TYTLE = "シマダヤ工場電力管理"
    @labels=Labels
    @TableEdit  = true
    @Show = @Delete = @Edir = true
    
  end
  def add_on_table
    @labels =  [
     HtmlText.new(:name,"工場名",:size => 8 ),
     HtmlText.new(:weather_location,"気象予報エリア名",:size => 8)
               ]
    super
  end


  def edit_on_table
    @labels =  [
     HtmlText.new(:name,"工場名",:size => 8 ),
     HtmlText.new(:weather_location,"気象予報エリア名",:size => 8)
               ]
    super
  end


  def today
    path = RAILS_ROOT+"/app/models/shimada/update_mysql.rb"
    
    today_graph    
  end
  def update_today
    line = params[:power][:line]  
    @today= Time.now.to_date
    @power = Shimada::Power.find_by_date(@today) 
    @power.update_attribute(:line,line)  
    redirect_to :action => :today
  end

  def today_graph
    #factory = @Model.find params[:id]
    @today= Time.now.to_date
    @power = Shimada::Power.find_or_create_by_date(@today)
    month = Shimada::Month.find_or_create_by_month(@today.beginning_of_month)
    @power.month = month;@power.save
    @power.update_attribute(:line,3)  unless @power.line
    @power.today_graph
    forecast = Forecast.find_or_fetch(:maebashi,@today)
    @temp = forecast.temperature
    @humi = forecast.humidity

    ############  Demo用 ####################
    if hr = @power.powers.index(nil)
      dmypw = Shimada::Power.find_or_create_by_date(@today.last_year).powers
      @power.update_attribute( "hour%02d"%(hr+1) , dmypw[hr])
    end
    #########################################
    @interbal = 10
    render :action => :today,:layout => "refresh"
  end

  def clear_today
    @today= Time.now.to_date
    ( pw = Shimada::Power.find_by_date(@today) ) && pw.delete 
    redirect_to :action => :today 
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
    @power = Shimada::Power.new(:date => @tomorrow,:line => line)
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
