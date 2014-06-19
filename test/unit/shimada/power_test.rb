# -*- coding: utf-8 -*-
require 'test_helper'

class ShimadaPowerTest < ActiveSupport::TestCase

  fixtures :shimada_powers

  must "データ数" do
    assert_equal 28*2 + 31*2,Shimada::Power.all.size
  end

  must "複数のpowerで gnuplot_data するとtmpfileは 1+24*日数 行できる" do
    powers = Shimada::Power.find(1,4,10)
    path = Shimada::Power.gnuplot_data(powers)
    lines = File.read path
    assert_equal 1+3*24,lines.split(/\n+/).size
  end

  must "複数のpowerで gnuplot するとgifができる" do
    powers = Shimada::Power.find(1,4,10)
    path   = Shimada::Power.gnuplot(powers)
  end

  must "Id=1 の最大値群とその平均は" do
    powers = Shimada::Power.find(1)
    assert_equal [632.6,[624.0, 626.0, 630.0, 636.0, 647.0]],
    [powers.max_ave(5) ,powers.max_powers(5)]
  end

  must "Id=1 の正規化 " do
    powers = Shimada::Power.find(1)
    assert_equal [0.98957, 0.98641, 0.98008,1.00537, 1.02276],
    powers.normalized(5)[10,5].map{ |p| p.round(5)}
  end

  must "Id=1 の移動平均 " do
    powers = Shimada::Power.find(1)
    assert_equal 618.2, powers.move_ave(5)[10]
    assert_equal 339.0, powers.move_ave(5)[0]
    assert_equal 571.25, powers.move_ave(5)[22]
  end 

end
