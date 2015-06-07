# -*- coding: utf-8 -*-
class Shimada::GraphDefine < ActiveRecord::Base
  belongs_to :factory,:class_name =>  "Shimada::Factory"
  serialize  :serials

  before_save  :serialize_serials

  attr_accessor :serials_to_s
  
  def serialize_serials
    unless serials.class == Array
      self.serials = self.serials.split(/[\s,]+/)
    end
  end

  def serials_to_s
    self.serials.join(" ")
  end

  # attr_accessor :id,:name,:factory_id,:title, :graph_type, :serials
  # def initialize(args)
  #   [:id,:name,:factory_id,  :title, :graph_type, :serials].
  #     each{|attr_name| instance_variable_set "@#{attr_name}",args.delete(attr_name)
  #   }
  # end

end

Shimada::GraphDefines =
  { 1 => 
   { "岐阜気象庁"   => Shimada::GraphDefine.new( name: "岐阜気象庁",factory_id: 1, id: 1,
                               title: "天気予報・実績", graph_type: "weather" ,
                               serials: [] ),
    "全電力・気温"  => Shimada::GraphDefine.new( name: "全電力" ,factory_id: 1,    id: 2,
                              title: "全電力と温度・蒸気圧", graph_type: "temp_vaper_power" ,
                              serials: %w(52C204E9 52BC036E) ),
    "フリーザーA"   => Shimada::GraphDefine.new( name: "フリーザーA"  ,factory_id: 1,  id: 3,
                              title: "フリーザーA",       graph_type: "temp_vaper_power" ,
                              serials: %w(52BC036F 52BC036E) ),
   },
  5=>{"全電力・気温"  => Shimada::GraphDefine.new( name: "全電力" ,factory_id: 1,    id: 2,
                              title: "全電力と温度・蒸気圧", graph_type: "temp_vaper_power" ,
                              serials: %w(52C204E9 52BC036E) ),},
  7=>{"全電力・気温"  => Shimada::GraphDefine.new( name: "全電力" ,factory_id: 1,    id: 2,
                              title: "全電力と温度・蒸気圧", graph_type: "temp_vaper_power" ,
                              serials: %w(52C204E9 52BC036E) ),},
  8=>{"全電力・気温"  => Shimada::GraphDefine.new( name: "全電力" ,factory_id: 1,    id: 2,
                              title: "全電力と温度・蒸気圧", graph_type: "temp_vaper_power" ,
                              serials: %w(52C204E9 52BC036E) ),},
  
 }
