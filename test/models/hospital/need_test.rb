# -*- coding: utf-8 -*-
require 'test_helper'
# -*- coding: utf-8 -*-

class Hospital::NeedTest < ActiveSupport::TestCase
  fixtures "hospital/needs","hospital/nurces","hospital/roles"
  # Replace this with your real tests.
  def setup
    @busho_id = 3
  end

  WeekDayPatern = { 
    [1,"3"] => [1,1], [2,"3"] => [3,3], [3,"3"] => [0,1], [4,"3"] => [1,2], [5,"3"] => [1,2], 
    [1,"2"] => [1,1], [2,"2"] => [4,4], [3,"2"] => [0,1], [4,"2"] => [1,2], [5,"2"] => [1,2],
    [2,"1"] => [10,20], [3,"1"] => [ 0, 1], [4,"1"] => [ 1, 2], [5,"1"] => [ 1, 2] 
  }
  WeekEndPatern = {
    [1,"3"] => [1,1], [2,"3"] => [3,3], [3,"3"] => [0,1], [4,"3"] => [1,2], [5,"3"] => [1,2],
    [1,"2"] => [1,1], [2,"2"] => [4,4], [3,"2"] => [0,1], [4,"2"] => [1,2], [5,"2"] => [1,2], 
    [2,"1"] => [10,10], [3,"1"] => [ 0, 1], [4,"1"] => [ 1, 2], [5,"1"] => [ 1, 2], 
  }
  must "平日の必要人数パターン" do
    assert_equal WeekDayPatern,
                 Hospital::Need.needs_of_busho_of_datetype(Hospital::Need::Weekday,@busho_id)
  end
  must "休日の必要人数パターン" do
    assert_equal WeekEndPatern,
                 Hospital::Need.needs_of_busho_of_datetype(Hospital::Need::Weekend,@busho_id).
                 sort_by{ |k,v| k}.to_h
  end

  must "看護師数" do
    kangoshi = Hospital::Define.define.kangoshi
    assert_equal 2,kangoshi
    assert_equal 33,Hospital::Nurce.where( ["busho_id = ? ",@busho_id]).size,"職場スタッフ数"
    assert_equal 51,Hospital::Nurce.where( ["shokushu_id  = ? ",kangoshi=2]).size,"看護師数"
    nurse_size_of_this_busho = Hospital::Nurce.
      where( ["busho_id = ? and shokushu_id = ? ",@busho_id,kangoshi]).size
    assert_equal 33,nurse_size_of_this_busho
  end

  must "平日、休日の必要人員の数 パターンを求める" do
    assert_equal [WeekDayPatern.merge([2,"0"] => [0,33-14]),WeekEndPatern.merge([2,"0"] => [0,19])],
                  Hospital::Need.need_patern(@busho_id)
  end

  must "検索結果をindex用に組み立てる" do
    ret = { 
      #role => { 平日 => [ [shift1],[2],[3] ]  休日  shift1,2,3    部門１のrole必要数
      1  => { 2 => [[nil,nil],[1,1],[1,1]] ,3 => [[nil,nil],[1,1],[1,1]]},
      2  => { 2 => [[10, 20], [4, 4], [3, 3]], 3=>[[10, 10], [4, 4], [3, 3]]},
      3  => { 2 => [[0,1],[0,1],[0,1]]     ,3 =>  [[0,1],[0,1],[0,1]]},
      4  => { 2 => [[1,2],[1,2],[1,2]]     ,3 => [[1,2],[1,2],[1,2]]},
      5  => { 2 => [[1,2],[1,2],[1,2]]     ,3 => [[1,2],[1,2],[1,2]]}
    }
    assert_equal [1,2,3,4,5],Hospital::Need.need_role_ids,"need_role_ids"
    assert_equal [1,2,3,4,5],Hospital::Need.need_list_each_role_daytype_of(@busho_id).
      keys.sort,"find_and_build(1).keys"
    # 部門１のrole必要数    ret[role_id][daytype][kinm] 
    rslt = Hash[*Hospital::Need.need_list_each_role_daytype_of(@busho_id).
                to_a.map{ |role,needs| 
                  [role, Hash[*needs.to_a.map{ 
                           |daytype,need| [daytype,
                                           need.map{ |nd| 
                                             [nd.minimun, nd.maximum] }
                                          ]}.flatten(1)]]
                }.flatten(1)]
    assert_equal ret[1],rslt[1],"検索結果をindex用 role 1"
    assert_equal ret[2],rslt[2],"検索結果をindex用 role 2"
    assert_equal ret[3],rslt[3],"検索結果をindex用 role 3"
    assert_equal ret[4],rslt[4],"検索結果をindex用 role 4"
    assert_equal ret[5],rslt[5],"検索結果をindex用 role 5"
  end

 
  must  "a self.combination2" do
    assert_equal [ [2,1,4],[2,4,1],[1,2,4],[1,4,2],[4,2,1],[4,1,2],
                   [2,1,5],[2,5,1],[1,2,5],[1,5,2],[5,2,1],[5,1,2],
                   [2,4,5],[2,5,4],[4,2,5],[4,5,2],[5,2,4],[5,4,2],
                   [1,4,5],[1,5,4],[4,1,5],[4,5,1],[5,1,4],[5,4,1]
                 ].sort,Hospital::Need.combination3
  end

  must "Need_roles " do
    assert_equal [1,2,3,4,5],Hospital::Need.need_roles.map(&:id).sort,"Roleに必要と登録されているlroe"
  end
end
# -*- coding: utf-8 -*-
