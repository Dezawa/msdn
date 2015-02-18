# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
#require 'need'

class Hospital::ReentrantTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies","hospital/defines"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.

  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @nurces=@assign.nurces
    srand(1)
  end

  must "2/1 夜の看護師候補" do
    assert_equal [[[34, 46], [36, 45]], [[34, 46], [36, 37]], [[34, 46], [36, 39]],
                  [[34, 35], [36, 45]], [[34, 35], [36, 37]], [[34, 46], [36, 48]]],
    hash_combination_ids(@assign.candidate_combination_for_shift23_selected_by_cost(1))
  end
  must "2/1 夜の看護師候補の割付" do
    pre = @assign.dump.split("\n")
    @assign.assign_night(1,:dipth => 1)
    assert_equal [["34 ______11_____________1______1", "36 _____3_0_______0____________0",
                   "45 _________________0________2__", "46 _________0_____________0_____"],
                  ["34 _20___11_____________1______1", "36 _30__3_0_______0____________0",
                   "45 _30______________0________2__", "46 _20______0_____________0_____"]
                 ],pre.diff(@assign.dump.split("\n"))
  end
end
