require 'csv'
module Shimada::GMC
end

module Shimada::Chubu
#puts "Shimada::Chubu"
    def csv_upload(file)
    end

    def  create_one_month_by(lines)
      #:first_row
      year = search_year(lines)
      return nil unless year

      data_clm,days =search_monthdate(lines)
      
      lastday = Date.new(year,*days.first.split("/").map(&:to_i)).end_of_month.day
      days = days[0,lastday].map{ |d| Date.new(year,*d.split("/").map(&:to_i))}
      skip_untile_first_data_line(lines)
      
      month = self.find_or_create_by(month: days.first)
      powers = days.map{ |day| Shimada::Power.find_or_create_by(date:  day) }
      set_power(powers,lines)
      month.shimada_powers = powers
    end

end

