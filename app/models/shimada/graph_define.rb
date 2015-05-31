# -*- coding: utf-8 -*-
class Shimada::GraphDefine
  include ActiveModel::Model
  include ActionView::Helpers::UrlHelper

  attr_accessor :id,:name,:factory_id,:title, :graph_type, :serials

  def initialize(args)
    [:id,:name,:factory_id,  :title, :graph_type, :serials].
      each{|attr_name| instance_variable_set "@#{attr_name}",args.delete(attr_name)
    }
  end

end

Shimada::GraphDefines = 
{ "岐阜気象庁"   => Shimada::GraphDefine.new( name: "岐阜気象庁",factory_id: 1, id: 1,
                               title: "天気予報・実績", graph_type: "weather" ,
                               serials: [] ),
 "全電力・気温"  => Shimada::GraphDefine.new( name: "全電力" ,factory_id: 1,    id: 2,
                              title: "全電力と温度・蒸気圧",       graph_type: "temp_vaper_power" ,
                              serials: %w(52C204E9 52BC036E) ),
 "フリーザーA"   => Shimada::GraphDefine.new( name: "フリーザーA"  ,factory_id: 1,  id: 3,
                              title: "フリーザーA",       graph_type: "temp_vaper_power" ,
                              serials: %w(52BC036F 52BC036E) ),
                               
 }
