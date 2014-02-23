# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::WakuDistryTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    @waku    = Ubr::Waku.new(
                             :name => "5K1A",
                             :dan3 => 30,
                             :dan2 => 0,
                             :dan1 => 0,
                             :kawa_suu => 10,
                             :retusu    => 3,
                             :direct_to => "↑",
                             :palette =>  "N"
                             )
    #@waku    = @Waku["5K1A"]
  end

  #  空枠 引き合い 埋まり 超過
  must "waku  [30,0,0,0]" do
    ary = [30,0,0,0]
    assert_equal [[10,0,0,0],[10,0,0,0],[10,0,0,0]],@waku.destribute_ary(ary)
  end

  must "waku  [20,10,0,0]" do
    ary = [20,10,0,0]
    assert_equal [[10,0,0,0],[10,0,0,0],[0,10,0,0]],@waku.destribute_ary(ary)
  end

  must "waku  [10,10,10,0]" do
    ary = [10,10,10,0]
    assert_equal [[10,0,0,0],[0,10,0,0],[0,0,10,0]],@waku.destribute_ary(ary)
  end

  must "waku  [5,10,10,0]" do
    ary = [5,10,10,0]
    assert_equal [[5,5,0,0],[0,5,5,0],[0,0,5,0]],@waku.destribute_ary(ary)
  end

  must "waku  [0,0,10,20]" do
    ary = [0,0,10,20]
    assert_equal [[0, 0, 10, 0], [0, 0, 0, 10], [0, 0, 0, 10]],@waku.destribute_ary(ary)
  end

end
