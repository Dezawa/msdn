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
    @busho_id =  1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = @assign.nurces
    @nurce = @assign.nurces[4]
  end

  def setup_5F
    limit([1,2,3,4,31,32,33,8,9].zip( [Limit00]*7+[Limit510]*2))
    @month  = Date.new(2013,3,1)
    @busho_id =  3
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = @assign.nurces
    setup_5Fafter
  end
  def setup_5Fafter
    extract_set_shifts(Log2_5)
    @assign.refresh
    @assign.night_mode = true
  end

  def limit(arg)# [ [nurce_id,limit],[ ],,,]
    arg.each{ |nurce_id,limits|
#pp [nurce_id,nurce_by_id(nurce_id,@nurces)]
      Hospital::Nurce.find(nurce_id).limit.update_attributes(limits)
    }
  end


  def nurce_set(ids)
    ids.map{ |id| Hospital::Nurce.find id}
  end

  def extract_set_shifts(string)
    nurces=[]
    string.each_line{|line|
      hp,assign,id,data,dmy = line.split(nil,5)
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
    nurces.select{ |n| n.id == id}[0]
  end

Log2_5 = "
assign_by_re_entrant
  HP ASSIGN 1 ________________________________   4
  HP ASSIGN 2 ________________________________   4
  HP ASSIGN 3 ________________________________   4
  HP ASSIGN 4 ________________________________  349
  HP ASSIGN 5 _______220330___________________  349  2533    3
  HP ASSIGN 6 _____220330_____________________  349  2533    3
  HP ASSIGN 7 ___220330_______________________  349  2533    3
  HP ASSIGN 8 _30220330_______________________   49            0
  HP ASSIGN 9 _220330______2__________________   49            0
  HP ASSIGN 10 _____________220330_____________ 34910        3
  HP ASSIGN 11 _220330_________________________ 3410   2786   3
  HP ASSIGN 12 __330____220330_________________ 3410   2786   3
  HP ASSIGN 13 _30________220330_______________  410          3
  HP ASSIGN 14 __220_________220330____________  410        4
  HP ASSIGN 15 _2__________220330______________  410           2
  HP ASSIGN 16 ________220330__________________ 3410   2786   3
  HP ASSIGN 17 ________________________________  410   2474    2
  HP ASSIGN 18 _330220_________________________  410   1903   3
  HP ASSIGN 19 ____220330______________________  410   1903   3
  HP ASSIGN 20 ______220330____________________  410   1903   3
  HP ASSIGN 21 __220330________________________  410   1903   3
  HP ASSIGN 22 _______220330___________________  410   1903   3  
  HP ASSIGN 23 _2__________220_________________  410         2
  HP ASSIGN 24 _________220330_________________  4910  1730   3
  HP ASSIGN 25 __________220___________________  4910  1730   3
  HP ASSIGN 26 ________220_____________________  4910  1730   3
  HP ASSIGN 27 ___________220330_______________               3
  HP ASSIGN 28 __________220330________________               3
  HP ASSIGN 29 ___330220_____220330____________                 1
  HP ASSIGN 30 __330220330___220_______________                 1
  HP ASSIGN 31 ________________________________
  HP ASSIGN 32 ________________________________
  HP ASSIGN 33 ________________________________
HP   5
"
Limit00  = { :night_total => 0,:kinmu_total => 0 }
Limit510 = { :night_total => 5,:kinmu_total => 10 }


    sft_str = "2"
    day = 15
require 'test/unit/hospital/make_comb_testdata'
must "update" do
pp Hospital::Nurce.find(1).hospital_roles.map(&:id)
    update
pp Hospital::Nurce.find(1).hospital_roles.map(&:id)

end
end
__END__

  must "3/15のneed_nurces_roles(day)のneed_nurces、short_roles" do
    setup_5F
    assert_equal [ {"3"=>0, "2"=>1},
                   {"3"=>[], "2"=>[4]}
                 ], @assign.need_nurces_roles(day)[1,2]
  end
  
  must "3/15のassinable_nurces(day)" do
    setup_5F
    assert_equal [5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26] ,
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  must "3/15のassinable_nurces(day)" do
    setup_5F
    assert_equal [5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26] ,
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end
  must "3/15のcost" do
    setup_5F
    pp @assign.tight_roles(sft_str)
    assinable_nurces=@assign.nurce_by_id([5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26])
    cost = assinable_nurces.map{ |n| n.cost(sft_str,@assign.tight_roles(sft_str))} # tight_roles [10, 3, 9] 
    assert_equal [ 2533, 2533, 2533,              # 5, 6, 7
                   2786, 2786, 2786,              # 11, 12, 16
                   2474,                          # 17
                   1903, 1903, 1903, 1903, 1903,  # 18, 19, 20, 21, 22
                   1730, 1730, 1730               # 24, 25, 26
                 ] , cost
  end
  must "3/15のgather_by_each_group_of_role の key" do
    setup_5F
    assinable_nurces=@assign.nurce_by_id([5, 6, 7, 11, 12, 16, 17, 18, 19, 20, 21, 22,24, 25, 26])
    gather_by_each_group_of_role = @assign.gather_by_each_group_of_role(assinable_nurces,sft_str,[4])
    assert_equal [[17, 
                   26, 25, 24, 22, 21, 20, 19, 18, 5, 6, 7, 17, 12, 16, 11]] , gather_by_each_group_of_role.map{ |g| g.map(&:id)}
  end

  #
  #
  #
  #
  must "3/15のneed_nurces_roles(day)のas_nurces_selected" do
    setup_5F
     assert_equal [[],[27, 4, 11, 19, 23, 24, 30, 5] ],
    @assign.need_nurces_roles(day)[0].map{ |cmb| cmb[1].map(&:id)}
  end
  must "3/15のID 24は、kchrecはOKだが" do
    setup_5F
    nurce = @assign.nurce_by_id(24)
    assert_equal [4],@assign.short_role(day,sft_str).map{|r,mi_max| r }
    assert_equal 3 , nurce.shift_remain[sft_str]
    assert_equal [4,9],nurce.role_ids
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

  must "3/15のnurce_combination_by_tightness shift2" do
    setup_5F

    as_nurces_selected,need_nurces, short_roles = @assign.need_nurces_roles(day)
    assert_equal [[1, 22, 2, 6],   #  1 2 3 5 6 10 11 22 24 25
                  [1, 5, 22, 2],   #  9 9 2 2 1  4  3  2  2  2   36
                  [1, 10, 24, 2],
                  [1, 2, 25, 11],
                  [1, 24, 2, 11],
                  [1, 3, 10, 2],
                  [1, 10, 2, 25],
                  [1, 3, 2, 11],
                  [1, 5, 10, 2]],
    @assign.nurce_combination_by_tightness(as_nurces_selected[sft_str],#[0..SelectedMax],
                                       need_nurces[sft_str], #@assign.need_nurces_shift(day,sft_str),
                                       short_roles[sft_str],sft_str)[0,6].
      map{ |nurces| 
      #@assign.cost_of_nurce_combination(nurces,sft_str,@assign.tight_roles(sft_str))
      nurces.map(&:id)
    }[0,9]
      
  end
end
__END__

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
  first_day = 9
  sft_str ="3"

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき avoid_なしk" do
    nurces = extract_set_shifts(log2_4)
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
    nurces = extract_set_shifts(log2_4)
    patern = assigned_patern.map{ |p| longpatern[p]}
    set_avoid([[38,45]])
    @assign = Hospital::Assign.new(@busho_id,@month)
    nurces = [38,45].map{ |id| nurce_by_id(id,@assign.nurces)}
    assert @assign.assign_patern_if_possible(nurces,first_day,sft_str,assigned_patern)
    assert_equal false,
    @assign.avoid_check(nurces,sft_str,first_day,patern),"avoidあり"
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき assign_patern avoidなし" do

    nurces = extract_set_shifts(log2_4)
    patern = assigned_patern.map{ |p| longpatern[p]}
    nurce_pair = [38,45].map{ |id| nurce_by_id(id,@assign.nurces)}
    #assert_equal true,
    @assign.assign_patern(nurce_pair,first_day,sft_str,assigned_patern)#,"avoidなし"
  end

  must " #{first_day}日 shift#{sft_str} assigned_patern #{assigned_patern}のとき assign_patern avoidあり" do
 
   nurces = extract_set_shifts(log2_4)
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
