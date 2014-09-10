# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::LotTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
      @Waku    = Ubr::Waku.all#waku(true) #load_from_master
      @lotlist = Ubr::LotList.lotlist(true,:file => File.join(RAILS_ROOT,"test","testdata","SCMstocklist.csv")).list
  end
  ids = 
      [ ["G123DC700V------F7","630314","1","-"],
        ["G123B022--------F7","23018","1","-"],
        ["G123YFC20H------F7","392905","1","-"],
        ["G123QX----B16---N3","5219","Z","-"]

      ]     #出荷、以外、非pull
    segs = [ [1,0,1],
              [1,0,2],
             [0,1,1],
             [0,3,2]
            ]
  ids.zip(segs).each{ |id,seg|
    all = with = seg[0]+seg[1]+seg[2]
    without    = seg[2]
    export     = seg[0]
    must "lot_no #{id[1]}の seg数は" do 
      assert_equal all,@lotlist[id].segments.size
    end

    must "lot_no  #{id[1]}の Without seg数は" do 
      assert_equal without,@lotlist[id].segments(WithoutPull).size
    end

    must "lot_no  #{id[1]}の With seg数は" do 
      assert_equal with,@lotlist[id].segments(WithPull).size
    end

    must "lot_no  #{id[1]}の 出荷 seg数は" do 
      assert_equal export,@lotlist[id].segments(:export).size
    end
  }
  must "ロット数" do
    assert_equal 1624,@lotlist.size
  end

  #[ ["G123Z481--------F7","14",3],["G1230540P-------F4","11",2],["G123Z670--------F7","14",1]].
  #  each{ |code,palet,stack|
  #  must code+"の積み段数max" do
  #    assert_equal palet,findlot_by_code(code).first[1].paret[-2,2]
  #    assert_equal stack,findlot_by_code(code).first[1].stack_limit
  #  end
  #}

  must "G123V322--C17---N3 G3305D の枠" do
    lot = findlot_by_lot("G3305D").first
    assert_equal ["2E3G"],lot[1].waku.map(&:name)
    assert_equal ["63157","G3305D"],lot[1].waku.first.lot_list.map(&:lot_no)
  end

# G123F222--------F7

  def findlot_by_code(code) ;    @lotlist.select{ |id,lot| id[0] == code } ;  end
  def findlot_by_lot(lot_no) ;   @lotlist.select{ |id,lot| id[1] == lot_no } ;  end

end
__END__
# -*- coding: utf-8 -*-
