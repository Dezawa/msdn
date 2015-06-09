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
    assert_equal ["予報",
                  [["2015-04-23 03:00", 13.3, 96.0, 14.6755], ["2015-04-23 06:00", 13.1, 96.0, 14.485], ["2015-04-23 09:00", 18.6, 69.0, 14.8019], ["2015-04-23 12:00", 23.5, 36.0, 10.4355], ["2015-04-23 15:00", 24.3, 29.0, 8.8204], ["2015-04-23 18:00", 22.3, 46.0, 12.3995], ["2015-04-23 21:00", 16.4, 87.0, 16.2424], ["2015-04-24 00:00", 14.3, 88.0, 14.3562]]], data_list[0]

  end
end
