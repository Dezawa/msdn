# -*- coding: utf-8 -*-
class WeatherLocationController < ApplicationController
  before_filter :set_instanse_variable
  def set_instanse_variable
    super
    @Model= WeatherLocation
    @Domain= @Model.name.underscore
    @TableEdit = true
    @labels=[ HtmlText.new(:name,"地域名", :size => 8),
              HtmlText.new(:location,"地域コード",:size=>12),
              HtmlNum.new(:weather_prec,"県code",:size=>8),
              HtmlNum.new(:weather_block,"ブロックNo",:size=>8),
              HtmlText.new(:forecast_code,"気象協会",:size=>12),
              HtmlText.new(:excite_zip,"Excite",:size=>9)
            ]
    @TableHeaderDouble =[2,[2,"過去データベース"],[2,"予報"]]
  end
end
