# -*- coding: utf-8 -*-
require 'test_helper'
Ubr::Lot
class Ubr::LotWakuTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  # Replace this with your real tests.
  def setup
    @Waku    = Ubr::Waku.waku true
  end

  #  "等級,品目コード,ロット№,,数量,置場 = 1,G123015AN-------F7,H309948000,"
  must "1,G123015AN-------F7,H3099,48000 をnewすると, lotが入る枠は" do
    attr ={ :grade => "1",:meigara_code => "G123015AN-------F7",
            :lot_no => "H3099",:weight => 48000,:waku => "7T01" }
    lot = Ubr::Lot.new( attr)
    assert_equal ["7T01"],lot.waku.map(&:name)
  end
  must "1,G123015AN-------F7,H3099,48000 をnewすると,枠に入る lotは" do
    attr ={ :grade => "1",:meigara_code => "G123015AN-------F7",
            :lot_no => "H3099",:weight => 48000,:waku => "7T01" }
    lot = Ubr::Lot.new( attr)
    waku = lot.waku.first
    assert_equal ["H3099"],waku.lot_list.map(&:lot_no)
  end

end
__END__
# -*- coding: utf-8 -*-
