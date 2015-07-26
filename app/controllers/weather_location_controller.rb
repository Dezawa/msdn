# -*- coding: utf-8 -*-
require 'nkf'
require 'csv'
class WeatherLocationController < CommonController #ApplicationController
  before_action :set_instanse_variable
  def set_instanse_variable
    super
    @Model= WeatherLocation
    @Domain= @Model.name.underscore
    @TableEdit = [:add_edit_buttoms,:csv_up_buttom,[:form,:csv_out,"CSVダウンロード"]]
    @labels=[ HtmlText.new(:name,"地域名", :size => 8),
              HtmlText.new(:location,"地域コード",:size=>12),
              HtmlNum.new(:weather_prec,"県code",:size=>8),
              HtmlNum.new(:weather_block,"ブロックNo",:size=>8),
              HtmlText.new(:forecast_code,"気象協会",:size=>12),
              HtmlText.new(:excite_zip,"Excite",:size=>9)
            ]
    @TableHeaderDouble =[2,[2,"過去データベース"],[2,"予報"]]
    @FindOption = { :order => "forecast_code"}
    @CSVatrs   = @labels.map{ |l| l.symbol.to_s}
    @CSVlabels = @labels.map{ |l| l.label}
  end
end
