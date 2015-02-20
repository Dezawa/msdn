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
    assert_equal 6 ,@assign.limit_of_nurce_candidate_night(20)
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
    assert_equal [37, 38, 46, 42, 47, 52],
    @assign.assinable_nurces_by_cost_size_limited("2",20, [3,4,9,10]).map(&:id)
  end
  
  must "2/20の深夜勤割り当て看護師候補。コストで足切り" do #37, 46, 42, 38, 47, 52
    assert_equal [37, 46, 42, 38, 47, 52],
    @assign.assinable_nurces_by_cost_size_limited("3",20, [3,4,9,10]).map(&:id)
  end

  must "2/20の深夜勤割り当て看護師組み合わせ候補" do #37, 46, 42, 38, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift(20,"3")
    assert_equal 15,candidate_combination_for_shift.size,"数は15"
    assert_equal [[37,46],[37,42],[37,38],[37,47],[37,52],
                  [46,42],[46,38],[46,47],[46,52],
                  [42,38],[42,47],[42,52],
                  [38,47],[38,52],[47,52]
                 ],combination_ids(candidate_combination_for_shift)
  end
  must "2/20の準夜勤割り当て看護師組み合わせ候補" do #37, 38, 46, 42, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift(20,"2")
    assert_equal 15,candidate_combination_for_shift.size,"数は15"
    assert_equal [[37,38],[37,46],[37,42],[37,47],[37,52],
                  [38,46],[38,42],[38,47],[38,52],
                  [46,42],[46,47],[46,52],
                  [42,47],[42,52],[47,52]
                 ],combination_ids(candidate_combination_for_shift)
  end
  must "2/20の深夜勤割り当て看護師組み合わせ候補ロール十分" do # 37, 46, 42, 38, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift_with_enough_role(20,"3")
    assert_equal [#[37,46],[37,42],           role3
                  #[37,38],                   role10
                  #[46,42],                   role3
                  # [46,47],                  rple9
                  [42, 38], [46, 38], [37, 47], [38, 47], [42, 47]
                 ],combination_ids(candidate_combination_for_shift)
  end
  must "2/20の準夜勤割り当て看護師組み合わせ候補ロール十分" do #37, 38, 46, 42, 47, 52
    candidate_combination_for_shift = @assign.candidate_combination_for_shift_with_enough_role(20,"2")
    assert_equal [#[37,38],                     role10
                  #[37,46],[37,42],[46,42],           3
                  # [46,47],        9
                  [38, 42], [38, 46], [37, 47], [38, 47], [42, 47]
                 ],combination_ids(candidate_combination_for_shift)
  end
  must "2/20の夜勤割り当て看護師組み合わせから除かれた組み合わせ" do
    candidate_combination_for_night = @assign.candidate_combination_for_night(20)
    hole =  @assign.candidate_combination_for_shift_with_enough_role(20,"2").
      product(@assign.candidate_combination_for_shift_with_enough_role(20,"3"))
    diff = hole - candidate_combination_for_night
    assert_equal 19, combination_combination_ids(diff).size
  end
  # [42, 38], [46, 38], [37, 47], [38, 47], [42, 47]
  # [38, 42], [38, 46], [37, 47], [38, 47], [42, 47]
  #  [42, 38] *  [37, 47],                
  #  [46, 38] *  [37, 47], [42, 47]
  #  [37, 47] *  [38, 42], [38, 46]                        
  #  [38, 47] *  
  #  [42, 47] *  [38, 46]
  must "2/20の夜勤割り当て看護師組み合わせ候補最初の12個" do
    assert_equal [[[37, 47], [42, 38]], [[38, 42], [37, 47]], [[37, 47], [46, 38]],
                  [[38, 46], [37, 47]], [[42, 47], [46, 38]], [[38, 46], [42, 47]]
                 ], combination_combination_ids(@assign.candidate_combination_for_night(20).to_a)
  end
  must "2/20の夜勤割り当て看護師組み合わせ候補最初の10個のコスト" do
    #             1      2    5     3      7    10      4      8   11    12    6      9
    assert_equal [4878, 4920, 5733, 5861, 6527, 6551
                 ], @assign.candidate_combination_for_night(20).
      to_a[0,12].
      map{ |nurces| @assign.cost_of_nurce_combination_of_combination(*nurces).to_i }
  end


  must "[52, 35]がroles_filled?" do
    day,sft_str ,nurces = 15,"2",[52, 35].map{ |id| nurce_by_id(id,@nurces)}
    assert_equal [0,1,0,0,0],@assign.roles_filled?(day,sft_str ,nurces)
  end

