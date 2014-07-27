# -*- coding: utf-8 -*-
class ForecastController < ApplicationController
  before_filter :set_instanse_variable
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weather     = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
  Humi     = %w(humi03 humi06 humi09 humi12 humi15 humi18 humi21 humi24)
  Vaper    = %w(vaper03 vaper06 vaper09 vaper12 vaper15 vaper18 vaper21 vaper24)

  Labels = [
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7),
#            HtmlDate.new(:month        ,"年月",  :tform => "%Y/%m", :ro => true, :size => 7 ),
            HtmlDate.new(:date         ,"年月日",  :tform => "%Y/%m/%d", :ro => true, :size => 7 ),
            HtmlDate.new(:announce ,"発表日",  :tform => "%m/%d %H", :ro => true, :size => 7 )
            ] +
    Temp.map{ |clm|  HtmlNum.new(clm.to_sym,clm.sub(/temp/,""),:tform => "%.1f") } +
    Humi.map{ |clm|  HtmlNum.new(clm.to_sym,clm.sub(/humi/,""),:tform => "%.1f") } +
    Weather.map{ |clm|  HtmlText.new(clm.to_sym,clm.sub(/weather/,"")) } +
    Vaper.map{ |clm|  HtmlNum.new(clm.to_sym,clm.sub(/vaper/,""),:tform => "%.1f") } 
  
  def set_instanse_variable
    @Model= Forecast
    @TYTLE = "予報 "
    @labels=Labels
    #@TableEdit = [[:input_and_action,"get_data","新規取得 年月(日) 2014-7(-10)",{:size=>8}]]
    @Domain= @Model.name.underscore
    @TableHeaderDouble = [3,[8,"気温"],[8,"湿度"],[8,"天気"],[8,"蒸気圧"]]
    @FindOption = { :order => "date"}
  end

  def now
    location = params[:location] || :maebashi
    fore = Forecast.find_or_fetch(location)
    render :text => fore.to_s
  end
end
