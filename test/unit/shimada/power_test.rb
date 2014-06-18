# -*- coding: utf-8 -*-
require 'test_helper'

class ShimadaPowerTest < ActiveSupport::TestCase

  fixtures :shimada_powers

  must "データ数" do
    assert_equal 28*2 + 31*2,Shimada::Power.all.size
  end

  must "gnuplot_data するとtmpfileができる" do
    power = Shimada::Power.find 1
    path = power.gnuplot_data
    require =
"時刻 電力\n1 384.000000\n2 330.000000\n3 303.000000\n4 386.000000\n5 442.000000\n6 559.000000\n7 575.000000\n8 598.000000\n9 619.000000\n10 602.000000\n11 626.000000\n12 624.000000\n13 620.000000\n14 636.000000\n15 647.000000\n16 621.000000\n17 630.000000\n18 622.000000\n19 603.000000\n20 623.000000\n21 618.000000\n22 586.000000\n23 576.000000\n24 505.000000\n"
puts require
    assert_equal require,File.read(path)
  end

  must "複数のpowerで gnuplot_data するとtmpfileは 1+24*日数 行できる" do
    powers = Shimada::Power.find(1,4,10)
    path = Shimada::Power.gnuplot_data(powers)
    lines = File.read path
    assert_equal 1+3*24,lines.split(/\n+/).size
  end

  must "複数のpowerで gnuplot するとgifができる" do
    powers = Shimada::Power.find(1,4,10)
    path = Shimada::Power.gnuplot(powers)
  end
end
