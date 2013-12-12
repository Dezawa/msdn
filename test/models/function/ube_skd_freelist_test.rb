# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/freelist.rb'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeSkdFreelistTest < ActiveSupport::TestCase
  fixtures :ube_holydays,:ube_maintains,:ube_products,:ube_operations,:ube_maintains
  fixtures :ube_constants
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  def setup
    #@skd0=UbeSkd.find(96,:include=>:ube_plans)
    #@skd=UbeSkd.find(97,:include=>:ube_plans)
  end


  def make_skd(planidx,sansen,plans=Plans,pre_plans=0)
    skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd
  end
  
  [:shozow,:shozoe,:dryo,:dryn,:kakou].each{| real_ope |
    must "#{real_ope} 製造FreeList初期値は" do
      skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
      assert_equal Freelist0[real_ope],skd.freeList[real_ope].freeList
    end
  }
  [:shozow,:shozoe,:dryo,:dryn,:kakou].each{| real_ope |
    must "#{real_ope} 保全FreeList初期値は" do
      skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
      assert_equal Freelist1[real_ope],skd.freeList[real_ope].hozenFree.freeList
    end
  }

  #[:shozow,:shozoe,:dryo,:dryn,:kakou].each{| real_ope |
  #real_ope=:shozow
  #start = Time.parse("2012/6/1 9:00")
  periad = 4.hour
  idx=0
  Searchlist0.keys.each{|real_ope|
    Searchlist0[real_ope].each{|ps,pe,start|
      must "#{real_ope} 開始 #{start.inspect}の 製造FreeListからのサーチは" do
        skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
        assert_equal [ps,pe],skd.freeList[real_ope].searchfree(start,periad)
      end
    }
  }
  Searchlist1.keys.each{|real_ope|
    Searchlist1[real_ope].each{|ps,pe,start|
      must "#{real_ope} 開始 #{start.inspect}の 保守FreeListからのサーチは" do
        skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
        assert_equal [ps,pe],skd.freeList[real_ope].searchfree(start,periad,true)
      end
    }
  }

  Searchlist1.keys.each{|real_ope|
      must "#{real_ope} 開始 2012/7/1 05:00の 保守FreeListからのサーチは" do
        skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
        assert_equal nil,skd.freeList[real_ope].serchfree(Time.parse("2012/7/1 05:00"),periad,true)
      end
  }
  Searchlist1.keys.each{|real_ope|
      must "#{real_ope} 開始 2012/7/1 05:00の 保守FreeListからのサーチは" do
        skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
        assert_equal nil,skd.freeList[real_ope].searchfree(Time.parse("2012/7/1 05:00"),periad)
      end
  }
        must "養生 開始 2012/7/1 05:00の 保守FreeListからのサーチは" do
        skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
        assert_equal [Time.parse("2012/7/1 05:00"),Time.parse("2012/7/1 09:00")],
                      skd.freeList[:yojo].searchfree(Time.parse("2012/7/1 05:00"),periad)
      end
    must "養生 開始 2012/6/8 05:00の 保守FreeListからのサーチは" do
        skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
        assert_equal  [Time.parse("2012/6/8 05:00"),Time.parse("2012/6/8 09:00")],
                     skd.freeList[:yojo].searchfree(Time.parse("2012/6/8 05:00"),periad,true)
      end
end


__END__
