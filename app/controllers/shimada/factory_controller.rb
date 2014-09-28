# -*- coding: utf-8 -*-
class Shimada::FactoryController <  Shimada::Controller

  PopupToday = %Q!onClick="window.open('/shimada/factory/today','today','width=800,height=500,scrollbars=yes');" target="today"! 
  Labels = 
    [
     HtmlText.new(:name,"工場名",:size => 8 ),
     HtmlSelect.new(:weather_location,"過去データ",:correction => WeatherLocation.name_location_past),
     #all.map{|wl| [wl.name,wl.location]}),
     HtmlSelect.new(:forecast_location,"予報",:correction => WeatherLocation.name_location),
     #all.map{|wl| [wl.name,wl.location]}),
     HtmlNum.new(:power_model_id,"パワーモデル",size: 2),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/today",:key => :id, :key_val => :id,
                    :link_label => "本日実績", :htmloption =>PopupToday}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/tomorrow",:key => :id, :key_val => :id,
                    :link_label => "明日予報"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/power",:key => :id, :key_val => :id,
                    :link_label => "過去実績"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/analyze",:key => :id, :key_val => :id,
                    :link_label => "分析"})
     #HtmlLink.new(:id,"",:link => { :url => shimada_month_analyze_index_path,:link_label => "分析"})
    ]
  LabelParams=
    %w(revise_threshold revise_slope_lower revise_slope_higher revise_y0 revise_power_0line
      raw_vaper_threshold raw_vaper_slope_lower raw_vaper_slope_higher raw_vaper_y0 raw_vaper_power_0line
     ).
    zip(%w(閾値 低域傾斜 高域傾斜 切片 ゼロライン 閾値 低域傾斜 高域傾斜 切片 ゼロライン)).
    map{ |param,lbl|  HtmlNum.new(param,lbl,size: 3) }

  def set_instanse_variable
    super
    @factory_id = params[:factory_id] if  params[:factory_id]
    @Model= Shimada::Factory

    @MonthModel = Shimada::MonthModels[@factory.power_model_id]
    @PowerModel = Shimada::PowerModels[@factory.power_model_id]
    @Domain= @Model.name.underscore
    @TYTLE = "シマダヤ工場電力管理"
    @labels=Labels
    @TableEdit  = true
    @TableHeaderDouble = [1,[2,"気象データ"],1,[5,"温度補正パラメータ"],[5,"蒸気圧補正パラメータ"]]
    @Show = @Delete = @Edir = true
  end
  def add_on_table
    @labels =  Labels[0,4]+LabelParams
    super
  end


  def edit_on_table
    @labels =  Labels[0,4]+LabelParams
    super
  end


  def today
    path = Rails.root+"app/models/shimada/update_mysql.rb"
    
    today_graph    
  end
  def update_today
    line = params[:power][:line]  
    @today= Time.now.to_date
    @power = @PowerModel.find_by(date: @today) 
    @power.update_attribute(:line,line)  
    redirect_to :action => :today
  end

  def today_graph
    factory = @Model.find @factory_id #params[:id]
    @today= Time.now.to_date
    @power = @PowerModel.find_or_create_by(date: @today)
    month = @MonthModel.find_or_create_by(month: @today.beginning_of_month)
    @power.month = month;@power.save
    @power.update_attribute(:line,3)  unless @power.line
    @power.today_graph factory.name #@factory_id
    @forecast = forecast = Forecast.find_or_fetch(factory.forecast_location,@today)
    @temp = forecast.temperature
    @humi = forecast.humidity
    @vaper = forecast.vaper

    ############  Demo用 ####################
    if hr = @power.powers.index(nil)
      dmypw = @PowerModel.find_or_create_by(date: @today.last_year).powers
      if hr < 2
        (0..1).each{ |h| @power.update_attribute( "hour%02d"%(h+1) , dmypw[h])}
        hr = 3
      end
      @power.update_attribute( "hour%02d"%(hr+1) , dmypw[hr])
    end
    #########################################
    @interbal = 2
    render :action => :today,:layout => "refresh"
  end

  def clear_today
    @today= Time.now.to_date
    ( pw = @PowerModel.find_by(date: @today)  ) && pw.delete 
    redirect_to :action => :today 
  end

  def update_tomorrow
    line = params[:power][:line]
    tomorrow_graph(@factory_id,line)
  end

  def tomorrow
    factory = @Model.find params[:id]
    line = 3
    tomorrow_graph(line)
  end

  def tomorrow_graph(line)
    factory = @Model.find params[:id]
    @today= Time.now.to_date
    @tomorrow = @today.tomorrow.to_date
    @power = @PowerModel.new(:date => @tomorrow,:line => line)
    @date = @tomorrow
    @power.tomorrow_graph(@factory_id,line)
    @forecast =  forecast = Forecast.find_or_fetch(factory.forecast_location,@tomorrow,@today)
    @temp = forecast.temperature
    @humi = forecast.humidity
    render :action => :tomorrow
  end

  def show_gif
    graph_file = (params[:graph_file].blank? ? "tomorrow" : params[:graph_file])+"_#{@factory_id}"
    send_file Rails.root+"tmp/shimada/giffiles/#{graph_file}.gif", :type => 'image/gif', :disposition => 'inline'
  end

end
