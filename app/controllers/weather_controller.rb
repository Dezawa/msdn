# -*- coding: utf-8 -*-
class WeatherController < ApplicationController
  before_filter :set_instanse_variable
  
  #Viewにて表示すべき項目の定義。
  Labels = [
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7),
#            HtmlDate.new(:month        ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ),
            HtmlDate.new(:date         ,"年月日",  :tform => "%Y/%m/%d", :ro => true, :size => 7 )
            ] 
  Temperature = Weather::Temperature.map{ |h| HtmlNum.new(h, h.sub(/hour/,""),:ro => true,:size => 2 ) }
  Vaper = Weather::Vaper.map{ |h| HtmlNum.new(h, h.sub(/vaper/,""),:ro => true,:size => 2 ) }
  Humidity = Weather::Humidity.map{ |h| HtmlNum.new(h, h.sub(/humidity/,""),:ro => true,:size => 2 ) }

  def set_instanse_variable
    @Model= Weather
    @TYTLE = "気象 "
    #@labels=Labels
    @TableEdit = nil
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
    @models = Weather.all(:select => :month,:select => "distinct month,location",
                          :order => "location,month")
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
