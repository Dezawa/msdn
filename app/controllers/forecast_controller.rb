# -*- coding: utf-8 -*-
class ForecastController < CommonController # ApplicationController
  before_filter :set_instanse_variable
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weather  = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
  Humi     = %w(humi03 humi06 humi09 humi12 humi15 humi18 humi21 humi24)
  Vaper    = %w(vaper03 vaper06 vaper09 vaper12 vaper15 vaper18 vaper21 vaper24)

  Labels = [
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7),
#            HtmlDate.new(:month        ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ),
            HtmlDate.new(:date         ,"年月日",  :tform => "%Y/%m/%d", :ro => true, :size => 7 ),
            HtmlDate.new(:announce ,"発表日",  :tform => "%m/%d %H", :ro => true, :size => 7 )
            ] +
    Temp.map{  |clm|   HtmlNum.new(clm.to_sym,clm.sub(/temp/,""),:tform => "%.1f") } +
    Vaper.map{ |clm|   HtmlNum.new(clm.to_sym,clm.sub(/vaper/,""),:tform => "%.1f") } +
    Humi.map{  |clm|   HtmlNum.new(clm.to_sym,clm.sub(/humi/,""),:tform => "%.1f") } +
    Weather.map{ |clm| HtmlText.new(clm.to_sym,clm.sub(/weather/,"")) } 
  
  def set_instanse_variable
    super
    @Model= Forecast
    @TYTLE = "予報 "
    @labels=Labels
    correction = WeatherLocation.all.map{|wl| [wl.name,wl.location]}
    #Forecast::ZP.map{ |location,value| [value[1],location]}
    @TableEdit = #[[:input_and_action,"get_data","新規取得 年月(日) 2014-7(-10)",{:size=>8}]]
    [ [:select_and_action,:change_location,"地域変更",
       {:correction => correction ,:selected => @weather_location }],
      [:form,:fetch,"取り込み",method: :get] ,[:form,:error_graph,"予報誤差",method: :get]
    ]
    @Domain= @Model.name.underscore
    @TableHeaderDouble = [3,[8,"気温"],[8,"蒸気圧"],[8,"湿度"],[8,"天気"]]
    @FindOption = { :conditions => ["location = ?", @weather_location],
      :order => "date"}
    @FindWhere =  ["location = ?", @weather_location]
    @FindOrder = "date"
  end

  def show
    if /[^\d]/ =~ params[:id]
      send(params[:id])
    else
      super
    end
  end

  def change_location
    location = params[@Domain][:change_location]
    @weather_location  = session[:weather_location] = location
    redirect_to "/forecast"
  end

  def error_graph
    location = @weather_location
    @Model.differrence_via_real_graph location , @graph_file  = "forecast-real"
    @graph_format = :jpeg
    render :action => :error_graph,:layout => "hospital_error_disp"
  end

  def fetch
    fore = Forecast.fetch(@weather_location,Time.now.to_date)
    redirect_to "/forecast"
  end

  def new
    location = params[:location] || @weather_location
    fore = Forecast.fetch(location,Time.now.to_date)
    render :text => fore.to_s
  end

  def get_all_location
    locations = WeatherLocation.all.map(&:location)
    locations.each{ |location| Forecast.fetch(location,Time.now.to_date)}
    render :text => locations.join(",")
  end

end
