# -*- coding: utf-8 -*-
require "tempfile"
require 'statistics'
class Shimada::Chubu::Power < Shimada::Power
  self.table_name = "shimada_powers" # "shimada_power_by_30mins"
  belongs_to :month     ,:class_name => "Shimada::Month::Chubu"
  belongs_to :db_weather,:class_name => "Weather" 
  belongs_to :shimada_factory     ,:class_name => "Shimada::Factory"

  HrMin2Hour = Hash[*(0..23).to_a.map{ |h| h.to_s+":30" }.zip(Hours).flatten]
  

  PolyFitHour = (5 .. 23)  # 6時～23時
  PolyFitX0   = 14.0       # 15時
  PolyLevel   = 4

  class << self
    def create_month_and_powers_by_csvtable( csvtable ,factory)
      powers = create_by_csvtable( csvtable ,factory)
      month = powers.first.date.beginning_of_month
      shimada_month = Shimada::Chubu::Month.
        find_or_create_by(month: month ,shimada_factory_id: factory.id)
      shimada_month.shimada_powers = powers
    end
    def create_by_csvtable( csvtable ,factory)
      ary_of_date_hour_pw_group_by_date = # [ [[日、時刻、PW],[],,,[]],[ ],[ ],, [ ] ] 時刻分が日数分
        ary_of_date_hour_pw_group_by_date_by_csvtable( csvtable ,factory)
      powers = ary_of_date_hour_pw_group_by_date.map{ |dailydata_ary_of_hourly|
        create_by_ary_of_hourly_data(dailydata_ary_of_hourly,factory)
      }
    end

    def create_by_ary_of_hourly_data(dailydata_ary_of_hourly,factory)
      date  = dailydata_ary_of_hourly.first.first.to_date
      month = dailydata_ary_of_hourly.first.first.beginning_of_month.to_date
      power = self.find_or_create_by(date: date,shimada_factory_id:factory.id)
      attrs = { }
      dailydata_ary_of_hourly.each{ |day,hour,pw| attrs[hour.to_sym] = pw  }
      power.update(attrs)
      power
    end

    def  ary_of_date_hour_pw_group_by_date_by_csvtable( csvtable ,factory)
      idxDay,idxHour,idxPw = ["日付","開始時間","最大電力(kW)"].
        map{ |clmn| csvtable.headers.find_index(clmn)}
      csvtable.map{ |row| 
        logger.debug("ARY_OF_DATE_HOUR: row #{row}")
        day=Time.parse(row[idxDay])
        hhmm = row[idxHour]
        next unless hour = HrMin2Hour[hhmm]
#puts [ row[idxHour],hh,mm,"%02d"%hh.to_i , "%d"%(mm.to_i*10/60),hour].join(",")
        [day,hour,row[idxPw].to_f]
      }.compact.group_by{ |day_hour_pw| day_hour_pw.first }.values
    end
    def average_diff(factory_id);    end


  end
  def max_diff_from_average_difference;  end
  #Hours = (0..235).step(5).map{ |h| "hour%03d"%h}
  #def powers ; Hours.map{ |h| self[h]} ; end


end
