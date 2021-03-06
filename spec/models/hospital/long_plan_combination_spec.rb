# -*- coding: utf-8 -*-
require 'spec_helper'

#class Hospital::LongPlanCombinationTest < ActiveSupport::TestCase
describe "LongPlanCombinationについて" do
  before do
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(nil,nil)#(@busho_id,@month)
    @nurces=@assign.nurces
  end

  def nurce(id); 
    nurce = Hospital::Nurce.find id
    nurce.monthly(@month)
    nurce
  end

  [[1,3, [[0],[1],[2]]],
   [2,3, [[0,0],[0,1],[0,2],[1,0],[1,1],[1,2],[2,0],[2,1],[2,2]]],
   [3,3, [[0, 0, 0], [0, 0, 1], [0, 0, 2], [0, 1, 0], [0, 1, 1], [0, 1, 2],
          [0, 2, 0], [0, 2, 1], [0, 2, 2], [1, 0, 0], [1, 0, 1], [1, 0, 2],
          [1, 1, 0], [1, 1, 1], [1, 1, 2], [1, 2, 0], [1, 2, 1], [1, 2, 2],
          [2, 0, 0], [2, 0, 1], [2, 0, 2], [2, 1, 0], [2, 1, 1], [2, 1, 2],
          [2, 2, 0], [2, 2, 1], [2, 2, 2]
         ]],
   nil
  ].each{|nurce,plan,result|
    next unless nurce
    msg = "看護師#{nurce}人、Plan数 #{plan}"
    it msg do
      assert_equal result,@assign.long_plan_combination(nurce,plan),msg
      @assign.long_plan_combination(nurce,plan)
    end
  }


end
# -*- coding: utf-8 -*-
