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
    assert_equal ["1A1", "1A2", "1A3", "1A4","1b", "1B2", "1B3", "1B4", "1B5", "1B5", "1B5", "1B6"],
    @floor.contents
    assert_equal 12,@floor.contents.size
    #             1A1  2    3    4     1b   1B2   3   4    5    5    5    6
    assert_equal ["A", "A", "A", "A", "01", "A", "A", "A", "B", "N", "Z", "A"],@floor.sufix
    assert_equal %w( Z Z Z Z  6 Z Z Z M R  Z Z),@floor.max
    assert_equal [[0.0, 0.0], [20.0, -0.2], [20.0, 2.4], [8.0, 2.4],  #1A
                  [0.0, 0.0],[15.0, -0.2], [15.0, 4.0], [15.0, -1.4],  #1b B2 B3 B4
                  [14.0, 1.2], [-3.0, -2.0],[14.0, 1.2], [14.0, -0.2]],@floor.label_pos,"label_pos"
    assert_equal [[0.0, 0.0], [4.7, 33.9], [7.6, 28.3], [36.2, 28.3],
                  [56.0, 5.0],[61.2, 39.9], [61.2, 32.0], [56.3, 23.5], [56.3, 16.0],
                  [86.0, 18.0],[56.3, 16.0], [56.3, 5.0]],@floor.base_points,"base_point"
    assert_equal  [[0,0],[90,46.5]],@floor.outline
  end

  must "#{name}のfloor_offset" do
    assert_equal [0.0,62.5],@floor.floor_offset
  end
  
end
