# -*- coding: utf-8 -*-
require 'ondotori_recode_reader'
class Sola::Dayly < ActiveRecord::Base
  serialize :kws
  before_save :set_culc
  def self.load_trz(trz_file)

    ondotori = ondotori_load(trz_file) #OndotoriRecode.new(trz_file)
#pp [trz_file,ondotori.base_name,ondotori.channels["power01-電圧"].class]
    unless ondotori.base_name == "dezawa" && ondotori.channels["power01-電圧"] 
      #errors.add(:base_name,"dezawaのsolaの電力データではない" )
#pp ["dezawaのsolaの電力データではない",ondotori.base_name,ondotori.channels["power01-電圧"].class]
      return
    end
    times_values = times_values_group_by_day(ondotori.channels["power01-電圧"])
    times_values.each{ |day,time_values|
      find_or_create_and_save(day,time_values)
    }
  end

  def self.find_or_create_and_save(day,time_values)
    #pp ["find_or_create_and_save",day,time_values.first,time_values.last]
    dayly = self.find_by(:date => day) || self.new(:date => day)
    #pp time_values.size
    time_values.each{ |time,value| 
      min = (time.seconds_since_midnight/60).to_i
      dayly.kws ||= []
      dayly.kws[min] =   value 
      #pp [day,min,dayly.kws[min]] if min == 731
    }
    dayly.save!
    #pp dayly.kws[731]
    dayly
  end

  def self.times_values_group_by_day(channel)
    channel.times.zip(channel.values).
      group_by{ |time,value| time.to_date }
  end

  def self.ondotori_load(trz_file); OndotoriRecode.new(trz_file);end


  ("06".."18").each{ |h|  
    define_method("kwh#{h}") do
      min = h.to_i*60
      (min..min+59).inject(0.0){ |kw,m|  kw + (kws[m] || 0.0) }
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
    monthly = Sola::Monthly.find_or_create_by(:month => month){ |monthly|
      monthly["kwh%02d"%date.day] = kwh_day
      monthly.save
    }
  end

  private
  def set_culc
    self.month ||= date.beginning_of_month
    kws_to_peak_kw
    kws_to_kwh_day
    update_monthly
  end

end
