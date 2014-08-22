# -*- coding: utf-8 -*-
module Power::Month
  include ExcelToCsv
  module ClassMethods

    def csv_upload(file)
      csvfiles = csv_files(file)
      csvfiles.each{ |csvfile|  create_month_by(csvfile) }
      Shimada::Power.delete_all("hour01 = '0.0'")
    end

    def  create_month_by(csvfile)
      lines = File.read(csvfile).split(/[\r\n]+/)
      while create_one_month_by(lines);end
    end

    def  create_one_month_by(lines)
      year_month = search_year_month(lines)
      return nil unless year_month
      data_clm,days =search_monthdate(lines)
      
      lastday = year_month.end_of_month.day
      days = (0..lastday-1).map{ |d| year_month + d }

      skip_untile_first_data_line(lines)
      month_data = read_month_data(lines)

      month = self.find_or_create_by_month(year_month)
      powers = days.map{ |day| 
        day_data = month_data.shift
logger.debug("CREATE_ONE_MONTH_BY: #{day_data.first}")
        next unless day_data && day_data.first.to_f > 0
        power = self.power_model.find_or_create_by_date( day)
        power.update_by_day_data(day_data)
        power
        }.compact
      month.powers = powers
    end

    def read_month_data(lines)
      month_lines = lines.shift(24).map{ |l| l.split(",")}.transpose
      raise unless /24:/ =~ month_lines.shift[23]
      month_lines
    end

    def search_monthdate(lines)
      line=lines.shift
      until /1日/ =~ line; line=lines.shift ;end
      clms = line.split(",")
      first_day_clm = clms.index{ |clm| /1日/ =~ clm }
      [first_day_clm-1,clms[first_day_clm..-1].map{ |d| d.sub(/日.*/,"")}]
    end

    def skip_untile_first_data_line(lines)
      line=nil
      until /01:/ =~ line; line=lines.shift ;end
      lines.unshift(line)
      line
    end
  end
  def self.included(base)
    base.extend ClassMethods

  end
end
