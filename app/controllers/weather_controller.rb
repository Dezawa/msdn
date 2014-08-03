# -*- coding: utf-8 -*-
class WeatherController < ApplicationController
  before_filter :set_instanse_variable
  
  #Viewにて表示すべき項目の定義。
  Labels = [
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7),
#            HtmlDate.new(:month        ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ),
            HtmlDate.new(:date         ,"年月日",  :tform => "%Y/%m/%d", :ro => true, :size => 7 ),
            HtmlText.new("気温<br>蒸気圧","")
            ] 
  #Temperature = Weather::Temperature.map{ |h| HtmlNum.new(h, h.sub(/hour/,""),:ro => true,:size => 2 ) }
  Temperature = ("01".."24").map{ |h| HtmlText.new("tempvaper#{h}".to_sym, h,:ro => true,:size => 2 ) }
  Vaper = Weather::Vaper.map{ |h| HtmlNum.new(h, h.sub(/vaper/,""),:ro => true,:size => 2 ) }
  Humidity = Weather::Humidity.map{ |h| HtmlNum.new(h, h.sub(/humidity/,""),:ro => true,:size => 2 ) }

  def set_instanse_variable
    super
    @Model= Weather
    @TYTLE = "気象 "
    #@labels=Labels
    correction = WeatherLocation.all.map{|wl| [wl.name,wl.location]}
    #Forecast::ZP.map{ |location,value| [value[1],location]}
    @TableEdit = [[:select_and_action,:change_location,"地域変更",
       {:correction => correction ,:selected => @weather_location }],
    [:input_and_action,"get_data","新規取得 年月(日) 2014-7(-10)",{:size=>8}]]
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
    @models = Weather.all(:conditions => ["location = ?",@weather_location],
                          :select => "distinct month,location",
                          :order => "location,month")
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
    @models = Weather.
      all(:conditions => ["location = ? and month = ?", params[:location],params[:month]],
          :order => "date")
    @labels = Labels + Temperature
    @TYTLE = "気温 "
    render  :file => 'application/index',:layout => 'application'
  end

  def vaper
    @models = Weather.
      all(:conditions => ["location = ? and month = ?", params[:location],params[:month]],
          :order => "date")
    @labels = Labels + Vaper
    @TYTLE = "蒸気圧 "
    render  :file => 'application/index',:layout => 'application'
  end

  def humidity
    @models = Weather.
      all(:conditions => ["location = ? and month = ?", params[:location],params[:month]],
          :order => "date")
    @labels = Labels + Humidity
    @TYTLE = "湿度 "
    render  :file => 'application/index',:layout => 'application'
  end
  def delete;end

end
