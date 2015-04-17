# -*- coding: utf-8 -*-
require 'ondotori'
require 'ondotori/converter'
require 'ondotori/recode'
require 'statistics'
require "csv"
# 月    日                     kW分のmax ΣkW分  モニターでの一日発電   毎分の電力
# month date base_name ch_name peak_kw   kwh_day :kwh_monitor           kws
class Sola::Dayly < ActiveRecord::Base
  include Sola::Graph
  extend Statistics
  include Tand
  extend Tand::ClassMethod
#include Statistics
  serialize :kws
  serialize :volts
  before_save :set_culc
#select max(peak_kw) sola_daylies,month from sola_daylies group by month;
#select max(peak_kw) max_peak,month from sola_daylies group by month;

  def self.oldload_trz(trz_file)
    ondotori = Ondotori::Recode.new(trz_file) # ondotori_load(trz_file)
    load_ondotori(ondotori)
  end

  def self.load_ondotori(ondotori)
    unless ondotori.base_name == "dezawa" && ondotori.channels["power01-電圧"] 
      #errors.add(:base_name,"dezawaのsolaの電力データではない" )
      return
    end
    logger.info("ONDOTORI:: slope #{ondotori.channels["power01-電圧"].slope} + graft #{ondotori.channels["power01-電圧"].graft}")
    times_values = times_values_group_by_day(ondotori.channels["power01-電圧"])
    times_values.each{ |day,time_values|
      find_or_create_and_save(day,time_values)
    }
  end

  def self.ondotori_load(trz_file)#Ondotori::Recode.new(trz_file)#
    file_or_xmlstring = case trz_file.class
                        when String ; trz_file
                        when ActionDispatch::Http::UploadedFile 
                          trz_file.read
                        else ; 
                          trz_file.read
                        end

    load_ondotori Ondotori::Recode.new(file_or_xmlstring)
  end

  def self.find_or_create_and_save(day,time_values)
    #dayly = self.find_or_create_by(:date => day){ |dly| dly.kws = [] }# || self.new(:date => day)
    dayly = self.find_by(:date => day) || self.new(:date => day)
    dayly.volts ||= []
    time_values.each{ |time,value| 
      min = (time.seconds_since_midnight/60).to_i
      dayly.volts[min] = value 
      # dayly.kws ||= []
      # dayly.kws[min] =   value 
    }
    #dayly.volts2kws
    dayly.save
    dayly
  end

  def self.times_values_group_by_day(channel)
    channel.times.zip(channel.values). #.map{ |v| scale(v)}).
      group_by{ |time,value| time.to_date }
  end

  def self.ondotori_load(trz_file)#Ondotori::Recode.new(trz_file)#
    file_or_xmlstring = case trz_file.class
                        when String ; trz_file
                        when ActionDispatch::Http::UploadedFile 
                          trz_file.read
                        else ; 
                          trz_file.read
                        end

    Ondotori::Recode.new(file_or_xmlstring)
  end


  def self.monthly_peak(month)
    models = self.where(month: month).select("max(peak_kw) peak").first.peak
    multiple_regression(models)
  end

  def self.csv_out_monitor(filename, csv_labels,csv_atrs)
    daylies = self.all.order(:date).pluck(:month,:date,:kwh_monitor).
      group_by{ |month,date,kwh_monitor| month}
    CSV.open(filename, "wb") do |csv|
      csv << csv_labels
      daylies.each{ |month,values| csv << csv_row(month,values) }
    end
    filename
  end

  def self.csv_row(month,values)
    ret = []
    ret << month.strftime("%Y-%m-%d")
    values.each{ |month,date,kwh_monitor|  ret[date.day] = kwh_monitor  }
    ret
  end

  def self.csv_update_monitor(csvfile,labels,columns0,option={ })
    condition = option.delete(:condition) || true
    #CSV.parse(NKF.nkf("-w",csvfile.read),:headers => true){ |row|
    CSV.parse(csvfile.read,:headers => true){ |row|
      month = Time.parse( row["month"])
      ("01".."31").each_with_index{ |day,idx| clmn = "kwh#{day}"
        next unless row[clmn]
        date = month + idx.day
        dayly = self.find_by(date: date.to_date) || self.new(date: date, month: month.to_date)
       # dayly = Sola::Dayly.find_by(date: date.to_date) || Sola::Dayly.new(date: date, month: month.to_date)
        dayly.kwh_monitor = row[clmn].to_f
        dayly.save
      }
    }
[]
  end

  ("04".."20").each{ |h|  
    define_method("kwh#{h}") do
      min = h.to_i*60
      (min..min+59).inject(0.0){ |kw,m|  kw + (kws[m] || 0.0) }/60.0
      end
  }
  def kws_to_peak_kw ; self.peak_kw = kws.compact.max if kws ; end
  def volt_peak
    self.volts ? self.volts.compact.max : nil
  end

  def kws_to_kwh_day
    return unless self.kws
    self.kwh_day = 
      self.kws[4*60..19*60].inject(0.0){ |kwh,kw| kwh + (kw || 0.0) } /
      self.kws[4*60 , 14*60].size * 14 # *60*24 / 60 
  end

  def update_monthly
    month = date.beginning_of_month
    #monthly = Sola::Monthly.find_or_create_by(:month => month)# || Sola::Monthly.create(:month => month)
    monthly["kwh%02d"%date.day] = kwh_day
    monthly.save
   end

  def scale(v) ; Sola::Scale[0] * v + Sola::Scale[1] ;end

  def volts2kws
    return unless self.volts
    self.kws ||= []
    if date == Date.new(2015,2,9) #.strftime("%Y%m%d") == "20150209"
      self.volts.each_with_index{ |v,idx| self.kws[idx] = (v ? (v*0.9) : nil)}
    else
      self.volts.each_with_index{ |v,idx| self.kws[idx] = (v ? scale(v) : nil)}
    end
  end

  private

  def set_culc
    self.month ||= date.beginning_of_month
    volts2kws
    kws_to_peak_kw
    kws_to_kwh_day
    #update_monthly
  end

end
