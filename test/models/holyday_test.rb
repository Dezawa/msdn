# -*- coding: utf-8 -*-
require 'test_helper'

class HolydayTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  must "西暦年数の4での剰余が0の場合 2092年 - 2096年 3/19" do
    assert_equal [19]*2 ,(2092..2096).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が0の場合 1960年 - 2088年 3/20" do
    assert_equal [20]*23 ,(2000..2088).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が1の場合 1993年 - 2097年までは3月20日" do
    assert_equal [20]*23,(2001..2089).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が2の場合 1902年 - 2022年までは3月21日" do
    assert_equal [21]*6  ,(2002..2022).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が2の場合 2026年 - 2098年までは3月20日" do
    assert_equal [20]*19 ,(2026..2098).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が3の場合 1927年 - 2055年までは3月21日" do
    assert_equal [21]*14 ,(2003..2055).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が3の場合 　2059年 - 2099年までは3月20日" do
    assert_equal [20]*11 ,(2059..2099).step(4).to_a.map{ |year| Holyday.vernal_equinox_day(year).day}
  end
  ##########
  must "西暦年数の4での剰余が0の場合 2012年 - 2096年 9/22" do
    assert_equal [22]*22,(2012..2096).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が0の場合 1900年 - 2008年 9/23" do
    assert_equal [23]*3  ,(2000..2008).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が1の場合 1921年 - 2041年までは9月23日" do
    assert_equal [23]*11,(2001..2041).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が1の場合 2045年 - 2097年までは9月22日" do
    assert_equal [22]*14,(2045..2097).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が2の場合 1902年 - 2074年までは9月23日" do
    assert_equal [23]*19 ,(2002..2074).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が2の場合 2078年 - 2098年までは9月22日" do
    assert_equal [22]*6  ,(2078..2098).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
  must "西暦年数の4での剰余が3の場合 1983年 - 2099年までは9月23日" do
    assert_equal [23]*25 ,(2003..2099).step(4).to_a.map{ |year| Holyday.autumnal_equinox_day(year).day}
  end
end
__END__
春分の日
西暦年数の4での剰余が0の場合
　　1900年 - 1956年までは3月21日
　　1960年 - 2088年までは3月20日
　　2092年 - 2096年までは3月19日
西暦年数の4での剰余が1の場合
　　1901年 - 1989年までは3月21日
　　1993年 - 2097年までは3月20日
西暦年数の4での剰余が2の場合
　　1902年 - 2022年までは3月21日
　　2026年 - 2098年までは3月20日
西暦年数の4での剰余が3の場合
　　1903年 - 1923年までは3月22日
　　1927年 - 2055年までは3月21日
　　2059年 - 2099年までは3月20日 [1]

秋分の日の数学的な簡易な求め方

    西暦年数の4での剰余が0の場合
        1900年 - 2008年までは9月23日
        2012年 - 2096年までは9月22日
    西暦年数の4での剰余が1の場合
        1901年 - 1917年までは9月24日
        1921年 - 2041年までは9月23日
        2045年 - 2097年までは9月22日
    西暦年数の4での剰余が2の場合
        1902年 - 1946年までは9月24日
        1950年 - 2074年までは9月23日
        2078年 - 2098年までは9月22日
    西暦年数の4での剰余が3の場合
        1903年 - 1979年までは9月24日
        1983年 - 2099年までは9月23日
