# -*- coding: utf-8 -*-
require 'test_helper'

class Shimada::MonthTest < ActiveSupport::TestCase
  #fixtures :shimada_months

  ExcelFile = Rails.root + "/test/testdata/shimada/gunmen-power-20130-23,2014-23.xls"
  CSVFile   = Rails.root + "/test/testdata/shimada/gunmen-power-20130-23,2014-23.csv.0"
  NullFile   = Rails.root + "/test/testdata/shimada/gunmen-power-20130-23,2014-23.csv.2"
  def setup
     #@month = Shimada::Month.new
  end

  must "EXCEL から取り込む CSVファイル数" do
    csvfiles = Shimada::Month.csv_files(ExcelFile).size
    assert_equal 3,csvfiles
  end

  must "CSV から取り込む 年" do
    lines = File.read(CSVFile).split(/[\r\n]+/)
    assert_equal 2013,Shimada::Month.search_year(lines)
  end

  must "CSV から取り込む 日付" do
    lines = File.read(CSVFile).split(/[\r\n]+/)
    Shimada::Month.search_year(lines)
    hour_clm,date = Shimada::Month.search_monthdate(lines)
    assert_equal "2/1",date.first
    assert_equal "2/29",date.last
  end
  must "CSV から取り込む 最初のデータ" do
    lines = File.read(CSVFile).split(/[\r\n]+/)
    Shimada::Month.search_year(lines)
    date = Shimada::Month.search_monthdate(lines)
    Shimada::Month.skip_untile_first_data_line(lines)
    assert_equal %w(1 384 451),lines.first.split(",")[0,3]
  end
  must "Nullファイル から取り込むと" do
    pre = Shimada::Month.count
    Shimada::Month.create_month_by(NullFile)
    assert_equal pre,Shimada::Month.count,"month数"
  end
  must "CSV から取り込む 最初のデータを取り込むと増える" do
    pre = Shimada::Month.count
    Shimada::Month.create_month_by(CSVFile)
    assert_equal pre+2,Shimada::Month.count,"month数"
  end
  must "CSV から取り込む 最初のデータを取り込む" do
    Shimada::Month.create_month_by(CSVFile)
    month = Shimada::Month.find_by_month(Date.new(2013,2,1))
    assert_equal 28,month.powers.size,"Power数"
    assert_equal [384.0, 330.0, 303.0, 386.0, 442.0, 559.0, 575.0, 598.0,
                  619.0, 602.0, 626.0, 624.0, 620.0, 636.0, 647.0, 621.0,
                  630.0, 622.0, 603.0, 623.0, 618.0, 586.0, 576.0, 505.0],
    Shimada::Power::Hours.map{ |h| month.powers.first[h]},"Power値"
  end
end
