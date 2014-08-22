# -*- coding: utf-8 -*-
require 'test_helper'

class PowerUbeHospitalMonthTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  CSVFILE = "./test/testdata/power/ube_hospital_H24-08.csv"
  Model = Power::UbeHospital::Month
  must "year_month" do
    lines = File.read(CSVFILE).split(/[\r\n]+/)
    assert_equal Date.new(2012,8,1),Model.search_year_month(lines)
  end

  must "monthdate line" do
    lines = File.read(CSVFILE).split(/[\r\n]+/)
    Model.search_year_month(lines)
    assert_equal [0,(1..31).to_a.map(&:to_s) << "合　計"],Model.search_monthdate(lines)
  end

  must "skip_untile_first_data_line" do
    lines = File.read(CSVFILE).split(/[\r\n]+/)
    Model.search_year_month(lines)
    Model.search_monthdate(lines)
    assert /00:00～01:00,384,372/ =~ Model.skip_untile_first_data_line(lines)
  end

  must "read_month_data" do
    lines = File.read(CSVFILE).split(/[\r\n]+/)
    Model.search_year_month(lines)
    Model.search_monthdate(lines)
    Model.skip_untile_first_data_line(lines)
    assert_equal %w(372 360 348 336 336 360),Model.read_month_data(lines)[30][0,6]
  end

  must "create_one_month_by" do
    lines = File.read(CSVFILE).split(/[\r\n]+/)
    Model.create_one_month_by(lines)
    assert power = Power::UbeHospital::Power.find_by_date(Date.new(2012,8,1))
    assert_equal 384,power.power01
  end
end
