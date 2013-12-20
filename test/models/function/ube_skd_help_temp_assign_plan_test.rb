# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/plan_assign.rb'
require 'testdata/ube_const.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHelpTempAssignPlanTest < ActiveSupport::TestCase
  fixtures "ube/holydays","ube/maintains","ube/products","ube/operations","ube/plans","ube/named_changes","ube/change_times"
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
    skd.set_yojoKo_object#sorted_plan
    skd
  end

  # 加工, 養生、抄造
  # 
  Plan.each{|real_ope,ids,plan_from,plan_time,runtime_symbols,msg|
    next unless real_ope
    must "#{real_ope} #{msg} " do
      skd = make_skd(ids)
      skd.pre_condition[real_ope]= skd.ube_plans[0]
      pre_plan,plan = skd.ube_plans[0..1]
      #plan_from = Time.parse("2012/"+planfrom)
      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_#{real_ope}"]=val
      }
      ClrList[ClrPoint[real_ope]..-1].each{|sym| plan[sym]=nil}

      maint = skd.temp_assign_maint(plan,real_ope)
      current_to = real_ope == :yojo ? plan.plan_shozo_to : nil
      assert_equal [maint[1],[plan_from,plan_from+plan.ope_length(real_ope)[0]]],
      [maint[1],skd.temp_assign_plan(plan,real_ope,current_to,maint[1])[0,2]]
    end
  }  

  #   切り替えは入るが製造が入らない
  #   切り替えは入るが製造が入らない
  #   切り替えも入らない
  #   水曜で保守が入る
  #   保守が入った後の水曜
  # 抄造
  #   酸洗済み
  #     切り替え、製造が休み前に入る
  #     切り替えは入るが製造が入らない
  #     切り替えも入らない
  #   WFが入る
  #     製造が休み前に入る
  #     製造が入らない
  #     WFは休転に入る
  #  酸洗まだ
  #     休日明け
  #     休転明け
  #     WFも入る
  # 乾燥

  

end


__END__

  # 乾燥
  DryPlan.each{|real_ope,ids,plan_from,change_time,runtime_symbols,msg|
    next unless real_ope
    must "乾燥の切り替えと開始・終了・#{real_ope} #{msg} " do
      skd = make_skd(ids)
      pre_plan = skd.ube_plans[0]#skd.pre_condition[real_ope]
      plan = skd.ube_plans[1]
      #plan_from = Time.parse("2012/"+planfrom)

      ClrList[4..-1].each{|sym| plan[sym]=nil}
      ClrList[4..-1].each{|sym| plan[sym]=nil}
      # pre_planをらしく割り当てる（ymlの値はいい加減だし、plan_endがないから）
      skd.assign_force(pre_plan,pre_plan.dry?,pre_plan.plan_yojo_to)
      # id 64  from 06/08-08:03, to 06/08-15:58, end 06/08-13:05

      c_len,c_stay = plan.ope_length(plan.dry?)
      expect = [ [pre_plan.plan_dry_end,pre_plan.plan_dry_end + change_time ,["切替"]],
                 [plan_from,plan_from+c_len,plan_from+c_stay,plan_from+c_len-c_stay]
               ]

      maint  = skd.temp_assign_maint(plan,plan.dry?)
      assign = skd.temp_assign_plan(plan,real_ope,nil,maint[1])
      #skd.assign_maint_plan_by_temp(pre_plan,pre_plan.dry?,dry)
      assert_equal expect, [ maint,assign ]
    end
  }
