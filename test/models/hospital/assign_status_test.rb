# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
#require 'need'

class Hospital::AssignStatusTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies","hospital/defines"
  fixtures "hospital/kinmucodes"
  def setup
    @month  = Date.new(2013,5,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @assign.nurces = extract_set_shifts(Log5_5)
    @nurces=@assign.nurces
    @assign.refresh
    srand(1)
  end
  RolesAssignable = { 
    [ 4, "1"]=>360, [ 4, "2"]=>81, [ 4, "3"]=>81, [ 4, :kinmu_total]=>396, [ 4, :night_total]=>147,
    [ 9, "1"]=>200, [ 9, "2"]=>47, [ 9, "3"]=>47, [ 9, :kinmu_total]=>220, [ 9, :night_total]=>85,
    [10, "1"]=>240, [10, "2"]=>57, [10, "3"]=>57, [10, :kinmu_total]=>264, [10, :night_total]=>103,
    [ 3, "1"]=>200, [ 3, "2"]=>50, [ 3, "3"]=>50, [ 3, :kinmu_total]=>220, [ 3, :night_total]=>90
  }
  RolesAssigned = {   # assign 5 は手伝いの 準夜
    [ 4,"0"]=>9.0,[ 4,"1"]=>30.0,[ 4,"2"]=>11,[ 4,"3"]=>13,[ 4,:night_total]=>24,[ 4,:kinmu_total]=>54.0,
    [ 9,"0"]=>6.0,[ 9,"1"]=> 7.0,[ 9,"2"]=> 7,[ 9,"3"]=> 9,[ 9,:night_total]=>16,[ 9,:kinmu_total]=>23.0,
    [10,"0"]=>6.0,[10,"1"]=>22.0,[10,"2"]=> 7,[10,"3"]=>10,[10,:night_total]=>17,[10,:kinmu_total]=>39.0,
    [ 3,"0"]=>4.0,[ 3,"1"]=>14.0,[ 3,"2"]=> 6,[ 3,"3"]=> 5,[ 3,:night_total]=>11,[ 3,:kinmu_total]=>25.0
  }
  RoleRemain = {
    [ 4,"0"] =>135.0,[ 4,"1"]=>330.0,[ 4,"2"]=>70,[ 4,"3"]=>68,[ 4,:night_total]=>123,[ 4,:kinmu_total]=>342.0,
    [ 9,"0"] => 74.0,[ 9,"1"]=>193.0,[ 9,"2"]=>40,[ 9,"3"]=>38,[ 9,:night_total]=> 69,[ 9,:kinmu_total]=>197.0,
    [10,"0"] => 90.0,[10,"1"]=>218.0,[10,"2"]=>50,[10,"3"]=>47,[10,:night_total]=> 86,[10,:kinmu_total]=>225.0,
    [ 3,"0"] => 76.0,[ 3,"1"]=>186.0,[ 3,"2"]=>44,[ 3,"3"]=>45,[ 3,:night_total]=> 79,[ 3,:kinmu_total]=>195.0
  }

  RolesRequiredTotal = { 
    [ 3, "1"]=>  0, [ 3, "2"]=>31, [ 3, "3"]=>31,    [ 4, "1"]=>252, [ 4, "2"]=>62, [ 4, "3"]=>62, 
    [ 9, "1"]=> 31, [ 9, "2"]=>31, [ 9, "3"]=>31,    [10, "1"]=> 31, [10, "2"]=>31, [10, "3"]=>31
  }
  RolesRequired = { 
    [3, "1"]=> 0, [3, "2"]=>27, [3, "3"]=>26, [ 4, "1"]=>222, [ 4, "2"]=>53, [ 4, "3"]=>49,
    [9, "1"]=>27, [9, "2"]=>25, [9, "3"]=>23, [10, "1"]=> 27, [10, "2"]=>25, [10, "3"]=>23
  }
  MarginOfRole = { 
    [3, "1"]=>186.0, [3, "2"]=>17, [3, "3"]=>19,  [4, "1"]=>108.0, [4, "2"]=>17, [4, "3"]=>19, 
    [9, "1"]=>166.0, [9, "2"]=>15, [9, "3"]=>15, [10, "1"]=>191.0, [10, "2"]=>25, [10, "3"]=>24
  }
  ShortRoleShift7 = { # 5/7
                   [4,"1"]=>[9,11],[9,"1"]=>[1,2],[10,"1"]=>[1,2],[ 4,"0"]=>[0,5],
    [3,"2"]=>[1,1],[4,"2"]=>[1, 1],[9,"2"]=>[1,2],[10,"2"]=>[0,1],
    [3,"3"]=>[1,1],[4,"3"]=>[1, 1],[9,"3"]=>[0,1],[10,"3"]=>[1,2]
  }

  CountRoleShift7 = { # 5/7 ??? 
    #[4,"_"]=>16,[9,"_"]=>9,[4,"2"]=>1,[10,"2"]=>1,[4,"3"]=>1,[9,"3"]=>1,[3,"_"]=>10,[10,"_"]=>11
  }
  ShortRole7 = [ [3,4,9],[3,4,10] ]
  RolesCountShort7 = [ [1,1,0,1,0],[1,1,0,0,1]]

   must "5月の roles_assignable" do
    assert_equal RolesAssignable,  @assign.roles_assignable
  end

   must "5月の roles_assigned" do
    assert_equal RolesAssigned,  @assign.roles_assigned(true)
  end

  must "5月の role_remain" do
    assert_equal RoleRemain,  @assign.role_remain#(true)
  end
  must "5月の roles_required_total" do
    assert_equal RolesRequiredTotal,  @assign.roles_required_total#(true)
  end
  must "5月の roles_required" do
    assert_equal RolesRequired,  @assign.roles_required#(true)
  end

  must "5月の roles_required" do
    assert_equal RolesRequired,  @assign.roles_required#(true)
  end

  must "5月の margin_of_role" do
    assert_equal MarginOfRole,  @assign.margin_of_role#(true)
  end
  must "5月7日の short_role_shift" do
    assert_equal ShortRoleShift7,  @assign.short_role_shift[7]#(true)
  end

  must "5月7日の count_role_shift" do
    assert_equal CountRoleShift7,  @assign.count_role_shift[7]#(true)
  end
  must "5月7日の short_role" do
    assert_equal ShortRole7,  %w(2 3).map{ |sft| @assign.short_role(7,sft) }
  end
  must "5月7日の roles_count_short" do
    assert_equal RolesCountShort7,  %w(2 3).map{ |sft| @assign.roles_count_short(7,sft) }
  end

  must  "5月7日に看護師41,47を、のshift2,3に割り付けた時の save/restore" do
    day =7
    nurces = nurce_by_ids([41,47],@nurces)
    shifts_short_role = @assign.save_shift(nurces,day)
    @assign.nurce_set_patern(nurces[0],day,"2")
    @assign.nurce_set_patern(nurces[1],day,"3")
    assert_equal [[0, 0, 0, 0, 0], [0, 0, 0, 0, 0]],  %w(2 3).map{ |sft| @assign.roles_count_short(7,sft) }
   @assign. restore_shift(nurces,day,shifts_short_role)
    assert_equal RolesCountShort7,  %w(2 3).map{ |sft| @assign.roles_count_short(7,sft) }
  end

# count_role_shift
# 
# margin_of_role
end
