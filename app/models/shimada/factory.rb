# -*- coding: utf-8 -*-
#Shimada::PowerModels = [Shimada::Power,Shimada::PowerBy_30min] # power_model_idで探す
Shimada::PowerModels = [Shimada::Power,Shimada::Power] # power_model_idで探す
Shimada::MonthModels = [Shimada::Month,Shimada::Chubu::Month]  # power_model_idで探す
Shimada::TimeOffset  = [2,4]
class Shimada::Factory < ActiveRecord::Base
  extend CsvIo
  has_many :shimada_powers ,:class_name =>  "Shimada::Power"
  has_many :shimada_instruments,:class_name =>  "Shimada::Instrument"

  def today_graph(graph_type)
    today = Time.now.to_date
    today = Date.new(2015,4,23)
    opt = {time_range:  :dayly,graph_file: "#{graph_type}_#{id}"}
    daylies =
    case graph_type.to_s
    when "temp_vaper_power"
      Shimada::Dayly.by_factory_id(id).where(date: today)
    when "temp_hyum"
      Shimada::Dayly.by_factory_id_order_instrument(id).
      where(date: today,measurement_type: Ondotori::TypeNameHash["温度"])
    end
    if daylies && daylies.size>0
      Shimada::Graph.create( graph_type.to_s,daylies,opt).plot
    end
  end
end

