# -*- coding: utf-8 -*-
require 'test_helper'

Waku        = "1A2C"
class Ubr::WakuBlockTest < ActiveSupport::TestCase
  fixtures :ubr_wakus
  fixtures :ubr_waku_blocks
  # Replace this with your real tests.
  def setup
  end

  souko = "3"
  count = 3
  must "#{souko}倉庫のBlock数は#{count}" do
    assert_equal count,Ubr::WakuBlock[souko].size
  end

  waku = "3F1A"
  must "#{waku}のbase_point は" do
    assert_equal [0.2,21.2],
      Ubr::WakuBlock[souko].select{ |block| block.content + block.sufix == waku}.first.base_point
  end
  must "#{waku}のlabel_point は" do
    assert_equal [7,0],
      Ubr::WakuBlock[souko].select{ |block| block.content + block.sufix == waku}.first.label_pos
  end
end
