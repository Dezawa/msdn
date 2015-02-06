# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

#################

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

  # 勤務コード 1～40 が shiftsではどう表されるか確認
  #123456789012345678901234567890123456789
  "12323111119A487564564564487CB111519A487".split("").each_with_index{|shift,code|
    must "To_123 of code #{code+1}" do
      nurce41 = nurce(41,[2013,3,1])
      set_code(nurce41,:day10,code+1); 
      assert_equal code+1,nurce41.monthly.day10
      assert_equal shift,nurce41.shifts[10,1],
      "code #{code+1} #{Hospital::Kinmucode.find(code+1).name} は#{shift}"
    end
  }
  #01234567890123456789012345678901234567890
  "4487CB1111111123FFF441FFF4401110000000000".split("").each_with_index{|shift,code|
    must "To_123 of code #{code+40}" do
      nurce41 = nurce(41,[2013,3,1])
      set_code(nurce41,:day10,code+40); 
      assert_equal code+40,nurce41.monthly.day10
      assert_equal code+40,nurce41.monthly.days[10].kinmucode_id
      assert_equal shift,nurce41.monthly.days[10].kinmucode.to_0123
      assert_equal shift,nurce41.monthly.days[10].shift
      assert_equal shift,nurce41.shifts[10,1],
      "code #{code+40} #{Hospital::Kinmucode.find(code+40).name} は#{shift}"
    end
  }


  must "勤務をセットする" do
    nurce=nurce(35);
    nurce.monthly @month
    msg="2月1,3,13の勤務初期値"
    assert_equal [msg,["_","0","_"]],[msg,[1,3,13].map{|day| nurce.shift(day)}]
    msg="2月1日のmonthly.days"
    kinmu=nurce.monthly.days[1]
    assert_equal [msg,nil,nil],[msg, kinmu.kinmucode_id,kinmu.shift]
    msg="2月3日のrole_shift"
    assert_equal [msg,[ [4, "0"], [9, "0"]]],[msg, nurce.role_shift[3].sort]
    

    ################# 2月1日に勤務2をset
    nurce.set_shift(1,"2")

    msg="2月1日に勤務2をsetしたときの勤務の値"
    assert_equal [msg,%w(2 0 _)],[msg,[1,3,13].map{|day| nurce.shift(day)}]
    #msg="2月1日に勤務2をsetしたときのmonthly.days"
    #shift=nurce.monthly.shift
    #assert_equal [msg,2,"2"],[msg, shift.kinmucode_id,kinmu.shift]
    msg="2月1日に勤務2をsetしたときのrole_shift"
    assert_equal [msg,[[4, "2"], [9, "2"]]],[msg, nurce.role_shift(@month,true)[1].sort]
    msg="2/1はassignされた"
    #puts nurce.monthly.shift[1,1]
    assert_equal [msg,true],[msg,nurce.assigned?(1)]
  end

  must "save_shift" do
    ret = 
      [
       "______1_____________12____1__",
       {"0"=>8.0, "1"=>17.0, "2"=>4, "3"=>5, :kinmu_total =>18,  :night_total =>8}
      ]
    nurce40 = nurce(40)#,[2013,3,1])
    save_shift=nurce40.save_shift
    assert_equal ret,save_shift
    nurce40.set_shift(1,"2")
    save_shift2 = nurce40.save_shift
    assert_not_equal save_shift[0],save_shift2[0]
    assert_not_equal save_shift[1],save_shift2[1]

    save_shift3 = nurce40.restore_shift(save_shift).save_shift
    assert_equal save_shift[0], nurce40.shifts
  end

  [3,4,5,9,10].product(%w(1 2 3)).zip([true,true,true, 
                                    true,true,true, 
                                    false,false,false,
                                    true,true,true,
                                    false,false,false
                                   ]).each{|role_shift,ret|
    must "Nurce 6 id 40 寺田輝子の#{role_shift}  has_assignable_roles_atleast_one" do
      assert_equal ret,nurce(40,[2013,3,1]).has_assignable_roles_atleast_one(role_shift[1],[role_shift[0]])
    end
  }
  [[[3,4],true],[[5,10],false]].each{|roles,ret|
    must "Nurce 6 id 40 寺田輝子の#{roles} no has_assignable_roles_atleast_one" do
      assert_equal ret,nurce(40,[2013,3,1]).has_assignable_roles_atleast_one("2",roles)
    end
  }

  [[48,"岡玲子",[[:interval, 0]]],[46,"藤井大介",nil]].
    each{|id,name,ret|
    must name+"は2/1に日勤をassignできるか" do
      nurce = nurce(id)
pp nurce.shift_with_last_month
      assert_equal ret,nurce.check_at_assign(1,"1")
    end
  }
  must "set_shift_days" do
    nurce = nurce(35)#,[2013,3,1])
    #puts
    #puts nurce.shifts
    nurce.set_shift_days(2,"12357890")
    assert_equal "__12357890____0______________",nurce.shifts
  end

  must "set_shift" do
    nurce = nurce(35)#,[2013,3,1])
    #puts
    #puts nurce.shifts
    nurce.set_shift_days(2,"12357890")
    assert_equal "__12357890____0______________",nurce.shifts
    #puts nurce.shifts
  end

  
  must "勤務設定のテスト" do
    nurce=nurce(35,[2013,3,1])# 1 2 3 4 5 6 7 8
    nurce.day_store([0,0,0,1,3,0,0,0])
    #assert_equal [0,0,0,1,3,0,0,0
    #             ],(1..8).map{|day| nurce.monthly.days[day].shift}
    assert_equal "00013000",nurce.monthly.shift[1..8]
  end
  must "勤務設定のテスト nil" do
    nurce=nurce(35,[2013,3,1])# 1 2 3 4 5 6 7 8
    nurce.day_store([0,0,nil,1,3,0,0,0])
    #assert_equal [0,0,nil,1,3,0,0,0
    #             ],(1..8).map{|day| nurce.monthly.days[day].shift}
    assert_equal "00_13000",nurce.monthly.shift[1..8]
  end
  
  must "既に割り当てられている日がPatern8に掛かるか" do

  end

  ################ 逼迫関連
  must "Costtable" do
    assert_equal [[3, 4, 9],
                  [3, 4, 10],
                  [3, 9, 4],
                  [3, 9, 10],
                  [3, 10, 4],
                  [3, 10, 9],
                  [4, 3, 9],
                  [4, 3, 10],
                  [4, 9, 3],
                  [4, 9, 10],
                  [4, 10, 3],
                  [4, 10, 9],
                  [9, 3, 4],
                  [9, 3, 10],
                  [9, 4, 3],
                  [9, 4, 10],
                  [9, 10, 3],
                  [9, 10, 4],
                  [10, 3, 4],
                  [10, 3, 9],
                  [10, 4, 3],
                  [10, 4, 9],
                  [10, 9, 3],
                  [10, 9, 4]],  Hospital::Nurce.cost_table.keys.sort,"keys of Nurce:Const"
    assert_equal [[3,9,10],[3,9],[3,10],[9,10],[3],[9],[10]].sort,
    Hospital::Nurce.cost_table[[3,10,9]].keys.sort,"keys of key 3109 Nurce:Const"
    assert_equal Hospital::Nurce::Cost[7], Hospital::Nurce.cost_table[[3,10,9]][[3,9,10]],"valu of key 1109 Nurce:Const"
  end
  
