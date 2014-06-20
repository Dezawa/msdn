# -*- coding: utf-8 -*-
class WeatherController < ApplicationController
  before_filter :set_instanse_variable
  
  #Viewにて表示すべき項目の定義。
  Labels = [
            HtmlDate.new(:date         ,"日付名",  :tform => "%Y/%m/%d", :ro => true, :size => 7 ),
            HtmlText.new(:location     ,"場所",    :ro => true , :size => 7)
            ] +
    Weather::Temperature.map{ |h| 
      HtmlNum.new(h, h.sub(/hour/,""),:ro => true,:size => 2 ) }

 def set_instanse_variable
   @Model= Weather
   @TYTLE = "温度"
   @labels=Labels
   @TableEdit = nil
   @Domain= @Model.name.underscore
   @TableHeaderDouble = [2,[24,"時刻"]]
   @FindOption = { :order => "date"}
  end
end # of class users_cont
