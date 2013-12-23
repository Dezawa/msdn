# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/assign_all.rb'
require 'testdata/ube_const.rb'
require 'pp'

#require 'result_copy_data.rb'
class Function::UbeSkdHelpAssignTest < ActiveSupport::TestCase
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

  must "temp_assign_kakou" do
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    plan = skd.ube_plans[1] #16
    kakou_allotment = skd.temp_assign_kakou(plan,plan.result_dry_to)
    assert_equal ["06/13-08:00, 06/13-08:40".times<<["切替"],
                  "06/13-08:40, 06/13-11:45 06/13-08:40, 06/13-11:45".times],
    kakou_allotment#.dump
  end
 
  must "assign_kakou" do
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    plan = skd.ube_plans[1] #16
    skd.assign_kakou(plan,plan.result_dry_to)
    assert_equal "06/13-08:40, 06/13-11:45".times,[plan.plan_kakou_from,plan.plan_kakou_to]
  end


  must "temp_assign_all_plan_check_biyond_holyday" do
    # Ube_plan ID=15~~19についてスカジュールを立てる
    skd = make_skd([15,16,17,18,19]) 
    skd.assign_if_resulted
    skd.procceed_stock
    # 06/08-21:34, 06/10-13:34, 06/11-12:34, 06/12-00:59, 06/11-21:51, 06/13-20:30, 06/14-01:00
    plan = skd.ube_plans[4] #18  
    skd.hozen_date[:shozow]=6    # 西抄造の前回保全は６日
    assert_equal_array([["06/08-08:00 06/08-10:00".times<<[105],
                         "06/08-10:00 06/08-13:30 06/08-10:00 06/08-13:30".times]],
                  [skd.temp_assign_all_plan_check_biyond_holyday(plan,nil)[0]]#.dump]
                  )
    

  end

must "affter procceed_stock" do
    # Ube_plan ID=15~~19についてスカジュールを立てる
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    skd.procceed_stock

    plan = skd.ube_plans[4] #19
    skd.hozen_date[:shozow]=6   # 西抄造の前回保全は６日
    skd.assign_temp_and_real(plan)
    #pp skd.ube_plans[3].plan_dry_end
    # 養生　　　　　　　　　　　乾燥　　　　　　　　　　　　　　　　　　加工
   # "06/08-21:17, 06/10-13:17, 06/11-12:17, 06/12-00:32, 06/11-21:23, 06/13-19:30, 06/13-23:25".
    # ube_plans[3]の抄造は 2012/6/8 8:00 に終っているから、8:05に開始可能だが、月曜なので
    # 始業作業が入り、10:00抄造開始となる。所要3:30    
    # 養生は4:30から可能であるが、ube_plans[3]の乾燥endは 06/11-21:23なので、
    # これの 24+40hr 6/9 05:23まで養生開始を遅らせる.切替5分あるから 06/09-06:28~06/10-22:28
    # ube_plans[3]の乾燥endは 06/11-21:23に切替5分後から開始06/11-21:28 06/12-06:03
    # ube_plans[3]の加工終了は
    assert_equal_array("06/08-10:00 06/08-13:30".times,#06/06-22:05, 06/07-09:40")],
                 [plan.plan_shozo_from,plan.plan_shozo_to])
    assert_equal("06/09-06:28 06/10-22:28".times, #06/08-19:40 06/10-11:40
                 [plan.plan_yojo_from,plan.plan_yojo_to])
    assert_equal("06/11-21:28 06/12-06:03, 06/12-02:54".times, #06/10-11:40
                 [plan.plan_dry_from,plan.plan_dry_to,plan.plan_dry_end])
    assert_equal("06/14-00:05 06/14-02:25".times,
                 [plan.plan_kakou_from,plan.plan_kakou_to])

  end

end
