# -*- coding: utf-8 -*-
require 'test_helper'

#################
class Hospital::Nurce < ActiveRecord::Base
  # [0,0,0,1,3,0.....]
  def day_store(shift_list)
    shift_list.each_with_index{|shift,day|  set_shift(day+1,shift.to_s)}
  end


end


class Hospital::NurceTest < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
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
    assert_equal 4,nurce(3).hospital_roles.size
    assert_equal [2,4,6,9],nurce(3).hospital_roles.map(&:id).sort
  end
  must "看護婦Id=3の職種を準看護師にするとhospital_rolesが変わる" do
    nurce3 = nurce(3)
    assert_equal 4,nurce3.hospital_roles.size ,"看護婦Id=3初めのrole数"
    assert_equal [2,4,6,9],nurce3.hospital_roles.map(&:id).sort,"看護婦Id=3初めのrole"
    nurce3.shokushu_id = 5
    nurce3.save
    assert_equal 4,nurce(3).hospital_roles.size,"看護婦Id=3変更後のrole数"
    assert_equal [2,5,6,9],nurce(3).hospital_roles.map(&:id).sort,"看護婦Id=3変更後のrole"

  end

  #123456789012345678901234567890123456789
  "1232311111AB487564564564477CB11151AB487".split("").each_with_index{|shift,code|
    must "To_123 of code #{code+1}" do
      nurce41 = nurce(41)
      set_code(nurce41,:day10,code+1); 
      assert_equal code+1,nurce41.monthly.day10
      assert_equal code+1,nurce41.monthly.days[10].id
      assert_equal shift,nurce41.monthly.days[10].to_0123
      assert_equal shift,nurce41.shifts[10,1],
      "code #{code+1} #{Hospital::Kinmucode.find(code+1).name} は#{shift}"
    end
  }
  #01234567890123456789012345678901234567890
  "4487CB1111111123FFF441FFF4401110000000000".split("").each_with_index{|shift,code|
    must "To_123 of code #{code+1}" do
      nurce41 = nurce(41)
      set_code(nurce41,:day10,code+40); 
      assert_equal code+40,nurce41.monthly.day10
      assert_equal code+40,nurce41.monthly.days[10].kinmucode_id
      assert_equal shift,nurce41.monthly.days[10].kinmucode.to_0123
      assert_equal shift,nurce41.monthly.days[10].shift
      assert_equal shift,nurce41.shifts[10,1],
      "code #{code+40} #{Hospital::Kinmucode.find(code+40).name} は#{shift}"
    end
  }

   Day = {"3"=>5, "2"=>5, "1"=>19.0, "0"=>8.0};HDy = {"3"=>5, "2"=>5, "1"=>19.5, "0"=>7.5}
   Jun = {"3"=>5, "2"=>4, "1"=>20.0, "0"=>8.0};HHl = [7.5,20,5,5]
   Sin = {"3"=>4, "2"=>5, "1"=>20.0, "0"=>8.0}
   All = {"3"=>5, "2"=>5, "1"=>20.0, "0"=>8.0}
   Holyday = {"3"=>5, "2"=>5, "1"=>20.0, "0"=>7.0}
  ([Day,Jun,Sin,Jun,Sin, #1,2,3,L2,L3
   Day,Day,Day,Day,Day, # 会,会,早,遅出,遅出
   HDy,HDy,Day,Day,Day, # Z,G,R1,Z/R,R/G
   Jun,Sin,Day,Jun,Sin, # R2,R3,H1,H2,H3
   Day,Jun,Sin,Day,     # イ1,イ2,イ3,1/セ
   Day,Day,Day,HDy,HDy, # 出,出/1,1/出,出/G,Z/出
   Day,Day,Day,         # 4,会,会
   Jun,Day,HDy,HDy,     # 管,早,Z,G
   Day,Day,Day,Day,     # R1,Z/R,R/G,J1
   Day,Day,Day,HDy,HDy, # 出,出/1,1/出,出/G,Z/出
   Day,Day,Day,Day,Day, # P4,4.5,5,6,7     
   Day,Day,Day,Jun,Sin, # セ,P/セ,1,L2,L3
   All,All,All,Day,Day, # 拘束3,Z/R,R/G
   Day,All,All,All,     # 4,拘束3
   Day,Day,Holyday,Day,Day,Day] +   # Z/R, R/G 公 遅早外
   [Holyday]*10         # 71〜80
  ).each_with_index{|ret,code|
    must "勤務code #{code+1}だとshift残は" do
      nurce41 = nurce(41)
      assert_equal({"3"=>5, "2"=>5, "1"=>20.0, "0"=>8.0},nurce41.shift_remain)
        set_code(nurce41,:day10,code+1); 
#puts nurce41.shifts
        assert_equal ret,nurce41.shift_remain(true),"code #{code+1} shift #{nurce41.shifts[10,1]} は#{ret}"
      
    end
  }

  DayR = [[3,"1"],[4,"1"],[9,"1"]] # role 4,[7,7,9 にshift_str "1" がアサイン
  JunR = [[3,"2"],[4,"2"],[9,"2"]]
  SinR = [[3,"3"],[4,"3"],[9,"3"]]
  HDyZ = [[3,"9"],[4,"9"],[9,"9"]]
  HDyG = [[3,"A"],[4,"A"],[9,"A"]]
  NonR = [[3,"3"],[4,"3"],[9,"3"]]
  DayZ = [[3,"8"],[4,"8"],[9,"8"]]
  DayG = [[3,"7"],[4,"7"],[9,"7"]]
  JunN = [[3,"5"],[4,"5"],[9,"5"]]
  SinN = [[3,"6"],[4,"6"],[9,"6"]]
  DayN = [[3,"4"],[4,"4"],[9,"4"]]
  HRdZ = [[3,"C"],[4,"C"],[9,"C"]]
  HRdG = [[3,"B"],[4,"B"],[9,"B"]]
  HDyR = [[3,"B"],[4,"B"],[9, "B"]] # 半日系は病院に聞いてから
  NonR = [[3,"F"],[4,"F"],[9, "F"]]
  HolyR= [[3,"0"],[4,"0"],[9, "0"]]
  ([DayR,JunR,SinR,JunR,SinR, #1,3,3,L3,L3  1-5
    DayR,DayR,DayR,DayR,DayR, #6-10 会,会,早,遅出,遅出
    HDyZ,HDyG,DayN,DayZ,DayG, #11-15 Z,G,R1,Z/R,R/G
    JunN,SinN,DayN,JunN,SinN, #16-20 R2,R3,H1,H2,H3
    DayN,JunN,SinN,DayN,DayN, #21-25 イ1,イ2,イ3,1/セ,出,
    DayZ,DayG,HRdZ,HDyR,      #26-29 出/1,1/出,出/G,Z/出
    DayR,DayR,DayR,           #30-32 4,会,会
    JunN,DayR,HDyZ,HDyG,      #33-36 管,早,Z,G
    DayN,DayZ,DayG,DayN,      #37-40 R1,Z/R,R/G,J1
    DayN,DayZ,DayG,HRdZ,HRdG, #41-45 出,出/1,1/出,出/G,Z/出
    DayR,DayR,DayR,DayR,DayR, #46-50 P4,4.5,5,6,7     
    DayR,DayR,DayR,JunR,SinR, #51-55 セ,P/セ,1,L2,L3
    NonR,NonR,NonR,DayN,DayN, #56-60 拘束3,Z/R,R/G
    DayR,NonR,NonR,NonR,      #61-64 4,拘束3
    DayN,DayN,HolyR,DayR,DayR,DayR]+ #65-70 Z/R, R/G 公 遅早外
    [HolyR]*10             # 71〜80    
  ).each_with_index{|ret,code|
    must "勤務code #{code+1}を入れるとrole_shiftは" do
      nurce41 = nurce(41)
      set_code(nurce41,:day10,code+1); 
      assert_equal ret,nurce41.role_shift(@month,true)[10], #month月10日の
      "code #{code+1}  shift #{nurce41.shifts[10,1]} は#{ret.join(',')}"
      
    end
  }

  must "after_find" do
    assert_equal "______1_____________12____1__",nurce(40).shifts
  end

  must "set_check_reg " do
    set_check_reg = nurce(40).set_check_reg
    assert_equal [[:kinmu_total], [], [:junya,:nine_nights], [ :nine_nights,:shinya]],
    set_check_reg[-1].map{ |r| r.sort}
