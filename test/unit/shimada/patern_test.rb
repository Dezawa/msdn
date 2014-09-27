# -*- coding: utf-8 -*-
require 'test_helper'

class ShimadaPaternTest < ActiveSupport::TestCase

  fixtures :shimada_powers, :shimada_months,:weathers

  def setup
    @power = Shimada::Power.find_by_date(Time.local(2013,2,6))
  end

  def select_by_(powers,find_conditions)
    find_conditions.to_a.inject(powers){ |p,sym_v| 
      sym,v = sym_v
      p.select{ |pw| pw.send(sym) == v }
    }
  end

  must "na" do
    assert_equal [ 0.93997115, 0.01024201, 0.00188269, -0.00025153, -4.843e-05
                 ],@power.na.map{ |f| f.round 8}
  end

  must "判別式" do
    assert_equal 1.1e-05,@power.discriminant.round( 7)
  end

  must "二次微分の解" do
     assert_equal  [-4.1556, 1.559],[@power.x1,@power.x2].map{ |f| f.round 4}
  end

  must "f2" do
     assert_equal  [-0.0032, 0.0005, 0.0031, 0.0045, 0.0047, 0.0038, 0.0017, -0.0016, -0.006],(-5..3).map{ |x| @power.f2(x).round 4}    
  end
  must "f3" do
     assert_equal  [-0.0032, -0.0045, -0.0026, 0.0012, 0.0059, 0.0102, 0.0131, 0.0132, 0.0095],(-5..3).map{ |x| @power.f3(x).round 4}    
  end
  must "f4" do
     assert_equal  [0.937, 0.9328, 0.9291, 0.9283, 0.9318, 0.94, 0.9518, 0.9652, 0.9769],(-5..3).map{ |x| @power.f4(x).round 4}    
  end

  must "all" do
    powers = Shimada::Month.where( "month='2013-2-1'").map(&:powers).flatten
    assert_equal [[1, "S"], [3, "00"], [3, "F"], [3, "H"], [4, "-0"], [4, "00"]
                 ],powers.map{ |pw| [pw.lines,pw.shape_calc]}.uniq.sort
  end

  must "average_diff:: data size" do
    assert_equal 118,Shimada::Power.where("date is  not null").size
  end
  must "average_diff:: ave_power 初めはなし" do
    assert_equal nil, Shimada::Power.find_by_date(nil)
  end
  must "average_diff:: ave_power できる" do
    ave_power = Shimada::Power.find_or_create_by(date: nil)
    assert  Shimada::Power.find_by(date: nil)
  end
  must "average_diff:: " do
    ave_power = Shimada::Power.average_diff 1
    assert_equal [],  Shimada::Power.find_by(date: nil)
  end
 # must "3O" do
 #   powers = Shimada::Month.where("month='2013-2-1'").map(&:powers).flatten
 #   assert_equal [1],powers.select{ |pw| pw.lines == 3 && pw.shape_calc=="O"}.map(&:date)
 # end
end
