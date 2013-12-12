# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/maintain_assign.rb'
require 'testdata/ube_const.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHelpTempAssignMaintTest < ActiveSupport::TestCase
  fixtures :ube_holydays,:ube_maintains,:ube_products,:ube_operations,:ube_plans,:ube_named_changes,:ube_change_times
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
    skd
  end
  
  must "NamedMust is" do
    make_skd
    assert_equal [111, 112, 113, 115, 116],UbeSkd.named_mult
#UbeProduct.all(:conditions => ["proname in (?)",%w(WF替 PF替 サラン替)]).map(&:id)
#UbeSkd::NamedMult
  end

  ### 乾燥仮割付
  
  ### 乾燥の保守。
  DryMaintain.each{|ids,ret_maintain,ret_chng,ret_maint,msg |
    next unless ids
    must "乾燥の保守。 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = plan.dry?
      skd.pre_condition[real_ope]=skd.ube_plans[0]

      assert_equal ret_maintain, skd.maintain_time(plan,real_ope).to_a
    end
  }
  ### 乾燥の切り替え。
  DryMaintain.each{|ids,ret_maintain,ret_chng,ret_maint,msg |
    next unless ids
    must "乾燥の切り替え時間 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = plan.dry?
      skd.pre_condition[real_ope]=skd.ube_plans[0]
      assert_equal( ret_chng,  skd.change_time(plan,real_ope).to_a
                    )
    end
  }

  ### 加工仮割付
  KakouMaintain.each{|ids,ret_maintain,ret_chng,ret_maint,msg |
    next unless ids
    must "加工仮割付 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = :kakou
      skd.pre_condition[real_ope]=skd.ube_plans[0]

      pre_plan_to = skd.ube_plans[0].plan_kakou_to
      assert_equal [pre_plan_to,pre_plan_to+ret_maint[0],ret_maint[1]], skd.temp_assign_maint(plan,real_ope)
    end
  }

  ### 加工の保守。
  KakouMaintain.each{|ids,ret_maintain,ret_chng,ret_maint,msg |
    next unless ids
    must "加工の保守。 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = :kakou
      skd.pre_condition[real_ope]=skd.ube_plans[0]

      assert_equal ret_maintain, skd.maintain_time(plan,real_ope).to_a
    end
  }
  ### 加工の切り替え。
  KakouMaintain.each{|ids,ret_maintain,ret_chng,ret_maint,msg |
    next unless ids
    must "加工の切り替え時間 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = :kakou
      skd.pre_condition[real_ope]=skd.ube_plans[0]
      assert_equal( ret_chng,  skd.change_time(plan,real_ope).to_a
                    )
    end
  }

  ### 抄造仮割付
  ShozoMaintain.each{|ids,ret,runtime_symbols,msg |
    next unless ids
    must "仮割付 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = plan.shozo?
      skd.pre_condition[real_ope]=skd.ube_plans[0]

      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_shozoe"]=val
      }
      pre_plan_to = skd.ube_plans[0].plan_shozo_to
      assert_equal [pre_plan_to,pre_plan_to+ret[2].minute,ret[3]], skd.temp_assign_maint(plan,real_ope)
    end
  }
 
  [1].each{
    ids,ret,runtime_symbols,msg =   [[37,36],[1440.0.minute,[115],1440,[115]],[[(1000-4).hour ,:pf]], 
                                     "1000-4 ではPF替 を行うが、休日が入る"]
    must "仮割付 #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = plan.shozo?
      skd.pre_condition[real_ope]=skd.ube_plans[0]

      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_shozoe"]=val
      }
      pre_plan_to = Time.parse("2012/6/5 8:00")
      assert_equal [pre_plan_to,pre_plan_to+ret[2].minute,ret[3]], skd.temp_assign_maint(plan,real_ope)
    end
  }
  must "作業が重なったときに、併記すべき保守・切り替え" do
    assert_equal  [111, 112, 113, 115, 116],
    UbeProduct.all(:conditions => ["proname in (?)",%w(WF替 PF替 サラン替)]).map(&:id)
  end
  ### 抄造の保守仮割付の評価
  Maintain.each{|real_ope,ids,ret,hday,msg |
    next unless real_ope
    must  "#{UbeSkd::Id2RealName[real_ope]} 前回保全#{hday}日 #{msg} #{ids.join('→ ')}の保守時間" do
      skd=make_skd(ids)
      skd.hozen_date[real_ope]=hday
      skd.pre_condition[real_ope]=skd.ube_plans[0]
      plan = skd.ube_plans[1]
      assert_equal ret[0..1], skd.maintain_time(plan,real_ope).to_a
    end
  }
  ### 抄造の保守。フェルト替え
  ShozoMaintain.each{|ids,ret,runtime_symbols,msg |
    next unless ids
    must "抄造の保守。フェルト替え #{msg}" do
      skd=make_skd(ids)
      plan = skd.ube_plans[1]
      real_ope = plan.shozo?
      skd.pre_condition[real_ope]=skd.ube_plans[0]

      runtime_symbols.each{|val,sym|
        skd.running["running_#{sym}_shozoe"]=val
      }
#pp plan. ope_length(:shozo)[0]/(1.0.hour)
      assert_equal ret[0..1], skd.maintain_time(plan,real_ope).to_a
    end
  }
  #### 切り替えの評価
  ChangeTimeList.each{|from_pro_id,to_pro_id,change|
    must "ChangeTime #{from_pro_id} -> ,#{to_pro_id}" do
      
      pro = UbeProduct.find(from_pro_id)
      from_condition = pro.ope_condition
      line     = pro.shozo
      pro = UbeProduct.find(to_pro_id)
      to_condition = pro.ope_condition
      assert_equal change,
      UbeChangeTime.find_by_ope_name_and_ope_from_and_ope_to(line,from_condition,to_condition).change_time
    end

  }
  ChangeDifferMeigara.each{|real_ope,ids,interval,msg|
    break unless real_ope
    time     = TimeSym[real_ope]
    must "#{UbeSkd::Id2RealName[real_ope]} #{msg} #{ids.join('→ ')}の切り替え時間" do
      skd = make_skd
      skd.ube_plans=[]
      skd.ube_plans<< UbePlan.find(ids[0])
      skd.ube_plans<< UbePlan.find(ids[1])
      skd.pre_condition[real_ope]=skd.ube_plans[0]
      plan=skd.ube_plans[1]
      assert_equal interval,  skd.change_time(plan,real_ope).to_a
                    
      #pp [UbeSkd::Id2Ope[UbeSkd::Real2Ope[real_ope]],skd.named_change_pro_ids(:shozoe,"","16高級")]
    end
  }

end


__END__
