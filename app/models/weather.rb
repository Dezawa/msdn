# -*- coding: utf-8 -*-
require 'pp'

class Weather < ActiveRecord::Base
  Temperature = ("hour01".."hour24").to_a
  class << self
    def fetch(location,day)
      y,m,d = [day.year, day.month, day.day]
      temp = `/usr/local/bin/weather_past.rb #{location} #{y} #{m} #{d}`
      logger.info("WEATHER:: #{temp.class}")
      return unless temp
pp day.beginning_of_month
      weather = self.create( { :location => location,:date => day,:month => day.beginning_of_month}.
                             merge(Hash[*Temperature.zip(temp.split(/\s+/)).flatten]))
    end

    def find_or_feach(location,day)
      weather = find_by_location_and_date(location,day)
      return weather if weather
      fetch(location,day)
    end
  end

  def temperatures ;   Temperature.map{ |t| self[t]} ; end

end
__END__
s = Time.local(2014,6,1).beginning_of_day
e = Time.local(2014,6,26).beginning_of_day
date = s
  Weather.fetch("maebashi",date)
while date <= e
  Weather.fetch("maebashi",date)
  date = date.tomorrow
p date
end

