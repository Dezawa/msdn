# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/temp_assign_all.rb'
require 'testdata/ube_const.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHelpTempAssignAllTest < ActiveSupport::TestCase
  fixtures "ube/holydays","ube/maintains","ube/products","ube/operations", "ube/plans","ube/named_changes","ube/change_times"
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
  
  def setup
    #@skd=make_skd
    #@skd=Ubeboard::Skd.find(97,:include=>:ube_plans)
  end


  def make_skd(ids=[])
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find_sub
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< Ubeboard::Plan.find(id) }
    skd.yojoko
    skd
  end

  must "sate" do
    skd = make_skd([70,71])
    skd.assign_if_resulted
    #pp skd.ube_plans[0].plan_dry_end
    plan=skd.ube_plans[1]
    assert_equal_array Assign71_2, skd.temp_assign_all_plan(plan)
    #assert_equal [],skd.pre_condition.map(&:id)
    
  end

end
