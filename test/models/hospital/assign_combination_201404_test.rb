# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
#require 'need'

class Hospital::AssignCombination201404Test < ActiveSupport::TestCase
  include Hospital::Const
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits","hospital/defines"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2014,4,1)
    @busho_id =  1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @assign.refresh
    @nurces = @assign.nurces
    @assign.night_mode = true
    srand(1)
  end

  day = 1
  must "4/1の need_nurces_of_night" do
    assert_equal( {"2"=>2, "3"=>2}, @assign.need_nurces_of_night(day) )
  end

   must "4/1の short_roles_of_night" do
     assert_equal( {"2"=>[3,4,9,10], "3"=>[3,4,9,10]}, @assign.short_roles_of_night(day) )
   end

   must "4/1の nurces_selected_of_night" do
       short_roles = @assign.short_roles_of_night(day)
     assert_equal( [[34, 46, 47, 52, 37, 42, 38, 36], [34, 46, 47, 52, 37, 42, 38, 36]],
                   @assign.nurces_selected_of_night(day,short_roles).map{ |sft,nurces| nurces.map(&:id)} )
   end

   must "4/1のassinable_nurces(day)" do
     sft_str ="2"
    assert_equal [34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52],
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

     sft_str ="2"
   must "4/1のcost" do
     pp @assign.tight_roles(sft_str)
     assinable_nurces=@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str))
     cost = assinable_nurces.map{ |n| n.cost(:night_total,@assign.tight_roles(sft_str))} # tight_roles [10, 3, 9] 
     assert_equal [ 0, 1610, 1330, 433,             # 34, 35, 36, 37
                    577, 577, 577, 577,             # 38, 39, 40, 41
                    524, 524, 524, 524,             # 42, 43, 44, 45
                    358,                            # 46, 
                    477, 477, 477, 477, 477, 477    # 47, 48, 49, 50, 51, 52
                  ] , cost.map(&:to_i)
   end

   must "4/1のgather_by_each_group_of_role " do
     assinable_nurces=@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str))
     gather_by_each_group_of_role = @assign.gather_by_each_group_of_role(assinable_nurces,sft_str,[3,4,9,10])
   
     assert_equal [[34], [46, 36], [47, 48, 49, 50, 51], [52], [37, 35], [42, 43, 44, 45], [38, 39, 40, 41]
                  ] , gather_by_each_group_of_role.map{ |g| g.map(&:id)}
   end
  must "4/1のcandidate_combination_for_shift_selected_by_cost" do
    assert_equal [[[47, 37]], [[47, 42]]
                 ], hash_combination_ids(@assign.candidate_combination_for_shift_selected_by_cost(day,sft_str))
  end
  must "4/1のcandidate_combination_for_shift_selected_by_cost" do
    assert_equal [[[47, 37]], [[46, 38]], [[47, 42]], [[47, 38]], [[42, 38]], [[38, 36]]
                 ], hash_combination_ids(@assign.candidate_combination_for_shift_selected_by_cost(day,"3"))
  end

  # # must "4/1のneed_nurces_roles(day)のas_nurces_selected" do
  # #   setup_5F
  # #   assert_equal [[26, 5, 25, 6, 20, 7],[] ],
  # #   @assign.need_nurces_roles(day)[0].map{ |cmb| cmb[1].map(&:id)}
  # # end

  # must "4/1のID 24は、kchrecはOKだが" do
  #   setup_5F
  #   nurce = @assign.nurce_by_id(24)
  #   assert_equal [3,4],@assign.short_role(day,sft_str).map{|r,mi_max| r }
  #   assert_equal 3 , nurce.shift_remain[sft_str]
  #   assert_equal [4,9,10],nurce.need_role_ids
  #   has_role = nurce.has_assignable_roles_atleast_one(sft_str, @assign.short_role(day,Sshift2).map{|r,mi_max| r })
  #   assert  has_role
  # end

  # must "4/1のID 1 のcheck_at_assign[5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22, 25, 26]" do
  #   setup_5F
  #   check = [5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26].
  #     map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
  #     map{ |nurce| nurce.check_at_assign(day,sft_str)}
  #   assert_equal [nil]*15,check
  # end 

  # nine_night = [[:nine_nights, true]]
  # after = [[:after_nights, 0]]
  # yakin = [[:yakinrenzoku, 0]]
  # space = [[:no_space, true]]
  # must "4/1のID 1 のcheck_at_assign [1,2,3,4,31,32,33]" do
  #   setup_5F
  #   check = [1,2,3,4,31,32,33,23].
  #     map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
  #     map{ |nurce| nurce.check_at_assign(day,sft_str)}
  #   assert_equal [[[:kinmu_total, true]]]*7+[yakin],check
  # end

  # must "4/1のID 1 のcheck_at_assign[8,9]" do
  #   setup_5F
  #   check = [8,9].
  #     map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
  #     map{ |nurce| nurce.check_at_assign(day,sft_str)}
  #   assert_equal [nine_night,nine_night],check
  # end

  # must "4/1のID 1 のcheck_at_assign[10,13,14,15,29,30,27,28]" do
  #   setup_5F
  #   check = [10,13,14,15,27,28,29,30].
  #     map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
  #     map{ |nurce| nurce.check_at_assign(day,sft_str)}
  #   assert_equal [space]*8,check
  # end

  # ######### 2014/4 の新規割付
end
