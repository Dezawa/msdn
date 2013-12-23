# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::SoukoTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @waku = Ubr::Waku.waku.values[0]
    @lotlist = Ubr::LotList.lotlist#.load(Ubr::Lot::SCMFILE)
  end

  ### フレコン
  # 枠   lot数 個数 桝
  [["2C3F", 3,        19,  7],  # 1tonフレコン、他に引き合い1lot
   nil
  ].each{ |waku_name,lot_num,paret_num,masu_num|
    next unless waku_name
    msg = waku_name+"のlot数 個数 使用桝"
    must msg do
      waku = Ubr::Waku.by_name(waku_name)
      assert_equal lot_num, waku.lot_list(true).size, waku_name+"のロット数"
      assert_equal paret_num, waku.paret_su(true), waku_name+"のパレット数"
      assert_equal masu_num, waku.occupied(true), waku_name+"の使用桝数"
    end
  }

  ### 紙
  # 枠   lot数 個数      40俵 桝
  [["2D1G", 2,      4+22, 8,  9],  # 25kg紙 125+842 完全 3+21, 半端 5 + 2
   ["4H1D", 5, 3+1+1+1+1, 1,  2],  # 20k,25k 半端な集まり。106+10+22+34+9,完全 2, 半端面 6+2+5+7+2
   ["1A3D", 1,        54, 18,54/3],# G123V322--C17---N3G3097D: 1 : 53.70tonG3097D: 1 : 53.70ton
   nil
  ].each{ |waku_name,lot_num,paret_num,masu_full_paret,masu_num|
    next unless waku_name
    msg = waku_name+"のlot数 個数 使用桝"
    must msg do
      waku = Ubr::Waku.by_name(waku_name)
      remain0 = [ 0,waku.dan1,waku.dan2,waku.dan3] 
      last_masu0 = [0]*4
      lot_paper0 = waku.lot_list(true).select{ |seg| /^N/ =~ seg.lot.keitai }

      assert_equal lot_num, waku.lot_list(true).size, waku_name+"のロット数"
      assert_equal paret_num, waku.paret_su(true), waku_name+"のパレット数"
     # pp [lot_paper0.size,lot_paper0.map{ |seg| seg.count}]

      remain ,last_masu, lot_paper = remain0.dup ,last_masu0.dup, lot_paper0.dup

      remain ,last_masu, lot_paper = remain0.dup ,last_masu0.dup, lot_paper0.dup
      assert_equal masu_full_paret, (used = waku.stack_40hyou(lot_paper,remain,last_masu)),
        waku_name+"の40俵パレットの使用桝数"
      assert_equal masu_num, waku.occupied(true), waku_name+"の使用桝数"
    end
  }
end
# -*- coding: utf-8 -*-
