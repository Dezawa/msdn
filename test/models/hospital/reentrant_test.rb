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
    assert_equal [[[51, 35], [36, 39]], [[51, 45], [36, 39]], [[51, 38], [36, 39]],
                  [[51, 35], [45, 39]], [[51, 35], [48, 45]], [[45, 38], [36, 39]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(1))
  end
  must "2/1 夜の看護師候補の割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1)
    assert_equal [["35 ___0__________0______________",
                   "36 _____3_0_______0____________0",
                   "39 _____________________________",
                   "51 __0____________00____________"],
                  ["35 _220330_______0______________",
                   "36 _30__3_0_______0____________0",  # 深夜２回まで
                   "39 _330_________________________",
                   "51 _20____________00____________"]
                 ],pre.diff(@assign.dump.split("\n"))
  end

  must "2/1割り付けたのち、2/2のshift3候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    sft_str = "3"
    #             x   4A 35A 349 49A 349
    assert_equal [34, 46, 52, 38, 42, 41
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,@assign.short_role(day,sft_str)).map(&:id)
  
    assert_equal [0, 1, 0, 0, 1],@assign.roles_count_short(day,sft_str),
    "2/1割り付けたのち、2/2のshift#{sft_str}不足ロール"
    assert_equal [[46],[42]
                 ],combination_ids(@assign.candidate_combination_for_shift_with_enough_role(day,sft_str)),
    "2/1割り付けたのち、2/2のshift#{sft_str}ロール満たす組み合わせ"
  end

  must "2/1割り付けたのち、2/2のshift2候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    sft_str = "2"
    assert_equal [34, 46, 38, 49, 52, 45
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,@assign.short_role(day,sft_str)).map(&:id)

    assert_equal [1, 1, 0, 0, 1],@assign.roles_count_short(day,sft_str),
    "2/1割り付けたのち、2/2のshift#{sft_str}不足ロール"

    assert_equal [[49]
                 ],combination_ids(@assign.candidate_combination_for_shift_with_enough_role(2,"2")),
    "2/1割り付けたのち、2/2のshift#{sft_str}ロール満たす組み合わせ"
  end

  must "2/1割り付けたのち、2/2の夜の候補" do
    @assign.assign_night(1,:dipth => 1)
    day = 2
    assert_equal [[[49], [46]], [[49], [42]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(day))
  end

  must "2/1割り付けたのちの、 shift1_is_enough?" do
    @assign.assign_night(1,:dipth => 1)
    assert !@assign.assign_night(2,:dipth => 1)
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
                   "36 _30__3_0_______0____________0",  # 深夜２回まで
                   "38 _20___0______________________",
                   "39 _330_________________________",
                   "51 _20____________00____________"]
                 ],pre.diff(@assign.dump.split("\n"))
  end

  # must "2/5まで割付" do
  #   pre = @assign.dump.split("\n")
  #   @assign.assign_night(1,:dipth => 5)
  #   assert_equal [["34 ______11_____________1______1",
  #                  "35 ___0__________0______________",
  #                  "36 _____3_0_______0____________0",
  #                  "42 ________0_______________0____",
  #                  "45 _________________0________2__",
  #                  "46 _________0_____________0_____",
  #                  "51 __0____________00____________",
  #                  "52 ___00____0_0___________0_____"],
  #                 ["34 _2033011_____________1______1",
  #                  "35 __2020________0______________",
  #                  "36 _30203_0_______0____________0", 
  #                  "42 _____2200_______________0____",
  #                  "45 _30__330_________0________2__",
  #                  "46 _20330___0_____________0_____",
  #                  "51 __0220330______00____________",
  #                  "52 __200220_0_0___________0_____"]

  #                ],pre.diff(@assign.dump.split("\n"))
  # end
end
