# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdOpelengthTest < ActiveSupport::TestCase
  fixtures "ube/products","ube/operations","ube/plans"
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
    skd
  end

  [ [1,195],[20,330],[24,300],[29,350]].each{|id,period|
    must "id=#{id}の抄造の所要時間 " do
      plan = Ubeboard::Plan.find id
      assert_equal period,plan.ope_length(plan.shozo?)[0]/60
    end
  }
  [ [28,[600, 181]],[20,[735, 223]],[24,[0, 0]],[29,[570, 208]]].each{|id,period|
    must "id=#{id}の乾燥の所要時間 " do
      plan = Ubeboard::Plan.find id
      assert_equal period,plan.ope_length(plan.dry?)[0..1].map{|l| (l/60).to_i}
    end
  }

  [ [28,[11100, 0]],[21,[0, 0]],[24,[0, 0]],[29,[9600, 0]]].each{|id,period|
    must "id=#{id}の加工の所要時間 " do
      plan = Ubeboard::Plan.find id
      assert_equal period,plan.ope_length(:kakou)[0..1]
    end
  }

end


