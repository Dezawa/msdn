# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

class Hospital::CandidateTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes","hospital/defines"
  # Replace this with your real tests.
  def setup
    srand(1)
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = @assign.nurces
   end

# HP ASSIGN 1日entry-1  初期値
#   HP ASSIGN 34 ______11_____________1______1
#   HP ASSIGN 35 ___0__________0______________
#   HP ASSIGN 36 ____3__0_______0____________0
#   HP ASSIGN 37 __00_______________________10
#   HP ASSIGN 38 ______0______________________
#   HP ASSIGN 39 _____________________________
#   HP ASSIGN 40 ______1_____________12____1__
#   HP ASSIGN 41 _____________________________
#   HP ASSIGN 42 ________0_______________0____
#   HP ASSIGN 43 _________00____1_0_1__1_2__1_
#   HP ASSIGN 44 __________1______0____3______
#   HP ASSIGN 45 _________________0________2__
#   HP ASSIGN 46 _________0_____________0_____
#   HP ASSIGN 47 _0__________1__00___1________
#   HP ASSIGN 48 __0_________________1________
#   HP ASSIGN 49 _____________________10______
#   HP ASSIGN 50 _____2______2___00____0_33_1_
#   HP ASSIGN 51 __0____________00____________
#   HP ASSIGN 52 ___00____0_0___________0_____
# HP ASSIGN (322)1:2 Try 1 of 35
 ShiftUsedNurce =
[[4, 0, 0, 0, 4], [0, 0, 0, 0, 0], [0, 0, 1, 1, 1], [1, 0, 0, 0, 1], [0, 0, 0, 0, 0],
 [0, 0, 0, 0, 0], [3, 1, 0, 1, 4], [0, 0, 0, 0, 0], [0, 0, 0, 0, 0], [4, 1, 0, 1, 5]]

  must "2/1割付時点でのシフト割り当て数" do
    assert_equal ShiftUsedNurce ,
    @nurces[0,10].map{ |nurce| ["1","2","3",:night_total,:kinmu_total].
      map{ |sft|nurce.shift_used[sft]}}
  end
  ShiftRemainNurce =
[[16,2, 2, 4,18], [20,2, 2, 4,22], [20,2, 1, 3,21], [19,5, 5, 9,21], [20,5, 5, 9,22],
 [20,5, 5, 9,22], [17,4, 5, 8,18], [20,5, 5, 9,22], [20,5, 5, 9,22], [16,4, 5, 8,17]]

  must "2/1割付時点でのシフト残数" do
    assert_equal ShiftRemainNurce ,
    @nurces[0,10].map{ |nurce| ["1","2","3",:night_total,:kinmu_total].
      map{ |sft|nurce.shift_remain[sft]}}
  end

  RoleRemainNurce =
{ "2" => [[0, 2, 0, 0], [0, 2, 2, 0], [0, 2, 0, 2], [0, 5, 5, 0], [5, 5, 5, 0], [5, 5, 5, 0], [4, 4, 4, 0], [5, 5, 5, 0], [0, 5, 5, 5], [0, 4, 4, 4], [0, 5, 5, 5], [0, 4, 4, 4], [0, 5, 0, 5], [5, 5, 0, 5], [5, 5, 0, 5], [5, 5, 0, 5], [3, 3, 0, 3], [5, 5, 0, 5], [5, 0, 0, 5]],
    "3" =>[[0, 2, 0, 0], [0, 2, 2, 0], [0, 1, 0, 1], [0, 5, 5, 0], [5, 5, 5, 0], [5, 5, 5, 0], [5, 5, 5, 0], [5, 5, 5, 0], [0, 5, 5, 5], [0, 5, 5, 5], [0, 4, 4, 4], [0, 5, 5, 5], [0, 5, 0, 5], [5, 5, 0, 5], [5, 5, 0, 5], [5, 5, 0, 5], [3, 3, 0, 3], [5, 5, 0, 5], [5, 0, 0, 5]],
:night_total => 
[[0, 4, 0, 0], [0, 4, 4, 0], [0, 3, 0, 3], [0, 9, 9, 0], [9, 9, 9, 0], [9, 9, 9, 0], [8, 8, 8, 0], [9, 9, 9, 0], [0, 9, 9, 9], [0, 8, 8, 8], [0, 8, 8, 8], [0, 8, 8, 8], [0, 9, 0, 9], [9, 9, 0, 9], [9, 9, 0, 9], [9, 9, 0, 9], [5, 5, 0, 5], [9, 9, 0, 9], [9, 0, 0, 9]]
}
["2","3",:night_total].each{ |sft|
    must "2/1割付時点でのShift #{sft} ロール残数" do
      assert_equal RoleRemainNurce[sft] ,
      @nurces.map{ |nurce| roles2factor(nurce.role_ids).times(nurce.shift_remain[sft] )}
    end 
  }

  must "2/1割付時点での全体の ロール残数" do
    assert_equal [[47, 76, 44, 53], [48, 77, 46, 53]],
    ["2","3"].map{|sft| @nurces.
      map{ |nurce| roles2factor(nurce.role_ids).
        times(nurce.shift_remain[sft] )
      }.inject{ |s,a| s.add a}
    }
  end 