assinable_roles = { 
    [9, "3"]=>5, [9, "2"]=>5, [9, "1"]=>20, [9, :kinmu_total]=>22,[9, :night_total]=>9,
    [3, "3"]=>5, [3, "2"]=>5, [3, "1"]=>20, [3, :kinmu_total]=>22,[3, :night_total]=>9,
    [4, "3"]=>5, [4, "2"]=>5, [4, "1"]=>20, [4, :kinmu_total]=>22,[4, :night_total]=>9,
  }
  must "Nurce 40 cost" do
    nurce40 = nurce(40)#,[2013,3,1])
    assert_equal [3,4,9], nurce40.role_ids.sort,"nurce40.role_ids"
    assert_equal assinable_roles, nurce40.assinable_roles
    assert_equal ({:night_total=>8, "3"=>5, "2"=>4, "1"=>17.0, "0"=>8.0, :kinmu_total=>18.0}),
    nurce40.shift_remain
    assert_equal [3,4,9],    nurce40.role_ids.sort
    assert_equal 5,nurce40.shift_remain["3"],"role remain5"
    cost = Hospital::Nurce::Cost[6][5]
    assert_equal cost, nurce40.cost("3",[3,9,10]).to_i ," tight 3,9,10"
    assert_equal Hospital::Nurce::Cost[5][5], nurce40.cost("3",[3,10,9]).to_i ," tight 3,10,9"
    assert_equal Hospital::Nurce::Cost[7][5], nurce40.cost("3",[3,9,4]).to_i ,"shft 3 is remains 5 before set\shift"
    saved = nurce40.save_shift
    #pp saved[2]
    #pp nurce40.role_remain[[2,3]]
    nurce40.set_shift(20,"3")
    #pp saved[2]
    assert_equal Hospital::Nurce::Cost[7][4], nurce40.cost("3",[3,9,4]).to_i ,"shft 3 is remains 4 after set\shift"
    nurce40.restore_shift(saved)
    #pp nurce40.role_remain
    #pp nurce40.role_remain[[2,3]]
    assert_equal Hospital::Nurce::Cost[7][5], nurce40.cost("3",[3,9,4]).to_i ,"shft 3 is remains 5 after restore"
  end

  


end
