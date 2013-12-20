# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeRenumberTest < ActiveSupport::TestCase
  fixtures "ube/products","ube/operations","ube/plans"
  fixtures "ube/skds","ube/plans_skds"


  must "未割り当てロット" do
    skd = Ubeboard::Skd.find 2
    #assert_equal [1,2,3],skd.ube_plans.map(&:jun)
    assert_equal [[23, "2M0307"],
                  [26, "2M0372"],
                  [72, "2W0266"],
                  [73, "2W0267"],
                  [74, "2M0289"],
                  [75, "2M0303"],
                  [76, "2M0294"],
                  [77, "2M0287"] ],
    skd.unassigned_plans.values.flatten.map{|plan| [plan.id,plan.lot_no]}.sort
  end

  must "Max lot_no of 西抄造" do
    skd = Ubeboard::Skd.find 2
    lot_no,jun = skd.max_lot_no_and_jun_of_assigned
    assert_equal "2W0299",lot_no[:shozow]
  end

  must "Max lot_no of 東 抄造" do
    skd = Ubeboard::Skd.find 2
    lot_no,jun = skd.max_lot_no_and_jun_of_assigned
    assert_equal "2M0372", lot_no[:shozoe]
  end

  must "Max jun " do
    skd = Ubeboard::Skd.find 2
    lot_no,jun = skd.max_lot_no_and_jun_of_assigned
    assert_equal 44     , jun
  end

  must "未割り当てロットのlot_no、順のつけ直し" do
    skd = Ubeboard::Skd.find 2
    unassigned = skd.unassigned_plans.values.flatten
    skd.renumber
    assert_equal [
                  ["2M0373", 45, 23],
                  ["2M0374", 46, 26],
                  ["2M0375", 47, 74],
                  ["2M0376", 48, 75],
                  ["2M0377", 49, 76],
                  ["2M0378", 50, 77],
                  ["2W0300", 51, 72],
                  ["2W0301", 52, 73]], 
    unassigned.map{|plan| [plan.lot_no,plan.jun,plan.id]}.sort
  end
    
end

