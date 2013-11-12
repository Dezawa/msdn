# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/maint_plan_assign.rb'
require 'testdata/ube_const.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHelpTempAssignTest < ActiveSupport::TestCase
  fixtures :ube_holydays,:ube_maintains,:ube_products,:ube_operations,
  :ube_plans,:ube_named_changes,:ube_change_times
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
  
  def setup
    #@skd=make_skd
    #@skd=UbeSkd.find(97,:include=>:ube_plans)
  end


  def make_skd(real_ope,ids=[])
    skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< UbePlan.find(id) }
    skd.yojoko
    skd.set_yojoKo_object#sorted_plan
    skd
  end

  # 初期化
  DryMaintPlan.
    each{|real_ope,ids,maintain,plantimes,msg|
    next unless real_ope
    must "乾燥の仮割付  #{msg} #{ids.join('->')} " do
      #         # 初期化
      skd = make_skd(real_ope,ids)
      skd.pre_condition[real_ope]= skd.ube_plans[0]
      pre_plan,plan = skd.ube_plans[0..1]
      # pre_condition他の設定
      skd.assign_force(pre_plan,pre_plan.dry?,pre_plan.plan_yojo_to)
      # planの結果期待値の作成
      # 開始時間は plantimes[0]
      len,sty = plan.ope_length(real_ope)
      plantimes[1] = plantimes[0]+len
      plantimes[2] = plantimes[0]+sty
      plantimes[3] = plantimes[0]+len-sty

      # current_toのために、加工時間を削除する

      pre_plan_from = pre_plan.plan_dry_from
      ClrList[4..-1].each{|sym| plan[sym]=nil}
      ClrList[6..-1].each{|sym| pre_plan[sym]=nil}

      # pre_condition他の設定
      expect = [ maintain ,   plantimes ]

      #skd.assign_maint_plan_by_temp(pre_plan,pre_plan.dry?,dry)
      assert_equal "06/08-08:03, 06/08-15:58, 06/08-10:56, 06/08-13:05".times,
      [pre_plan.plan_dry_from,pre_plan.plan_dry_to,pre_plan.plan_dry_out,pre_plan.plan_dry_end]
      assert_equal [maintain,plantimes], skd.temp_assign_dry(plan)
    end
  }  


# 抄造の temp_assign_工程
[[ShozoMaintPlan,"(酸洗は前ロットで済)"],[ShozoMaintPlanSansen,"(酸洗はまだ)"]].each{|plan,sansen|
  plan.each{|real_ope,ids,runtime_symbols,hozen_date,maintain,plantimes,msg|
    next unless real_ope
    must "抄造の仮割付#{sansen} #{msg} #{ids.join('->')} " do
      skd = make_skd(real_ope,ids)
      skd.pre_condition[real_ope]= skd.ube_plans[0]
      pre_plan,plan = skd.ube_plans[0..1]
      pre_plan_to   = pre_plan[TimeSym[real_ope]]
      #[0,1]#.each{|idx| maintain[idx] = Time.parse("2012/"+maint[idx])}
      # plantimes[0] = Time.parse("2012/"+plantimes[0])
      plantimes[1] = plantimes[0]+plan.ope_length(real_ope)[0]
      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_#{real_ope}"]=val
      }
      ClrList[ClrPoint[real_ope]..-1].each{|sym| plan[sym]=nil}
      skd.hozen_date[real_ope] = hozen_date
      assert_equal [maintain,plantimes*2],
      skd.temp_assign_shozo(plan) #,skd.yojoko[plan.yojoko])
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
    
    assert_equal [[pre_plan_to,pre_plan_to+maint[0],maint[1]],
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
#pp [skd.yojoko,skd.ube_plans[0].yojoKo,skd.ube_plans[1].yojoKo]

    skd.pre_condition[real_ope]= skd.ube_plans[0]
    pre_plan,plan = skd.ube_plans[0..1]
    #plan_from = Time.parse("2012/"+planfrom)
    runtime_symbols.each{|val,sym|
      skd.running["running_#{sym}_#{real_ope}"]=val
    }
    ClrList[ClrPoint[real_ope]..-1].each{|sym| plan[sym]=nil}
    current_to =  plan.plan_shozo_to
    assert_equal [plan_from,plan_from+plan.ope_length(real_ope)[0]],
    skd.temp_assign_plan_yojo(plan,plan.plan_shozo_to)
  end
}  


end
