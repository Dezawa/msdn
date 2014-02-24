# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::SoukoFloorTest < ActiveSupport::TestCase
  fixtures :ubr_souko_plans,:ubr_waku_blocks,:ubr_souko_floors,:ubr_souko_floor_souko_plans,:ubr_souko_floor_waku_blocks
  # Replace this with your real tests.
  def setup
    @floor = Ubr::SoukoFloor.find_by_name("1")
  end

  name    =  "1"
  must "#{name}の" do
    assert_equal ["1A1", "1A2", "1A3", "1A4", "1B2", "1B3", "1B4", "1B5", "1B5", "1B5", "1B6", "1b"],
    @floor.contents
    assert_equal 12,@floor.contents.size
    assert_equal  [[0,0],[90,46.5]],@floor.outline
  end

  must "#{name}のfloor_offset" do
    assert_equal [0.0,62.5],@floor.floor_offset
  end
  
end
