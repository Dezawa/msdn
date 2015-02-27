# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
#require 'need'

class Hospital::AssignCombinationTest < ActiveSupport::TestCase
  include Hospital::Const
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits","hospital/defines"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id =  1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @assign.refresh
    @nurces = @assign.nurces
    @nurce = @assign.nurces[4]
    @assign.night_mode = true
    srand(1)
  end

  def setup_5F
    limit([1,2,3,4,31,32,33,8,9].zip( [Limit00]*7+[Limit510]*2))
    @month  = Date.new(2013,3,1)
    @busho_id =  3
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = @assign.nurces = extract_set_shifts(Log2_5)
    @assign.refresh
    @assign.night_mode = true
  end

  def limit(arg)# [ [nurce_id,limit],[ ],,,]
    arg.each{ |nurce_id,limits|
      #pp [nurce_id,nurce_by_id(nurce_id,@nurces)]
      Hospital::Nurce.find(nurce_id).limit.update_attributes(limits)
    }
  end


  Limit00  = { :night_total => 0,:kinmu_total => 0 }
  Limit510 = { :night_total => 5,:kinmu_total => 10 }


  sft_str = "2"
  day = 15
  require './test/unit/hospital/make_comb_testdata.rb'

  must "update" do
    pp Hospital::Nurce.find(1).hospital_roles.map(&:id)
    update
    pp Hospital::Nurce.find(1).hospital_roles.map(&:id)
  end

  must "3/15の need_nurces_of_night" do
    setup_5F
    assert_equal( {"2"=>1, "3"=>0}, @assign.need_nurces_of_night(day) )
  end

  must "3/15の short_roles_of_night" do
    setup_5F
    assert_equal( {"2"=>[3,4], "3"=>[3]}, @assign.short_roles_of_night(day) )
  end

  must "3/15の nurces_selected_of_night" do
    setup_5F
    short_roles = @assign.short_roles_of_night(day)
    assert_equal( [[26, 5, 25, 6, 20, 7, 19, 11, 18, 16], []],
                  @assign.nurces_selected_of_night(day,short_roles).map{ |sft,nurces| nurces.map(&:id)} )
  end

  # must "3/15のneed_nurces_roles(day)のneed_nurces" do
  #   setup_5F
  #   assert_equal [ {"3"=>0, "2"=>1},  {"2"=>[3,4], "3"=>[3]}
  #                ], @assign.need_nurces_roles(day)[1,2] # [as_nurces_selected,need_nurces, short_roles] 
  # end
  
  must "3/15のshort_role(day)" do
    setup_5F
    assert_equal [3,4],    @assign.short_role(day,"2")
  end

  must "3/15のassinable_nurces(day)" do
    sft_str ="2"
      setup_5F
      assert_equal [5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26] ,
      @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  must "3/15のcost" do
    setup_5F
    pp @assign.tight_roles(sft_str)
    assinable_nurces=@assign.nurce_by_id([5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26])
    cost = assinable_nurces.map{ |n| n.cost(:night_total,@assign.tight_roles(sft_str))} # tight_roles [10, 3, 9] 
    assert_equal [ 1498, 1498, 1498,              #  5, 6, 7        220330 349
                   1648, 2786, 1648,              # 11, 12, 16      22033,2332033,22033 3410
                   1463,                          # 17              __  410  j夜勤上限 2,2
                   1126, 1126, 1126, 1126, 1126,  # 18,19,20 21,22  220330 410
                   1362,                          # ,24             220330 4910
                   806, 806                      # 25, 26          220      49
                 ] , cost.map(&:to_i)
  end

  must "3/15のgather_by_each_group_of_role " do
    setup_5F
    assinable_nurces=@assign.nurce_by_id([5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26])
    gather_by_each_group_of_role = @assign.gather_by_each_group_of_role(assinable_nurces,"2",[3,4])
    
    assert_equal [[26, 25, 20, 19, 18, 22, 21, 24, 17], [5, 6, 7, 11, 16, 12]
                 ] , gather_by_each_group_of_role.map{ |g| g.map(&:id)}
  end

  # must "3/15のneed_nurces_roles(day)のas_nurces_selected" do
  #   setup_5F
  #   assert_equal [[26, 5, 25, 6, 20, 7],[] ],
  #   @assign.need_nurces_roles(day)[0].map{ |cmb| cmb[1].map(&:id)}
  # end

  must "3/15のID 24は、kchrecはOKだが" do
    setup_5F
    nurce = @assign.nurce_by_id(24)
    assert_equal [3,4],@assign.short_role(day,sft_str).map{|r,mi_max| r }
    assert_equal 3 , nurce.shift_remain[sft_str]
    assert_equal [4,9,10],nurce.need_role_ids
    has_role = nurce.has_assignable_roles_atleast_one(sft_str, @assign.short_role(day,Sshift2).map{|r,mi_max| r })
    assert  has_role
  end

  must "3/15のID 1 のcheck_at_assign[5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22, 25, 26]" do
    setup_5F
    check = [5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26].
      map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
      map{ |nurce| nurce.check_at_assign(day,sft_str)}
    assert_equal [nil]*15,check
  end 

  nine_night = [[:nine_nights, true]]
  after = [[:after_nights, 0]]
  yakin = [[:yakinrenzoku, 0]]
  space = [[:no_space, true]]
  must "3/15のID 1 のcheck_at_assign [1,2,3,4,31,32,33]" do
    setup_5F
    check = [1,2,3,4,31,32,33,23].
      map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
      map{ |nurce| nurce.check_at_assign(day,sft_str)}
    assert_equal [[[:kinmu_total, true]]]*7+[yakin],check
  end

  must "3/15のID 1 のcheck_at_assign[8,9]" do
    setup_5F
    check = [8,9].
      map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
      map{ |nurce| nurce.check_at_assign(day,sft_str)}
    assert_equal [nine_night,nine_night],check
  end

  must "3/15のID 1 のcheck_at_assign[10,13,14,15,29,30,27,28]" do
    setup_5F
    check = [10,13,14,15,27,28,29,30].
      map{ |nurce_id| @assign.nurce_by_id(nurce_id)}.
      map{ |nurce| nurce.check_at_assign(day,sft_str)}
    assert_equal [space]*8,check
  end

  # must "3/15のnurce_combination_by_tightness shift2" do
  #   setup_5F
  #   sft_str ="2"
  #   day = 15
  #   as_nurces_selected,need_nurces, short_roles = @assign.need_nurces_roles(day)
  #   assert_equal [[5], [6], [7]],
  #                # [[1, 22, 2, 6],   #  1 2 3 5 6 10 11 22 24 25
  #                #  [1, 5, 22, 2],   #  9 9 2 2 1  4  3  2  2  2   36
  #                #  [1, 10, 24, 2],
  #                #  [1, 2, 25, 11],
  #                #  [1, 24, 2, 11],
  #                #  [1, 3, 10, 2],
  #                #  [1, 10, 2, 25],
  #                #  [1, 3, 2, 11],
  #                #  [1, 5, 10, 2]],
  #   @assign.nurce_combination_by_tightness(as_nurces_selected[sft_str],#[0..SelectedMax],
  #                                          need_nurces[sft_str], #@assign.need_nurces_shift(day,sft_str),
  #                                          short_roles[sft_str],sft_str)[0,6].
  #     map{ |nurces| 
  #     #@assign.cost_of_nurce_combination(nurces,sft_str,@assign.tight_roles(sft_str))
  #     nurces.map(&:id)
  #   }[0,9]
    
  # end
  
