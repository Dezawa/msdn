# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
class Shimada::Chubu::MonthTest < ActiveSupport::TestCase
  fixtures :shimada_factories
  def setup
    @csvfile = "/home/dezawa/MSDN/Custamer/しまだや/中部/平成２６年８月分.csv"
    @rows    = Shimada::Chubu::Month.parse_csvfile_ommit_header(@csvfile)
    @date = Time.parse("2014/8/1").to_date
    @month=@date.beginning_of_month
    @factory = Shimada::Factory.find_by(name: "中部シマダヤ")
  end

  must "平成２６年８月分.csvをパースすると最初のrowの最初のcolummnは 650-2508-1" do
    assert_equal "650-2508-1", @rows[0]["お客さま番号"]
  end

  must "2014/8 の最初のデータ" do
    assert_equal [@month,@date,:hour000,913.0],Shimada::Chubu::Month.extract_hour_data(@rows[0])
  end

  must "2014/8 のmonth作成:月は2014/8一つできた" do
    monthis =     Shimada::Chubu::Month.create_all_monthis_by_csvtable( @rows ,@factory)
    assert_equal [@month],monthis.map(&:month)
  end

  must "2014/8 のmonth作成:CSV_UPLOAD するとMonthが１増える" do
    start = Shimada::Chubu::Month.count
    Shimada::Chubu::Month.csv_upload(@csvfile,@factory)
    assert_equal start+1,Shimada::Chubu::Month.count
  end

  must "2014/8 のmonth作成:CSV_UPLOAD するとPowerが31増える" do
    start = Shimada::Chubu::Power.count
    Shimada::Chubu::Month.csv_upload(@csvfile,@factory)
    assert_equal start+31,Shimada::Chubu::Power.count
  end

  must "2014/8 のmonth作成:CSV_UPLOAD するとできたのは8月" do
    month = Shimada::Chubu::Month.csv_upload(@csvfile,@factory)
    assert_equal @month,month.first.month
  end

  def cooldown
    @fp.close
  end

end
