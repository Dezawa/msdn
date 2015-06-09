# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'
class Shimada::ValuesTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"

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
    [TD0424,TD0423,TD0423svr,TD0424svr].each{|file|    Shimada::Dayly.load_trz(file)}
    values = Shimada::Values.new(1, "2015-4-23").hours
    #             フリーザ温湿度 サーバ電力 １F温湿度 太陽
    assert_equal [
                  [nil, nil, 1.67, 9.35, 8.61, nil, 14.4, 79.0, 13.0, nil, nil, nil],
                  [nil, nil, 1.68, 10.53, 8.81, nil, 16.5, 61.0, 11.5, nil, nil, nil],
                  [nil, nil, 1.68, 11.93, 8.52, nil, 18.6, 53.0, 11.4, 18.60,69.0,14.8019],
                  [nil, nil, 1.72, 13.54, 9.01, nil, 20.1, 45.0, 10.6, nil, nil, nil]
                 ],  values[6,4]
  end
  must "TD0424,TD0423,TD0423svr,TD0424を読んだ時の 4/23の8時のhtmlデータ" do
    [TD0424,TD0423,TD0423svr,TD0424].each{|file|    Shimada::Dayly.load_trz(file)}
    assert_equal "ー　<br>ー　<br>ー　<br>11.93<br>8.52<br>ー　<br>18.60<br>53.00<br>11.40<br>18.60<br>69.00<br>14.80",
      Shimada::Values.new(1, "2015-4-23").hour_html08
  end
end
