# -*- coding: utf-8 -*-
require 'test_helper'

class ForecastTest < ActiveSupport::TestCase

Maebashi = 
"20.0	19.0	22.0	94
27.6	17.2	19.6	53
23.1	21.2	25.2	89
10.8	0.0	6.1	47
4.5	0.8	6.5	77
25.7	23.2	28.4	86
-2.6	-11.3	2.6	51
".split(/[\n\r]+/).map{ |l| l.split.map(&:to_f)}

  def setup
    @forecast = Forecast.new
    @lines    = File.read(RAILS_ROOT+"/test/testdata/forecast_tenki").split(/[\n\r]+/)
    @excite   = File.read(RAILS_ROOT+"/test/testdata/forecast_excite").split(/[\n\r]+/)
  end

  must "Maebashi =" do
    Maebashi.each{ |tdvp| temp,dew,vaper,humi = tdvp
      assert_equal vaper,@forecast.vaper_presser(temp,humi).round(1),"#{tdvp.join(',')}"
    }
  end


  must "天気.jp アナウンス日 Excite" do
    assert_equal Time.local(2014,7,27,12,00),Forecast.announce_datetime_excite(@excite)
  end

  must "天気.jp 今日の日付 Excite" do
    Forecast.announce_datetime_excite(@excite)
    assert_equal Date.new(2014,7,27),Forecast.today_is_excite(@excite)
  end

  must "天気.jp アナウンス日" do
    assert_equal Time.local(2014,7,26,7,0),Forecast.announce_datetime(@lines)
  end
  must "天気.jp 今日、明日の日付" do
    Forecast.announce_datetime(@lines)
    assert_equal Date.new(2014,7,26),Forecast.today_is(@lines)
    assert_equal Date.new(2014,7,27),Forecast.tomorrow_is(@lines)
  end
  must "天気.jp 雨" do
    Forecast.announce_datetime(@lines)
    Forecast.today_is(@lines)
    Forecast.tomorrow_is(@lines)
    Forecast.hour_lines(@lines)
    assert_equal %w(曇り 曇り 曇り 晴れ 晴れ 晴れ 晴れ 晴れ
                    晴れ 晴れ 晴れ 晴れ 曇り 晴れ 晴れ 晴れ),Forecast.rain_rank(@lines)
  end
  must "天気.jp 気温" do
    Forecast.announce_datetime(@lines)
    Forecast.today_is(@lines)
    Forecast.tomorrow_is(@lines)
    Forecast.hour_lines(@lines)
    Forecast.rain_rank(@lines)
    assert_equal [26.9, 26.4, 27.8, 34.2, 36.3, 33.4, 30.4, 28.3,
                  26.9, 26.1, 30.2, 35.0, 34.6, 31.8, 28.8, 26.4],Forecast.temperaures(@lines)
  end

#  must "Tommow data " do
#    today = Time.now.to_date
#    tomorrow = today + 1
#    assert_equal nil,Forecast.find_by_location_and_date_and_announce_day(:maebashi.to_s,tomorrow,today )
#    Forecast.fetch(:maebashi,tomorrow)
#    tomorrow_fore = Forecast.find_by_location_and_date_and_announce_day(:maebashi.to_s,tomorrow,today )
#    assert_equal Time.now,tomorrow_fore.announce
#  end
end
__END__