RolesShortDay =
    [ { }, # 0日
      { "2" => [1,2,1,1],"3" =>[1,2,1,1]},  # 1日。[shift 2での不足],[shift 3での不足]
      { "2" => [1,2,1,1],"3" =>[1,2,1,1]},  # 2日。[role3,4,9,10の不足],[shift 3での不足]
      { "2" => [1,2,1,1],"3" =>[1,2,1,1]},  # 3日
      { "2" => [1,2,1,1],"3" =>[0,0,0,0]},  # 4日
    ]
  [1,2,3,4].each{ |day|
    ["2","3"].each{ |sft|
      must "#{day}日 Shift #{sft} 割り当て不足ロール数" do
        assert_equal RolesShortDay[day][sft] ,
        [3,4,9,10].map{ |role_id| @assign.short_role_shift[day][[role_id,sft]].first}
      end 
    }
  }

RolesRequired_total =
{ "2" => [28, 56, 28, 28],"3" => [28, 56, 28, 28]#:night_total => [56, 112, 56, 56]
}
["2","3"].each{ |sft|
    must "Shift #{sft} ロール必要総数" do
      assert_equal RolesRequired_total[sft] ,
      [3,4,9,10].map{ |role_id| @assign.roles_required_total[[role_id,sft]]}
    end 
  }

RoleRequireNow =
{ "2" => [25, 51, 25, 24],"3" => [26, 52, 27, 25],:night_total => [85, 138, 81, 95]
}
["2","3"].each{ |sft|
    must "Shift #{sft} ロール必要残り数" do
      assert_equal RoleRequireNow[sft] ,
      [3,4,9,10].map{ |role_id| @assign.roles_required[[role_id,sft]]}
    end 
  }

