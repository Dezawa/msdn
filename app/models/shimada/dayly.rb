# -*- coding: utf-8 -*-
require 'ondotori'
require 'ondotori/converter'
require 'ondotori/recode'
require "vaper"
require "statistics"
require "pp"

class Shimada::Dayly < ActiveRecord::Base
  module Temp
    def time_and_converted_value
      objects = self.class.where( serial: serial, date: date).order(:ch_name_type)
      objects[0].time_values("%Y-%m-%d %H:%M").
        zip(objects[0].converted_value,
            objects[1].measurement_value,
            objects[1].converted_value)
    end 
  end
  
  delegate :logger, :to=>"ActiveRecord::Base"
  include Tand
  
  serialize :measurement_value
  serialize :converted_value

  belongs_to :instrument , :class_name => "Shimada::Instrument"

  before_save  :set_attrs, :convert

  def self.instrument ; Shimada::Instrument ;end
  def self.instruments ; @instruments ||= Shimada::Instrument.all.order(:id) ;end
  def self.serials     ; @serials ||=  instruments.map(&:serial)                 ;end
  
  def self.valid_trz(ondotori)
    (serials & ondotori.channels.values.map(&:serial)).size>0
  end
  
  def self.channel_and_attr
    [["フリーザーA-温度",:measurement_value],["フリーザーA-湿度",:measurement_value],
     ["1F休憩所-温度",:measurement_value],["1F休憩所-湿度",:measurement_value],
     ["power01-電圧",:measurement_value]
    ]
  end

  scope :by_factory_name, -> factory_name {
    joins(:instrument).merge(Shimada::Instrument.by_factory_name(factory_name)).order(:date)
  }
  scope :by_factory_id, -> factory_id {
    joins(:instrument).merge(Shimada::Instrument.by_factory_id(factory_id)).order(:date)
  }
  
  scope :by_factory_id_order_instrument, -> factory_id {
    joins(:instrument).merge(Shimada::Instrument.by_factory_id(factory_id)).
      order(:date,"shimada_instruments.id")
  }
  scope :by_factory_id_and_instrument_serial, -> (factory_id,serials) {
    joins(:instrument).merge(Shimada::Instrument.by_factory_id_and_serial(factory_id,serials))
  }
  
  def self.by_factory(factory_name)
    factory_id = Shimada::Factory.find_by(name: factory_name).id
    by_factory_id(factory_id)
  end


  def time_values(fmt=nil)
    date0 = date.to_time
    unless fmt ;(0..3600*24-1).step(interval).map{|t| date0+t}
    else       ;(0..3600*24-1).step(interval).map{|t| (date0+t).strftime(fmt)}
    end
  end
  
  def convert
    self.converted_value =
    case self.instrument.converter
    when 0  ; measurement_value.dup
    when 1  ; measurement_value.map{|value| value && instrument.slope * value + instrument.graft}
    when  2 ; vaper_pressure        
    when 9  ;
    end
  end

  def vaper_pressure
    temperature = Shimada::Dayly.
      find_by(date: date,serial: serial,measurement_type: Ondotori::TypeNameHash["温度"])
    return unless temperature
    temperature.measurement_value.map.with_index{|temp,idx|
      if temp && measurement_value[idx]
        Vaper.pressure(measurement_value[idx],temp)
      end
    }        
  end

  def time_and_converted_value_with_vaper
    if temperature?
      objects = self.class.where( serial: serial, date: date).order(:ch_name_type)
      objects[0].time_values("%Y-%m-%d %H:%M").
        zip(objects[0].converted_value,
            objects[1].measurement_value,
            objects[1].converted_value)
    else
      nil
    end
  end
  
  def time_and_converted_value
    time_values("%Y-%m-%d %H:%M").zip(converted_value)
  end
  
  ### temp_humidity_vaper
  def converted_value_hourly
    (converted_value.each_slice(3600/interval).
     map{|values| vals= values.compact ; vals.average.round(2) unless vals.empty? } +
     [nil]*24
    )[0,24]
  end
  
  ("00".."23").each_with_index{ |h,idx|
    define_method("hourly#{h}".to_sym){  converted_value_hourly[idx] }
  }
  
  # base_name ch_name 
  def set_attrs
   # month = date.to_time.beginning_of_month.to_date
   # base
  end

  def temperature?
    self[:measurement_type] == Ondotori::TypeNameHash["温度"]
  end
    # pp "Shimada::Dayly initialize #{measurement_type}"
end
