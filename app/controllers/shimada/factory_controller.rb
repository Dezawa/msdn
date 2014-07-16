# -*- coding: utf-8 -*-
class Shimada::FactoryController <  Shimada::Controller

  Labels = 
    [
     HtmlText.new(:name,"工場名",:size => 8 ),
     HtmlText.new(:weather_location,"気象予報エリア名",:size => 8),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/today",:link_label => "本日実績"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/factory/tomorrow",:link_label => "明日予報"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/results",:link_label => "過去実績"}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/factory",:link_label => "分析"})
    ]
  def set_instanse_variable
    super
    @Model= Shimada::Factory
    @Domain= @Model.name.underscore
    @TYTLE = "但馬屋工場電力管理"
    @labels=Labels
    @TableEdit  = true
    @Show = @Delete = @Edir = true
    
  end

  def today
    factory = @Model.find params[:id]
    @power = Shimada::Power.find_by_month((Time.now-1.year))
  end
end
