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
  end

  must "Maebashi =" do
    Maebashi.each{ |tdvp| temp,dew,vaper,humi = tdvp
      assert_equal vaper,@forecast.vaper_presser(temp,humi).round(1),"#{tdvp.join(',')}"
    }
  end
end
__END__
気温	露点           蒸気圧        湿度
(hPa)	湿度
20.0	19.0	22.0	94
27.6	17.2	19.6	53
23.1	21.2	25.2	89
10.8	0.0	6.1	47	6.6
4.5	0.8	6.5	77
25.7	23.2	28.4	86
-2.6	-11.3	2.6	51
