# -*- coding: utf-8 -*-
class WeatherController < CommonController #ApplicationController
  before_action :set_instanse_variable
  
  #Viewにて表示すべき項目の定義。
  Labels = [
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7),
#            HtmlDate.new(:month        ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ),
            HtmlDate.new(:date         ,"年月日",  :tform => "%Y/%m/%d", :ro => true, :size => 7 ),
            ] 
  #Temperature = Weather::Temperature.map{ |h| HtmlNum.new(h, h.sub(/hour/,""),:ro => true,:size => 2 ) }
  TempVaper = [HtmlText.new("気温<br>蒸気圧".html_safe,"")] + 
    ("01".."24").map{ |h| HtmlText.new("tempvaper#{h}".to_sym, h,:ro => true,:size => 2 ) }
  Temperature = [HtmlText.new("気温","")] + 
    ("01".."24").map{ |h| HtmlText.new("temp_#{h}".to_sym, h,:ro => true,:size => 2 ) }
  Vaper = Weather::Vaper.map{ |h| HtmlNum.new(h, h.sub(/vaper/,""),:ro => true,:size => 2 ) }
  Humidity = Weather::Humidity.map{ |h| HtmlNum.new(h.to_sym, h.sub(/humidity/,""),:ro => true,:size => 2 ) }

  def set_instanse_variable
    super
    @Model= Weather
    @TYTLE = "気象 "
    #@labels=Labels
    correction = WeatherLocation.all.map{|wl| [wl.name,wl.location]}
    #Forecast::ZP.map{ |location,value| [value[1],location]}
    @TableEdit = [[:select_and_action,:change_location,"地域変更",
                   {:correction => correction ,:selected => @weather_location }],
                  [:input_and_action,"get_data","新規取得 年月(日) 2014-7(-10)",{:size=>8}],
                  [:input_and_action,"plot_year","期間変化グラフ。start end 時刻-時刻",{:size=>24},{method: "get"}],
                  [:popup,:temp_vaper,"温度-水上気圧図"],
                  [:form,:weather_location,"気象エリア設定"],
                  [:form,:cband,"C-band"]
                 ]
    @Domain= @Model.name.underscore
    #@TableHeaderDouble = [3,[24,"時刻"]]
    @FindOption = { :order => "date"}
  end

  def index
    @labels =  [
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7),
            HtmlDate.new(:month        ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ),
            ]
    @Show = false
    @Delete = true
    @models = Weather.where( ["location = ?",@weather_location]).
      select( "distinct month,location").
      order("location,month")
    session[:c_band] = nil
  end

  def show
    if /[^\d]/ =~ params[:id]
      send(params[:id].to_sym)
    else
      super
    end
  end

  def plot_year
    day_from,day_to,hour_from,hour_to = params[@Domain][:plot_year].split(/\s+|,/)
    logger.debug("######## plot_year day_from,day_to,hour_from,hour_to = #{[day_from,day_to,hour_from,hour_to].join(',')}")
    @graph_path = Weather.plot_year(@weather_location,day_from,day_to,hour_from,hour_to)
    @graph_format = :jpeg
    render  :file => 'application/graph',:layout => 'application'
  end

  def temp_vaper
    @graph_file = Weather.temp_vaper_graph(@weather_location)
    @graph_format = :jpeg
    render  :file => 'application/graph',:layout => 'application'
  end

  def weather_location
    redirect_to :controller => :weather_location,:action => :index
  end

  def cband
    if params[@Domain]
      end_date_time  = params[@Domain][:end_date_time]
      from_date_time = params[@Domain][:from_date_time]
      now            = params[@Domain][:now] || from_date_time

      limit = Time.at(Time.now.to_i/300*300-5.minute)
      end_date_time = if end_date_time
                        Time.at(Time.parse(end_date_time).to_i/300*300)
                      else
                        limit
                      end
      end_date_time =  limit if end_date_time > limit
      
      from_date_time = if from_date_time
                         Time.at(Time.parse(from_date_time).to_i/300*300)
                       else
                         (end_date_time-2.hour)
                       end
      now = Time.at(Time.parse(now).to_i/300*300)
      next_date_time  = from_date_time #[ now, from_date_time ].max
      session[:c_band] =YAML.dump( [from_date_time,end_date_time,next_date_time])
      c_band_ref
    else
      return c_band_ref if session[:c_band]
      end_date_time  =Time.at(Time.now.to_i/300*300)
      @end_date_time  = end_date_time.strftime("%Y-%m-%d-%H:%M")
      @from_date_time = (end_date_time-2.hour).strftime("%Y-%m-%d-%H:%M")
      @now          = @from_date_time 
    end
  end
  
  def c_band_ref
    from_date_time,end_date_time,next_date_time = YAML.load session[:c_band] 
    session[:c_band] = YAML.dump([from_date_time,end_date_time,next_date_time+5.minute])
    @img_url = "http://www.river.go.jp/img/11/0083/#{next_date_time.strftime('%Y%m%d')}/#{next_date_time.strftime('%H%M')}00.png"
    @interbal = 1
    @now          = next_date_time.strftime("%Y-%m-%d-%H:%M")
    @end_date_time = end_date_time.strftime("%Y-%m-%d-%H:%M")
    @from_date_time = from_date_time.strftime("%Y-%m-%d-%H:%M")
    if next_date_time < end_date_time
      render :layout => 'refresh',:action => :cband
    else
      session[:c_band] = nil
    end

  end

  def change_location
    location = params[@Domain][:change_location]
    @weather_location  = session[:weather_location] = location
    redirect_to "/weather"
  end


  def get_data
    y,m,d = params[@Domain][:get_data].split(/[^\d]+/).map(&:to_i)
    if d
      start = last = Date.new(y,m,d)
    else
      start =  Date.new(y,m)
      last = start.end_of_month
    end
    (start..last).each{ |day|  @Model.find_or_feach(@weather_location,day) }
    redirect_to :action => :index
  end

  def temperatuer
    @models = Weather.where(["location = ? and month = ?", params[:location],params[:month]]).
      order("date")
    @labels = Labels + ( WeatherLocation.with_vaper?(@weather_location) ? TempVaper : Temperature)
    @TYTLE = "気温 "
    render  :file => 'application/index',:layout => 'application'
  end

  def vaper
    @models = Weather.where( ["location = ? and month = ?", params[:location],params[:month]]).
          order("date")
    @labels = Labels + Vaper
    @TYTLE = "蒸気圧 "
    render  :file => 'application/index',:layout => 'application'
  end

  def humidity
    @models = Weather.where( ["location = ? and month = ?", params[:location],params[:month]]).
          order("date")
    @labels = Labels + Humidity
    @TYTLE = "湿度 "
    render  :file => 'application/index',:layout => 'application'
  end
  def delete;end

end
