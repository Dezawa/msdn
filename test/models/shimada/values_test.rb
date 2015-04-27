# -*- coding: utf-8 -*-
require 'test_helper'
class Shimada::ValuesTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"

Testdata="./test/testdata/shimada/"
Power01 = Testdata+"dezawa_power01_20150401-191041.trz"
Hyum    = Testdata+"temp-hyumidity-20141223-060422.trz"
TD24    = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150424-060350.trz"
TD01rest= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150401-060343.trz"
TD01svr = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150401-063443.trz"
TD0424   = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150424-060350.trz"
TD0423   = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
TD0423svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150423-060853.trz"
TD0424svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150424-060837.trz"
  def setup
    Shimada::Dayly.delete_all
  end
  must "channels数は6" do
    assert_equal 6, Shimada::Values.new(1,nil).instruments.size
  end
  must "channelsの順" do
    assert_equal ["フリーザーA温度", "フリーザーA湿度", "サーバー電力",
                  "1F休憩所温度", "1F休憩所蒸気圧", "power01電力"],
      Shimada::Values.new(1,nil).instruments.
      map{|ins| ins.ch_name + ins.measurement}
  end
  must "TD01svr,TD01restを読んだ時の 4/1のデータのチャンネル名-タイプ" do
    Shimada::Dayly.load_trz(TD01rest)
    Shimada::Dayly.load_trz(TD01svr)
    assert_equal [nil,nil, "サーバー-電圧", "1F休憩所-温度", "1F休憩所-湿度", nil],
      Shimada::Values.new(1,Date.new(2015,4,1)).daylies.
      map{|dayly| dayly.ch_name_type if dayly}
  end
  must "TD0424,TD0423,TD0423svr,TD0424を読んだ時の 4/23のデータ" do
    [TD0424,TD0423,TD0423svr,TD0424].each{|file|    Shimada::Dayly.load_trz(file)}
    values = Shimada::Values.new(1, "2015-4-23").hours
    #             フリーザ温湿度 サーバ電力 １F温湿度 太陽
    assert_equal [[nil, nil, nil, 11.92, 8.518, nil],      [nil, nil, nil, 13.54, 9.011, nil], #8、9時
                  [nil, nil, nil, 15.53, 8.396, nil],      [nil, nil, nil, 17.32, 6.917, nil],
                  [nil, nil, nil, 19.08, 5.922, nil],      [nil, nil, nil, 20.42, 5.608, nil]              
                  ],  values[8,6]
  end
  must "TD0424,TD0423,TD0423svr,TD0424を読んだ時の 4/23の8時のhtmlデータ" do
    [TD0424,TD0423,TD0423svr,TD0424].each{|file|    Shimada::Dayly.load_trz(file)}
    assert_equal "<br><br><br>11.92<br>8.52<br>",
      Shimada::Values.new(1, "2015-4-23").hour_html08
  end
end
