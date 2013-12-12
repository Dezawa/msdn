# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeMakeHolydayPlansTest < ActiveSupport::TestCase
  fixtures :ube_products,:ube_operations,:ube_plans,:ube_holydays,:ube_maintains
 RealOpe = [:shozow,:shozoe,:dryero,:dryern,:kakou]
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
  HOLYDAY_CODE = { 
    [1,:shozow] => [100,"A01",:shozow] ,
    [1,:shozoe] => [101,"A01",:shozoe] ,
    [1,:dryo]   => [102,"A01",:dryo] ,
    [1,:dryn]   => [103,"A01",:dryn] ,
    [1,:kakou]  => [104,"A01",:kakou] ,
    [4,:shozow] => [130,"A01-1",:shozow] ,
    [4,:shozoe] => [131,"A01-1",:shozoe] ,
    [4,:dryo]   => [132,"A01-1",:dryo] ,
    [4,:dryn]   => [133,"A01-1",:dryn] ,
    [4,:kakou]  => [134,"A01-1",:kakou] ,
    ["A15",:shozow] => [123,"A15",:shozow],
    ["A15",:shozoe] => [124,"A15",:shozoe],
    ["A15",:dryo  ] => [123,"A15",:dryo  ],
    ["A15",:dryn  ] => [124,"A15",:dryn  ],
    ["A15",:kakou ] => [125,"A15",:kakou ],
  }
  HOLYDAY_CODE.each{|key,val|
    must "HOLYDAY_CODE of [#{key},#{val}] は" do
      assert_equal HOLYDAY_CODE[key] ,UbeProduct.holyday_code[key]
    end
  }
  #          Product_id condition pro_name
  HolyPlans = 
    [[100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [100, "休日(西抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [101, "休日(東抄造)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [102, "休日(原乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [103, "休日(新乾燥)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [104, "休日(加工)", "A01"],
     [123, "休転", "A15"],
     [123, "休転", "A15"],
     [124, "休転", "A15"],
     [124, "休転", "A15"],
     [125, "休転", "A15"],
     [130, "運休(西抄造)", "A01-1"],
     [131, "運休(東抄造)", "A01-1"]

    ]
  #RealOpe.each{|real_ope|
  must "休日のUbePlan " do
    skd =  make_skd([1])
    skd.make_plans_of_holyday_and_maintain
    assert_equal HolyPlans,
    skd.ube_plans[1..-1].map{|plan| [plan.ube_product_id,plan.proname,plan.condition]}.sort
  end

  #}
end
__END__
