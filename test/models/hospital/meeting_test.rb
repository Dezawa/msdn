# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

class Hospital::MeetingTest < ActiveSupport::TestCase
  fixtures "hospital/meetings","hospital/roles","hospital/nurces","hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2013,2,1)
  end

  def meeting(id)
    Hospital::Meeting.find(id)
  end

  must "最初の5つは 会議 会議 会議 出張 出張" do
    assert_equal [true, true, true,false,false],Hospital::Meeting.find(1,2,3,4,5).map(&:kaigi)
  end
  must "最初の5つは 1.5 1.5 1.0 1.5 1.0" do
    assert_equal [ 1.5, 1.5, 1.0, 1.5, 1.0],Hospital::Meeting.find(1,2,3,4,5).map(&:length)
  end

  must "会議１ nurce42日勤の勤務選択肢" do
    assert_equal [["会□", 31]],meeting(1).assign_correction( nurce(42))
  end
  must "会議１ nurce38三交代の勤務選択肢" do
    assert_equal [["会", 6]],meeting(1).assign_correction( nurce(38))
  end
  must "会議3 nurce42日勤の勤務選択肢" do
    assert_equal [["会1", 32]],meeting(3).assign_correction( nurce(42))
  end
  must "会議3 nurce38三交代の勤務選択肢" do
    assert_equal [["会1", 7]],meeting(3).assign_correction( nurce(38))
  end
  must "会議3 の day_column" do
    assert_equal :day07,meeting(3).day_column
  end

  must "select" do
    nrc = nurce(34)
    monthly = nrc.monthly
    assert_equal [nil, 2031, 2032],[1,2,3].map{ |id| monthly.send(meeting(id).day_column)}
  end
end
