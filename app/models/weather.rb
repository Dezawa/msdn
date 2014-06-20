# -*- coding: utf-8 -*-
require 'pp'

class Weather < ActiveRecord::Base
  Temperature = ("temp01".."temp24").to_a
  class << self
    def fetch(location,day)
      y,m,d = [day.year, day.month, day.day]
      temp = `/home/dezawa/bin/weather/weather_past.rb #{location} #{y} #{m} #{d}`
      weather = self.create( { :location => location,:date => day}.
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
