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
    assert_equal [@month],monthis

  end

  must "2014/8 のmonth作成:工場は中部" do
    #assert_equal "中部シマダヤ",Shimada::Chubu::Month.create_by_file( @fp ,@factory).shimada_factory.name
  end

  def cooldown
    @fp.close
  end

end
