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
    assert_equal [[[51, 35], [36, 39]], [[38, 46], [36, 39]], [[51, 45], [36, 39]], 
                  [[35, 49], [36, 39]], [[51, 38], [36, 39]], [[51, 35], [45, 39]],
                  [[36, 38], [45, 39]], [[45, 38], [36, 39]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(1))
  end
  must "2/1 夜の看護師候補の割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1)
    assert_equal [["35 ___0__________0______________",
                   "36 _____3_0_______0____________0",
                   "39 _____________________________",
                   "51 __0____________00____________"],
                  ["35 _220__________0______________",
                   "36 _3___3_0_______0____________0",  # 深夜２回まで
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
    assert_equal [34, 36, 38, 49, 52, 46
                 ], @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                                  @assign.short_role(day,sft_str)).map(&:id)

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
    assert_equal false,  @assign.assign_night(2,:dipth => 1)
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
    assert_equal([[[49, 35], [46]],   [[49, 45], [46]],   [[49, 35], [42]],   [[49, 45], [42]]
                 ],hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(day)),
                  "2/2 夜の看護師候補"
)

 
  end

  must "combinationを引数で渡す" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1,:nurce_combinations => @assign.candidate_combination_for_shift23_selected_by_cost(1))
    assert_equal [["35 ___0__________0______________",
                   "36 _____3_0_______0____________0",
                   "39 _____________________________",
                   "51 __0____________00____________"],
                  ["35 _220__________0______________",
                   "36 _3___3_0_______0____________0",  # 深夜２回まで
                   "39 _330_________________________",
                   "51 _20____________00____________"]
                 ],pre.diff(@assign.dump.split("\n"))

  end

   must "2/14まで割付" do
     pre = @assign.dump.split("\n")
     @assign.assign_night(1,:dipth => 18)
    puts @assign.dump.split("\n")
   end
end
