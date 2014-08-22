# -*- coding: utf-8 -*-
class Power::UbeHospital::Month < ActiveRecord::Base
  extend ExcelToCsv
  include Power::Month
  set_table_name 'power_ube_hospital_months'
  has_many :powers ,:class_name =>  "Power::UbeHospital::Power" ,
           :dependent => :delete_all

  class << self
    def power_model ;   Power::UbeHospital::Power ;end


    def search_year_month(lines)
      line=lines.shift
      until /平成(\d\d)年([01]\d)月分/ =~ line
        line=lines.shift 
        return nil unless line
      end
      Time.local($1.to_i+2000-12,$2.to_i).to_date.beginning_of_month
    end

    def set_power(powers,lines)
      Shimada::Power::Hours.each_with_index{ |hour,idx|
        clms = (line = lines.shift).split(",")
        raise RuntimeError,"時刻が合わない: #{line}" if idx+1 != clms.shift.to_i
        powers.each{ |power| power[hour] = clms.shift.to_f }
      }
         line=lines.shift until /袋数/ =~ line
logger.debug("SET_POWER:#{line}")
      clms = line.split(",")
      clms.shift
      powers.each{ |power| power[:hukurosu] = clms.shift.to_f ;power.save}
    end

  end
end
