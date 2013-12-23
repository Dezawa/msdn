# -*- coding: utf-8 -*-
require 'test_helper'

class UbePlanTest < ActiveSupport::TestCase
  fixtures "ube/plans","ube/products"
  fixtures "ube/operations","ube/change_times"
  #def setup
  #  @plans = Ubeboard::Plan.all(:order => "id")
  #  @plans[2].ube_product_id=nil
  #end

  def make_skd_and_set_pre_condition(ids=[])
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find_sub
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< Ubeboard::Plan.find(id) }
    Ubeboard::Skd::RealOpe.each{|real_ope| skd.pre_condition[real_ope] = skd.ube_plans.first}
    skd.yojoko
    skd
  end

  must "cont" do
    assert_equal 100,Ubeboard::Plan.count
  end
  #must "PTime is" do
  #  assert_equal [],Ubeboard::Plan::PTime
  #end
  #product_error?
  Product_error = ["","ID=300の製品登録がありません","2M0248の製品が未入力です"]
  (1..3).each{|id| idx=id-1
    must "ID=#{id} proname_id" do 
      plan=Ubeboard::Plan.find(id) 
      plan.ube_product_id = nil if idx==2
      assert_equal Product_error[idx],plan.ube_product_error?
    end
  }

  #n_mass
  Nmass=[0.75,1.00,1.25]
  (4..6).each{|id| idx = id - 4 
    must "ID #{id}.mass" do
      assert_equal Nmass[idx],Ubeboard::Plan.find(id).n_mass
    end
  }
  must "大きすぎる mass のときは 1.25" do
    plan =Ubeboard::Plan.find 5
    plan.mass=100000
    assert_equal 1.25,plan.n_mass
  end
  must "小さすぎる mass のときは 0.75" do
    plan = Ubeboard::Plan.find 5
    plan.mass=100
    assert_equal 0.75,plan.n_mass
  end

  #deletabl?
  [7,8,9,10,11].zip([false,false,true,false,true]).each{|id,bool|
    idx = id - 7 
    must "ID #{id}の削除可能性" do
      assert_equal bool,Ubeboard::Plan.find(id).deletable?
    end
  }

  #date
  plan=Ubeboard::Plan.new
  time = %w(23:59 0:00 0:01 7:59 8:00 8:01)
  day  =   [ 10  ,9   ,9   ,9   ,10   ,10]
  (0..5).each{|idx|
    must "10日#{time[idx]}は#{day[idx]}日扱い" do
      assert_equal day[idx],plan.date(Time.parse("2012/6/10 "+time[idx]))
    end
  }
  #copy_results
  copy_count = [8,6,0]
  rsrt = [ [true,true,true,true,true,true,true,true],
           [true,true,true,true,true,true,false,false],
           [false,false,false,false,false,false,false,false]
         ]
  ptime = %w(shozo yojo dry kakou).map{|ope| ["plan_#{ope}_from","plan_#{ope}_to"]}.flatten
  rtime = ptime.map{|ope| ope.sub(/plan/,"result")}
  prtime = ptime.zip rtime
  (12..14).each{|id| idx=id-12
    must "ID #{id} は #{copy_count[idx]}個までcopy" do
      plan=Ubeboard::Plan.find(id); 
      plan.copy_results
      assert_equal rsrt[idx],prtime.map{|p,r|  plan[p].to_i == plan[r].to_i }
    end
  }


  (15..26).each{|id|    idx = id-15
  # current
    must "ID #{id} の終了工程 current は" do 
      plan =  Ubeboard::Plan.find(id)
      current = plan.meigara.split[2].to_sym
      current = nil if current == :nil
      assert_equal current, plan.current
    end
  }

  [:nil,:shozo,:shozoe,:shozow,:yojo,:dry,:dryo,:dryn,:kakou].
    zip([:nil,:nil,:nil,:nil,:shozo,:yojo,:yojo,:yojo,:dry]).
  each{|c,p|
    must "#{c}の前工程は#{p}" do
      plan=Ubeboard::Plan.new
      assert_equal p, plan.pre(c)
    end
  }
  # pre
  (15..26).each{|id|    idx = id-15
    must "ID #{id} の終了工程一つまえ pre は" do 
      plan =  Ubeboard::Plan.find(id)
      pre = plan.meigara.split[1].to_sym
      assert_equal pre, plan.pre
    end
  }
  #done?
  Done = [true,false,false,false,false,
          true,false,false,false,
          true,false,false]
  #lastmonth
  Done2 = [false,false,false,false,false,
           true,false,false,false,
           true,false,false]
  Done3 = [false,false,false,false,false,
           false,false,false,false,
           false,false,false]
    #current_to
  Current_to=["2012/6/12 8:00","2012/6/11 8:00","2012/6/10 8:00","2012/6/8 8:00",nil,
              "2012/6/11 8:00","2012/6/10 8:00","2012/6/08 8:00",nil,
              "2012/6/10 8:00","2012/6/8 8:00",nil].map{|t|
    Time.parse(t) if t
  }
    #done?
  (15..26).each{|id|    idx = id-15
    must "ID #{id} は完了しているかdone?" do 
      assert_equal Done[idx], Ubeboard::Plan.find(id).done?
    end
 
     #next?
      must "ID #{id} next?" do 
        plan =  Ubeboard::Plan.find(id)
#pp plan.proname
        assert_equal  plan.meigara.split[3].to_sym,plan.next?
      end
    #result_done?
    must "ID #{id} は実績完了しているかresult_done?" do 
      assert_equal Done[idx], !!Ubeboard::Plan.find(id).result_done?
    end

    #current_to
    must "ID #{id} の現工程（つまり今割り付けている工程の一つ前）の終了時間current_to" do
      assert_equal Current_to[idx], Ubeboard::Plan.find(id).current_to
    end

    #lastmonth 2011-10-1
    must "ID #{id} 2012/6/10 に完了しているか done?  " do 
      assert_equal Done2[idx], Ubeboard::Plan.find(id).lastmonth?(Time.parse("2012/6/10"))
    end

    #lastmonth 2011/9/8
    must "ID #{id} 2012/6/9に完了しているか done?  " do 
      assert_equal Done3[idx], Ubeboard::Plan.find(id).lastmonth?(Time.parse("2012/6/9"))
    end
  }

  #real_ope?
  RealOpe  = [:shozow,:shozoe,:dryo,:dryn,:yojo,:kakou,:dmy,:done]
  RealOpeBool = [ [ true,false,true,false,true,true,true,true], #西原 
                  [ true,false,false,true,true,true,true,true], #西新
                  [ false,true,true,false,true,true,true,true], #東原
                  [ false,true,false,true,true,true,true,true]  #東新 
                ]

  (44..47).each{|id|  idx=id-44
    RealOpe.each_with_index{|real_ope,j|
      must "ID #{id} real_ope?  #{real_ope}" do
        assert_equal RealOpeBool[idx][j],Ubeboard::Plan.find(id).real_ope?(real_ope)
      end
    }  
  }

  # change_time(ope,before)
  #            lot,    jun,pro_id,mass,養生庫,shozo_to       
  Plans = [  [ "2W0030", 80, 4 , 2304,14,"2011/9/14 12:40"], # 7 12F無塗装(西新)12F 200枚/hr
             [ "2W0031", 90, 2 , 1728, 9]                   # 8 12F化粧(西新) 12F  2304 -> 11.2
          ]
  #             抄造、乾燥end、乾燥、加工]
  OpeLength = 
    [ [(2304*3600.0/500).marume(Ubeboard::Skd::Round),(2304*3600.0/750).marume(Ubeboard::Skd::Round)],
      [(1728*3600.0/500).marume(Ubeboard::Skd::Round),(1728*3600.0/750).marume(Ubeboard::Skd::Round)],
      [(2304*3600.0/500).marume(Ubeboard::Skd::Round),(2304*3600.0/650).marume(Ubeboard::Skd::Round)]

    ]
  # ope_length
  (0..1).each{|idx|
    lot,jun,pro_id,mass,yojoko = Plans[idx]
    must "Ope_length　#{idx}" do
      plan = Ubeboard::Plan.new(:ube_product_id => pro_id,:mass => mass)
      shozo,dry,kakou = [:shozo,:dry,:kakou].map{|ope| plan.ope_length(ope)}
      assert_equal OpeLength[idx],[shozo[0],kakou[0]]
    end
  }

  #乾燥の切り替え
  [ [16,17, 5] ,         # 12F 別銘柄
    [29,30, 5],          # 16高級 同銘柄
    [29,31,40],          # 16高級 別銘柄
    []
  ].each{|pre_id,id,ch| next unless id
    must "ID#{id}->#{pre_id}の切り替えは #{ch}分" do
      skd = make_skd_and_set_pre_condition([id,pre_id])
      plan     = skd.ube_plans[1]
      pre_plan = skd.ube_plans[0]
      assert_equal ch.minute,skd.change_time(plan,plan.dry?).periad
    end
  }

end
