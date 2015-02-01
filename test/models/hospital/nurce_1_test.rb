# -*- coding: utf-8 -*-
require 'test_helper'

#################
# Nurce の属性関連のテスト
class Hospital::Nurce < ActiveRecord::Base
  # [0,0,0,1,3,0.....]
  def day_store(shift_list)
    shift_list.each_with_index{|shift,day|  set_shift(day+1,shift.to_s)}
  end
end
class Hospital::NurceTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
    srand(1)
  end

  def nurce(id); 
    n = Hospital::Nurce.find id
    @month  = Date.new(2013,2,1)
    n.monthly(@month)
    n
  end

  def set_code(nurce,day,code)
    nurce.monthly.day10 = code
    nurce.monthly.shift = nil
    nurce.monthly.store_days
  end

  must "看護婦Id=3のrole数" do
    assert_equal 3,nurce(3).roles.size
    assert_equal [4,6,9],nurce(3).roles.map{ |r,n| r }.sort
  end

  ###### Validation のテスト ###### 
  must "看護婦Id=3の 職位 に 9 を入れるとNG" do
    nurce3 = nurce(3)
    nurce3.shokui  = Hospital::Role.find_by(bunrui: Hospital::Const::Bunrui2Id['職種'])
    nurce3.save
    assert_equal ["職位でないrole"],nurce3.errors.messages[:shokui]
  end

  must "看護婦Id=3の 職位 に 1 を入れるとOK" do
    nurce3 = nurce(3)
    nurce3.shokui  = Hospital::Role.find_by(bunrui: Hospital::Const::Bunrui2Id['職位'])
    nurce3.save
    assert_equal nil,nurce3.errors.messages[:shokui]
  end
  
  must "看護婦Id=3の 職種 に 職位 を入れるとNG" do
    nurce3 = nurce(3)
    nurce3.shokushu = Hospital::Role.find_by(bunrui: Hospital::Const::Bunrui2Id['職位'])
    nurce3.save
    assert_equal ["職種でないrole"],nurce3.errors.messages[:shokushu]
  end

  must "看護婦Id=3の 職種 に 職種 を入れるとOK" do
    nurce3 = nurce(3)
    nurce3.shokushu = Hospital::Role.find_by(bunrui: Hospital::Const::Bunrui2Id['職種'])
    nurce3.save
    assert_equal nil,nurce3.errors.messages[:shokushu]
  end

  must "看護婦Id=3の 勤務区分 に 職位 を入れるとNG" do
    nurce3 = nurce(3)
    nurce3.kinmukubun = Hospital::Role.find_by(bunrui: Hospital::Const::Bunrui2Id['職位'])
    nurce3.save
    assert_equal ["勤務区分でないrole"],nurce3.errors.messages[:kinmukubun]
  end

  must "看護婦Id=3の 勤務区分 に 勤務区分 を入れるとOK" do
    nurce3 = nurce(3)
    nurce3.kinmukubun = Hospital::Role.find_by(bunrui: Hospital::Const::Bunrui2Id['勤務区分'])
    nurce3.save
    assert_equal nil,nurce3.errors.messages[:kinmukubun]
  end
  ###### Validation のテスト 終わり###### 
 
  must "看護婦Id=3の職種を準看護師にするとrolesが変わる" do
    nurce3 = nurce(3)
    nurce3.shokushu_id = 5
    nurce3.save
    assert_equal 3,nurce(3).roles.size,"看護婦Id=3変更後のrole数"
    assert_equal [5,6,9],nurce(3).roles.map{ |r,n| r}.sort,"看護婦Id=3変更後のrole"
  end

end
