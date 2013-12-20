# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/maint_plan_assign.rb'
require 'testdata/ube_const.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHelpTempAssignMaintPlanTest < ActiveSupport::TestCase
  fixtures "ube/holydays","ube/maintains","ube/products","ube/operations","ube/plans","ube/named_changes","ube/change_times","ube/constants"
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
 
  def setup
    #@skd=make_skd
    #@skd=Ubeboard::Skd.find(97,:include=>:ube_plans)
  end


  def make_skd(real_ope,ids=[])
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find_sub
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< Ubeboard::Plan.find(id) }
    skd.yojoko
    skd.set_yojoKo_object#sorted_plan
    skd
  end

  # 抄造の temp_assign_工程
  [[ShozoMaintPlan,"(酸洗は前ロットで済)"],[ShozoMaintPlanSansen,"(酸洗はまだ)"]].each{|plan,sansen|
    plan.each{|real_ope,ids,runtime_symbols,hozen_date,maintain,plantimes,msg|
      next unless real_ope
      must "抄造の仮割付#{sansen} #{msg} #{ids.join('->')} " do
        skd = make_skd(real_ope,ids)
        skd.pre_condition[real_ope]= skd.ube_plans[0]
        pre_plan,plan = skd.ube_plans[0..1]
        pre_plan_to   = pre_plan[TimeSym[real_ope]]
        #[0,1].each{|idx| maintain[idx] = Time.parse("2012/"+maintain[idx])}
        #plantimes[0] = Time.parse("2012/"+plantimes[0])
        plantimes[1] = plantimes[0]+plan.ope_length(real_ope)[0]
        runtime_symbols.each{|val,sym|
          skd.running["running_#{sym}_#{real_ope}"]=val
        }
        ClrList[ClrPoint[real_ope]..-1].each{|sym| plan[sym]=nil}
        skd.hozen_date[real_ope] = hozen_date
        assert_equal [maintain,plantimes*2],
        skd.temp_assign_shozo(plan)#,skd.yojoko[plan.yojoko])
      end
    }  
  }
  # 加工の temp_assign_工程
  KakouMaintPlan.each{|real_ope,ids,runtime_symbols,maint,plan_from,msg|
    next unless real_ope
    must "加工の仮割付 #{ids.join('->')} #{msg} " do
      skd = make_skd(real_ope,ids)
      skd.pre_condition[real_ope]= skd.ube_plans[0]
      pre_plan,plan = skd.ube_plans[0..1]
      pre_plan_to   = pre_plan[TimeSym[real_ope]]
      #plan_from     = Time.parse("2012/"+planfrom)
      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_#{real_ope}"]=val
      }
      ClrList[ClrPoint[real_ope]..-1].each{|sym| plan[sym]=nil}
      
      assert_equal_array [[pre_plan_to,pre_plan_to+maint[0],maint[1]],
                    [plan_from,plan_from+plan.ope_length(real_ope)[0],
                     plan_from,plan_from+plan.ope_length(real_ope)[0]
                    ]],
                    skd.temp_assign_kakou(plan)
                   
    end
  }  

  # 養生の temp_assign_工程
  YojoMaintPlan.each{|real_ope,ids,runtime_symbols,maint,plan_from,msg|
    next unless real_ope
    must "養生の仮割付 #{msg} " do
      skd = make_skd(real_ope,ids)
      skd.pre_condition[real_ope]= skd.ube_plans[0]
      pre_plan,plan = skd.ube_plans[0..1]
      #plan_from = Time.parse("2012/"+planfrom)
      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_#{real_ope}"]=val
      }
      ClrList[ClrPoint[real_ope]..-1].each{|sym| plan[sym]=nil}
      current_to =  plan.plan_shozo_to
      assert_equal_array [plan_from,plan_from+plan.ope_length(real_ope)[0]],
      skd.temp_assign_plan_yojo(plan,plan.plan_shozo_to)
    end
  }  
end
