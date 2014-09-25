# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
class Shimada::Chubu::PowerTest < ActiveSupport::TestCase
  fixtures :shimada_factories
  def setup
    @csvfile = "/home/dezawa/MSDN/Custamer/しまだや/中部/平成２６年８月分.csv"
    @rows    = Shimada::Chubu::Month.parse_csvfile_ommit_header(@csvfile)
    @date = Time.parse("2014/8/1").to_date
    @month=@date.beginning_of_month
    @factory = Shimada::Factory.find_by(name: "中部シマダヤ")
  end

  must "[日 時刻 電力] の配列を作ると、31要素" do
    assert_equal 31,
    Shimada::Chubu::Power.ary_of_date_hour_pw_group_by_date_by_csvtable(@rows,@factory).size
  end
  must "[日 時刻 電力] の配列を作ると、31要素すべて48要素" do
    assert_equal [48]*31,
    Shimada::Chubu::Power.ary_of_date_hour_pw_group_by_date_by_csvtable(@rows,@factory).
    map(&:size)
  end

  must "二日目のPower作成" do
    dailydata_ary_of_hourly =
      Shimada::Chubu::Power.ary_of_date_hour_pw_group_by_date_by_csvtable(@rows,@factory)[1]
    power = Shimada::Chubu::Power.create_by_ary_of_hourly_data(dailydata_ary_of_hourly,@factory)
    assert_equal [919.8, 944.6, 905.8, 893.2, 549.6, 509.4, 433.4, 383.0, 367.8, 381.0, 627.2, 822.8, 801.0, 915.4, 979.8, 985.0, 978.0, 973.8, 974.2, 976.6, 981.2, 984.4, 961.2, 956.4, 804.0, 801.4, 905.6, 926.0, 883.4, 908.6, 903.6, 905.0, 899.8, 900.2, 879.4, 895.4, 894.6, 896.0, 848.6, 888.6, 899.0, 903.8, 904.2, 877.2, 888.0, 911.2, 901.2, 880.4],
    power.powers
  end

  must "月度のデータ作成 要素は31" do
    powers = Shimada::Chubu::Power.create_by_csvtable(@rows,@factory)
    assert_equal 31,powers.size
  end
  must "月度のデータ作成 要素はShimada::Chubu::Power" do
    powers = Shimada::Chubu::Power.create_by_csvtable(@rows,@factory)
    assert_equal [Shimada::Chubu::Power]*31,powers.map(&:class)
  end
  must "月度のデータ作成 最初の要素の日、月、工場ションは" do
    power = Shimada::Chubu::Power.create_by_csvtable(@rows,@factory).first
    assert_equal [@date ,nil,"中部シマダヤ"],[power.date,power.month,power.shimada_factory.name]
  end

  must "月度のデータ作成 最初の要素の月も入れる" do
    power = Shimada::Chubu::Power.create_month_and_powers_by_csvtable(@rows,@factory).first
    assert_equal @month,power.month.month
  end
  must "月度のデータ作成 すると、月が１増え、powerが31増える" do
    month_count = Shimada::Chubu::Month.count
    power_count = Shimada::Chubu::Power.count
    Shimada::Chubu::Power.create_month_and_powers_by_csvtable(@rows,@factory)
    assert_equal 1 ,Shimada::Chubu::Month.count - month_count
    assert_equal 31,Shimada::Chubu::Power.count - power_count
  end

  def cooldown
    @fp.close
  end

end
