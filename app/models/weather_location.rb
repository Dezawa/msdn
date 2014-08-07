class WeatherLocation < ActiveRecord::Base
  extend Function::CsvIo
  def self.name_location
    all(:order =>"forecast_code").map{|wl| [wl.name,wl.location]}
  end

  def self.name_location_past
    all(:conditions => "weather_prec is not null",:order =>"forecast_code").
      map{|wl| [wl.name,wl.location]}
  end


end
