# -*- coding: utf-8 -*-
require 'test_helper'
#require 'need'

class Hospital::AssignCombinationTest < ActiveSupport::TestCase
  include Hospital::Const
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits,:hospital_defines
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign = Hospital::Assign.new(@busho_id,@month)
  end

  def nurce_set(ids)
    ids.map{ |id| Hospital::Nurce.find id}
  end

  def extract_set_shifts(string)
    nurces=[]
    string.each_line{|line|
      hp,assign,id,data = line.split(nil,4)
      case id
      when /^\d+$/
        nurces[id.to_i]=@assign.nurce_by_id(id.to_i)
       @assign.nurce_set_patern(nurces[id.to_i],1,data[1..-1].chop)
      when  /ENTRY/
      end
    }
    nurces.compact
  end

  def nurce_by_id(id,nurces)
    nurces.select{ |n| n.id}[0]
  end

  # [[1,2],[1,3]]
  def set_avoid(ary_of_ids)
    ary_of_ids.each{ |ids|
      Hospital::AvoidCombination.create(:nurce1_id => ids[0],:nurce2_id => ids[1],:weight => 2)
    }
  end

  log2_4 = 
"  HP ASSIGN 34 _1_1__11_____________1______1
  HP ASSIGN 35 _110___250330_0______________
  HP ASSIGN 36 _2503300_______0____________0
  HP ASSIGN 37 _200_______________________10
  HP ASSIGN 38 _1____0______________________
  HP ASSIGN 39 _112_________________________
  HP ASSIGN 40 _311__1_____________12____1__
  HP ASSIGN 41 __330________________________
  HP ASSIGN 42 ________0_______________0____
  HP ASSIGN 43 _1_______00____1_0_1__1_2__1_
  HP ASSIGN 44 _12_______1______0____3______
  HP ASSIGN 45 _311_____________0________2__
  HP ASSIGN 46 _1_2203300_____________0_____
  HP ASSIGN 47 _011________1__00___1________
  HP ASSIGN 48 __01________________1________
  HP ASSIGN 49 _12__________________10______
  HP ASSIGN 50 __11_2______2___00____0_33_1_
  HP ASSIGN 51 _103___________00____________
  HP ASSIGN 52 __300____0_0___________0_____
"
  [ [1,"3",[40,45]],[2,"2",[44,49]],[4,"2",[46]],[9,"3",[]]
  ].each{ |day,sft_str,ids|
    must " #{day}日 shift#{sft_str}の看護師は " do
      nurces = extract_set_shifts(log2_4)
      assert_equal ids,
         @assign.nurce_ids_of_the_day_shift(nurces,day,sft_str).sort
  end
  }

  longpatern = Hospital::Nurce::LongPatern[true][Sshift3]
  assigned_patern = [0,2]
  first_day = 8
  sft_str ="3"

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき avoid_なしk" do
    nurces = extract_set_shifts(log2_4)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [36,37].map{ |id| nurce_by_id(id,nurces)}
    assert_equal true,
    @assign.avoid_check(nurce_pair,sft_str,first_day,patern),"avoidなし"
  end

  must "  avoid_list" do
    set_avoid([[36,37]])
    @assign = Hospital::Assign.new(@busho_id,@month)
    assert_equal [[[36, 37], 2]],@assign.avoid_list
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき avoid_あり" do
    nurces = extract_set_shifts(log2_4)
    patern = assigned_patern.map{ |p| longpatern[p]}
    set_avoid([[36,37]])
    @assign = Hospital::Assign.new(@busho_id,@month)
    nurce_pair = [36,37].map{ |id| nurce_by_id(id,nurces)}
    assert_equal false,
    @assign.avoid_check(nurce_pair,sft_str,first_day,patern),"avoidあり"
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき assign_patern avoidなし" do
    nurces = extract_set_shifts(log2_4)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [36,37].map{ |id| nurce_by_id(id,nurces)}
    assert_equal true,
    @assign.assign_patern(nurce_pair,first_day,sft_str,assigned_patern),"avoidなし"
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき assign_patern avoidあり" do
    nurces = extract_set_shifts(log2_4)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [36,37].map{ |id| nurce_by_id(id,nurces)}
    set_avoid([36,37])
    assign = Hospital::Assign.new(@busho_id,@month)
    assert_equal false,
    assign.assign_patern(nurce_pair,first_day,sft_str,assigned_patern),"avoidあり"
  end

  must "看護師 1,2,3,4,5 に禁忌はない" do
    assign=Hospital::Assign.new(@busho_id,@month)
    assert_equal 0,assign.nurces_have_avoid_combination?(nurce_set([1,2,3,4,5]))
  end

  must "看護師 [1,2],[1,3]を禁忌にすると２" do
    Hospital::AvoidCombination.create(:nurce1_id => 1,:nurce2_id => 2,:weight => 2)
    Hospital::AvoidCombination.create(:nurce1_id => 1,:nurce2_id => 3,:weight => 3)
    assign=Hospital::Assign.new(@busho_id,@month)
    assert_equal 5,assign.nurces_have_avoid_combination?(nurce_set([1,2,3,4,5]))
  end
end
