# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::SoukoTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
     Ubr::Waku.waku true # 複数回のsetupでlotが重複してしまう
    @lotlist = Ubr::LotList.
      lotlist(true,:file => File.join(RAILS_ROOT,"test","testdata","SCMstocklist.csv")).list
  end

  ### フレコン
  # 枠   lot数 個数 桝
  [["2C3F", 3,        38, 12+2],  # 1tonフレコン、他に引き合い1lot
   nil
  ].each{ |waku_name,lot_num,paret_num,masu_num|
    next unless waku_name
    msg = waku_name+"の引き合い無しのlot数 個数 使用桝"
    must msg do
      waku = Ubr::Waku.by_name(waku_name)
      assert_equal lot_num, waku.lot_list(WithPull).size, waku_name+"のロット数"
      assert_equal paret_num, waku.paret_su(WithPull), waku_name+"のパレット数"
      assert_equal masu_num, waku.occupied(WithPull), waku_name+"の使用桝数"
    end
  }

  ### 紙
  # 枠   lot数 個数      40俵 桝
  [["2C3C", 2,        39,  13],  # 25kg紙 125+842 完全 3+21, 半端 5 + 2
   ["4H1D", 5, 2+2+1+2+1,3+1],  # n完全が3lot4パレット半端が3パレット
   ["1A3D", 2, 19+1     ,11],# T14 1,Y14 19なので 55俵1パレット、2段積み 1045+7 => 
   nil
  ].each{ |waku_name,lot_num,paret_num,masu_num|
    next unless waku_name
    msg = waku_name+"のlot数 個数 使用桝"
    must msg do
      waku = Ubr::Waku.by_name(waku_name)
      remain0 = [ 0,waku.dan1,waku.dan2,waku.dan3] 
      last_masu0 = [0]*4
      lot_paper0 = waku.lot_list(WithPull).select{ |seg| /^N/ =~ seg.lot.keitai }

      assert_equal lot_num, waku.lot_list(WithPull).size, waku_name+"のロット数"
      assert_equal paret_num, waku.paret_su(WithPull), waku_name+"のパレット数"
     # pp [lot_paper0.size,lot_paper0.map{ |seg| seg.count}]

      remain ,last_masu, lot_paper = remain0.dup ,last_masu0.dup, lot_paper0.dup

      remain ,last_masu, lot_paper = remain0.dup ,last_masu0.dup, lot_paper0.dup
      #assert_equal masu_full_paret, (used = waku.stack_40hyou(lot_paper,remain,last_masu)),
      #  waku_name+"の40俵パレットの使用桝数"
      assert_equal masu_num, waku.occupied(WithPull), waku_name+"の使用桝数"
    end
  }
end
# -*- coding: utf-8 -*-