end
__END__

  must "2/20のshift2,3の候補の組み合わせを作る。 数" do
    candidate_combination=@assign.candidate_combination_for_shift23(day)
    assert_equal 4*3/2 * 8 , # = 48
      candidate_combination.size
  end

  must "2/20のshift2,3の候補の組み合わせを作る。 shift2,3のコストで選ぶ" do
    candidate_combination=@assign.candidate_combination_for_shift23_selected_by_cost(day)
    srand(1)
    assert_equal [[[38, 41], [37, 38]],
 [[37, 41], [38, 40]],
 [[37, 38], [38, 40]],
 [[52, 41], [37, 38]],
 [[38, 52], [37, 38]],
 [[38, 52], [37, 40]],
 [[38, 38], [37, 40]],
 [[38, 41], [37, 40]]],
      candidate_combination.map{  |nurces_shift2,nurces_shift3| 
      [nurces_shift2.map(&:id),nurces_shift3.map(&:id)]
    }
  end
  must "月データ読み込み" do
    nurce = nurce_by_id(52,@assign.nurces)
    assert_equal "__300____0_0___________0_____",nurce.shifts
  end

  must "nurce 34 は？？？" do
    nurce = nurce_by_id(34,@assign.nurces)
    assert_equal "_220330______________________",nurce.shifts ,"shifts"
    @assign.refresh
    nurce = nurce_by_id(34,@assign.nurces)
    #assert_equal "",nurce.shifts.gsub(/[^1478]/,"")
    #assert_equal "",nurce.shifts.gsub(/[^9ABC]/,"")
    assert_equal "_220330______________________",nurce.shifts ,"shifts"
  end
 
  must "シフト1使用・残り" do
    assert_equal [0]*19,@nurces.map{ |nurce| nurce.shift_used["1"] },"shift_used"
    assert_equal [20]*19,@nurces.map{ |nurce| nurce.shift_remain(true)["1"] },"shift_remain"
  end
  must "シフト2使用・残り" do
    assert_equal [0,0,0,5,4,5,3,5,3,3,4,3,1,1,3,1,1,1,5],@nurces.map{ |nurce| nurce.shift_remain(true)["2"] }
  end
  must "シフト3使用・残り" do
    assert_equal [0,0,0,5,5,4,5,3,4,4,3,3,3,3,0,2,1,1,4],@nurces.map{ |nurce| nurce.shift_remain(true)["3"] }
  end
  must "シフト:night_total使用・残り" do
    assert_equal [0,0,0,9,8,8,7,7,6,6,6,5,3,3,2,2,1,1,8],@nurces.map{ |nurce| nurce.shift_remain(true)[:night_total] }
  end
          
  must "シフト:kinmu_total使用・残り" do
    assert_equal [18,18,18,22,21,21,20,20,19,19,19,18,16,16,15,15,14,14,21],
    @nurces.map{ |nurce| nurce.shift_remain(true)[:kinmu_total] }
  end


  sft_str = "2"
  must "2/20のshift2の割り当て可能看護師" do
  sft_str = "2"
    assert_equal [37, 38, 38, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52],
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  must "2/20のshift3の割り当て可能看護師" do
  sft_str = "3"
    assert_equal [37, 38, 38, 40, 41, 42, 43, 44, 45, 46, 47, 49, 50, 51, 52],
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  #  4      34
  # 34
  #  49     35  37
  # 349         41    38 38 40
  #  4910       44    42 43 45
  #  410    36  46 52        51 50
  # 3410              48 49 47
  # 
  # 
  must "2/20のshift2の割り当て可能看護師gather_by" do
    sft_str = "2"
    assert_equal [[37], [38, 41, 38, 40], [46], [44, 42, 43, 45], [52, 48, 51, 49, 47, 50]],
    @assign.gather_by_each_group_of_role(@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)),
                                         sft_str,@assign.short_role(day,sft_str)).
      map{ |cmb| cmb.map(&:id)}

 end
  must "2/20のshift3の割り当て可能看護師gather_by" do
    sft_str = "3"
    assert_equal [[37], [46], [42, 43, 45, 44], [38, 40, 38, 41], [52, 47, 49, 50, 51]],
    @assign.gather_by_each_group_of_role(@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)),
                                         sft_str,@assign.short_role(day,sft_str)).
      map{ |cmb| cmb.map(&:id)}
  end

  must "2/20のshift2の割り当て可能看護師 数制限" do
  sft_str = "2"
    assert_equal [37, 38, 46, 44, 52, 41, 42, 48],
    @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                  @assign.short_role(day,sft_str)).map(&:id)
  end
  sft_str = "3"
  must "2/20のshift3の割り当て可能看護師 数制限" do
  sft_str = "3"
    assert_equal [37, 46, 42, 38, 52, 43, 40, 47],
    @assign.assinable_nurces_by_cost_size_limited(sft_str,day,
                                                  @assign.short_role(day,sft_str)).map(&:id)
  end

  must "2/20の夜勤割り当て候補" do
    #            [37, 41, 44, 46, 52, 38, 42, 48, 38, 40, 43, 47]
    srand(1)
    assert_equal [37, 38, 42, 46, 52, 40, 43, 47, 41, 44, 38, 48].sort,
      @assign.candidate_for_night(day).map(&:id).sort
  end

  must "2/20の夜勤割り当て候補 ソート" do
    #            [37, 41, 44, 46, 52, 38, 42, 48, 38, 40, 43, 47]
    srand(1)
    assert_equal [37, 38, 38, 52, 41, 40, 44, 42, 43, 46, 47, 48],
      @assign.candidate_for_night(day).map(&:id)
  end

  must "夜勤の時のタイトロール" do
    assert_equal [3,9,10],@assign.tight_roles(:night_total).sort
  end

end
