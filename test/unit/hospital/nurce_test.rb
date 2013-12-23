# -*- coding: utf-8 -*-
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
    n.monthly(@month)
    n
  end

  def set_code(nurce,day,code)
    nurce.monthly.day10 = code
    nurce.monthly.store_days
  end


  #123456789012345678901234567890123456789
  "1232311111AB487564564564477CB11151AB487".split("").each_with_index{|shift,code|
    must "To_123 of code #{code+1}" do
      nurce41 = nurce(41)
      set_code(nurce41,:day10,code+1); 
      assert_equal shift,nurce41.shifts[10,1],
      "code #{code+1} #{Hospital::Kinmucode.find(code+1).name} は#{shift}"
    end
  }
  #01234567890123456789012345678901234567890
  "4487CB1111111123FFF441FFF4401110000000000".split("").each_with_index{|shift,code|
    must "To_123 of code #{code+1}" do
      nurce41 = nurce(41)
      set_code(nurce41,:day10,code+40); 
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

  DayR = [[1,"1"],[2,"1"],[4,"1"]]
  JunR = [[1,"2"],[2,"2"],[4,"2"]]
  SinR = [[1,"3"],[2,"3"],[4,"3"]]
  HDyZ = [[1,"9"],[2,"9"],[4,"9"]]
  HDyG = [[1,"A"],[2,"A"],[4,"A"]]
  NonR = [[1,"3"],[2,"3"],[4,"3"]]
  DayZ = [[1,"8"],[2,"8"],[4,"8"]]
  DayG = [[1,"7"],[2,"7"],[4,"7"]]
  JunN = [[1,"5"],[2,"5"],[4,"5"]]
  SinN = [[1,"6"],[2,"6"],[4,"6"]]
  DayN = [[1,"4"],[2,"4"],[4,"4"]]
  HRdZ = [[1,"C"],[2,"C"],[4,"C"]]
  HRdG = [[1,"B"],[2,"B"],[4,"B"]]
  HDyR = [[1, "B"], [2, "B"], [4, "B"]] # 半日系は病院に聞いてから
  NonR = [[1, "F"], [2, "F"], [4, "F"]]
  HolyR= [[1, "0"], [2, "0"], [4, "0"]]
  ([DayR,JunR,SinR,JunR,SinR, #1,2,3,L2,L3  1-5
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
    check_reg = nurce(40).set_check_reg
    assert_equal [[],[],[:junya],[:shinya]],check_reg[-1]
    assert check_reg[0][2][:junya].first =~ "222222","junya set_check_reg Over 5 error"
    assert !(check_reg[0][2][:junya].first =~ "22222"),"junya set_check_reg under 6  error"

  end

  must "by_bhsho" do
    assert_equal 19,Hospital::Nurce.by_busho(1).size
  end 

  must "2/1時廣眞弓さん割り当てなし" do
    assert !nurce(35).assigned?(1)
  end 

  must "38,39,43,44のshift_remain" do
    nurce38,nurce39,nurce43,nurce44 = [38,39,43,44].map{|id| nurce(id)}
    assert_equal [{"3"=>5, "2"=>5, "1"=>20.0, "0"=>7.0},
 {"3"=>5, "2"=>5, "1"=>20.0, "0"=>8.0},
 {"3"=>5, "2"=>4, "1"=>16.0, "0"=>5.0},
 {"3"=>4, "2"=>5, "1"=>19.0, "0"=>7.0}],
    [nurce38,nurce39,nurce43,nurce44].map(&:shift_remain)
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
    assert_equal [msg,[[1, "0"], [2, "0"], [4, "0"]]],[msg, nurce.role_shift[3]]
    

    ################# 2月1日に勤務2をset
    nurce.set_shift(1,"2")

    msg="2月1日に勤務2をsetしたときの勤務の値"
    assert_equal [msg,%w(2 0 _)],[msg,[1,3,13].map{|day| nurce.shift(day)}]
    #msg="2月1日に勤務2をsetしたときのmonthly.days"
    #shift=nurce.monthly.shift
    #assert_equal [msg,2,"2"],[msg, shift.kinmucode_id,kinmu.shift]
    msg="2月1日に勤務2をsetしたときのrole_shift"
    assert_equal [msg,[[1, "2"], [2, "2"], [4, "2"]]],[msg, nurce.role_shift(@month,true)[1]]
    msg="2/1はassignされた"
    #puts nurce.monthly.shift[1,1]
    assert_equal [msg,true],[msg,nurce.assigned?(1)]
  end

  must "save_shift" do
    ret = ["______1_____________12____1__",
           { [1, "2"]=>1, 
             [2, "1"]=>3, 
             [1, "1"]=>3,
             [4, "1"]=>3,
             [2, "2"]=>1,
             [4, "2"]=>1,
             [1,"0"]=>0,
             [2,"0"]=>0,
             [4,"0"]=>0,
             [1,"3"]=>0,
             [2,"3"]=>0,
             [4,"3"]=>0},
           { [1, "2"]=>4,
             [2, "1"]=>17,
             [1, "1"]=>17,
             [4, "1"]=>17,
             [2, "3"]=>5,
             [4, "3"]=>5,
             [2, "2"]=>4,
             [1, "3"]=>5,
             [4, "2"]=>4,
             [1, "3"]=>5},
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

  rslt0 = {
    [1,"1"]=>20,[1,"2"]=>5,[1,"3"]=>5,
    [2,"1"]=>20,[2,"2"]=>5,[2,"3"]=>5,
    [4,"1"]=>20,[4,"2"]=>5,[4,"3"]=>5
  }
  must "Nurce 6 id 40 寺田輝子のアサイン可能なrole" do
    assert_equal rslt0, nurce(40).assinable_roles
  end

  rslt1 = {
    [1, "1"]=>3,    [2, "1"]=>3,     [4, "1"]=>3,
    [1, "2"]=>1,    [2, "2"]=>1,     [4, "2"]=>1,
    [1, "3"]=>0,    [2, "3"]=>0,     [4, "3"]=>0, 
    [1, "0"]=>0,    [2, "0"]=>0,     [4, "0"]=>0  }
  must "Nurce 6 id 40 寺田輝子の使われたrole" do
    assert_equal rslt1, nurce(40).role_used
  end

  rslt2 = {
    [1, "1"]=>17, [2, "1"]=>17, [4, "1"]=>17,
    [1, "2"]=>4,  [2, "2"]=>4,  [4, "2"]=>4 ,
    [1, "3"]=>5,  [2, "3"]=>5,  [4, "3"]=>5
  }
  must "Nurce 6 id 40 寺田輝子の残っているrole" do
    assert_equal rslt2, nurce(40).role_remain
  end

  rslt1_2 = {
    [1, "1"]=>3, [2, "1"]=>3,  [4, "1"]=>3,[1, "2"]=>1, [2, "2"]=>1, [4, "2"]=>1,
    [1, "3"]=>1, [2, "3"]=>1,  [4, "3"]=>1,[1, "0"]=>0, [2, "0"]=>0 ,[4, "0"]=>0
  }
  rslt2_2 = {
    [1, "1"]=>17, [2, "1"]=>17, [4, "1"]=>17,
    [1, "2"]=>4,  [2, "2"]=>4,  [4, "2"]=>4 ,
    [1, "3"]=>4,  [2, "3"]=>4,  [4, "3"]=>4
  }
  must "Nurce 6 id 40 寺田輝子に 2/2 shift3を割り振ると、usedとremainは" do
    nrc =  nurce(40)
    assert_equal rslt1,nrc.role_used,"割り振り前 used"
    assert_equal rslt2,nrc.role_remain,"割り振り前 remain"
    nrc.set_shift(2,"3")
    assert_equal rslt1_2,nrc.role_used,"割り振り後 used"
    assert_equal rslt2_2,nrc.role_remain,"割り振り後 remain"
  end

  (1..5).to_a.product(%w(1 2 3)).zip([true,true,true, 
                                    true,true,true, 
                                    false,false,false,
                                    true,true,true,
                                    false,false,false
                                   ]).each{|role_shift,ret|
    must "Nurce 6 id 40 寺田輝子の#{role_shift} no has_assignable_roles_atleast_one" do
      assert_equal ret,nurce(40).has_assignable_roles_atleast_one(role_shift[1],[role_shift[0]])
    end
  }
  [[[1,2],true],[[3,5],false]].each{|roles,ret|
    must "Nurce 6 id 40 寺田輝子の#{roles} no has_assignable_roles_atleast_one" do
      assert_equal ret,nurce(40).has_assignable_roles_atleast_one("2",roles)
    end
  }

  must "roles,role_ids" do
    assert_equal [[1, "リーダー"], [2, "看護\345\270\253"], [4, "Aチー\343\203\240"]],nurce(40).roles
    assert_equal [1,2,4],nurce(40).role_ids
    [[1,true],[2,true],[3,false],[4,true],[5,false]].each{|id,rsrt|
      assert_equal rsrt,nurce(40).role_id?(id), "role_id? #{id}"
    }
  end

  must "喜津直美さんの2/4 の [role,勤務]" do
    assert_equal [[1, "3"], [2, "3"], [5, "3"]],nurce(36).role_shift(@month)[4],"role_shift"
    assert_equal [[1, 3], [2, 3], [5, 3]],nurce(36).role_shift_of(3),"role_shift_of"
    assert_equal [[1, 2], [2, 2], [5, 2]],nurce(36).role_shift_of(2),"role_shift_of"
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
    assert_equal [1.0,2.0,2.0,3,0,0,0,0],[:shift1,:shift2,:shift3,:shift0,:nenkyuu,:osode,:sankyuu,:ikukyuu].
      map{|sym| nurce(50).send sym}
  end
  must  "山野恵子の2月 の 勤務" do
    assert_equal [4.0, 1.0, 0.0, 3, 0, 0, 0, 0],[:shift1,:shift2,:shift3,:shift0,:nenkyuu,:osode,:sankyuu,:ikukyuu].
      map{|sym| nurce(43).send sym}
  end
  must "看護婦数" do
    assert_equal 52,@nurces.size
  end
  must "看護婦Id=1のrole数" do
    assert_equal 1,nurce(1).hospital_roles.size
  end
  must "看護婦Id=1の準夜数" do
    assert_equal 2,nurce(1).limit.code2
  end

  ################ 逼迫関連
  must "Costtable" do
    assert_equal [[1, 2, 4],
                  [1, 2, 5],
                  [1, 4, 2],
                  [1, 4, 5],
                  [1, 5, 2],
                  [1, 5, 4],
                  [2, 1, 4],
                  [2, 1, 5],
                  [2, 4, 1],
                  [2, 4, 5],
                  [2, 5, 1],
                  [2, 5, 4],
                  [4, 1, 2],
                  [4, 1, 5],
                  [4, 2, 1],
                  [4, 2, 5],
                  [4, 5, 1],
                  [4, 5, 2],
                  [5, 1, 2],
                  [5, 1, 4],
                  [5, 2, 1],
                  [5, 2, 4],
                  [5, 4, 1],
                  [5, 4, 2]],  Hospital::Nurce.cost_table.keys.sort,"keys of Nurce:Const"
    assert_equal [[1,4,5],[1,4],[1,5],[4,5],[1],[4],[5]].sort,
    Hospital::Nurce.cost_table[[1,5,4]].keys.sort,"keys of key 154 Nurce:Const"
    assert_equal Hospital::Nurce::Cost[7], Hospital::Nurce.cost_table[[1,5,4]][[1,4,5]],"valu of key 154 Nurce:Const"
  end
  
  must "Nurce 40 cost" do
    nurce40 = nurce(40)
    assert_equal [1,2,4], nurce40.role_ids,"nurce40.role_ids"
    assert_equal 5,nurce40.role_remain[[2,"3"]],"role remain5"
    cost = Hospital::Nurce::Cost[6][5]
    assert_equal cost, nurce40.cost("3",[1,4,5]) ," tight 1,4,5"
    assert_equal Hospital::Nurce::Cost[5][5], nurce40.cost("3",[1,5,4]) ," tight 1,5,4"
    assert_equal Hospital::Nurce::Cost[7][5], nurce40.cost("3",[1,4,2]),"shft 3 is remains 5 before set\shift"
    saved = nurce40.save_shift
    #pp saved[2]
    #pp nurce40.role_remain[[2,3]]
    nurce40.set_shift(20,"3")
    #pp saved[2]
    assert_equal Hospital::Nurce::Cost[7][4], nurce40.cost("3",[1,4,2]),"shft 3 is remains 4 after set\shift"
    nurce40.restore_shift(saved)
    #pp nurce40.role_remain
    #pp nurce40.role_remain[[2,3]]
    assert_equal Hospital::Nurce::Cost[7][5], nurce40.cost("3",[1,4,2]),"shft 3 is remains 5 after restore"
  end

  


end
# -*- coding: utf-8 -*-
