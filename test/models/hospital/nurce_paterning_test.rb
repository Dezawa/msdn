# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
class Hospital::NurcePaterningTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies","hospital/defines"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    $HP_DEF=nil
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @nurces=@assign.nurces
 end
# @nurces.each{|n| p [n.id,!!n.role_id?(1),n.shift_count(3),n.evaluate([1,2,4,5],3)]};1
  #######

  #################
#      1...5....0.... 5
#  34 ______11_______ ______1______1
#  35 ___0__________0 ______________
#  36 ____3__0_______ 0____________0
#  37 __00___________ ____________10
#  38 ______0________ ______________
#  39 _______________ ______________
#  40 ______1________ _____12____1__
#  41 _______________ ______________
#  42 ________0______ _________0____
#  43 _________00____ 1_0_1__1_2__1_
#  44 __________1____ __0____3______
#  45 _______________ __0________2__
#  46 _________0_____ ________0_____
#  47 _0__________1__ 00___1________
#  48 __0____________ _____1________
#  49 _______________ ______10______
#  50 _____2______2__ _00____0_33_1_
#  51 __0____________ 00____________
#  52 ___00____0_0___ ________0_____

  must "need_patern " do
    ret = [{ [3,"2"]  => [1,1] ,[3,"3"]  => [1,1],
             [4,"1"]  => [9,11],[4,"2"]  => [2,2],[4,"3"]  => [2,2],
             #[5,"1"]  => [0,1] ,[5,"2"]  => [0,1],[5,"3"]  => [0,1],
             [9,"1"]  => [1,2] ,[9,"2"]  => [1,2],[9,"3"]  => [1,2],
             [10,"1"] => [1,2] ,[10,"2"] => [1,2],[10,"3"] => [1,2],
             [4,"0"]  => [0,5]
           },
           { [3,"2"]  => [1,1] ,[3,"3"]  => [1,1],
             [4,"1"]  => [6,7] ,[4,"2"]  => [2,2],[4,"3"]  => [2,2],
             #[5,"1"]  => [0,1] ,[5,"2"]  => [0,1],[5,"3"]  => [0,1],
             [9,"1"]  => [1,2] ,[9,"2"]  => [1,2],[9,"3"]  => [1,2],
             [10,"1"] => [1,2] ,[10,"2"] => [1,2],[10,"3"] => [1,2],
             [4,"0"]  => [0,8]
           }
          ]
    assert_equal ret[0],@assign.need_patern[0],"平日のパターン"
    assert_equal ret[1],@assign.need_patern[1],"休日のパターン"
  end

  must "2/15の休暇" do
    day,role,shift = 15,@assign.Kangoshi,"0"
    assert_equal [0,5],@assign.need(day,role,shift),"#{day}日 看護師の休暇数[下限,上限]"
    assert_equal [0,5],@assign.need(day,role,shift),"#{day}日 看護師の休暇数[下限,上限]"
    assert_equal 3,@assign.count_role_shift[15][[@assign.Kangoshi,"0"]],"初めの休暇数(希望数)"
    assert_equal  [0,2],@assign.short_role_shift[day][[role,shift]],"既に休暇３。あといくつOKか"
  end
  must "2/13、nurce 37～40の4人に220,330を割り振る2/15に0が7になる。多すぎて失敗になるか" do
   comb_nurces=@assign.nurce_by_id([38,46,39,40])
    day = 13
    shift = "3"
    #                                     nurce 37,38に  15日に sft3で パターン 330を
    assigned = @assign.assign_test_patern(comb_nurces[0,2],day  ,shift,[0,0])
    assert_equal [["330",[[2],[],[],[1]]],["330",[[2],[],[],[1]]]], 
    assigned.map{ |as| [as.patern,as.target_days]},"二人ほどshift3にlong_patern[0,0],330を入れるのは可能"
pp "bofore ret = @assign.assign_patern"
ret = @assign.assign_patern(comb_nurces[0,2],day,shift,[0,0])#assigned) #####  二人に割り振る
pp ["after ret = @assign.assign_patern",ret]
puts @assign.dump
    assert_equal true ,ret,"2/13 330はOK"
    @assign.long_check_later_days(day,[[2],[],[],[1]],"3")

    #assert_equal  [-5,1],@assign.short_role_shift[15][[2,0]],"330を入れたので0のshort"
    shift = "2"
    assigned = @assign.assign_test_patern(comb_nurces[2,2],day,shift,[0,0]) # 220を割付試みる
    assert_equal false ,@assign.assign_patern(comb_nurces[2,2],day,shift,[0,0]),"2/13 220は失敗"
  end

