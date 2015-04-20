# -*- coding: utf-8 -*-
require 'ondotori'
require 'ondotori/converter'
require 'ondotori/recode'
require "vaper"
require "pp"
class Shimada::Dayly < ActiveRecord::Base
  include Tand
  extend Tand::ClassMethod
  
  serialize :measurement_value
  serialize :converted_value

  belongs_to :instrument , :class_name => "Shimada::Instrument"

  before_save  :set_attrs, :convert

  def self.instrument ; Shimada::Instrument ;end
  def self.valid_trz(ondotori)
    ondotori.base_name == "dezawa" && ondotori.channels["power01-電圧"] ||
      ondotori.base_name == "中部" &&
      ( ["フリーザーA-温度","フリーザーA-湿度"] &  ondotori.channels.keys).size > 0
  end
  
  def self.channel_and_attr
    [["フリーザーA-温度",:measurement_value],["フリーザーA-湿度",:measurement_value],
     ["power01-電圧",:measurement_value]
    ]
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
      find_by(date: date,serial: serial,measurement_type: 13)
    return unless temperature
    temperature.measurement_value.map.with_index{|temp,idx|
      if temp && measurement_value[idx]
        Vaper.pressure(measurement_value[idx],temp)
      end
    }        
  end
  
  # base_name ch_name 
  def set_attrs
   # month = date.to_time.beginning_of_month.to_date
   # base
  end
end
