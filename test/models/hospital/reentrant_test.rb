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
    @assign.night_mode = true
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
    assert_equal [[[46, 38], [37, 48]], [[38, 49], [37, 48]], [[37, 49], [48, 39]],
                  [[46, 38], [48, 39]], [[49, 44], [37, 48]], [[37, 49], [48, 45]],
                  [[37, 49], [48, 44]], [[43, 49], [37, 48]], [[46, 38], [48, 45]], [[46, 38], [48, 44]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(1))
  end
  must "2/1 夜の看護師候補の割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1)
    assert_equal [["37 __00_______________________10",
                   "38 ______0______________________",
                   "46 _________0_____________0_____",
                   "48 __0_________________1________"],
                  ["37 _300_______________________10",
                   "38 _2____0______________________",
                   "46 _2_______0_____________0_____",
                   "48 _30_________________1________"]
                 ],pre.diff(@assign.dump.split("\n"))
  end

  must "2/1割り付けたのち、2/2のshift3候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    sft_str = "3"
    #             x   4A 35A 349 49A 349
    assert_equal [34, 36, 47, 52, 35, 42, 39, 49, 44, 41
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,@assign.short_role(day,sft_str)).map(&:id)
    
    assert_equal [1, 2, 0, 1, 1],@assign.roles_count_short(day,sft_str),
    "2/1割り付けたのち、2/2のshift#{sft_str}不足ロール"
    assert_equal [[36, 39], [36, 41], [47, 35], [47, 42], [47, 39], [47, 44], [47, 41], [35, 49], [42, 39], [42, 49], [42, 41], [39, 49], [39, 44], [49, 44], [49, 41], [44, 41]
                 ],combination_ids(@assign.candidate_combination_for_shift_with_enough_role(day,sft_str)),
    "2/1割り付けたのち、2/2のshift#{sft_str}ロール満たす組み合わせ"
  end

  must "2/1割り付けたのち、2/2のshift2候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    sft_str = "2"
    assert_equal [34, 36, 49, 52, 35, 43, 39, 50, 44, 41
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                                  @assign.short_role(day,sft_str)).map(&:id)

    assert_equal [1, 2, 0, 1, 1],@assign.roles_count_short(day,sft_str),
    "2/1割り付けたのち、2/2のshift#{sft_str}不足ロール"

    assert_equal [[36, 39], [36, 41], [49, 35], [49, 43], [49, 39], [49, 44], [49, 41], [35, 50], [43, 39], [43, 50], [43, 41], [39, 50], [39, 44], [50, 44], [50, 41], [44, 41]
                 ],combination_ids(@assign.candidate_combination_for_shift_with_enough_role(2,"2")),
    "2/1割り付けたのち、2/2のshift#{sft_str}ロール満たす組み合わせ"
  end

  must "2/1割り付けたのち、2/2の夜の候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    assert_equal [[[49, 41], [47, 42]], [[49, 39], [47, 42]], [[49, 39], [47, 41]],
                  [[49, 41], [47, 39]], [[49, 41], [42, 39]], [[49, 39], [42, 41]],
                  [[49, 43], [47, 42]], [[49, 44], [47, 42]], [[49, 44], [47, 41]], [[49, 44], [47, 39]]
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
    assert_equal([[[46, 41], [49]], [[46, 41], [47]], [[49, 41], [46]], [[46, 41], [42]], [[49, 43], [46]], [[49, 44], [46]], [[49, 41], [47]], [[49, 41], [42]], [[41, 44], [46]], [[43, 41], [46]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(day)),
                 "2/2 夜の看護師候補"
                 )
  end

  must "combinationを引数で渡す" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1,:nurce_combinations => @assign.candidate_combination_for_shift23_selected_by_cost(1))
    assert_equal [["37 __00_______________________10",
                   "38 ______0______________________",
                   "46 _________0_____________0_____",
                   "48 __0_________________1________"],
                  ["37 _300_______________________10",
                   "38 _2____0______________________",
                   "46 _2_______0_____________0_____",
                   "48 _30_________________1________"]
                 ],pre.diff(@assign.dump.split("\n"))

  end

  must "2/11まで割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 11)
    assert_equal ["34 ______11_____________1______1", "35 ___0__________0______________", "36 _____3_0_______0____________0", "37 _300220330_________________10", "38 _2____0___220330_____________", "39 ______220330_________________", "40 ______1_____________12____1__", "41 __220330_____________________", "42 __330___0_3_____________0____", "43 _________00____1_0_1__1_2__1_", "44 ____3_3__31______0___________", "45 ________220330___0________2__", "46 _2____2__0220330_______0_____", "47 _0330_______1__00___1________", "48 _30_____220330______1________", "49 __220________________10______", "50 ____3__2____2___00____0__3_1_", "51 __0_220330_____00____________", "52 ___00____0_0___________0_____"
# "34 ______11_____________1______1",
#                   "35 ___0__________0______________",
#                   "36 _____3_0_______0____________0",
#                   "37 _300220330_________________10",
#                   "38 _2____0___220330_____________",
#                   "39 ______220330_________________",
#                   "40 ______1_____________12____1__",
#                   "41 __220330_____________________",
#                   "42 __330___0_3_____________0____",
#                   "43 _________00____1_0_1__1_2__1_",
#                   "44 ____3_3__31______0___________",
#                   "45 ________220330___0________2__",
#                   "46 _2____2__0220330_______0_____",
#                   "47 _0330_______1__00___1________",
#                   "48 _30_____220330______1________
# ",
#                   "49 __220________________10______",
#                   "50 ____3__2____2___00____0__3_1_",
#                   "51 __0_220330_____00____________",
#                   "52 ___00____0_0___________0_____"
                  # "34 ______11_____________1______1",
                  # "35 ___0220330____0______________",
                  # "36 _220_3_0_3_____0____________0",
                  # "37 __00_______________________10",
                  # "38 _2_3__0_220330_______________",
                  # "39 _330__2__330_________________",
                  # "40 ______1_____________12____1__",
                  # "41 __220330___220330____________",
                  # "42 __330___0_220330________0____",
                  # "43 _________00____1_0_1__1_2__1_",
                  # "44 ____3_____1______0___________",
                  # "45 _3_____220330____0________2__",
                  # "46 ______2__0_____________0_____",
                  # "47 _0__________1__00___1________",
                  # "48 __0_________________1________",
                  # "49 _____________________10______",
                  # "50 ____32_23___2___00____0__3_1_",
                  # "51 __022033022033000____________",
                  # "52 ___00____0_0___________0_____"
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
    assert_equal [[0, 1, 0, 1, 0], [0, 0, 0, 0, 0]
                 ],["2","3"].map{ |sft_str| @assign.roles_count_short(12,sft_str)}
  end
  must "2/11まで割付た後の夜勤候補のタイトロール" do
    @assign.assign_night(1,:dipth => 11)
    candidate_combination = @assign.candidate_combination_for_shift23_selected_by_cost(12)
    assert_equal [[3, 9, 10], [9, 3, 10]
                 ],["2","3"].map{ |sft_str| @assign.tight_roles(sft_str) }
  end
  
  must "2/11まで割付た後の tight & role_ids" do
    @assign.assign_night(1,:dipth => 11)
   assert_equal [[9], [9, 3], [9, 3], [9, 10], [9, 10], [9, 10]
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|  [9, 3, 10] & nurce.role_ids}
  end
  must "2/11まで割付た後の shift_remain" do
    @assign.assign_night(1,:dipth => 11)
   assert_equal [3, 3, 4, 5, 5, 2 #5, 4, 4, 3, 5, 2 #5, 3, 4, 5, 5, 2
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
   assert_equal [2093, 2786, 2143, 1498, 1498, 3292
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|   nurce.cost("2",[9, 3, 10])}
   assert_equal [1610, 1648, 750, 1152, 1152, 1948 # 433, 2786,  750, 1498, 682, 1948
                ], nurce_select(37,39,40,42,44,45).map{ |nurce|   nurce.cost(:night_total,[9, 3, 10])}
  end
  must "2/11まで割付た後の看護師群の Cost" do
    @assign.assign_night(1,:dipth => 11)
    @assign.night_mode = true
    assert_equal [ 1610.0, 1648.0, 750.0, 1152.0, 1152.0, 1948.0
                ], nurce_select(37,39,40,42,44,45).
      map{ |nurce| @assign.cost_of_nurce_combination([nurce],:night_total,[9, 3, 10])-2}
  end

  must "2/11まで割付た後の夜勤の候補" do
    @assign.assign_night(1,:dipth => 11)
   @assign.night_mode = true
    candidate_combination = @assign.candidate_combination_for_shift23_selected_by_cost(12)
    assert_equal [[[], [43]], [[], [40]], [[], [44]], [[], [42]], [[], [37]], [[], [35]]
                 ],hash_combination_ids(candidate_combination)
   end

  #####################################
  Log2_1_1 =
"### Hospital ASSIGN 2日 entry ###
  HP ASSIGN 34 ______11_____________1______1
  HP ASSIGN 35 ___0__________0______________
  HP ASSIGN 36 _3___3_0_______0____________0
  HP ASSIGN 37 __00_______________________10
  HP ASSIGN 38 _2____0______________________
  HP ASSIGN 39 _330_________________________
  HP ASSIGN 40 ______1_____________12____1__
  HP ASSIGN 41 _____________________________
  HP ASSIGN 42 ________0_______________0____
  HP ASSIGN 43 _________00____1_0_1__1_2__1_
  HP ASSIGN 44 ____3_____1______0___________
  HP ASSIGN 45 _2_______________0________2__
  HP ASSIGN 46 _________0_____________0_____
  HP ASSIGN 47 _0__________1__00___1________
  HP ASSIGN 48 __0_________________1________
  HP ASSIGN 49 _____________________10______
  HP ASSIGN 50 ____3__2____2___00____0__3_1_
  HP ASSIGN 51 __0____________00____________
  HP ASSIGN 52 ___00____0_0___________0_____
"
  def log2_1_1_set
    @assign.nurces = extract_set_shifts(Log2_1_1)
    @assign.refresh
    @nurce_pair = nurce_by_ids([41,49],@assign.nurces)
  end

  must "log2_1_1にて、41,49に2,220330 を割り当てると,assign_patern_if_possibleは成功" do 
    #2/5の必要ロールが00010になり割り当て不能 " do
    log2_1_1_set
    day ,sft_str,idx_list_of_long_patern = 2,"2",[2,0]

    assert_equal ["2","220330"],
    @assign.assign_patern_if_possible(@nurce_pair,day,sft_str,idx_list_of_long_patern).map(&:patern)
  end
  must "log2_1_1にて、41,49に2,220330 を割り当てると,merged_paternは" do 
    #2/5の必要ロールが00010になり割り当て不能 " do
    log2_1_1_set
    day ,sft_str,idx_list_of_long_patern = 2,"2",[2,0]
    list_of_long_patern = @assign.assign_patern_if_possible(@nurce_pair,day,sft_str,idx_list_of_long_patern)
    #          shift 0   1    2    3
   assert_equal [[2, 5], [], [1], [3, 4]], @assign.merged_patern(list_of_long_patern)
  end
  must "log2_1_1にて、41,49に2,220330 を割り当てると,5日のroles_able_be_filledは" do 
    #2/5の必要ロールが00010になり割り当て不能 " do
    log2_1_1_set
    day ,sft_str,idx_list_of_long_patern = 2,"2",[2,0]
    list_of_long_patern = @assign.assign_patern_if_possible(@nurce_pair,day,sft_str,idx_list_of_long_patern)
    #          shift 0   1    2    3
   assert_equal false, @assign.roles_able_be_filled?(5,"3")
  end
  must "log2_1_1にて、41,49に2,220330 を割り当てると,5日のroles_count_shortは" do 
    #2/5の必要ロールが00010になり割り当て不能 " do
    log2_1_1_set
    day ,sft_str,idx_list_of_long_patern = 2,"2",[2,0]
    list_of_long_patern = @assign.assign_patern_if_possible(@nurce_pair,day,sft_str,idx_list_of_long_patern)
    #          shift 0   1    2    3
   assert_equal [0, 0, 0, 1, 0], @assign.roles_count_short(5,"3")
  end
  must "log2_1_1にて、41,49に2,220330 を割り当てると,5日のneeds_all_daysは" do 
    #2/5の必要ロールが00010になり割り当て不能 " do
    log2_1_1_set
    day ,sft_str,idx_list_of_long_patern = 2,"2",[2,0]
    list_of_long_patern = @assign.assign_patern_if_possible(@nurce_pair,day,sft_str,idx_list_of_long_patern)
    #          shift 0   1    2    3
    assert_equal({ [3, "2"]=>[1, 1], [3, "3"]=>[1, 1],
                   [4, "3"]=>[2, 2], [4, "2"]=>[2, 2], [4, "1"]=>[6, 7],
                   [9, "3"]=>[1, 2], [9, "2"]=>[1, 2], [9, "1"]=>[1, 2],
                   [10, "3"]=>[1, 2], [10, "2"]=>[1, 2], [10, "1"]=>[1, 2], [4, "0"]=>[0, 8]
                 }, @assign.needs_all_days[day])
  end
 
end
