# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

class Hospital::RoleTest < ActiveSupport::TestCase
  fixtures "hospital/needs","hospital/roles","hospital/nurces_roles","hospital/nurces","hospital/defines"
  fixtures "hospital/bushos","hospital/limits","holydays"

  def setup
    #$HP_DEF = Hospital::Define.create
    @month     = Time.parse("2014/3/1 JST")
    # 休日 11 平日 20  20*9+11*6=180+66 = 246
    #                  4*31 = 124         124 = 370
  end

  def roles2factor(roles);[3,4,9,10].map{ |r| roles.include?(r) ? 1 : 0 } ;end

  must "部署１の看護師の roleとlimitは " do
    nurces = Hospital::Nurce.by_busho(1)
    roles  = nurces.map{ |nurce| nurce.need_role_ids}
    limits = nurces.map{ |nurce|  [:code1,:code2,:code3,:kinmu_total,:night_total].map{ |sym| nurce.limit.send(sym)}}

    assert_equal [[4], [4, 9], [4, 10], [4, 9],   [3, 4, 9], [3, 4, 9], [3, 4, 9], [3, 4, 9],
                  [4, 9, 10],  [4, 9, 10], [4, 9, 10], [4, 9, 10],
                  [4, 10], [3, 4, 10], [3, 4, 10], [3, 4, 10],[3, 4, 10], [3, 4, 10], [3, 10]],roles
    factors = roles.map{ |r| roles2factor(r)}
    assert_equal( [[0,1,0,0],[0,1,1,0],[0,1,0,1],[0,1,1,0]] + [[1,1,1,0]]*4 +
                  [[0,1,1,1]] * 4 + [[0,1,0,1]]+[[1,1,0,1]]*5 + [[1,0,0,1]],
                  factors)
    assert_equal [[20, 2, 2, 22,4]]*3 + [[20, 5, 5,22,9]]*16 ,limits

    idx = 0; role = [3,4,9,10][idx]
    # role の shift 毎の集計   
    assert_equal [[200, 50, 50, 220, 90],  # role 3
                  [360, 81, 81, 396, 147], # role 4
                  [200, 47, 47, 220, 85],  # role 9
                  [240, 57, 57, 264, 103]  # role 10
                 ], 
    (0..3).map{ |idx| role = [3,4,9,10][idx]
      (0..4).map{ |sidx| shift= [1,2,3,:kinmu_total,:night_total][sidx]
        factors.zip(limits).               #                        role有無    勤務数上限
        inject(0){|sum,factor_limit|  factor,limit=factor_limit;sum+factor[idx]*limit[sidx] }
      }
    }
  end

  must "部署１のneedsは " do
    assert_equal %w(2 3),Hospital::Define.define.night
    needs = {  [4, "0"]=>0,
                       [ 3, "2"]=>31, [ 3, "3"]=>31, [ 3, :kinmu_total]=> 62,[ 3, :night_total]=>62, 
      [ 4, "1"]=>246,  [ 4, "2"]=>62, [ 4, "3"]=>62, [ 4, :kinmu_total]=>370,[ 4, :night_total]=>124,
      [ 9, "1"]=> 31,  [ 9, "2"]=>31, [ 9, "3"]=>31, [ 9, :kinmu_total]=> 93,[ 9, :night_total]=>62, 
      [10, "1"]=> 31,  [10, "2"]=>31, [10, "3"]=>31, [10, :kinmu_total]=> 93,[10, :night_total]=>62, 
    }
    assert_equal needs,Hospital::Limit.need_roles(1,@month)
  end

  must "部署１のarrowableは " do
    arrowable = { 
    [ 3, "1"] => 200, [ 3, "2"] => 50, [ 3, "3"] => 50, [ 3, :kinmu_total] => 220, [ 3, :night_total] =>  90,
    [ 4, "1"] => 360, [ 4, "2"] => 81, [ 4, "3"] => 81, [ 4, :kinmu_total] => 396, [ 4, :night_total] => 147,
    [ 9, "1"] => 200, [ 9, "2"] => 47, [ 9, "3"] => 47, [ 9, :kinmu_total] => 220, [ 9, :night_total] =>  85, 
    [10, "1"] => 240, [10, "2"] => 57, [10, "3"] => 57, [10, :kinmu_total] => 264, [10, :night_total] => 103,
  } 
    assert_equal arrowable,Hospital::Limit.arrowable_roles(1,@month)
  end

  margin = { 
                     [3, "2"] => 19, [3, "3"] => 19, [3, :kinmu_total] =>158,  [3, :night_total] => 28,  
     [4, "1"] =>114, [4, "2"] => 19, [4, "3"] => 19, [4, :kinmu_total] => 26,  [4, :night_total] => 23,
     [9, "1"]=> 169, [9, "2"] => 16, [9, "3"] => 16, [9, :kinmu_total] =>127,  [9, :night_total] => 23,
     [10, "1"]=>209, [10, "2"]=> 26, [10, "3"]=> 26, [10, :kinmu_total]=>171,  [10, :night_total]=> 41,
  }
  must "部署１の月初 marginは " do
    assert_equal margin,Hospital::Limit.margin_roles(Hospital::Limit.need_roles(1,@month),
                                                  Hospital::Limit.arrowable_roles(1,@month))
  end

  must "部署１の月初 警告は " do
    assert_equal [],Hospital::Limit.enough?(1,@month)[0]
  end

  must "看護師50～52の夜勤上限数をゼロ、38藤原トキエの夜勤上限数を7にすると 警告は " do
    [50,51,52].each{ |id| Hospital::Nurce.find(id).
      limit.update_attributes(:night_total => 0 )}
    Hospital::Nurce.find(38).limit.update_attribute(:night_total,7)

    margin_roles = Hospital::Limit.margin_roles(Hospital::Limit.need_roles(1,@month),
                                                  Hospital::Limit.arrowable_roles(1,@month)
                                                     )
    assert_equal -1,margin_roles[[3,:night_total]],"リーダー夜勤の余裕が -1(不足)になる"

    # 部署１の人員は十分か
    hospital_limit = Hospital::Limit.enough?(1,@month)
    assert_equal 2, hospital_limit[0].size
    warn = hospital_limit[0].sort
    ret  = ["夜勤計にはリーダーが延べ 62人日必要なところ、1人日不足のため、計算不能です",
            "夜勤計には看護師が延べ 124人日必要なところ余裕は3人日です。計算時間が掛かるかもしれません"
           ].sort
    assert_equal ret,warn,"警告"
    assert_equal ret[0],warn[0],"警告０"
    assert_equal ret[1],warn[1],"警告１"
    assert_equal ret[2],warn[2],"警告２"

  end

end
