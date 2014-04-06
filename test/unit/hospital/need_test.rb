# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::NeedTest < ActiveSupport::TestCase
  fixtures :hospital_needs,:hospital_roles
  # Replace this with your real tests.

  must "remake combination3 after save" do
    need = Hospital::Need.new("daytype"=>1,"busho_id"=>3,"role_id"=>5,"kinmucode_id"=>2,"minimun"=>1,"maximum"=>1)
    need.save
    pp Hospital::Need.all( :conditions => ["minimun>0"]).map(&:role_id).uniq.sort
    
    assert_equal [3,4,5,9,10],Hospital::Need.roles,"Need.roles"
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
    assert_equal [3,4,5,8,9,10],Hospital::Need.need_roles.map(&:id).sort,"Roleに必要と登録されているlroe"
  end
end
