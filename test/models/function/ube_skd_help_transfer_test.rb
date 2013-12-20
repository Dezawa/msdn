# -*- coding: utf-8 -*-
require 'test_helper'
#require 'testdata/plan_assign.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdHelpTransferTest < ActiveSupport::TestCase
  fixtures "ube/products","ube/operations","ube/plans"
  #Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
    TimeTo= {:shozo =>:plan_shozo_to , :yojo =>:plan_yojo_to ,:dry =>:plan_dry_to,
    :kakou=>:plan_kakou_to}
  def setup
    #@skd=make_skd
    #@skd=Ubeboard::Skd.find(97,:include=>:ube_plans)
  end
  def make_skd(id,real_ope=nil)
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find_sub
    skd.ube_plans=[]
    skd.ube_plans<< Ubeboard::Plan.find(id)
    skd.pre_condition[real_ope]= skd.ube_plans[0] if real_ope
    skd
  end

  Trans=
    [#ids
     [48,[[:shozo,0],[:yojo,60],[:dry,10],[:kakou,1450]],"12F化粧(西原)   "],
     [49,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,10]],"12普3×6(東新)  "],
     [50,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,1450]],"12普及化粧(東原)"],
     [51,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,1450]],"12高意匠(東原)  "],
     [52,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,1450]],"15高級(東原)    "],
     [53,[[:shozo,0],[:yojo,60],[:dry,10],[:kakou,1450]],"16F化粧(西新)   "],
     [54,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,1450]],"16高級(東原)    "],
     [55,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,1450]],"S1コタタキ(東原)"],
     [56,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,10]],"野地2M(東新)    "],
     [57,[[:shozo,0],[:yojo,30],[:dry,10],[:kakou,10]],"野地板(東新)    "],
     [82,[[:shozo,0],[:yojo,60],[:dry,10],[:kakou,10]],"野地2M(西新)    "],
     nil                                                           
    ]
  Trans.each{|id,data,msg|
    next unless id
    data.each{|ope,trans|
      must "id=#{id} #{ope} #{msg} の移動時間は #{trans}分" do
        skd  = make_skd(id)
        plan = skd.ube_plans[0]
        real_ope = plan.real_ope(ope)
        assert_equal trans, 
        plan.transfer[real_ope]/60#, plan[TimeTo[ope]])
      end
    }
  }
  TransTime = ["6/12 8:10","6/10 8:10","6/08 9:00","6/1 8:00"].map{|d| Time.parse("2012/"+d)}
  (16..19).each{|id|
    must "移動時間考慮した開始可能時間 id #{id}" do
      skd=make_skd id
      plan=Ubeboard::Plan.find id
      assert_equal TransTime[id-16],plan.transfer_time(skd)
    end
  }

  Ope       = [:kakou,:dryo,:yojo,:shozow]
  TransTime1=["6/12 8:10","6/09 8:10","6/6 9:00","6/1 8:00"].map{|t| Time.parse("2012/"+t)}
   Ope.each_with_index{|ope,idx|
    must "工程指定：移動時間考慮した開始可能時間 #{ope}" do
      skd=make_skd 16
      plan=Ubeboard::Plan.find 16
      assert_equal TransTime1[idx],plan.transfer_time(skd,ope)
    end
  }
  TransTime2= ["6/11 8:10","6/10 8:10","6/10 9:00","6/10 8:00"].map{|d| Time.parse("2012/"+d)}
  (16..19).each{|id|
    must "工程開始時刻指定：移動時間考慮した開始可能時間 id #{id}" do
      skd=make_skd id
      plan=Ubeboard::Plan.find id
      assert_equal TransTime2[id-16],
      plan.transfer_time(skd,Ope[id-16],Time.parse("2012/6/10 8:00"))
    end
  }
end












__END__
