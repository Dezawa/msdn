# -*- coding: utf-8 -*-
require 'test_helper'

require 'testdata/maintain'
require 'testdata/freelist'
require 'testdata/holyday'

class Ube::UbeMaintainTest < ActiveSupport::TestCase
  fixtures  "ube/maintains","ube/holydays","ube/products","ube/operations","ube/constants"
  #test "the truth" do ;    assert true; end

  def setup
    @skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
  end

  must " 最初の保守" do
    maintain = Ubeboard::Maintain.find 1
    assert_equal Time.parse("2012-6-3 8:00"),maintain.plan_time_start
  end
  ########### 休転が FreeList に与える影響
  Holyday.each{|real_ope,list| 
    must "#{real_ope}の休日は " do
    assert_equal_array list,@skd.holydays[real_ope],[],"休転が FreeList に与える影響"
    end
  }

  ## 初期化
  Freelist0.each{|real_ope,list|
    must "製造を入れないFreeList #{real_ope}" do
     assert_equal_array  list,@skd.freeList[real_ope].freeList,[],"製造を入れないFreeList #{real_ope}"
    end
  }  

  Freelist1.each{|real_ope,list|
    must "保守を入れない FreeList #{real_ope}" do
      assert_equal_array  list,@skd.freeList[real_ope].hozenFree.freeList,nil,"保守を入れない FreeList #{real_ope}"
    end
  }

  # 検索
  [[:shozoe,"2012/6/5-14:00",2.hour,"2012/6/5-14:00","2012/6/5-16:00"],
   [:shozow,"2012/6/5-14:00",2.hour,"2012/6/5-14:00","2012/6/5-16:00"],
   [:dryn  ,"2012/6/5-14:00",2.hour,"2012/6/7-08:00","2012/6/7-10:00"]
  ].
  each{|real_ope,start,periad,p_start,p_end|
    must "#{real_ope} 製造の空き時間サーチは freeListから" do
      assert_equal [Time.parse(p_start),Time.parse(p_end)],
      @skd.freeList[real_ope].searchfree(Time.parse(start),periad)
    end
  }

  [[:shozoe,"2012/6/5-14:00",2.hour,"2012/6/5-14:00","2012/6/5-16:00"],
   [:shozow,"2012/6/5-14:00",2.hour,"2012/6/5-14:00","2012/6/5-16:00"],
   [:dryn  ,"2012/6/5-14:00",2.hour,"2012/6/7-08:00","2012/6/7-10:00"]
  ].
  each{|real_ope,start,periad,p_start,p_end|
    must "#{real_ope} 保守の空き時間サーチは freelistから" do
      assert_equal [Time.parse(p_start),Time.parse(p_end)],
      @skd.freeList[real_ope].searchfree(Time.parse(start),periad,true)
    end
  }

  # 製造のアサイン
Assign.keys.each{|real_ope|
    start,periad,list = Assign[real_ope]
#pp ["Assign",real_ope,start,periad,list]
    must "#{real_ope} 製造のアサインは 両方から" do
      s,e = @skd.freeList[real_ope].searchfree(start,periad)
      @skd.freeList[real_ope].assignFreeList(s,e)
      assert_equal_array_array list,[@skd.freeList[real_ope].freeList ,@skd.freeList[real_ope].hozenFree.freeList]
      #assert_equal list[1],@skd.freelist[real_ope]
    end
    }

Assign1.keys.each{|real_ope|
    start,periad,list = Assign1[real_ope]
      must "#{real_ope} 保守のアサインは 両方から" do
        @skd.freeList[real_ope].assignFreeList(*@skd.freeList[real_ope].searchfree(start,periad,true))
        assert_equal_array_array list,[@skd.freeList[real_ope].freeList,@skd.freeList[real_ope].hozenFree.freeList]
      end
    
  }
end
