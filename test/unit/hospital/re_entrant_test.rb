# -*- coding: utf-8 -*-
require 'test_helper'
#require 'need'

class Hospital::ReEntrantTest < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @nurces=@assign.nurces
# as=Hospital::Assign.new(1,Date.new(2013,2,1));as.assign1cool_to_shunin
# as.assign_day_by_re_entrant( 1,3,true)
# as.assign_day_by_re_entrant( 1,3)
#puts @assign.dump
  end

  def nurce(id); 
    nurce = Hospital::Nurce.find id
    nurce.monthly(@month)
    nurce
  end
end
__END__

  must "2/28" do
    @assign.assign1cool_to_shunin
    pp @assign.assign_day_by_re_entrant23(28)
puts @assign.dump
    pp @assign.assign_day_by_re_entrant1(28)
puts @assign.dump
  end

  must "2/1のシミュレーション" do
    day,shift = 1,3
     @assign.assign1cool_to_shunin
    need_nurces =  @assign.short_role_shift_of(day)[[2,shift]][0] 
    short_roles =  @assign.short_role(day,shift)
    as_nurces   =  @assign.assinable_nurces(day,shift ,short_roles)  

    assert_equal [ 37, 39, 40, 44, 45, 48],  as_nurces.map(&:id).sort,
    "割付可能看護師の一覧"

    comb_nurces = []
    #@assign.
    #  nurce_combination_by_remain(as_nurces,need_nurces,short_roles,shift,
    #                              short_roles.include?(1)){|cmb|
    #  comb_nurces <<  cmb.map{|n| n.id}
    #}
    #assert_equal [[45, 40], [39, 48], [37, 48], [48, 44], [40, 44], [48, 40]],
    #comb_nurces,"看護師の組み合わせ"
    
  end
  
  must "4:2まで行い、4:1を二回restoreするとどうなるか" do
    @assign.assign1cool_to_shunin
    [
     [1,3,[40,48],[3,3]],
     [1,2,[39],[0]],
     [1,1,[38,46,45,49,44,51,37,43,35],[1,1,1,1,0,1,1,1,1]],
     [2,3,[41,47],[0,0]],
     [2,2,[43],[3]],
     [2,1,[42,49,45,52,50],[1,1,1,1,0]],
     [3,2,[40,42],[2,3]],
     [3,1,[38,46,48,45,49],[1,1,0,1,1]]
    ].each{|line|
      day,shift,nurces,long_patern = line
      comb_nurces = @assign. nurce_by_id(nurces)
#pp comb_nurces
      shifts_short_role = @assign.save_shift(comb_nurces,day)
#pp line
      assigned = @assign.assign_test_patern(comb_nurces,day,shift,long_patern)
#pp assigned
      @assign.assign_patern(comb_nurces,day,shift,assigned)
    }

     [[4,1,[38,37,51,46,45,43,35,34],[1,0,0,1,1,1,1,1]],
      [4,1,[38,37,51,46,45,43,35,34],[1,0,1,1,1,1,1,1]]
     ]
    puts save42 = @assign.dump,"\n"

    day,shift,nurces,long_patern =[4,1,[38,37,51,46,45,43,35,34],[1,0,0,1,1,1,1,1]]
    comb_nurces = @assign. nurce_by_id(nurces)
    shifts_short_role = @assign.save_shift(comb_nurces,day)
    assigned = @assign.assign_test_patern(comb_nurces,day,shift,long_patern)
    assert assigned
    assert   !@assign.assign_patern(comb_nurces,day,shift,assigned)
    puts @assign.dump,"\n"
    @assign.restore_shift(comb_nurces,day,shifts_short_role,shift)
    puts restore41 = @assign.dump,"\n"
    assert_equal save42,restore41
        day,shift,nurces,long_patern =[4,1,[38,37,51,46,45,43,35,34],[1,0,1,1,1,1,1,1]]
    comb_nurces = @assign. nurce_by_id(nurces)
    shifts_short_role = @assign.save_shift(comb_nurces,day)
    assigned = @assign.assign_test_patern(comb_nurces,day,shift,long_patern)
    assert assigned
    assert   !@assign.assign_patern(comb_nurces,day,shift,assigned)
    puts @assign.dump,"\n"
    @assign.restore_shift(comb_nurces,day,shifts_short_role,shift)
    puts restore41_2 = @assign.dump,"\n"
    assert_equal save42,restore41_2
    
  end

  must "assign_test_patern:Nurce40,48に'330','3'を2/1割当テストするとNG" do
    # 1/31が"3"なので
    assigned = @assign.assign_test_patern([@nurces[6],@nurces[14]],1,3,[2,3])
    #pp Hospital::Nurce::LongPatern[3][2]
    #pp @nurces[6]
    #pp @nurces[6].long_check_sub(1,[3])
    #pp @nurces[6].long_check(1,3,
    #                         Hospital::Nurce::LongPatern[3][2])
    assert_equal false,assigned
  end

  must "assign_test_patern:Nurce39 に'220330110'を2/1割当テストするとNG" do
     assigned = @assign.assign_test_patern([@nurces[5]],1,2,[0])
    pp Hospital::Nurce::LongPatern[2][0]
    pp @nurces[5].long_check_sub(1,[3])
    pp @nurces[5].long_check(1,2,Hospital::Nurce::LongPatern[2][0])
    assert_equal [["220330110", [[2, 5, 8], [6, 7], [1], [3, 4]]]],assigned