#pp  check_regset_check_reg[0][2][:junya].first
pp set_check_reg[0][2][:junya]
    assert set_check_reg[0][2][:junya].check(0, "000000222222"),"junya set_check_reg Over 5 error"
    assert !(set_check_reg[0][2][:junya].check(0, "00000022222")),"junya set_check_reg under 6  error"

  end

  must "by_bhsho" do
    assert_equal 19,Hospital::Nurce.by_busho(1).size
  end 

  must "2/1時廣眞弓さん割り当てなし" do
    assert !nurce(35).assigned?(1)
  end 

  must "時廣眞弓さんの先月からの勤務状況" do
    nurce = nurce(35)
    nurce.monthly(@month-1.month)
    #puts nurce.monthly.shift
    nurce.monthly(@month)
    #puts nurce.monthly.shift
    assert_equal "12011__0__________0______________",nurce.shift_with_last_month
  end

  must "村上真澄さんの先月からの勤務状況" do
    nurce = nurce(44)
    nurce.monthly(@month-1.month)
    #puts nurce.monthly.shift
    nurce.monthly(@month)
    #puts nurce.monthly.shift
    assert_equal "11020_________1______0____3______",nurce.shift_with_last_month
  end


  must "勤務をセットする" do
    nurce=nurce(35);
    nurce.monthly @month
    msg="2月1,3,13の勤務初期値"
    assert_equal [msg,["_","0","_"]],[msg,[1,3,13].map{|day| nurce.shift(day)}]
    msg="2月1日のmonthly.days"
    kinmu=nurce.monthly.days[1]
    assert_equal [msg,nil,nil],[msg, kinmu.kinmucode_id,kinmu.shift]
    msg="2月3日のrole_shift"
    assert_equal [msg,[ [4, "0"], [9, "0"]]],[msg, nurce.role_shift[3]]
    

    ################# 2月1日に勤務2をset
    nurce.set_shift(1,"2")

    msg="2月1日に勤務2をsetしたときの勤務の値"
    assert_equal [msg,%w(2 0 _)],[msg,[1,3,13].map{|day| nurce.shift(day)}]
    #msg="2月1日に勤務2をsetしたときのmonthly.days"
    #shift=nurce.monthly.shift
    #assert_equal [msg,2,"2"],[msg, shift.kinmucode_id,kinmu.shift]
    msg="2月1日に勤務2をsetしたときのrole_shift"
    assert_equal [msg,[[4, "2"], [9, "2"]]],[msg, nurce.role_shift(@month,true)[1]]
    msg="2/1はassignされた"
    #puts nurce.monthly.shift[1,1]
    assert_equal [msg,true],[msg,nurce.assigned?(1)]
  end

  must "save_shift" do
    ret = ["______1_____________12____1__",
           { [3,"0"]=>0,
             [3, "2"]=>1, 
             [3, "1"]=>3,
             [3,"3"]=>0,
             [4,"0"]=>0,
             [4, "1"]=>3, 
             [4, "2"]=>1,
             [4,"3"]=>0,
             [9, "1"]=>3,
             [9, "2"]=>1,
             [9,"0"]=>0,
             [9,"3"]=>0},
           { [3, "1"]=>17,
             [3, "2"]=>4,
             [3, "3"]=>5,
             [4, "1"]=>17,
             [4, "2"]=>4,
             [4, "3"]=>5,
             [9, "3"]=>5,
             [9, "1"]=>17,
             [9, "2"]=>4,
 },
            {"0"=>8.0, "1"=>17.0, "2"=>4, "3"=>5}]
    nurce40 = nurce(40)
    save_shift=nurce40.save_shift
    assert_equal ret,save_shift
    nurce40.set_shift(1,"2")
    save_shift2 = nurce40.save_shift
    assert_not_equal save_shift[0],save_shift2[0]
    assert_not_equal save_shift[1],save_shift2[1]
    assert_not_equal save_shift[2],save_shift2[2]

    save_shift3 = nurce40.restore_shift(save_shift).save_shift
    assert_equal save_shift[0], nurce40.shifts
  end

  must "2/1尾木さん割り当てあり" do
    assert nurce(47).assigned?(1)
  end

  [3,4,5,9,10].product(%w(1 2 3)).zip([true,true,true, 
                                    true,true,true, 
                                    false,false,false,
                                    true,true,true,
                                    false,false,false
                                   ]).each{|role_shift,ret|
    must "Nurce 6 id 40 寺田輝子の#{role_shift} no has_assignable_roles_atleast_one" do
      assert_equal ret,nurce(40).has_assignable_roles_atleast_one(role_shift[1],[role_shift[0]])
    end
  }
  [[[3,4],true],[[5,10],false]].each{|roles,ret|
    must "Nurce 6 id 40 寺田輝子の#{roles} no has_assignable_roles_atleast_one" do
      assert_equal ret,nurce(40).has_assignable_roles_atleast_one("2",roles)
    end
  }

  must "roles,role_ids" do
    assert_equal [[3, "リーダー"], [4, "看護\345\270\253"], [7, "三交\344\273\243"],[9, "Aチー\343\203\240"]],nurce(40).roles
    assert_equal [3,4,9],nurce(40).role_ids.sort
    [[3,true],[4,true],[5,false],[9,true],[10,false]].each{|id,rsrt|
      assert_equal rsrt,nurce(40).role_id?(id), "role_id? #{id}"
    }
  end

  [[1,1],[2,2],[3,2]].each{|shift,count|
    must "shift_count" do
      nurce50 = nurce(50)
      assert_equal count, nurce50.shift_count(shift),"shift_count of #{shift}"
    end
  }
  [[:shift0,3.0],[:shift1,1.0],[:shift2,2.0],[:shift3,2.0]].each{|shift,val|
    must "total time of #{shift}" do
      nurce50 = nurce(50)
      assert_equal val,nurce50.send( shift)
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
    nurce = nurce(35)
    #puts
    #puts nurce.shifts
    nurce.set_shift_days(2,"12357890")
    assert_equal "__12357890____0______________",nurce.shifts
  end

  must "set_shift" do
    nurce = nurce(35)
    #puts
    #puts nurce.shifts
    nurce.set_shift_days(2,"12357890")
    assert_equal "__12357890____0______________",nurce.shifts
    #puts nurce.shifts
  end

  
  must "勤務設定のテスト" do
    nurce=nurce(35)# 1 2 3 4 5 6 7 8
    nurce.day_store([0,0,0,1,3,0,0,0])
    #assert_equal [0,0,0,1,3,0,0,0
    #             ],(1..8).map{|day| nurce.monthly.days[day].shift}
    assert_equal "00013000",nurce.monthly.shift[1..8]
  end
  must "勤務設定のテスト nil" do
    nurce=nurce(35)# 1 2 3 4 5 6 7 8
    nurce.day_store([0,0,nil,1,3,0,0,0])
    #assert_equal [0,0,nil,1,3,0,0,0
    #             ],(1..8).map{|day| nurce.monthly.days[day].shift}
    assert_equal "00_13000",nurce.monthly.shift[1..8]
  end
  
  must "既に割り当てられている日がPatern8に掛かるか" do

  end

  must  "渡邊清美さんの2月 の 勤務" do
pp [50,nurce(50).shifts]
    assert_equal [1.0,2.0,2.0,3,0,0,0,0],[:shift1,:shift2,:shift3,:shift0,:nenkyuu,:osode,:sankyuu,:ikukyuu].
      map{|sym| nurce(50).send sym}
  end
  must  "山野恵子の2月 の 勤務" do
pp [43,nurce(43).shifts]#"_________00____1_0_1__1_2__1_"
    assert_equal [4.0, 1.0, 0.0, 3, 0, 0, 0, 0],[:shift1,:shift2,:shift3,:shift0,:nenkyuu,:osode,:sankyuu,:ikukyuu].
      map{|sym| nurce(43).send sym}
  end
  must "看護婦数" do
    assert_equal 52,@nurces.size
  end
  must "看護婦Id=1の準夜数" do
    assert_equal 2,nurce(1).limit.code2
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
  
  must "Nurce 40 cost" do
    nurce40 = nurce(40)
    assert_equal [3,4,9], nurce40.role_ids,"nurce40.role_ids"
    assert_equal ({ [9, "3"]=>5, [9, "2"]=>5, [9, "1"]=>20,
                    [3, "3"]=>5, [3, "2"]=>5, [3, "1"]=>20, 
                    [4, "3"]=>5, [4, "2"]=>5, [4, "1"]=>20}
                  ), nurce40.assinable_roles
    assert_equal 5,nurce40.role_remain[[4,"3"]],"role remain5"
    cost = Hospital::Nurce::Cost[6][5]
    assert_equal cost, nurce40.cost("3",[3,9,10]) ," tight 3,9,10"
    assert_equal Hospital::Nurce::Cost[5][5], nurce40.cost("3",[3,10,9]) ," tight 3,10,9"
    assert_equal Hospital::Nurce::Cost[7][5], nurce40.cost("3",[3,9,4]),"shft 3 is remains 5 before set\shift"
    saved = nurce40.save_shift
    #pp saved[2]
    #pp nurce40.role_remain[[2,3]]
    nurce40.set_shift(20,"3")
    #pp saved[2]
    assert_equal Hospital::Nurce::Cost[7][4], nurce40.cost("3",[3,9,4]),"shft 3 is remains 4 after set\shift"
    nurce40.restore_shift(saved)
    #pp nurce40.role_remain
    #pp nurce40.role_remain[[2,3]]
    assert_equal Hospital::Nurce::Cost[7][5], nurce40.cost("3",[3,9,4]),"shft 3 is remains 5 after restore"
  end

  


end