RoleRemain =
{ "2" => [47, 76, 44, 53],"3" => [48, 77, 46, 53],:night_total => [85, 138, 81, 95]
}
["2","3",:night_total].each{ |sft|
    must "2/1割付時点でのShift #{sft} ロール残数" do
      assert_equal RoleRemain[sft] ,
      [3,4,9,10].map{ |role_id| @assign.role_remain[[role_id,sft]]}
    end 
  }


  # RoleRemain = { "2" => [47, 76, 44, 53],"3" => [48, 77, 46, 53] }
 MarginOfRole =
{ "2" => [22, 25, 19, 29],"3" => [22, 25, 19, 28]#:night_total => [56, 112, 56, 56]
}
["2","3"].each{ |sft|
    must "Shift #{sft} ロール余裕数" do
      assert_equal MarginOfRole[sft] ,
      [3,4,9,10].map{ |role_id| @assign.margin_of_role[[role_id,sft]]}
    end 
  }
  
  TigntRoles =
{"2" => [9,3,10,4],"3" => [9,3,10,4],:night_total => [9,3,10,4] }
  ["2","3",:night_total].each{ |sft| 
    must "2/1割付時点でのshift #{sft}のタイトロール順" do
      assert_equal TigntRoles[sft] ,@assign.role_order_by_tightness( sft )
    end
  }

  ####################################################
  ## 2/1 は1月末の勤務の制約を受ける
  ## 連続勤務 41 50 52  夜勤連続 42 47
  ## 1 のあと 3はだめ  34,35,38,43,46,49,51
  day = 1
  short_roles = [9,3,10]

   ["2","3"].zip([ [35, 36, 37, 38, 39, 40, 43, 44, 45, 46, 48, 49, 51],
                   [36, 37, 39, 40, 44, 45, 48],
                 ]).each{ |sft_str,nurces|
    must "assinable_nurces shift #{sft_str}" do
      assert_equal nurces, @assign.assinable_nurces(day,sft_str,short_roles).map(&:id)
    end
  }

  # 3 4 9      38 39 40 41
  # 3 4   10   47 48 49 51
  #   4 9 10   42 43 44 45
  #   4 9      35 37
  #   4   10   36 46 50 52
  group_nurces = [ [[36, 46], [51, 48, 49], [35, 37], [45, 44, 43], [38, 39, 40]],
                   [[36], [48], [37], [45, 44], [39, 40]]
                 ]
  ["2","3"].zip(group_nurces).each{ |sft_str,group_nurce|
    must "gather_by_each_group_of_role shift #{sft_str}" do
      as_nurce = @assign.assinable_nurces(day,sft_str,short_roles)
      short_roles_this_shift = @assign.short_role(day,sft_str)
      assert_equal group_nurce,@assign.
        gather_by_each_group_of_role(as_nurce,sft_str,short_roles_this_shift).
        map{ |nurces| nurces.map(&:id)}
    end
  }
  ["2","3"].each{ |sft_str| 
    must "limit_of_nurce_candidate Shift #{sft_str}" do
      assert_equal 6,@assign.limit_of_nurce_candidate(sft_str,day)
    end
  }
["2","3"].zip([[34, 46, 51, 35, 45, 39],[36, 48, 37, 45, 39, 44]]).each{ |sft_str,an| 
    must "#assinable_nurces_by_cost_size_limited  Shift #{sft_str}" do
      short_roles_this_shift = @assign.short_role(day,sft_str)
      assert_equal an,
       @assign.assinable_nurces_by_cost_size_limited(sft_str,day,short_roles_this_shift ).map(&:id)
    end
  }


  must "夜の組み合わせ候補" do
    combinations = combination_combination_ids(@assign.candidate_combination_for_night(day))
    
    assert_equal [[[34, 46], [36, 45]], [[34, 46], [36, 37]], [[34, 46], [36, 39]],
                  [[34, 35], [36, 45]], [[34, 35], [36, 37]], [[34, 46], [36, 48]],
                  [[34, 51], [36, 45]], [[34, 35], [36, 39]]
                 ], combinations[0,8]
  end

  comb = [
          [[34, 35], [36, 37]], [[34, 35], [36, 39]], [[34, 35], [36, 44]],
          [[34, 35], [36, 45]], [[34, 35], [36, 48]], [[34, 35], [37, 39]],
          [[34, 35], [37, 44]], [[34, 35], [37, 45]], [[34, 35], [39, 44]],

          [[34, 35], [45, 39]], [[34, 35], [45, 44]], [[34, 35], [48, 37]],
          [[34, 35], [48, 39]], [[34, 35], [48, 44]], [[34, 35], [48, 45]],
          [[34, 39], [36, 37]], [[34, 39], [36, 44]], [[34, 39], [36, 45]],

          [[34, 39], [36, 48]], [[34, 39], [37, 44]], [[34, 39], [37, 45]],
          [[34, 39], [45, 44]], [[34, 39], [48, 37]], [[34, 39], [48, 44]],
          [[34, 39], [48, 45]], [[34, 45], [36, 37]], [[34, 45], [36, 39]],

          [[34, 45], [36, 44]], [[34, 45], [36, 48]], [[34, 45], [37, 39]],
          [[34, 45], [37, 44]], [[34, 45], [39, 44]], [[34, 45], [48, 37]],
          [[34, 45], [48, 39]], [[34, 45], [48, 44]], [[34, 46], [36, 37]]
         ]
  must "shift 2 3 に分ける" do
    combination = hash_combination_ids(@assign.candidate_combination_for_shift23(day))
    #assert_equal 6*6,combination.size
    assert_equal comb[0,9],    combination.sort[0,9]#_by{ |s2,s3| s2[0]+s2[1]*100}
    assert_equal comb[9,9],    combination.sort[9,9]#_by{ |s2,s3| s2[0]+s2[1]*100}
    assert_equal comb[18,9],    combination.sort[18,9]#_by{ |s2,s3| s2[0]+s2[1]*100}
    assert_equal comb[27,9],    combination.sort[27,9]#_by{ |s2,s3| s2[0]+s2[1]*100}
  end
  selected_comb = [ [[34, 46], [36, 45]], [[34, 46], [36, 37]], [[34, 46], [36, 39]],
                    [[34, 35], [36, 45]], [[34, 35], [36, 37]], [[34, 46], [36, 48]]]
  must "shift2,3の選ばれた組み合わせ1日" do
    combination = hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(day))
    assert_equal 6,combination.size
    assert_equal selected_comb,combination
  end

  #################
 