puts ",@assign.assign_patern"
    assert_equal true ,@assign.assign_patern([@nurces[5]],1,2,assigned)
  end

  must "assign_test_patern:Nurce43,44に'3','330110'を割当テストするとOK" do
    assigned = @assign.assign_test_patern(@nurces[9,2],21,3,[3,1])
    assert_equal [["3", [[], [], [], []]], ["330110", [[2, 5], [3, 4], [], [1]]]],assigned
    assert_equal true ,@assign.assign_patern(@nurces[9,2],21,3,assigned)
  end

  must "assign_test_patern:Nurce36,37に'330','330110220'を割当テストすると,36が深夜勤オーバーでNG" do
    assigned = @assign.assign_test_patern(@nurces[2,2],21,3,[2,1])
    assert_equal false,assigned
  end


  must "assign_test_patern:Nurce48,49に'330','330'を23日に割当テストすると,24日が深夜勤3人でNG" do
    assigned = @assign.assign_test_patern(@nurces[14,2],23,3,[2,2])
    assert_equal [["330", [[2], [], [], [1]]], ["330", [[2], [], [], [1]]]],assigned
    assert_equal false  ,@assign.assign_patern(@nurces[14,2],23,3,assigned)
  end

  #must "Nurce#role_shift(" do
  #  role_shift0 = @nurces[1].role_shift(@month)
  #  @nurces[1].shifts[4,1]="3"
  #  role_shift1 = @nurces[1].role_shift(@month,true)
  #  assert_equal [[1, 3], [2, 3], [4, 3]],role_shift1[4]
  #end

  #must "Assign#role_shift" do
  #  #role_shift0 = @nurces[1].role_shift(@month)
  #  ret = {[5, 3]=>1, [2, 3]=>1, [1, 3]=>1}
  #  role_shift1 = @assign.role_shift true
  #  assert_equal ret ,role_shift1[4]
  #  @nurces[1].shifts[4,1]="3"
  #  role_shift1 = @assign.role_shift true
  #  ret = {[5, 3]=>1, [2, 3]=>2, [4, 3]=>1, [1, 3]=>2}
  #  assert_equal ret  ,role_shift1[4]
  #end

  #must "short_role_shift_of(day" do
  #  s_r0 = @assign.short_role_shift_of(4)
  #  @nurces[1].shifts[4,1]="3"
  #  @assign.role_shift(true)
  #  s_r1 = @assign.short_role_shift_of(4)
  #  assert_not_equal s_r0,s_r1
  #  assert_equal [0, 1], s_r0[[5, 3]] 
  #  assert_equal [0, 1], s_r1[[5, 3]] 
  #  
  #end

  #must "short_role_shift" do
  #  s_r0 = @assign.short_role_shift
