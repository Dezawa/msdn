# -*- coding: utf-8 -*-
require 'test_helper'

class ShimadaPowerTest < ActiveSupport::TestCase

  fixtures :shimada_powers

  must "データ数" do
    assert_equal 28*2 + 31*2,Shimada::Power.all.size
  end

  must "複数のpowerで gnuplot_data するとtmpfileは 1+24*日数 行できる" do
    powers = Shimada::Power.find(1,4,10)
    path = Shimada::Power.gnuplot_data(powers.map{ |p| p.powers })
    lines = File.read path
    assert_equal 1+3*24,lines.split(/\n+/).size
  end

  must "複数のpowerで gnuplot するとgifができる" do
    powers = Shimada::Power.find(1,4,10)
    path   = Shimada::Power.gnuplot(powers.map{ |p| p.powers })
  end

  must "Id=1 の最大値群は" do
    powers = Shimada::Power.find(1)
    assert_equal [624.0, 626.0, 630.0, 636.0, 647.0], powers.max_powers(5)
  end

  must "Id=1 の移動平均 最大値群の平均は" do
    powers = Shimada::Power.find(1)
    assert_equal 629.36, powers.max_ave(5)
  end


  must "Id=1 の正規化 " do
    powers = Shimada::Power.find(1)
    assert_equal [0.98227, 0.98767, 1.00197, 1.00038, 1.00229],
    powers.normalized(5)[10,5].map{ |p| p.round(5)}
  end

  must "Id=1 の移動平均 " do
    powers = Shimada::Power.find(1)
    assert_equal 618.2, powers.move_ave(5)[10]
    assert_equal 339.0, powers.move_ave(5)[0]
    assert_equal 571.25, powers.move_ave(5)[22]
  end 

  must "ID=1 2013-02-01 の気温は" do
    powers = Shimada::Power.find(1)
    assert_equal Weather,powers.weather.class  
    assert_equal [0.4, 0.4, -0.8, -0.7, -0.4, -0.9, -1.1, 0.3, 2.4, 4.3,
                  6.4, 8.1, 9.9, 9.9, 9.1, 9.0, 8.1, 7.7, 6.2, 5.8, 5.8, 5.5, 5.5, 5.2],powers.temps
  end

  must "600kwH 30℃は20℃のときは" do
    day = Time.local(2013,2,1)
    power = Shimada::Power.create(:date => day,:hour01 => 600)
    temp  = Weather.create(:date => day,:hour01 => 30 )
    assert_equal 600 - 9*(30-20),power.revise_by_temp[0]
  end
  must "ID=1の温度補正後" do
    powers = Shimada::Power.find(1)
    assert_equal [],powers.revise_by_temp
  end
end
