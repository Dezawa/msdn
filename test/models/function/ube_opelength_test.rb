# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdOpelengthTest < ActiveSupport::TestCase
  fixtures :ube_products,:ube_operations,:ube_plans
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

  [ [1,195],[20,330],[24,300],[29,350]].each{|id,period|
    must "id=#{id}の抄造の所要時間 " do
      plan = UbePlan.find id
      assert_equal period,plan.ope_length(plan.shozo?)[0]/60
    end
  }
  [ [28,[600, 181]],[20,[735, 223]],[24,[0, 0]],[29,[570, 208]]].each{|id,period|
    must "id=#{id}の乾燥の所要時間 " do
      plan = UbePlan.find id
      assert_equal period,plan.ope_length(plan.dry?)[0..1].map{|l| (l/60).to_i}
    end
  }

  [ [28,[11100, 0]],[21,[0, 0]],[24,[0, 0]],[29,[9600, 0]]].each{|id,period|
    must "id=#{id}の加工の所要時間 " do
      plan = UbePlan.find id
      assert_equal period,plan.ope_length(:kakou)[0..1]
    end
  }

end


__END__
