# -*- coding: utf-8 -*-
class Shimada::InstrumentController < Shimada::Controller
  
  Labels =
  [
   HtmlText.new(:serial,"機器連番",size: 6),
   HtmlSelect.new(:base_name       ,"おんどとりbase" ,:correction => %w(Chubu GMC dezawa),size: 6),
   HtmlText.new(:ch_name           ,"おんどとりchannel",size: 20, ),
   HtmlSelect.new(:measurement_type,"測定type"    ,:correction => %w(温度 湿度 電力),size: 3),
   HtmlSelect.new(:unit            ,"単位",:correction => %w(℃ %Rh kWh)    ,size: 2),
   HtmlText.new(:comment         ,"説明"    ,size: 20),
   HtmlSelect.new(:converter     ,"変換"     ,:correction => [["無し",0],["一次",1],["特殊",9]] ,size: 4),
   HtmlNum.new( :slope           ,"傾き"    ,size: 3), 
   HtmlNum.new( :graft           ,"切片"    ,size: 3)
  ]
  def set_instanse_variable
    super
    @Model= Shimada::Instrument
    @Domain= @Model.name.underscore
    @TYTLE = "シマダヤ測定器"
    @labels=Labels
    @TableEdit  = true
    @Show = @Delete = @Edit = true
  end
end
