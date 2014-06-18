# -*- coding: utf-8 -*-
class Shimada::Month < ActiveRecord::Base
  extend ExcelToCsv
  
  set_table_name 'shimada_months'
  has_many :shimada_powers ,:class_name =>  "Shimada::Power"

  def powers
    @powers ||= shimada_powers.sort_by{ |p| p.date }
  end

  class << self

    def csv_upload(file)
      csv_files(file).each{ |csvfile|  create_month_by(csvfile) }
    end

    def  create_month_by(csvfile)
      lines = File.read(csvfile).split(/[\r\n]+/)
      while create_one_month_by(lines);end
    end

    def  create_one_month_by(lines)
      year = search_year(lines)
      return nil unless year

      data_clm,days =search_monthdate(lines)
      
      lastday = Date.new(year,*days.first.split("/").map(&:to_i)).end_of_month.day
      days = days[0,lastday].map{ |d| Date.new(year,*d.split("/").map(&:to_i))}
      skip_untile_first_data_line(lines)
      
      month = self.create(:month => days.first)
      powers = days.map{ |day| Shimada::Power.create(:date => day) }
      set_power(powers,lines)
      month.shimada_powers = powers
    end

    def search_year(lines)
      line=lines.shift
      until /^,?(201\d)/ =~ line
        line=lines.shift 
        return nil unless line
      end
      $1.to_i
    end

    def search_monthdate(lines)
      line=lines.shift
      until /月日/ =~ line; line=lines.shift ;end
      clms = line.split(",")
      hour_clm = clms.index("月日")
      [hour_clm,clms[hour_clm+1..-1]]
    end

    def skip_untile_first_data_line(lines)
      line=lines.shift
      until /時間/ =~ line; line=lines.shift ;end
    end


    def set_power(powers,lines)
      Shimada::Power::Hours.each_with_index{ |hour,idx|
        clms = lines.shift.split(",")
        raise RuntimeError,"時刻が合わない" if idx+1 != clms.shift.to_i
        powers.each{ |power| power[hour] = clms.shift.to_f }
      }
    end



end
end
