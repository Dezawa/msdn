class WeatherLocation < ActiveRecord::Base
  extend CsvIo
  def self.name_location
    order("forecast_code").map{|wl| [wl.name,wl.location]}
  end

  def self.name_location_past
    where("weather_prec is not null").order("forecast_code").
      map{|wl| [wl.name,wl.location]}
  end

  def self.with_vaper?(location) ; self.find_by(location: location).with_vaper? ;end

  def with_vaper? ; /^47\d{3}/ =~ self.weather_block ; end

end
