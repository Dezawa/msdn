# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/temp_assign_all.rb'
require 'testdata/ube_const.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::BeyondHolydayTest < ActiveSupport::TestCase
  fixtures :ube_holydays,:ube_maintains,:ube_constants
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
    skd.yojoko
    skd
  end
  
  [ 
   [ :shozow,"6/2-23:00 6/3-2:00",nil],
   [ :shozow,"6/3-2:00 6/5-12:00",1],
   [ :shozow,"6/7-2:00 6/10-11:00",4],
   [ :shozow,"6/09-23:00 6/11-9:00",1],
   []
  ].each{|real_ope,range,result| next unless real_ope
    must "#{real_ope} #{range} " do
      skd = make_skd([])
    assert_equal result,skd.biyond_holyday?(real_ope,*range.times)
    end
  }
    
end
