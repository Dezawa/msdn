# -*- coding: utf-8 -*-
require 'ondotori'
require "ondotori/converter"
class Shimada::InstrumentController < Shimada::Controller
  Labels =
  [
   HtmlText.new(:serial,"機器連番",size: 6),
   HtmlText.new(:base_name       ,"おんどとりbase",size: 6),
   HtmlText.new(:ch_name           ,"おんどとりchannel",size: 20, ),
   HtmlSelect.new(:measurement_type,"測定機type"    ,:correction => Ondotori::TypeName,size: 3),
   HtmlSelect.new(:measurement,"測定項目"    ,correction: %w(温度 湿度 電力),size: 3),
   HtmlSelect.new(:unit            ,"単位",:correction => %w(℃ %Rh kWh)    ,size: 2),
   HtmlText.new(:comment         ,"説明"    ,size: 20),
   HtmlSelect.new(:converter     ,"変換"     ,:correction => Shimada.converter ,size: 4),
   HtmlNum.new( :slope           ,"傾き"    ,size: 3), 
   HtmlNum.new( :graft           ,"切片"    ,size: 3)
  ]

  CSVatrs = Labels.map{|lbl| lbl.symbol}
  CSVlabels= Labels.map{|lbl| lbl.label}
  
  def set_instanse_variable
    super
    @Model= Shimada::Instrument
    @Domain= @Model.name.underscore
    @TYTLE = "シマダヤ測定器"
    @labels=Labels
    @TableEdit  = [:add_edit_buttoms,:csv_out, :csv_up_buttom]
    @Show = @Delete = @Edit = true
  @CSVatrs  = [:id] + Labels.map{|lbl| lbl.symbol}
  @CSVlabels= ["id"] +Labels.map{|lbl| lbl.label}
  end
end