#pp s_r0
  #  @nurces[1].shifts[4,1]="3"
  #  s_r1 = @assign.short_role_shift(true)
#pp s_r1
  #  assert_not_equal s_r0,s_r1
  #  assert_equal [0, 1], s_r0[4][[5,3]]
  #  assert_equal [0, 1], s_r1[4][[5,3]]
  #  
  #end
  #
  #must "short_role(day,shift,reculc)" do
  #  sr0 = @assign.short_role(4,2)
  #  assert_equal [1,2, 4,5],sr0.sort
  #  @nurces[1].shifts[4,1]="2"
  #  sr1 = @assign.short_role(4,2,true)
  #  assert_equal [2, 5],sr1.sort
  #end

  #
  #  
  #must "nurce_not_assigned_with_eval" do
  #  nurces0 =  @assign.nurce_not_assigned_with_eval(4,3).map{|nurce| nurce[0].id}
#pp nurces0
  #  @nurces[1].shifts[4,1]="3"
  #  nurces1 = @assign.nurce_not_assigned_with_eval(4,3,true).map{|nurce| nurce[0].id}
  #  pp @nurces.map{|nurce| nurce.shifts[4,1]}
#pp nurces1
  #  assert_not_equal nurces0,nurces1
  #  assert nurces0.include?(35)
  #  assert !nurces1.include?(35)
  #end
  must "2/28にわりつけ " do
    puts "2/28にわりつけ "
    pp @assign.assign_day_by_re_entrant(28)
    assert_equal "1_00112312_11311_1_",@assign.assigned_list(28)
  end
  must "2/27にわりつけ " do
    puts "2/27にわりつけ "
    assert  @assign.assign_day_by_re_entrant(27)
    assert_equal "__21112311__13111__",@assign.assigned_list(27),"2/27 of 2/27"
    assert_equal "1_0011231211131__1_",@assign.assigned_list(28),"2/28 of 2/27"
  end
  must "2/26にわりつけ " do
    day = 26
    puts "2/26にわりつけ "
    @assign.assign_day_by_re_entrant(day)
    assert_equal "_2__11131_121311_1_",@assign.assigned_list(26),"2/26 of 2/26"
    assert_equal "_2_111_311_32_1111_",@assign.assigned_list(27),"2/27 of 2/26"
    assert_equal "100011302211_311_11",@assign.assigned_list(28),"2/28 of 2/26"
  end

  must "2/1 にわりつけ " do
    day = 1
    puts "2/#{day}にわりつけ "
    @assign.assign_day_by_re_entrant(day)
    puts @assign.dump
    puts "============== #{day} ======== #{@assign.restore_count} ============="
    #assert_equal 497,@assign.restore_count
    assert_equal "____11_31211121131_",@assign.assigned_list(25),"2/25 of 2/#{day}"
    assert_equal "_2__11131_121_11_13",@assign.assigned_list(26),"2/26 of 2/#{day}"
    assert_equal "_3_1112011__12111_3",@assign.assigned_list(27),"2/27 of 2/#{day}"
    assert_equal "1_00113212111311__0",@assign.assigned_list(28),"2/28 of 2/#{day}"
  end

  must "2/24にわりつけ " do
    day = 24
    puts "2/#{day}にわりつけ "
    @assign.assign_days_by_re_entrant(day)
    puts @assign.dump
    puts "======= #{day} ========== #{@assign.restore_count} =================="
    #assert_equal 497,@assign.restore_count
    assert_equal "____12_302_11_1131_",@assign.assigned_list(25),"2/25 of 2/#{day}"
    assert_equal "___112_31_11121131_",@assign.assigned_list(25),"2/25 of 2/#{day}"
    assert_equal "_2__101_13121311_11",@assign.assigned_list(26),"2/26 of 2/#{day}"
    assert_equal "_23113__11121_111__",@assign.assigned_list(27),"2/27 of 2/#{day}"
    assert_equal "10001123121_1311_1_",@assign.assigned_list(28),"2/28 of 2/#{day}"
  end

  #must "2/20にわりつけ " do
  #  day = 20
  #  puts "2/#{day}にわりつけ "
  #  @assign.assign_day_by_re_entrant(day)
  #  puts @assign.dump
  #  puts "======= #{day} ========== #{@assign.restore_count} =================="
  #  #assert_equal 497,@assign.restore_count
  #  assert_equal "____12_302_11_1131_",@assign.assigned_list(25),"2/25 of 2/#{day}"
  #  assert_equal "___112_31_11121131_",@assign.assigned_list(25),"2/25 of 2/#{day}"
  #  assert_equal "_2__101_13121311_11",@assign.assigned_list(26),"2/26 of 2/#{day}"
  #  assert_equal "_23113__11121_111__",@assign.assigned_list(27),"2/27 of 2/#{day}"
  #  assert_equal "10001123121_1311_1_",@assign.assigned_list(28),"2/28 of 2/#{day}"
  #end

  #must "shift3から" do
  #  assert  @assign.assign_shift_by_re_entrant(1,3)
  #end
  #must "2/23にわりつけ " do
  #  day = 21
  #  puts "2/#{day}にわりつけ "
  #  assert  @assign.assign_days_by_re_entrant(day)
  #  assert_equal "____11_31211121131_",@assign.assigned_list(25),"2/25 of 2/#{day}"
  #  assert_equal "____11131_121211_13",@assign.assigned_list(26),"2/26 of 2/#{day}"
  #  assert_equal "_2_111_311_213111__",@assign.assigned_list(27),"2/27 of 2/#{day}"
  #  assert_equal "10001130223_1011111",@assign.assigned_list(28),"2/28 of 2/#{day}"
  #end
  #must "2/1にわりつけ " do
  #  puts "2/1にわりつけ "
  #  assert  @assign.assign_days_by_re_entrant(1)
  #  assert_equal "",@assign. assigned_list(28)
  #end
