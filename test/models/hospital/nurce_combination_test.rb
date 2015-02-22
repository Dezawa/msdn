# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

class Hospital::NurceCombinationTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes","hospital/defines"
  # Replace this with your real tests.


  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @assign.nurces = extract_set_shifts(Log2_4)
    @assign.refresh
    @assign.night_mode = true
    @nurces = @assign.nurces
    srand(1)
  end

  # 割付なしのとき arrowable がどのくらいあるかは limit_test 参照
   #   arrowable = { 
  #   [ 3, "1"] => 200, [ 3, "2"] => 50, [ 3, "3"] => 50, [ 3, :kinmu_total] => 220, [ 3, :night_total] =>  90,
  #   [ 4, "1"] => 360, [ 4, "2"] => 81, [ 4, "3"] => 81, [ 4, :kinmu_total] => 396, [ 4, :night_total] => 147,
  #   [ 9, "1"] => 200, [ 9, "2"] => 47, [ 9, "3"] => 47, [ 9, :kinmu_total] => 220, [ 9, :night_total] =>  85, 
  #   [10, "1"] => 240, [10, "2"] => 57, [10, "3"] => 57, [10, :kinmu_total] => 264, [10, :night_total] => 103,
  # } 
  
  # 看護師が持っている role  limit_test 参照
  # role 3,4,9,10 を持っていない 0、持っている 1
  factors = [[0,1,0,0,0],[0,1,0,1,0],[0,1,0,0,1],[0,1,0,1,0]] + [[1,1,0,1,0]]*4 +
    [[0,1,0,1,1]] * 4 + [[0,1,0,0,1]]+[[1,1,0,0,1]]*5 + [[1,0,1,0,1]]
  # 

  must "持ってるロールのパターン" do
    assert_equal factors,@nurces.map(&:have_need_role_patern)
  end

  must "37,38,42で追加されるroleの数" do
    assert_equal [1,3,0,3,1],@assign.roles_count_assigned( nurce_set([37,38,42]))
  end

  sft_str = "2"
  must "割付が進んで、set_upの状態でのshift_remain" do
    #             0, 0, 0, 5, 4, 5, 3, 5, 3, 3, 4, 3, 1, 1, 3, 1, 1, 1, 5
    assert_equal [0, 0, 0, 5, 4, 5, 3, 5, 3, 3, 4, 3, 1, 1, 3, 1, 1, 1, 5],
    @nurces.map{ |nurce| nurce.shift_remain(true)[sft_str]}
  end

  must "割付が進んで、set_upの状態でどのくらいassignされたか" do
    assigned = 
      (0..@nurces.size-1).
      inject([0,0,0,0,0]){ |sum,id| 

      sum.add(factors[id].times(@nurces[id].shifts.gsub(/[^2]/,"").size)) # そのshiftに割り当てられた回数
    }
    
    assigned = [[3,"2"],[4,"2"],[5,"2"],[9,"2"],[10,"2"]].zip(assigned).to_h
    assert_equal({[3, "2"]=>21, [4, "2"]=>38, [5,"2",] => 0,[9, "2"]=>12, [10, "2"]=>31}, assigned)
  end

  must "nurceのshift_remainは" do
    assert_equal 29,@nurces.inject(0){ |sum,nurce| sum + ( nurce.role_ids.include?(3) ?  nurce.shift_remain(true)[sft_str] : 0) }
  end

  must "割付が進んで、set_upの状態でのrole_remain" do
    assert_equal [29,43,35,26],
                 [[3, "2"], [4, "2"], [9, "2"], [10, "2"]].map{ |r_s| @assign.role_remain[r_s]}
  end

  must "割付が進んで、set_upの状態での short_role" do
    short_role = @assign.short_role_shift_of(1)
    require    = [[0, 0], [1, 1],[0,0],[0, 1], [1, 2]]
    assert_equal require,    [3,4,5,9,10].map{ |role_id| short_role[[role_id,"3"]]}
  end

  must "割付が進んで、set_upの状態での roles_count_short" do
    assert_equal [0,1,0,0,1], @assign.roles_count_short(1,"3")
  end

  must "割付が進んで、set_upの状態で深夜に看護師40を割り当てたときのロール充足は" do
    assert_equal [0,0,0,0,1], @assign.roles_filled?(1,"3",[nurce(40)])
  end
  day = 20

  ["2"].each{ |sft_str|
    must "2/20 Shift#{sft_str}のタイトロール" do
      assert_equal [10, 3, 9],@assign.tight_roles(sft_str)
    end
  }

  must "2/20の夜勤割り当ての組み合わせ候補" do
    #            [37, 41, 44, 46, 52, 39, 42, 48, 38, 40, 43, 47]
  #  assert_equal 12 * 11 * 10 * 9 / (2*3*4),  # = 495 [37, 38, 39, 52, 40, 41, 44, 43, 42, 46, 47, 48],
  #  @assign.candidate_combination_for_night(day).map{ |comb| comb.map(&:id)}.size
  end
  
  must "2/20の準夜勤割り当ての不足role" do
    assert_equal [3,4,9,10],@assign.short_role(20,"2")
  end
  must "2/20の準夜勤割り当ての可能看護師" do
    assert_equal [37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52],
    @assign.assinable_nurces(20,"2", [3,4,9,10]).map(&:id)
  end

  must "limit_of_nurce_candidate_night" do
    assert_equal 8 ,@assign.limit_of_nurce_candidate_night(20)
  end
  must "shift 2,3のタイトロール" do
    assert_equal [[10,3,9],[3, 10, 9]],%w(2 3).map{ |sft_str| @assign.tight_roles(sft_str)}
  end

  # タイトロールが [10, 3, 9] であるときの看護師のcost順  nurce_3_cost_test.rb 参照
  # 35, 36,34, 37, 38, 39, 52, 40, 41, 44, 42, 43, 45, 46, 47, 48, 49, 50, 51
  # 35,36,37はshift2使い切った。
  #   4 9     1  37
  #   4   10  2  46
  # 3 4 9     1  38,39,40,41
  # 3 4   10  2  42,43,44,45,47,48,49,50,51
  # 3     10  3  52
  # 
  must "2/20の準夜勤割り当て看護師候補。コストで足切り" do
    assert_equal [37, 38, 46, 42, 47, 52, 39, 43],
    @assign.assinable_nurces_by_cost_size_limited("2",20, [3,4,9,10]).map(&:id)
  end
  
  must "2/20の深夜勤割り当て看護師候補。コストで足切り" do #37, 46, 42, 38, 47, 52
    assert_equal [37, 46, 42, 38, 47, 52, 43, 39],
    @assign.assinable_nurces_by_cost_size_limited("3",20, [3,4,9,10]).map(&:id)
  end

  must "2/20の深夜勤割り当て看護師組み合わせ候補" do #37, 46, 42, 38, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift(20,"3")
    assert_equal 28,candidate_combination_for_shift.size,"数は28" # 8*7/2
    assert_equal [[37, 46], [37, 42], [37, 38], [37, 47], [37, 52], [37, 43], [37, 39],
                  [46, 42], [46, 38], [46, 47], [46, 52], [46, 43], [46, 39], [42, 38],
                  [42, 47], [42, 52], [42, 43], [42, 39], [38, 47], [38, 52], [38, 43],
                  [38, 39], [47, 52], [47, 43], [47, 39], [52, 43], [52, 39], [43, 39]
                 ],combination_ids(candidate_combination_for_shift)
  end
  must "2/20の準夜勤割り当て看護師組み合わせ候補" do #37, 38, 46, 42, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift(20,"2")
    assert_equal 28,candidate_combination_for_shift.size,"数は28"  #8*7/2
    assert_equal [[37, 38], [37, 46], [37, 42], [37, 47], [37, 52], [37, 39], [37, 43],
                  [38, 46], [38, 42], [38, 47], [38, 52], [38, 39], [38, 43], [46, 42],
                  [46, 47], [46, 52], [46, 39], [46, 43], [42, 47], [42, 52], [42, 39],
                  [42, 43], [47, 52], [47, 39], [47, 43], [52, 39], [52, 43], [39, 43]
                 ],combination_ids(candidate_combination_for_shift)
  end
  must "2/20の深夜勤割り当て看護師組み合わせ候補ロール十分" do # 37, 46, 42, 38, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift_with_enough_role(20,"3")
    assert_equal [#[37,46],[37,42], [37, 43]  [46, 43]  [42, 43]         role3
                  #[37,38], [38, 39]   [37, 39]                 role10
                  #[46,42],                   role3
                  #[46,47],                  rple9
                  #[37, 52] [46, 52]  [42, 52] [38, 52]  [47, 52] [52, 43], [52, 39] role4   17
                  [43, 39], [38, 43], [42, 38], [42, 39], [46, 38], [46, 39], [37, 47],      #11 + = 28
                  [38, 47], [47, 39], [47, 43], [42, 47]
                 ].sort,combination_ids(candidate_combination_for_shift).sort
  end
  must "2/20の準夜勤割り当て看護師組み合わせ候補ロール十分" do #37, 38, 46, 42, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift_with_enough_role(20,"2")
    assert_equal [#[37,38], [37, 39]  [38, 39],                    role10
                  #[37,46],[37,42],[46,42], [46, 43],[42, 43],[37, 43],            3
                  #[37, 52] [38, 52], [47, 52], [52, 39], [52, 43]  [42, 52],[46, 52],  #role4
                  # [46,47],        9
                  [39, 43], [38, 43], [42, 39], [38, 42], [38, 46], [46, 39], [37, 47],
                  [38, 47], [47, 39], [47, 43], [42, 47]
                 ].sort,combination_ids(candidate_combination_for_shift).sort
  end
 
  # [42, 38], [46, 38], [37, 47], [38, 47], [42, 47]
  # [38, 42], [38, 46], [37, 47], [38, 47], [42, 47]
  #  [42, 38] *  [37, 47],                
  #  [46, 38] *  [37, 47], [42, 47]
  #  [37, 47] *  [38, 42], [38, 46]                        
  #  [38, 47] *  
  #  [42, 47] *  [38, 46]
  must "2/20の夜勤割り当て看護師組み合わせ候補" do
    assert_equal [[[37, 47], [38, 43]], [[37, 47], [42, 38]], [[37, 47], [42, 39]], [[37, 47], [43, 39]],
                  [[37, 47], [46, 38]], [[37, 47], [46, 39]], [[38, 42], [37, 47]], [[38, 42], [43, 39]],
                  [[38, 42], [46, 39]], [[38, 42], [47, 39]], [[38, 42], [47, 43]], [[38, 43], [37, 47]],
                  [[38, 43], [42, 39]], [[38, 43], [42, 47]], [[38, 43], [46, 39]], [[38, 43], [47, 39]],
                  [[38, 46], [37, 47]], [[38, 46], [42, 39]], [[38, 46], [42, 47]], [[38, 46], [43, 39]],
                  [[38, 46], [47, 39]], [[38, 46], [47, 43]], [[38, 47], [42, 39]], [[38, 47], [43, 39]],
                  [[38, 47], [46, 39]], [[39, 43], [37, 47]], [[39, 43], [38, 47]], [[39, 43], [42, 38]],
                  [[39, 43], [42, 47]], [[39, 43], [46, 38]], [[42, 39], [37, 47]], [[42, 39], [38, 43]],
                  [[42, 39], [38, 47]], [[42, 39], [46, 38]], [[42, 39], [47, 43]], [[42, 47], [38, 43]],
                  [[42, 47], [43, 39]], [[42, 47], [46, 38]], [[42, 47], [46, 39]], [[46, 39], [37, 47]],
                  [[46, 39], [38, 43]], [[46, 39], [38, 47]], [[46, 39], [42, 38]], [[46, 39], [42, 47]],
                  [[46, 39], [47, 43]], [[47, 39], [38, 43]], [[47, 39], [42, 38]], [[47, 39], [46, 38]],
                  [[47, 43], [42, 38]], [[47, 43], [42, 39]], [[47, 43], [46, 38]], [[47, 43], [46, 39]]
                 ].sort_by{ |a| a.flatten},
    combination_combination_ids(@assign.candidate_combination_for_night(20).to_a).sort_by{ |a| a.flatten}
