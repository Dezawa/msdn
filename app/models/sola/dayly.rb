# -*- coding: utf-8 -*-
require 'ondotori_recode_reader'
class Sola::Dayly < ActiveRecord::Base
  include Sola::Graph
  serialize :kws
  before_save :set_culc
  def self.load_trz(trz_file)

    ondotori = ondotori_load(trz_file)
    unless ondotori.base_name == "dezawa" && ondotori.channels["power01-電圧"] 
      #errors.add(:base_name,"dezawaのsolaの電力データではない" )
      return
    end
    times_values = times_values_group_by_day(ondotori.channels["power01-電圧"])
    times_values.each{ |day,time_values|
      find_or_create_and_save(day,time_values)
    }
  end

  def self.find_or_create_and_save(day,time_values)
    #dayly = self.find_or_create_by(:date => day){ |dly| dly.kws = [] }# || self.new(:date => day)
   dayly = self.find_by(:date => day) || self.new(:date => day)
    time_values.each{ |time,value| 
      min = (time.seconds_since_midnight/60).to_i
      dayly.kws ||= []
      dayly.kws[min] =   value 
    }
    dayly.save!
    dayly
  end

  def self.times_values_group_by_day(channel)
    channel.times.zip(channel.values).
      group_by{ |time,value| time.to_date }
  end

  # 1V = 10A → 1kW
  def self.ondotori_load(trz_file); OndotoriRecode.new(trz_file);end
  ("04".."20").each{ |h|  
    define_method("kwh#{h}") do
      min = h.to_i*60
      (min..min+59).inject(0.0){ |kw,m|  kw + (kws[m] || 0.0) }/60.0
      end
  }
  def kws_to_peak_kw ;     self.peak_kw = kws.compact.max ; end
  def kws_to_kwh_day
    self.kwh_day = 
      kws.inject(0.0){ |kwh,kw| kwh + (kw || 0.0) } /
      kws.compact.size * 24 # *60*24 / 60 
  end

  def update_monthly
    month = date.beginning_of_month
    monthly = Sola::Monthly.find_or_create_by(:month => month)# || Sola::Monthly.create(:month => month)
    monthly["kwh%02d"%date.day] = kwh_day
    monthly.save
   end

  private
  def set_culc
    self.month ||= date.beginning_of_month
    kws_to_peak_kw
    kws_to_kwh_day
    update_monthly
  end

end
