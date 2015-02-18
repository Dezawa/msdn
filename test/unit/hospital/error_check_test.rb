# -*- coding: utf-8 -*-
require 'test_helper'
# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

class Hospital::ErrorCheckTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies","hospital/defines"
  fixtures "hospital/kinmucodes"
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @assign.nurces = extract_set_shifts(Log201302assigned_with_error)  
    @assign.refresh
    @nurces = @assign.nurces
  end

  must "42 加藤幸子勤務違反は？ 月末に2222というエラーがあるが、これは今月の割付では解決できないので無視する必要がある" do
    assert_equal [],nurce(42).error_check
  end

  must "2日、準夜看護師不足" do
    assert_equal ["2日 準夜:看護師 "],@assign.error_day(2)
  end
end

__END__

  must "喜津直美は３超過" do
    @assign.assign_month
    assert_equal [["喜津直\347\276\216", "深夜が2を越え\343\201\237",
                   4, "033002503300_____310____________0"]
                 ],@assign.nurces[2].error_check
  end

  must "看護師全部では" do
    @assign.assign_month
    assert_equal [],@assign.error_nurces
  end
  must "日のチェック" do
    @assign.assign_month
    assert_equal [],@assign.error_days
  end

  must "error" do
    @assign.assign_month
    @assign.error_check
  end
# -*- coding: utf-8 -*-