end
  # must "2/20の夜勤割り当て看護師組み合わせ候補最初の10個のコスト" do
  #   #             1      2    5     3      7    10      4      8   11    12    6      9
  #   assert_equal [4878, 4920, 5733, 5861, 6527, 6551
  #                ], @assign.candidate_combination_for_night(20).
  #     to_a[0,12].
  #     map{ |nurces| @assign.cost_of_nurce_combination_of_combination(*nurces).to_i }
  # end

  must "[52, 35]がroles_filled?" do
    day,sft_str ,nurces = 15,"2",[52, 35].map{ |id| nurce_by_id(id,@nurces)}
    assert_equal [0,1,0,0,0],@assign.roles_filled?(day,sft_str ,nurces)
  end

  must "2/1 のshift1の割り当て可能看護師" do
    day,sft_str = 9,"1"
    assert_equal 8,@assign.limit_of_nurce_candidate(sft_str,day),"候補数上限"
    assert_equal [34, 36, 37, 42, 39, 43, 38, 45
                 ],@assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                                 @assign.short_role(day,sft_str)).map(&:id),
                   "候補者リスト8名"
    assert_equal 28,@assign.candidate_combination_for_shift(day,sft_str).size,"組み合わせ数"
    assert_equal 28,@assign.candidate_combination_for_shift_with_enough_role(day,sft_str).size,"うちロール満たす組み合わせ数"
  end
 must "2/1 のshift1の割り当て候補看護師組み合わせ" do
    day,sft_str = 9,"1"
    assert_equal [[34, 37, 42, 39, 43, 38], [34, 37, 42, 39, 38, 45], [34, 37, 39, 43, 38, 45],
                   [34, 37, 42, 39, 43, 45], [34, 37, 42, 43, 38, 45], [34, 42, 39, 43, 38, 45],
                   [37, 42, 39, 43, 38, 45], [34, 36, 37, 39, 43, 38], [34, 36, 37, 42, 39, 38],
                   [34, 36, 37, 42, 43, 38], [34, 36, 37, 42, 39, 43], [34, 36, 37, 39, 38, 45],
                   [34, 36, 37, 42, 39, 45], [34, 36, 37, 39, 43, 45], [34, 36, 37, 42, 38, 45],
                   [34, 36, 37, 43, 38, 45], [34, 36, 42, 39, 43, 38], [34, 36, 37, 42, 43, 45],
                   [34, 36, 42, 39, 38, 45], [34, 36, 39, 43, 38, 45], [36, 37, 42, 39, 43, 38],
                   [34, 36, 42, 43, 38, 45], [34, 36, 42, 39, 43, 45], [36, 37, 42, 39, 38, 45],
                   [36, 37, 39, 43, 38, 45], [36, 37, 42, 39, 43, 45], [36, 37, 42, 43, 38, 45],
                   [36, 42, 39, 43, 38, 45]
                 ].sort,
    combination_combination_ids(@assign.candidate_combination_for_shifts(day,[sft_str])).first.sort
  end

  must "2/1 のshift1の割り当て候補看護師組み合わせ,コスト順" do
    day,sft_str = 9,"1"
    candidate_combination_for_shift_selected_by_cost =
      @assign.candidate_combination_for_shift_selected_by_cost(day,sft_str)
    assert_equal [[[34, 37, 42, 39, 43, 38]], [[34, 37, 42, 39, 38, 45]], [[34, 37, 39, 43, 38, 45]],
                  [[34, 37, 42, 39, 43, 45]], [[34, 37, 42, 43, 38, 45]], [[34, 42, 39, 43, 38, 45]],
                  [[37, 42, 39, 43, 38, 45]], [[34, 36, 37, 39, 43, 38]]
                 ],hash_combination_ids(candidate_combination_for_shift_selected_by_cost)
  end
end
 
