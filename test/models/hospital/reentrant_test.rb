# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
#require 'need'

class Hospital::ReentrantTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies","hospital/defines"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.

  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @assign.limit_time = Time.now + 10
    @nurces=@assign.nurces
    srand(1)
  end

  def assign_night_shift(day,sft_str,nurce_id_combination)
    nurce_combination = nurce_id_combination.map{ |id| nurce_by_id(id,@nurces)}
    @assign.assign_night_shift(day,sft_str,nurce_combination)
  end

  def assign_night(day,nurce_id_combination_combination)
    ["2","3"].zip(nurce_id_combination_combination).each{ |sft_str,nurce_id_combination|
      assign_night_shift(day,sft_str,nurce_id_combination)
    }
  end

  must "2/1 夜の看護師候補" do
    assert_equal [[[36, 38], [45, 39]], [[51, 38], [45, 39]], [[51, 38], [36, 39]],
                  [[45, 38], [36, 39]], [[51, 45], [36, 39]], [[51, 35], [36, 39]],
                  [[38, 46], [45, 39]], [[51, 35], [45, 39]], [[38, 46], [36, 39]], [[38, 46], [39, 48]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(1))
  end
  must "2/1 夜の看護師候補の割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1)
    assert_equal [["36 _____3_0_______0____________0",
                   "38 ______0______________________",
                   "39 _____________________________",
                   "45 _________________0________2__"],
                  ["36 _220_3_0_______0____________0",
                   "38 _2____0______________________",
                   "39 _330_________________________",
                   "45 _3_______________0________2__"]
                 ],pre.diff(@assign.dump.split("\n"))
  end

  must "2/1割り付けたのち、2/2のshift3候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    sft_str = "3"
    #             x   4A 35A 349 49A 349
    assert_equal [41, 42, 52, 35, 46, 40, 44, 34, 49, 50
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,@assign.short_role(day,sft_str)).map(&:id)
  
    assert_equal [0, 1, 0, 0, 1],@assign.roles_count_short(day,sft_str),
    "2/1割り付けたのち、2/2のshift#{sft_str}不足ロール"
    assert_equal [[42], [46], [44], [49], [50] #[42], [43], [44], [45], [46], [47], [49], [50]
                 ],combination_ids(@assign.candidate_combination_for_shift_with_enough_role(day,sft_str)),
    "2/1割り付けたのち、2/2のshift#{sft_str}ロール満たす組み合わせ"
  end

  must "2/1割り付けたのち、2/2のshift2候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    sft_str = "2"
    assert_equal [52, 35, 46, 41, 49, 50, 44, 40, 43, 34
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                                  @assign.short_role(day,sft_str)).map(&:id)

    assert_equal [1, 1, 0, 1, 0],@assign.roles_count_short(day,sft_str),
    "2/1割り付けたのち、2/2のshift#{sft_str}不足ロール"

    assert_equal [[41], [40]
                 ],combination_ids(@assign.candidate_combination_for_shift_with_enough_role(2,"2")),
    "2/1割り付けたのち、2/2のshift#{sft_str}ロール満たす組み合わせ"
  end

  must "2/1割り付けたのち、2/2の夜の候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    assert_equal [[[41], [42]], [[41], [46]], [[41], [44]], [[41], [50]], [[41], [49]],
                  [[40], [46]], [[40], [42]], [[40], [44]], [[40], [49]], [[40], [50]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(day))
  end

  must "2/1割り付けたのちの、 shift1_is_enough?" do
    @assign.assign_night(1,:dipth => 1)
    assert_equal true,  @assign.assign_night(2,:dipth => 1)
  end

  # このままだと、1月末4連で終わってる人が多いので、1日がshift1不足になる
  must "2/2まで割付。1月末4連で終わってる人が多いので、1日がshift1不足になる" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1)

  end

  must "1日を [[51, 38], [36, 39] で割り付ける" do
    pre = @assign.dump.split("\n")
    day = 1
    assign_night(day,[[51, 38],[36, 39]])
    assert_equal [[
                   "36 _____3_0_______0____________0",
                   "38 ______0______________________",
                   "39 _____________________________",
                   "51 __0____________00____________"],
                  [
                   "36 _3___3_0_______0____________0",  # 深夜２回まで
                   "38 _2____0______________________",
                   "39 _330_________________________",
                   "51 _20____________00____________"]
                 ],pre.diff(@assign.dump.split("\n"))
  end
  must "1日を [[51, 38], [36, 39] で割り付け,２日を割り付ける" do
    pre = @assign.dump.split("\n")
    day = 1
    assign_night(day,[[51, 38],[36, 39]])
    day = 2
    assert_equal([[[36, 41], [42]], [[36, 41], [45]], [[36, 41], [46]], [[41, 46], [45]], [[41, 46], [42]], 
                  [[45, 41], [46]], [[45, 41], [42]], [[49, 35], [46]], [[41, 44], [46]], [[49, 45], [42]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(day)),
                  "2/2 夜の看護師候補"
                 )
  end

  must "combinationを引数で渡す" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1,:nurce_combinations => @assign.candidate_combination_for_shift23_selected_by_cost(1))
    assert_equal [["36 _____3_0_______0____________0",
                   "38 ______0______________________",
                   "39 _____________________________",
                   "45 _________________0________2__"],
                  ["36 _220_3_0_______0____________0",
                   "38 _2____0______________________",
                   "39 _330_________________________",
                   "45 _3_______________0________2__"]
                ],pre.diff(@assign.dump.split("\n"))

  end

   must "2/11まで割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 11)
    assert_equal ["34 ______11_____________1______1",
                  "35 ___0220330____0______________",
                  "36 _220_3_0_3_____0____________0",
                  "37 __00_______________________10",
                  "38 _2_3__0_220330_______________",
                  "39 _330__2__330_________________",
                  "40 ______1_____________12____1__",
                  "41 __220330___220330____________",
                  "42 __330___0_220330________0____",
                  "43 _________00____1_0_1__1_2__1_",
                  "44 ____3_____1______0___________",
                  "45 _3_____220330____0________2__",
                  "46 ______2__0_____________0_____",
                  "47 _0__________1__00___1________",
                  "48 __0_________________1________",
                  "49 _____________________10______",
                  "50 ____32_23___2___00____0__3_1_",
                  "51 __022033022033000____________",
                  "52 ___00____0_0___________0_____"
                  # "34 ______11_____________1______1",
                  # "35 _220____3_____0______________",
                  # "36 _3___3_0220____0____________0",
                  # "37 __00_______________________10",  # 0 0 0   1
                  # "38 _____20_220330_______________", 
                  # "39 _330__220330_________________",  # 2 4 6   6
                  # "40 ______1_____________12____1__",  # 1 0 1   2
                  # "41 _____330__220330_____________",
                  # "42 __330___0330____________0____",  # 0 4 4   4
                  # "43 _________00____1_0_1__1_2__1_",
                  # "44 ____3_____1______0___________",  # 0 1 1   2
                  # "45 ___220330________0________2__",  # 3 2 5   5
                  # "46 _____220_0220330_______0_____",
                  # "47 _0__________1__00___1________",
                  # "48 __0_________________1________",
                  # "49 __220________________10______",
                  # "50 ____3__2____2___00____0__3_1_",
                  # "51 _2032__330_330_00____________",
                  # "52 ___00____0_0___________0_____"
                 ], @assign.dump.split("\n")
  end

  must "2/11まで割付た後の夜勤の不足ロール" do
    @assign.assign_night(1,:dipth => 11)
    assert_equal [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0]
                 ],["2","3"].map{ |sft_str| @assign.roles_count_short(12,sft_str)}
  end
  must "2/11まで割付た後の夜勤候補のタイトロール" do
    @assign.assign_night(1,:dipth => 11)
    candidate_combination = @assign.candidate_combination_for_shift23_selected_by_cost(12)
    assert_equal [[9, 3, 10], [9, 3, 10]
                 ],["2","3"].map{ |sft_str| @assign.tight_roles(sft_str) }
  end
  
  must "2/11まで割付た後の tight & role_ids" do
    @assign.assign_night(1,:dipth => 11)
   assert_equal [[9], [9, 3], [9, 3], [9, 10], [9, 10], [9, 10]
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|  [9, 3, 10] & nurce.role_ids}
  end
  must "2/11まで割付た後の shift_remain" do
    @assign.assign_night(1,:dipth => 11)
   assert_equal [5, 4, 4, 3, 5, 2 #5, 3, 4, 5, 5, 2
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|   nurce.shift_remain["2"]}
  end

  must "2/11まで割付た後の Cost table" do
    @assign.assign_night(1,:dipth => 11)
    table = nurce_by_id(37,@nurces).class.cost_table
    #                                                                              2  3  4  5          3 4  5  8  9
   assert_equal [[99999, 3537, 2721, 2093, 1610, 1238,  952, 732, 563, 433], # [9]               37,             37
                 [99999, 4708, 3622, 2786, 2143, 1648, 1268, 975, 750, 577], # [3, 9]      39 40       39      40
                 [99999, 4280, 3292, 2533, 1948, 1498, 1152, 886, 682, 524]  # [9, 10]  45       42,44   45 42 44
                ], [[9], [3, 9], [9, 10]].map{ |ids| table[[9, 3, 10]][ids][0,10]}
  end

  must "2/11まで割付た後の看護師の Cost" do
    @assign.assign_night(1,:dipth => 11)
    #                                                              2  3  4  5
   assert_equal [1238, 2143, 2143, 2533, 1498, 3292
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|   nurce.cost("2",[9, 3, 10])}
   assert_equal [433, 2143, 750, 2533, 682, 2533 # 433, 2786,  750, 1498, 682, 1948
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|   nurce.cost(:night_total,[9, 3, 10])}
  end
  must "2/11まで割付た後の看護師群の Cost" do
    @assign.assign_night(1,:dipth => 11)
    @assign.night_mode = true
    assert_equal [ 433.0, 2143.0, 750.0, 2533.0, 682.0, 2533.0
                ], nurce_select(37,39,40,42,44,45).
      map{ |nurce| @assign.cost_of_nurce_combination([nurce],:night_total,[9, 3, 10])-2}
  end

  must "2/11まで割付た後の夜勤候補とコスト" do
    @assign.assign_night(1,:dipth => 11)
   @assign.night_mode = true
    candidate_combination = @assign.candidate_combination_for_shift23_selected_by_cost(12)
    assert_equal :fill,candidate_combination
  end
  

  must "2/11まで割付た後の夜勤の候補" do
    @assign.assign_night(1,:dipth => 11)
   @assign.night_mode = true
    candidate_combination = @assign.candidate_combination_for_shift23_selected_by_cost(12)
    assert_equal :fill,candidate_combination
   end

 
end