end
__END__
   # [[1,2],[1,3]]
  def set_avoid(ary_of_ids)
    ary_of_ids.each{ |ids|
      Hospital::AvoidCombination.create(:nurce1_id => ids[0],:nurce2_id => ids[1],:weight => 2)
    }
  end

 [ [1,"3",[40,45]],[2,"2",[44,49]],[4,"2",[46]],[9,"3",[]]
  ].each{ |day,sshift,ids|
    must " #{day}日 shift#{sshift}の看護師は " do
      @assign.nurces = nurces = extract_set_shifts(Log2_3)
      assert_equal ids,
      @assign.nurce_ids_of_the_day_shift(nurces,day,sshift).sort
    end
  }

  longpatern = Hospital::Nurce::LongPatern[true][Sshift3]
  assigned_patern = [0,2]
  first_day = 9
  sft_str ="3"

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき avoid_なしk" do
    nurces = extract_set_shifts(Log2_3)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [38,45].map{ |id| nurce_by_id(id,@assign.nurces)}
    assert_equal true,
    @assign.avoid_check(nurce_pair,sft_str,first_day,patern),"avoidなし"
  end

  must "  avoid_list" do
    set_avoid([[38,45]])
    @assign = Hospital::Assign.new(@busho_id,@month)
    assert_equal [[[38,45], 2]],@assign.avoid_list
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき avoid_あり" do
    nurces = extract_set_shifts(Log2_3)
    patern = assigned_patern.map{ |p| longpatern[p]}
    set_avoid([[38,45]])
    @assign = Hospital::Assign.new(@busho_id,@month)
    nurces = [38,45].map{ |id| nurce_by_id(id,@assign.nurces)}
    assert @assign.assign_patern_if_possible(nurces,first_day,sft_str,assigned_patern)
    assert_equal false,
    @assign.avoid_check(nurces,sft_str,first_day,patern),"avoidあり"
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき assign_patern avoidなし" do

    nurces = extract_set_shifts(Log2_3)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [38,45].map{ |id| nurce_by_id(id,@assign.nurces)}
    #assert_equal true,
    @assign.assign_patern(nurce_pair,first_day,sft_str,assigned_patern)#,"avoidなし"
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき assign_patern avoidあり" do
    
    nurces = extract_set_shifts(Log2_3)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [38,45].map{ |id| nurce_by_id(id,@assign.nurces)}
    set_avoid([38,45])
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
