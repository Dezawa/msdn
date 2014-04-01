# -*- coding: utf-8 -*-
require 'test_helper'

  # 2C3Fを使って,oppupied_map を色々試す
Waku = "2C3F"

class Ubr::OccupiedTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
    @Waku    = Ubr::Waku.waku true #load_from_master
    @waku    = @Waku[Waku]
    @Lotlist = Ubr::LotList.
      lotlist(true,:file => File.join(RAILS_ROOT,"test/testdata/SCMstocklist.csv"))
    @segments = @waku.lot_list( WithPull)
    ["出荷","引き合い",""].each_with_index{ |pull,idx| @segments[idx].pull = pull}
  end

  must "${Waku} には3ロットある" do
    assert_equal 3,@segments.size
  end

  #         [空,出,引,充,過],[出荷、引き合い、引き合いなし の重さ]
  [["case1 空きあり",[2,2,3,3,0],[6000,7000,8000]],
   ["case2 ちょうど",[0,2,3,5,0],[6000,7000,15000]],
   ["case3 過剰1の特例はやめ",[0,2,3,4,1],[6000,7000,16000]],
   ["case4 過剰2",[0,2,3,3,2],[6000,7000,21000]],
   ["case5 充がなくなるくらい過剰",[0,3,4,0,3],[9000,12000,18000]],
   ["case6 引き合いに食い込む位い過剰",[0,3,3,0,4],[9000,12000,21000]],
   ["case6 引き合いが無くなる位い過剰",[0,5,0,0,5],[15000,12000,18000]],
   ["case6 出荷に食い込む位い過剰",[0,4,0,0,6],[15000,15000,18000]],
   ["case6 出荷が無くなる位い過剰",[0,0,0,0,10],[15000,15000,30000]],
   ["case6 とにかく多い",[0,0,0,0,10],[15000,15000,30000]],
   ["case6 ものすごく多い",[0,0,0,0,10],[15000,15000,40000]]
  ].
   each{ |msg,occupies,weights|
    must "#{msg}" do
      set_weight(weights)
      #assert_equal 21,@waku.paret_su( WithPull)
      #assert_equal 8,@waku.paret_su( WithoutPull)
      #assert_equal 6,@waku.paret_su( OnlyExport)
      pp @waku.oppupied_map
      assert_equal occupies,@waku.oppupied_map[0],msg
    end
   }
  
  def set_weight(weights)
    @segments.each_with_index{ |seg,idx|
      seg.weight = weights[idx]
    }
  end
end

