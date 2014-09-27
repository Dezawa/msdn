# -*- coding: utf-8 -*-
require 'test_helper'

class ShimadaPowerTest < ActiveSupport::TestCase

  fixtures :shimada_powers
  GMC=1
  must "データ数" do
    assert_equal 28*2 + 31*2,Shimada::Power.all.size
  end

  must "複数のpowerで gnuplot_data するとtmpfileは 1+24*日数 行できる" do
    powers = Shimada::Power.find(1,4,10)
    path = Shimada::Power.output_plot_data(powers,:powers){ |f,power| 
      power.send(:powers).each_with_index{ |h,idx| f.printf "%d %.3f\n",idx+1,h }
    }
    lines = File.read path.first
    assert_equal 1+3*24,lines.split(/\n+/).size
  end

  must "複数のpowerで gnuplot するとgifができる" do
    powers = Shimada::Power.find(1,4,10)
    path   = Shimada::Power.gnuplot(GMC,powers,:powers)
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

  must "ID=1の温度補正後" do
    powers = Shimada::Power.find(1)
    assert_equal [442.8, 388.8, 365.4, 448.1, 503.2, 621.7, 638.3, 657.1,
                  671.8, 649.1, 666.8, 659.7, 650.3, 666.3, 679.7, 654.0,
                  665.7, 658.9, 644.4, 665.6, 660.6, 629.5, 619.5, 549.4],powers.revise_by_temp
  end

  must "ID=1の近似" do
    powers = Shimada::Power.find(1)
    assert_equal [657.8844, -2.6897, 0.8771, 0.089, -0.0239],powers.a(4).map{ |f| f.round(4)}
  end
end
