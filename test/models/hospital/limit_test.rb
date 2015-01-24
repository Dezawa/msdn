# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::RoleTest < ActiveSupport::TestCase
  fixtures :hospital_needs,:hospital_roles,:nurces_roles,:nurces,:hospital_defines
  fixtures :bushos,:hospital_limits,:holydays

  def setup
     $HP_DEF = Hospital::Define.create
    @month     = Time.parse("2014/3/1 JST")
    # 休日 11 平日 20  20*9+11*6=180+66 = 246
    #                  4*31 = 124         124 = 370
  end

  
  must "部署１のneedsは " do
    assert_equal %w(2 3),$HP_DEF.night
    assert_equal ({
                    [ 3, :kinmu_total]=> 62,[ 3, :night_total]=>62,  
                    [ 4, :kinmu_total]=>370,[ 4, :night_total]=>124,  
                    [ 9, :kinmu_total]=> 93,[ 9, :night_total]=>62,      
                    [10, :kinmu_total]=> 93,[10, :night_total]=>62,     
                    [ 3, "2"]=>31,  [ 3, "3"]=>31,
                    [ 4, "3"]=>62,  [ 4, "2"]=>62, [ 4, "1"]=>246, [4, "0"]=>0,
                    [ 9, "3"]=>31,  [ 9, "2"]=>31, [ 9, "1"]=> 31,
                    [10, "3"]=>31,  [10, "2"]=>31, [10, "1"]=> 31,
                  }),Hospital::Limit.need_roles(1,@month)
  end
  must "部署１のarrowableは " do
    assert_equal ({
                    [ 3, :kinmu_total]=>220, [ 3, :night_total]=> 90,
                    [ 4, :kinmu_total]=>418, [ 4, :night_total]=>156,
                    [ 9, :kinmu_total]=>220 ,[ 9, :night_total]=> 85, 
                    [10, :kinmu_total]=>264, [10, :night_total]=>103,
                    [ 3, "1"]=>200, [ 3, "2"]=>50, [ 3, "3"]=>50,
                    [ 4, "1"]=>380, [ 4, "2"]=>86, [ 4, "3"]=>86,
                    [ 9, "1"]=>200, [ 9, "2"]=>47, [ 9, "3"]=>47,
                    [10, "1"]=>240, [10, "2"]=>57, [10, "3"]=>57
                  }),Hospital::Limit.arrowable_roles(1,@month)
  end

  margin = { 
    [3, :kinmu_total]=>158,  [3, :night_total]=> 28,  
    [4, :kinmu_total]=> 48,  [4, :night_total]=> 32,
    [9, :kinmu_total]=>127,  [9, :night_total]=> 23,
    [10, :kinmu_total]=>171, [10, :night_total]=>41,
    [3, "2"]=> 19,  [3, "3"]=> 19,
    [4, "1"]=>134,  [4, "2"]=>24, [4, "3"]=>24,
    [9, "1"]=> 169, [9, "2"]=> 16,  [9, "3"]=>16,
    [10, "1"]=>209, [10, "2"]=>26, [10, "3"]=>26,
  }

  must "部署１の月初 marginは " do
    assert_equal margin,Hospital::Limit.margin_roles(Hospital::Limit.need_roles(1,@month),
                                                  Hospital::Limit.arrowable_roles(1,@month))
  end

  
  must "部署１の月初 警告は " do
    assert_equal [],Hospital::Limit.enough?(1,@month)[0]
  end

  

  must "50-52の夜勤数をゼロ、38藤原トキエの夜勤数を7にすると 警告は " do
    [50,51,52].each{ |id| Hospital::Nurce.find(id).
      limit.update_attributes(:night_total => 0,:kinmu_total => 8 )}
    
     Hospital::Nurce.find(38).limit.update_attribute(:night_total,7)
    margin_roles = Hospital::Limit.margin_roles(Hospital::Limit.need_roles(1,@month),
                                                  Hospital::Limit.arrowable_roles(1,@month)
                                                     )
    assert_equal -1,margin_roles[[3,:night_total]]
#pp margin_roles
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