end
__END__


  must "月の最後の日を越えたらtrue" do
    assert_equal true, @assign.assign_day_by_re_entrant(29,1), "月の最後の日を越えたらtrue"
  end
  (1..3).each{|s|
    must "一時的なテスト勤務#{s}は" do
      #assert_equal true,  @assign.assign_day_by_re_entrant(28,s), "勤務1#{s}は"
    end
  }
  must "勤務1,2,3で無かったらtrue" do
    assert_equal :shift,  @assign.assign_day_by_re_entrant(28,0), "勤務1,2,3で無かったらtrue"
  end

  must "一時的なテスト。再帰するか " do
    #assert  @assign.assign_day_by_re_entrant(20)
  end

  must "2/1の勤務3をアサインする" do
    save = @nurces[6].shifts.dup
    @assign.assign_(@nurces[6],1,3)
    assert_equal "3",@nurces[6].shifts[1,1]
  end


  must "2/28にわりつけ " do
    assert  @assign.assign_day_by_re_entrant(28)
    assert_equal [1],@assign. short_role_shift_of(28)
  end
must "2/1にわりつけ " do
  
    #assert  @assign.assign_day_by_re_entrant(1)
    assert_equal [1],@assign. short_role_shift_of(28)
  end

  must "ちゃんとやってみる"  do
    #assert  @assign.assign_month #assign_days_by_re_entrant
    #assert_equal [1],@assign.short_role_shift_of(28)
  end
end