end
__END__
  must "2/1、nurce 44に110220330を割り振ると、2/5がrole不足で失敗" do
    comb_nurces=@assign.nurce_by_id([44])
    day = 1
    shift = 1
    assigned = @assign.assign_test_patern(comb_nurces,day,shift,[0])
#pp assigned
    assert_equal false ,@assign.assign_patern(comb_nurces,day,shift,assigned),"2/1、nurce 44に110220330を割り振ると、2/5がrole不足で失敗" 
  end

  must "2/4、nurce 35に220を割り振ると成功" do
    comb_nurces=@assign.nurce_by_id([35])
    day = 4
    shift = 2
\    assigned = @assign.assign_test_patern(comb_nurces,day,shift,[2])
#pp assigned
    assert_equal true ,@assign.assign_patern(comb_nurces,day,shift,assigned),"2/4、nurce 35に220を割り振ると成功1"
  end
  #must "14日から3人、38,39,46に勤務1を割り振ると、2人目まで112233、3人目は1" do
  #  nurces = nurce_select(38,39,46)
  #  day = 14
  #  shift = 1
  #  assert_equal "110220330",@assign.assign_(nurces[0],day,shift),"勤務1 1人目"
  #  assert_equal "110220330",@assign.assign_(nurces[1],day,shift),"勤務1 2人目"
  #  assert_equal 1          ,@assign.assign_(nurces[2],day,shift),"勤務1 3人目"
  #end

  #must "14日から 41に勤務3を割り振ると331122" do
  #  nurces = nurce_select(41)
  #  day = 14
  #  shift = 3
  #  assert_equal "330110220",@assign.assign_(nurces[0],day,shift),"勤務1 1人目"
  #end


  #   1...5....0....5.            1...5....0...
  [ ["_______________1",     "250330_________1","希望皆無"],
    ["__2____________1",     "_520330________1","希望2"], ##
    ["__25___________1",     "__250330_______1","希望25"],
    ["__5____________1",     "_250330________1","希望5"],
    ["__52___________1",     "__520330_______1","希望52"],##
    ["__52_0_________1",     "__52_0250330___1","希望52_0"],
    ["_1_____________1",     "_1250330_______1","希望皆無"],
    ["_12____________1",     "_1250330_______1","希望2"], ##
    ["_125___________1",     "_1250330_______1","希望25"],
    ["_15____________1",     "_1520330_______1","希望5"],
    ["_152___________1",     "_1520330_______1","希望52"],##
    ["_152_0_________1",     "_152_0250330___1","希望52_0"],
    ["_0_____________1",     "_0250330_______1","希望皆無"],
    ["_02____________1",     "_0250330_______1","希望2"], ##
    ["_025___________1",     "_0250330_______1","希望25"],
    ["_05____________1",     "_0520330_______1","希望5"],
    ["_052___________1",     "_0520330_______1","希望52"],##
    ["_052_0_________1",     "_052_0250330___1","希望52_0"],

    ["_________3_____1",     "_____250330____1","希望2"], ##
    ["_________33____1",     "______250330___1","希望25"],
    ["________13_____1",     "250330__13_____1","希望2"], ##
    ["_________31____1",     "250330___31____1","希望2"], ##
    ["_______0_3_____1",     "_____250330____1","希望25"],
    ["_______1_3_____1",     "250330_1_3_____1","希望52"],##
    nil
  ].each{|init,rsrt,msg|
    next unless init
    must "#{init}で管理準夜を入れる:#{msg}" do
      nurce=nurce 35
      nurce.shifts[1,init.size] = init
      nurce.assign_1_cool
      assert_equal rsrt,nurce.shifts[1,16]
      
    end
  }

  must "LongCheckPatern" do
    assert_equal [2,4,4],[1,2,3].map{|p| Hospital::Nurce::LongPatern[p].size}
  end

end

