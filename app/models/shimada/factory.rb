# -*- coding: utf-8 -*-
#Shimada::PowerModels = [Shimada::Power,Shimada::PowerBy_30min] # power_model_idで探す
Shimada::PowerModels = [Shimada::Power,Shimada::Power] # power_model_idで探す
Shimada::MonthModels = [Shimada::Month,Shimada::Chubu::Month]  # power_model_idで探す
Shimada::TimeOffset  = [2,4]
Shimada::GraphType =
  {"temp_vaper_power" => "温度・蒸気圧・電力",
   "temp_hyum" => "温湿度・蒸気圧",
   "weather"   => "天気予報・実績"

  }
class Shimada::Factory < ActiveRecord::Base
  extend CsvIo
  has_many :shimada_powers ,:class_name =>  "Shimada::Power"
  has_many :shimada_instruments,:class_name =>  "Shimada::Instrument"

  def today_graph(graph_type)
    today = Time.now.to_date
    today = Date.new(2015,4,23)
    day_graph(today,graph_type)
  end

  def day_graph_new(day_range,graph_define,option = Gnuplot::OptionST.new)
    opt = option.dup.merge({time_range:  :dayly,
                            graph_file: "#{graph_define.graph_type}_#{graph_define.id}",
                            },[:header])
    day_range = (day_range .. day_range) unless day_range.class == Range

    case graph_define.graph_type.to_s
    when "weather"
      return Forecast.differrence_via_real_graph weather_location,day_range
      
    else
      daylies = Shimada::Dayly.by_factory_id_and_instrument_serial(id,graph_define.serials).
        where(date: day_range)

      Shimada::Graph.create( graph_define.graph_type.to_s,daylies,opt).plot
    end
  end

  def day_graph(day,graph_type,option = Gnuplot::OptionST.new)
    opt = option.dup.merge({time_range:  :dayly,graph_file: "#{graph_type}_#{id}"},[:header])
    day = (day .. day) unless day.class == Range
    daylies =
    case graph_type.to_s
    when "temp_vaper_power"
      Shimada::Dayly.by_factory_id(id).where(["date >= ? and date <= ?",day.first,day.last])
    when "temp_hyum"
      Shimada::Dayly.by_factory_id_order_instrument(id).
        where(["date >= ? and date <= ?",day.first,day.last]).
              where(measurement_type: Ondotori::TypeNameHash["温度"])
    when "weather"
     return Forecast.differrence_via_real_graph weather_location,day
    end
    if daylies && daylies.size>0
      Shimada::Graph.create( graph_type.to_s,daylies,opt).plot
    end
  end

  def day_graphs(date,graph_types=nil,option = Gnuplot::OptionST.new)
    (graph_types || ["temp_vaper_power","temp_hyum","weather"]).
      map{|graph_type|  [graph_type,day_graph(date,graph_type,option)]
    }
  end

  def day_graphs(date,option = Gnuplot::OptionST.new)#all_graphs    }
    Shimada::GraphDefines.keys.map{|graph_define_name|
      [graph_define_name,graph(graph_define_name,(date..date),option)]
    }
    
  end
Shimada::GraphDefine
  def graph(graph_define_name,day_range,option = Gnuplot::OptionST.new)
    graph_define = Shimada::GraphDefines[graph_define_name]
    option = option.dup.merge( {title: graph_define.title},[:body,:common] )
    day_graph_new(day_range,graph_define,option)
  end
end

