# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/assign_all.rb'
require 'testdata/ube_const.rb'
require 'pp'

#require 'result_copy_data.rb'
class Function::UbeSkdHelpAssignTest < ActiveSupport::TestCase
  fixtures :ube_holydays,:ube_maintains,:ube_products,:ube_operations, :ube_plans,:ube_named_changes,:ube_change_times
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
  
  def setup
    #@skd=make_skd
    #@skd=UbeSkd.find(97,:include=>:ube_plans)
  end


  def make_skd(ids=[])
    skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< UbePlan.find(id) }
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
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    skd.procceed_stock
    # 06/08-21:34, 06/10-13:34, 06/11-12:34, 06/12-00:59, 06/11-21:51, 06/13-20:30, 06/14-01:00
    
    plan = skd.ube_plans[4] #18
    skd.hozen_date[:shozow]=6 
    assert_equal([:shozo,[times("06/08-08:00, 06/08-10:00")<<[105],
                  times("06/08-10:00, 06/08-13:30, 06/08-10:00, 06/08-13:30")]],
                  [:shozo,skd.temp_assign_all_plan_check_biyond_holyday(plan,nil)[0]]#.dump]
                  )
    

  end

must "affter procceed_stock" do
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    skd.procceed_stock

    plan = skd.ube_plans[4] #19
    skd.hozen_date[:shozow]=6
    skd.assign_temp_and_real(plan)
    #pp skd.ube_plans[3].plan_dry_end
    # 養生　　　　　　　　　　　乾燥　　　　　　　　　　　　　　　　　　加工
   # "06/08-21:17, 06/10-13:17, 06/11-12:17, 06/12-00:32, 06/11-21:23, 06/13-19:30, 06/13-23:25".
    # ube_plans[3]の乾燥endは 06/11-21:23。これの 24+40hr - 切り替え前まで養生開始を遅らせる
    assert_equal([:shozo,"06/08-10:00, 06/08-13:30".times],#06/06-22:05, 06/07-09:40")],
                 [:shozo,[plan.plan_shozo_from,plan.plan_shozo_to]])
    assert_equal([:yojo,times("06/09-06:28, 06/10-22:28")], #06/08-19:40 06/10-11:40
                 [:yojo,[plan.plan_yojo_from,plan.plan_yojo_to]])
    assert_equal([:dry,times("06/11-21:28, 06/12-06:03, 06/12-02:54")], #06/10-11:40
                 [:dry,[plan.plan_dry_from,plan.plan_dry_to,plan.plan_dry_end]])
    assert_equal([:kakou,times("06/14-00:05, 06/14-02:25")],
                 [:kakou,[plan.plan_kakou_from,plan.plan_kakou_to]])

  end

end
