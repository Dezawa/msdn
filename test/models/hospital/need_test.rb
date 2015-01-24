# -*- coding: utf-8 -*-
require 'test_helper'
# -*- coding: utf-8 -*-

class Hospital::NeedTest < ActiveSupport::TestCase
  fixtures :hospital_needs,:hospital_roles
  # Replace this with your real tests.

  must "検索結果をindex用に組み立てる" do
    ret = { 
      #role => { 平日 => [ [shift1],[2],[3] ]  休日  shift1,2,3    部門１のrole必要数
      3  => { 2 => [[nil,nil],[1,1],[1,1]] ,3 => [[nil,nil],[1,1],[1,1]]},
      4  => { 2 => [[9,11],[2,2],[2,2]]    ,3 => [[6,7],[2,2],[2,2]]},
      5  => { 2 => [[0,1],[0,1],[0,1]]     ,3 =>  [[0,1],[0,1],[0,1]]},
      9  => { 2 => [[1,2],[1,2],[1,2]]     ,3 => [[1,2],[1,2],[1,2]]},
      10 => { 2 => [[1,2],[1,2],[1,2]]     ,3 => [[1,2],[1,2],[1,2]]}
    }
    assert_equal [3,4,5,9,10],Hospital::Need.need_role_ids,"need_role_ids"
    assert_equal [3,4,5,9,10],Hospital::Need.need_list_each_role_daytype_of(1).keys.sort,"find_and_build(1).keys"
    # 部門１のrole必要数    ret[role_id][daytype][kinm] 
    rslt = Hash[*Hospital::Need.need_list_each_role_daytype_of(1).
                to_a.map{ |role,needs| 
                  [role, Hash[*needs.to_a.map{ 
                           |daytype,need| [daytype,
                                           need.map{ |nd| 
                                             [nd.minimun, nd.maximum] }
                                          ]}.flatten(1)]]
                }.flatten(1)]
    assert_equal ret,rslt
  end

  must "remake combination3 after save" do
    assert_equal [3,4,9,10],Hospital::Need.roles,"Need.roles"
    need = Hospital::Need.new("daytype"=>1,"busho_id"=>3,"role_id"=>5,"kinmucode_id"=>2,"minimun"=>1,"maximum"=>1)
    need.save
    pp Hospital::Need.all( :conditions => ["minimun>0"]).map(&:role_id).uniq.sort
    
    assert_equal 10*6,Hospital::Need.combination3.size
  end
  must  "a self.combination3" do
    assert_equal [ [4,3,9],[4,9,3],[3,4,9],[3,9,4],[9,4,3],[9,3,4],
                   [4,3,10],[4,10,3],[3,4,10],[3,10,4],[10,4,3],[10,3,4],
                   [4,9,10],[4,10,9],[9,4,10],[9,10,4],[10,4,9],[10,9,4],
                   [3,9,10],[3,10,9],[9,3,10],[9,10,3],[10,3,9],[10,9,3]
                 ].sort,Hospital::Need.combination3
  end

  must "Need_roles " do
    assert_equal [3,4,5,9,10],Hospital::Need.need_roles.map(&:id).sort,"Roleに必要と登録されているlroe"
  end
end
# -*- coding: utf-8 -*-
