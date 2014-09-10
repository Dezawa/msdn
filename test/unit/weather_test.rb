# -*- coding: utf-8 -*-
require 'test_helper'

class WeatherTest < ActiveSupport::TestCase
  Maebashi = "maebashi"
  Day = Date.new(2014,5,1)
  must "前橋 2014/5/1 2時の気温はデータがない" do
    weather = Weather.find_by_location_and_date(Maebashi,Day)
    assert_equal nil,weather
  end

  must "前橋 2014/5/1の気温データを取り込む" do
    "16.3 16.2 16.4 16.5 16.4 16.4 16.4 17.0 19.3 20.1 22.4 23.8 25.1 25.1 "+
      "17.9 21.5 20.8 19.8 18.9 18.2 17.6 17.0 16.4 15.3"
    weather = Weather.fetch(Maebashi,Day)
    assert_equal 16.2 , weather.hour02
  end
  must "前橋 2014/5/1 2時の気温はデータがないときは取得してDBに取り込む" do
    weather = Weather.find_by_location_and_date(Maebashi,Day)
    assert_equal nil,weather
    weather = Weather.find_or_feach(Maebashi,Day)
    assert_equal 16.2,weather.hour02
  end
end
