# -*- coding: utf-8 -*-
require 'test_helper'
Testdata="./test/testdata/shimada/"
Power01 = Testdata+"dezawa_power01_20150401-191041.trz"
Hyum    = Testdata+"temp-hyumidity-20141223-060422.trz"

class Shimada::DaylyTest < ActiveSupport::TestCase
  fixtures "shimada/instrument"
  def setup
    Shimada::Dayly.delete_all
  end
  must "Power01を取り込むと3/31と4/1のデータができる" do
    Shimada::Dayly.load_trz(Power01)
    assert_equal 2,Shimada::Dayly.count
  end
  must "Power01を取り込むと4/1の電圧データは" do
    Shimada::Dayly.load_trz(Power01)
    dayly1 =  Shimada::Dayly.find_by(date: "2015-04-01" ,ch_name_type: "power01-電圧")
    assert_equal [0.4908, 0.489, 0.4652, 0.4824, 0.5022, 0.5152, 0.527, 0.5254, 0.5224, 0.5162],
      dayly1.measurement_value[12*60,10]
  end
  
  must "Power01を取り込むと4/1の電力データは" do
    Shimada::Dayly.load_trz(Power01)
    dayly1 =  Shimada::Dayly.find_by(date: "2015-04-01" ,ch_name_type: "power01-電圧")
    assert_equal [1.0095, 1.0056, 0.9546, 0.9915, 1.034, 1.0619, 1.0872, 1.0838, 1.0773, 1.064],
      dayly1.converted_value[12*60,10].map{|v| v.round(4)}
  end
  
  must "Hyumを取り込むと" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal 4,Shimada::Dayly.count
  end
  
  must "Hyumを取り込むと12/22,23日のデータが二つずつできる" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal [[2014,12,22],[2014,12,23],[2014,12,22],[2014,12,23]].map{|date| Date.new(*date)},
      Shimada::Dayly.all.pluck(:date)
  end

  must "Hyumを取り込むと12/22日のデータは温度と湿度" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal ["フリーザーA-温度","フリーザーA-湿度"],
      Shimada::Dayly.where(date: "2014-12-22").map{|d| d.ch_name_type}
  end

  must "Hyumを取り込むと12/22日のデータの温度の変換は" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal 0 ,
      Shimada::Dayly.find_by(date: "2014-12-22",ch_name_type: "フリーザーA-温度").
      instrument.converter
  end

  
  must "Hyumを取り込むと12/22日の温度データ" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-温度")
    assert_equal [3.9, 3.9, 4.3, 4.1, 4.2, 4.2, 4.6, 3.9, 4.0, 4.6, 4.5, 4.5  ],
      dayly22.measurement_value[12*12,12]
  end
  must "Hyumを取り込むと12/22日の温度の変換後データ" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-温度")
    assert_equal [3.9, 3.9, 4.3, 4.1, 4.2, 4.2, 4.6, 3.9, 4.0, 4.6, 4.5, 4.5],
      dayly22.converted_value[12*12,12]
  end
  must "Hyumを取り込むと12/22日の湿度データ" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-湿度")
    assert_equal [41.0, 40.0, 39.0, 38.0, 37.0, 36.0, 37.0, 34.0, 36.0, 38.0, 35.0, 36.0],
      dayly22.measurement_value[12*12,12]
  end
  must "Hyumを取り込むと12/22日の湿度データのパラメータは" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-湿度")
    assert_equal [2,"52BC036E", "208"],
      [:instrument_id,:serial,:measurement_type].map{|sym| dayly22.send(sym)}
  end
  must "Hyumを取り込むと12/22日の湿度データの相棒温度は" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-湿度")
    dayly22tmp = Shimada::Dayly.#find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-温度")
      find_by(date:"2014-12-22",serial: dayly22.serial,measurement_type: 13)
    assert_equal [1,"52BC036E", "13"],
      [:instrument_id,:serial,:measurement_type].map{|sym| dayly22tmp.send(sym)}
  end
  must "Hyumを取り込むと12/22日の湿度の変換後データ" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-湿度")
    assert_equal [3.31, 3.23, 3.24, 3.12, 3.06, 2.97, 3.14, 2.75, 2.93, 3.23, 2.95, 3.03],
      dayly22.converted_value[12*12,12]
  end
end
