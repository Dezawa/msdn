# -*- coding: utf-8 -*-
require 'test_helper'
require 'hospital/kinmu'
class Hospital::MonthlyTest < ActiveSupport::TestCase
  fixtures "hospital/monthlies","hospital/kinmucodes", "hospital/roles"
  fixtures "hospital/nurces", "hospital/defines"
  def setup
    @monthlies = Hospital::Monthly.all
    @monthly   = Hospital::Monthly.find(1)
  end

  must "月ID 57は看護師 id:38 初めは2/3は割り当てなし" do
    monthly=month(57)
    assert_equal [nil, "_"],[monthly.days[3].shift,monthly.shift[3,1]]
  end
  must "看護師 id:38 寺田輝子2月度。初めは2/3は割り当てなし" do
    nrc = nurce(38)
    assert_equal ["_", nil, "_"],[nrc.shift(3),nrc.monthly.days[3].shift,nrc.monthly.shift[3,1]]
   end
  must "看護師 id:38 寺田輝子2月度。２月3日に勤務2をsetする " do
    nrc = nurce(38)
    nrc.set_shift(3,"2")
    assert_equal [ "2", nil, "2"],[nrc.shift(3),nrc.monthly.days[3].shift,nrc.monthly.shift[3,1]]
  end

  must "看護師 id:38 寺田輝子2月度。２月3日に勤務2をsetし]saveにそなえ restoreする " do
    nrc = nurce(38)
    nrc.set_shift(3,"2")
    nrc.monthly.restore_days
    assert_equal ["day03",2],["day03",nrc.monthly.day03],"save"
   end
  must "看護師 id:38 寺田輝子2月度２月3日に勤務2をsetしsaveして読み直す " do
    nrc = nurce(38)
    nrc.set_shift(3,"2")
    nrc.monthly.restore_days
    nrc.monthly.save
    monthly=month(57)
    assert_equal  ["2", "2"],[monthly.days[3].shift,monthly.shift[3,1]]

  end

  must "月度データの数" do
#pp @monthlies #Hospital::Monthly.all
    assert_equal 90,@monthlies .size
    #assert_equal 2,@monthlies.size
  end
  
  must "月度の@shiftは" do
    assert_equal "__231___1_1_____________________",@monthly.shift
  end

  must "月度データの[]は" do
    assert_equal 34,@monthly.days[4].kinmucode_id
  end
  must "月度データの[1..4]は" do
    assert_equal [0,1002, 2003, 34],@monthly.days[1..4].map(&:kinmucode_want)
  end
  must "月度データの[1,4]は" do
    assert_equal [0, 1002, 2003, 34],@monthly.days[1,4].map(&:kinmucode_want)
  end

  must "月度データの[1,4]の勤務は" do
    #assert_equal [nil, 2, 3, 1],@monthly.days[1,4].map(&:shift)
    assert_equal "_231",@monthly.shift[1,4]
  end


  must "最終日は" do
    assert_equal 31,@monthly.lastday
  end

  #must "daysを修正してsaveするとday08を変更できる" do
  #  a=@monthly.days[8]
  #  @monthly.set_shift(8,9)#days[8].kinmucode_id = 9# = Hospital::Kinmu.new(9)
  #  @monthly.restore_days.save
  #  assert_equal 9,Hospital::Monthly.find(1).day08
  #end

  must "3/2はcede 2" do
    assert_equal 2,@monthly.kinmucode(2)
  end
  must "3/2はcede 2" do
    assert_equal 2,@monthly.days[2].kinmucode_id
  end
  must "色は" do
    assert_equal  ["","bgcolor='orange'","bgcolor='red'"],
    [4,2,3].map{|day| @monthly.days[day].color}
  end

  def month(id)
    Hospital::Monthly.find id
  end

  def nurce(id)
    nurce = Hospital::Nurce.find id
    nurce.monthly(Date.new(2013,2,1))
    nurce
  end

  
end
