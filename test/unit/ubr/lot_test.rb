# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::LotTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
      @Waku    = Ubr::Waku.all#waku(true) #load_from_master
      @lotlist = Ubr::LotList.lotlist(true,:file => File.join(RAILS_ROOT,"test","testdata","SCM在庫一覧.csv")).list
  end

  must "枠数" do
    assert_equal 2090,@Waku.size
  end

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