#   ####################################################
#   ## 2/4
   day4 = 4
   short_roles = [9,3,10]
    ["2","3"].zip([ [ 35, 36, 37, 38, 39, 40, 41, 42, 43, 45, 46, 47, 48, 49, 51],
                    []
                  ]).each{ |sft_str,nurces|
     must "assinable_nurces  4日 shift #{sft_str}" do
       assert_equal nurces, @assign.assinable_nurces(day4,sft_str,short_roles).map(&:id)
     end
   }

   # 3 4 9      38 39 40 41
   # 3 4   10   47 48 49 51
   #   4 9 10   42 43 44 45
   #   4 9      35 37
   #   4   10   36 46 50 52
   group_nurces = [ [[36, 46], [51, 49, 48, 47], [35, 37], [42, 45, 43], [41, 39, 38, 40]],
                    []
                  ]
   ["2","3"].zip(group_nurces).each{ |sft_str,group_nurce|
     must "gather_by_each_group_of_role shift  4日 #{sft_str}" do
       as_nurce = @assign.assinable_nurces(day4,sft_str,short_roles)
       short_roles_this_shift = @assign.short_role(day4,sft_str)
       assert_equal group_nurce,@assign.
         gather_by_each_group_of_role(as_nurce,sft_str,short_roles_this_shift).
         map{ |nurces| nurces.map(&:id)}
     end
   }
   ["2","3"].each{ |sft_str| 
     must "limit_of_nurce_candidate Shift 4日  #{sft_str}" do
       assert_equal 6,@assign.limit_of_nurce_candidate(sft_str,day4)
     end
   }
 ["2","3"].zip([[34, 46, 51, 35, 42, 38],[]]).each{ |sft_str,an| 
     must "#assinable_nurces_by_cost_size_limited  Shift  4日 #{sft_str}" do
       short_roles_this_shift = @assign.short_role(day4,sft_str)
       assert_equal an,
        @assign.assinable_nurces_by_cost_size_limited(sft_str,day4,short_roles_this_shift ).map(&:id)
     end
   }


   must " 4日 夜の組み合わせ候補" do
     combinations = combination_combination_ids(@assign.candidate_combination_for_night(day4))
   
     assert_equal [[[34, 46], []], [[34, 35], []], [[34, 51], []], [[34, 42], []],
                   [[34, 38], []], [[46, 35], []], [[46, 51], []], [[46, 42], []]
                  ], combinations[0,8]
   end

   comb4 = [[[34, 35], []], [[34, 38], []], [[34, 42], []], [[34, 46], []],
            [[34, 51], []], [[35, 38], []], [[35, 42], []], [[42, 38], []],
            [[46, 35], []], [[46, 38], []], [[46, 42], []], [[46, 51], []],
            [[51, 35], []], [[51, 38], []], [[51, 42], []]
           ]
   must " 4日 shift 2 3 に分ける" do
     combination = hash_combination_ids(@assign.candidate_combination_for_shift23(day4))
     #assert_equal 6,combination.size
     assert_equal comb4,    combination.sort
   end

   selected_comb4 = [
                     [[34, 46], []], [[34, 35], []], [[34, 51], []],
                     [[34, 42], []], [[34, 38], []], [[46, 35], []]
                   ]
  must "shift2,3の選ばれた組み合わせ 4日。shift3はfilles" do
     combination = hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(4))
     assert_equal 6,combination.size
     assert_equal selected_comb4,combination
   end


end