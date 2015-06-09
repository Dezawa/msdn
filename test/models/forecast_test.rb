# -*- coding: utf-8 -*-
require 'test_helper'

class ForecastTest < ActiveSupport::TestCase
  fixtures :forecasts,:weathers
  def setup
    @date = "2015-4-23"
    @peirod = "2015-4-22"..@date
    @location = "gifu"
  end
  
  must "rangeの前後が同じで読み込む" do
    pp @peirod 
    forecast = Forecast.daylies_period(@location,@date..@date)
    assert_equal 1, forecast.size
  end
  
  must "2015-4-23を日付をdateで読み込む" do
    forecast = Forecast.daylies_period(@location,@date)
    assert_equal 1, forecast.size
  end

  must "Weatherもよむ" do
    weather = Weather.where( location: @location, date: @date)
    assert_equal 1, weather.size
  end
  
  must "Weatherの:temperature,:humidity,:vaper" do
    weather = Weather.where( location: @location, date: @date).first
    assert_equal [14.7, 14.4], weather.temperature[0,2]
    assert_equal [90.0, 91.0], weather.humidity[0,2]
    assert_equal [15.1, 14.9], weather.vaper[0,2]
  end
  
  must "Forecastの:temperature,:humidity,:vaper" do
    forecast = Forecast.daylies_period(@location,@date).first
    assert_equal [13.3, 13.1], forecast.temperature[0,2]
    assert_equal [96.0, 96.0], forecast.humidity[0,2]
    assert_equal [14.7, 14.5], forecast.vaper[0,2].map{|v| v.round(1)}
  end

  must "array_of_models_to_data_list" do
    forecast = Forecast.daylies_period(@location,@date)
    weather = Weather.where( location: @location, date: @date)
    data_list =
      Graph::TempHumidity.array_of_models_to_data_list([forecast,weather])
    assert_equal [], data_list[0]

  end
end
