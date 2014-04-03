# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/freelist.rb'
require 'testdata/ube_const.rb'
require 'pp'

#require 'result_copy_data.rb'
class Function::UbeSkdPreproccesTest < ActiveSupport::TestCase
  fixtures "ube/holydays","ube/maintains","ube/products","ube/operations", "ube/plans","ube/named_changes","ube/change_times","ube/constants"
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
  
  def setup
    #@skd=make_skd
    #@skd=UbeSkd.find(97,:include=>:ube_plans)
  end


  def make_skd(ids=[])
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find_sub
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< Ubeboard::Plan.find(id) }
    skd.yojoko
    skd
  end

  [:shozow,:shozoe,:dryo,:dryn,:kakou].
    zip( [[15,16,17,18],[],[15,16],[],[15]] ).each{| real_ope,ids |
    must "#{real_ope}の実績入りのplanは" do
      skd = make_skd([15,16,17,18,19])
      assert_equal ids,skd.sorted_resulted_plans(real_ope).map(&:id)
    end
  }
    
  [:shozow,:shozoe,:dryo,:dryn,:kakou].each{| real_ope |
    must "#{real_ope}の assign_if_resultedの後のFreeList" do
      skd = make_skd([15,16,17,18,19])
      assert_equal Freelist0[real_ope],skd.freeList[real_ope].freeList
      skd.assign_if_resulted
      assert_equal FreelistResuted0[real_ope],skd.freeList[real_ope].freeList
      assert_equal FreelistResuted1[real_ope],skd.freeList[real_ope].hozenFree.freeList
    end
  }

  [:shozow,:dryo,:kakou].
    zip(["06/05-08:00 06/06-08:00 06/07-08:00 06/08-08:00".times,
         "6/10-8:00 6/11-8:00".times, "6/12-8:00".times
        ]).each{|real_ope,times|
    must "#{real_ope}の実績終了時間は" do 
      skd = make_skd([15,16,17,18,19])
      assert_equal times,
      [0,1,2,3,4].map{|i| skd.ope_to_time(skd.ube_plans[i],real_ope)}.compact
    end
  }


  must "assign_if_resultedの後,lot 16 の加工割付 procceedは" do 
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    plan=skd.ube_plans[1]
    skd.assign_kakou(plan,plan.result_dry_to || plan.plan_dry_to )
    assert_equal "06/13-08:40, 06/13-11:45".times,[:plan_kakou_from,:plan_kakou_to].map{|t| plan[t]}
  end
  # id=16 mass 2304 product_id=1,12F kakou: "750"
  # 2304/750*3600 = 11059.2sec -> 11059sec 184.3min -> 185min 3h5min
   
  must "lot 17 加工割付後の、乾燥割付 procceedは" do 
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    plan=skd.ube_plans[1]
    skd.assign_kakou(plan,plan.result_dry_to || plan.plan_dry_to )
    assert_equal "06/13-08:40, 06/13-11:45".times,[:plan_kakou_from,:plan_kakou_to].map{|t| plan[t]}
    ## ここまで lot16

    #養生6/10 8:00終了。前ロット乾燥 6/11 8:00 終了、別柄だが、切り替え5分
    #pp [plan.plan_dry_from,plan.plan_dry_to,plan.plan_dry_out,plan.plan_dry_end]
    #   [06/10-08:00       , 06/11-08:00     , 06/10-11:09,    06/11-04:51]
    len,stay = plan.ope_length(:dry)
    maint       = 5.minute
    may_start   = plan.plan_dry_end + maint
    kakou_start = plan.plan_kakou_to + 240.minute # 水曜AM
    plan=skd.ube_plans[2]
    kakou_end  = kakou_start + plan.ope_length(:kakou)[0]
    skd.assign_dry_kakou(plan) #                        6/11 8:10
    #pp  [may_start, may_start+len,  may_start+stay, may_start+len-stay, kakou_end ]
    #[06/11-04:56, 06/11-15:21, 06/11-08:05, 06/11-12:12, 06/13-18:50]
    assert_equal [may_start, may_start+len,  may_start+stay, may_start+len-stay, kakou_end ] ,
    [:plan_dry_from,:plan_dry_to,:plan_dry_out,:plan_dry_end,:plan_kakou_to].map{|t| plan[t]}
  end


  must "lot 18 のprocceedは" do 
    skd = make_skd([15,16,17,18,19])
    # lot 15
    skd.assign_if_resulted
    # lot 16
    plan=skd.ube_plans[1]
    skd.assign_kakou(plan,plan.result_dry_to || plan.plan_dry_to )
    # lot 17
    plan=skd.ube_plans[2]
    skd.assign_dry_kakou(plan)
    #pp  [may_start, may_start+len,  may_start+stay, may_start+len-stay, kakou_end ]
    #[06/11-04:56, 06/11-15:21, 06/11-08:05, 06/11-12:12, 06/13-18:50]
    # pp [plan.plan_yojo_to,plan.plan_dry_end,plan.plan_kakou_to]
    # [06/10-08:00, 06/11-12:11, 06/13-18:50]

    # lot 18
    plan=skd.ube_plans[3]

    dry_start = skd.ube_plans[2].plan_dry_end+5.minute
    dry       = plan.ope_length(:dry)
    #pp [ dry_start,dry] [06/11-12:17, [37500, 11340, nil]] + 10:25 3:9
    #                           22:42
    kakou_start = skd.ube_plans[2].plan_kakou_to+40.minute #銘柄違い
    #    乾燥開始可能が06/11-12:11+5分.　その前 23+40hr前まで養生開始を遅らせる
    #"06/08-21:34, 06/10-13:34, 06/11-12:34, 06/12-00:59, 06/11-21:51, 06/13-20:30, 06/14-01:00".times,

    skd.assign_yojo_dry_kakou(plan)

    assert_equal [dry_start-63.hour,dry_start-23.hour,
                  dry_start,dry_start+dry[0],dry_start+dry[0]-dry[1],
                  kakou_start, kakou_start + plan.ope_length(:kakou).first
                 ],
    [:plan_yojo_from,:plan_yojo_to,
     :plan_dry_from,:plan_dry_to,:plan_dry_end,
     :plan_kakou_from,:plan_kakou_to].map{|t| plan[t]}

  end

  must "Procceed 終わると" do
    skd = make_skd([15,16,17,18,19])
    skd.assign_if_resulted
    skd.procceed_stock
    plan=skd.ube_plans[3]
    #    乾燥開始可能が06/11-12:29+5分.　その前 24+40hr前まで養生開始を遅らせる
    assert_equal "06/08-21:17, 06/10-13:17, 06/11-12:17, 06/12-00:32, 06/11-21:23, 06/13-19:30, 06/13-23:25".times,
    [:plan_yojo_from,:plan_yojo_to,
     :plan_dry_from,:plan_dry_to,:plan_dry_end,
     :plan_kakou_from,:plan_kakou_to].map{|t| plan[t]}
  end

 
 
end
