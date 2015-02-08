# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

#################
# Nurce の属性関連のテスト
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

  must "看護婦数" do
    assert_equal 52,@nurces.size
  end

  must "看護婦Id=3のrole数" do
    assert_equal 3,nurce(3).roles.size
    assert_equal [4,6,9],nurce(3).roles.map{ |r,n| r }.sort
  end

  must "看護婦Id=1の準夜数" do
    assert_equal 2,nurce(1).limit.code2
  end

  must "看護婦Id=40のneed_role_ids " do
    assert_equal [3,4,9],nurce(40).need_role_ids.sort
  end

  must "看護婦Id=40のroles " do
    assert_equal [[3, "リーダー"],[4, "看護師"], [7, "三交代"],[9, "Aチーム"]], nurce(40).roles.sort
  end

  must "看護婦Id=40のneed_role_id? " do
    [[3,true],[4,true],[5,false],[9,true],[10,false]].each{|id,rsrt|
      assert_equal rsrt,nurce(40).need_role_id?(id), "need_role_id? #{id}"
    }
  end

  # 
  must "Userを読み込んだ後 shiftsは設定されるかafter_find" do
    assert_equal "______1_____________12____1__",nurce(40).shifts
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

  ########################################

  must "2/1時廣眞弓さん割り当てなし" do
    assert !nurce(35).assigned?(1)
  end 

  must "2/1尾木さん割り当てあり" do
    assert nurce(47).assigned?(1)
  end

  must "加藤照子さんの先月からの勤務状況" do
    nurce = nurce(50)
    nurce.monthly(@month-1.month)
    nurce.monthly(@month)
    assert_equal "33111____2______2___00____0_33_1_",nurce.shift_with_last_month
  end

  # 加藤照子さんの 割り当て済み勤務
  [[1,1],[2,2],[3,2]].each{|shift,count|
    must "shift_count" do
      nurce50 = nurce(50)
      assert_equal count, nurce50.shift_count(shift),"shift_count of #{shift}"
    end
  }

  # 加藤照子さんの各シフトの合計日数
  [[:shift0,3.0],[:shift1,1.0],[:shift2,2.0],[:shift3,2.0]].each{|shift,val|
    must "total time of #{shift}" do
      nurce50 = nurce(50)
      assert_equal val,nurce50.send( shift)
    end
  }

  must  "加藤照子さんの2月 の 勤務" do
    assert_equal [1.0,2.0,2.0,3,0,0,0,0],
    [:shift1,:shift2,:shift3,:shift0,:nenkyuu,:osode,:sankyuu,:ikukyuu].
      map{|sym| nurce(50).send sym}
  end
  must "村上真澄さんの先月からの勤務状況" do
    nurce = nurce(44)
    nurce.monthly(@month-1.month)
    nurce.monthly(@month)
    assert_equal "11020_________1______0____3______",nurce.shift_with_last_month
  end

  must "時廣眞弓さんの先月からの勤務状況" do
    nurce = nurce(35)
    nurce.monthly(@month-1.month)
    #puts nurce.monthly.shift
    nurce.monthly(@month)
    #puts nurce.monthly.shift
    assert_equal "12011__0__________0______________",nurce.shift_with_last_month
  end

  must  "山野恵子の2月 の 勤務" do
    assert_equal [4.0, 1.0, 0.0, 3, 0, 0, 0, 0],
    [:shift1,:shift2,:shift3,:shift0,:nenkyuu,:osode,:sankyuu,:ikukyuu].
      map{|sym| nurce(43).send sym}
  end

  must "by_bhsho" do
    assert_equal 19,Hospital::Nurce.by_busho(1).size
  end 
 ######## 初期化テスト ###################

  must "set_check_reg " do
    set_check_reg = nurce(40).set_check_reg
    assert_equal [[:kinmu_total], [], [:junya,:nine_nights], [ :nine_nights,:shinya]],
    set_check_reg[-1].map{ |r| r.sort}
    assert set_check_reg[0][2][:junya].check(0, "000000222222"),"junya set_check_reg Over 5 error"
    assert !(set_check_reg[0][2][:junya].check(0, "00000022222")),"junya set_check_reg under 6  error"
  end

end
