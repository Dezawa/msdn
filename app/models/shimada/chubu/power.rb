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
      dailydata_ary_of_hourly.each{ |_day,hour,pw| attrs[hour.to_sym] = pw  }
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

  def revise_by_vaper
    return @revise_by_vaper if @revise_by_vaper
    unless self.by_vaper01
      return [] unless weather

      x0,y0,p0,sll,slh = [:threshold,:y0,:power_0line, :slope_lower, :slope_higher ].
        map{ |sym| vaper_params_raw[sym]}

      vapers0 = (0..23).map{ |h|
        power = powers[h]
        vaper  = weather[Vapers[h]]
        logger.debug("Vapers #{vaper},#{Vapers[h]}")
         if power && vaper
           slp = vaper > vaper_params_raw[:threshold]  ? slh : sll
           power -  slp*(vaper-x0)*(power-p0)/(slp*(vaper-x0)+y0-p0)
         else power ? power : 0
         end
      }
      ByVapers.each{ |r|  self[r] = vapers0.shift}
      save
    end
    @revise_by_vaper = ByVapers.map{ |r| self[r]}
  end 

  # 12-18時の平均と分散を求め、 
  #   平均： deviation_of_difference,"差分の偏差"
  #   分散： :deviation_of_revice、電力偏差
  # その関係から平日稼働、平日稼働だが不安定、休日 を分ける
  #    line   稼働数：  休0   不1   平2
  def deviation_of_difference # 平均
    @deviation_of_difference ||= powers[11..17].average
  end

  def deviation_of_revice(range = 8..20 ) # 分散
    @deviation_of_revice ||= powers[11..17].standard_devitation 
  end

  # 分散 <20 平均 > 350
  def lines
    return @lines if @lines
    unless line
      lines = 
        case [deviation_of_revice <= 20.0 , deviation_of_difference > 350]
        when [true,true]   ; 2
        when [false,true]  ; 1
        else               ;0
        end
      update_attribute(:line , lines)
    end
    @lines = line
  end

  def shape_calc
    case [deviation_of_revice <= 20.0 , deviation_of_difference > 350]
    when [true,true]   ; 2
    when [false,true]  ; 1
    else               ;0
    end

  end


end
