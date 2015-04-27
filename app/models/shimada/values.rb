# -*- coding: utf-8 -*-
class Shimada::Values
  include ActiveModel::Model
  #attr_reader :channels
  def initialize(factory_id_or_name,date)
    @factory_id =
      case factory_id_or_name
      when Integer ; factory_id_or_name
      when String ;
        if /^\d/  ; factory_id_or_name.to_i
        else
          Shimada::Factory.find_by(name: factory_id_or_name).id
        end
      end
    @date = date
  end

  def instruments
    @channels ||= Shimada::Instrument.where(factory_id: @factory_id).order(:id)
  end

  def daylies
    return @daylies if @daylies
    daylies = Shimada::Dayly.by_factory_id_order_instrument(@factory_id).where(date: @date)
    @daylies = Shimada::Dayly.instruments.map{|instrument|
      daylies.find_by(instrument_id: instrument.id,
                      measurement_type: instrument.measurement_type)
      }    
  end

  def self.by_factory_id(factory_id,date)
    new(Shimada::Dayly.by_factory_id(@factory_id).where(date: date))
  end
  def self.by_factory_name(factory_name,date)
    new(Shimada::Factory.where(name: factory_name))
  end
  
  def hours
      daylies.map{|dayly| dayly ? dayly.converted_value_hourly : [nil]*24}.transpose
  end

  ("00".."23").each{|h|
    define_method("hour_html#{h}") do 
      hours[h.to_i].map{|v| v ? "%.2f"%v : ""}.join("<br>")
    end
  }
  def hour_html0888
    hours[8].map{|v| v ? "%.2f"%v : ""}.join("<br>")
  end
end
