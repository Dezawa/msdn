# -*- coding: utf-8 -*-
require 'test_helper'

Waku        = "1A2C"
class Ubr::WakuBlockTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  fixtures :ubr_waku_blocks,:ubr_souko_floors
  # Replace this with your real tests.
  def setup
    souko_floor_id = 4 #"3"
    @wakublock = Ubr::WakuBlock[souko_floor_id]
  end


  count = 3
  must "3倉庫のBlock数は#{count}" do
    assert_equal count,@wakublock.size
  end

  waku = "3F1A"
  must "#{waku}のbase_point は" do
    assert_equal [0.2,21.2],@wakublock.
      select{ |block| block.content + block.sufix == waku}.first.base_point
  end
  must "#{waku}のlabel_point は" do
    assert_equal [7,0],@wakublock.select{ |block| block.content + block.sufix == waku}.first.label_pos
  end
end
