# -*- coding: utf-8 -*-
require 'test_helper'
#require 'need'

class Hospital::KinmuTest < ActiveSupport::TestCase
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup

  end

  must "勤務コード 1" do
    kinmu = Hospital::Kinmu.new(1)
    assert_equal [1, 0, "1"],[kinmu.kinmucode_id,kinmu.want,kinmu.shift]
  end
  must "勤務コード 2003" do
    kinmu = Hospital::Kinmu.new(2003)
    assert_equal [3, 2, "3"],[kinmu.kinmucode_id,kinmu.want,kinmu.shift]
  end
end
