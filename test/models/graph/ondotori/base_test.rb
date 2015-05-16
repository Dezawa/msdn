# -*- coding: utf-8 -*-
require 'test_helper'
Hyums   = Dir.glob("/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_2015040*trz")
Hyum0405 ="/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150405-060815.trz"
Hyum0423 ="/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
TD0423svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150423-060853.trz"
class Graph::Ondotori::BaseTest < ActiveSupport::TestCase
  
  fixtures "shimada/instrument", "shimada/factory"
  def setup
    Shimada::Dayly.delete_all
  end

  must "温度データをone_dayに与えると" do
    puts __LINE__
    Shimada::Dayly.load_trz(Hyum0405)
    dayly = Shimada::Dayly.first
    assert_equal [["2015-04-04 12:00", 14.9, 65.0, 11.02],
                  ["2015-04-04 12:05", 15.2, 65.0, 11.24]],
      Graph::Ondotori::Base.new(dayly).arry_of_data_objects[12*12,2]#one_day(dayly)[12*12,2]
  end
  must "電力データをone_dayに与えると" do
    puts __LINE__
    Shimada::Dayly.load_trz(TD0423svr)
    dayly = Shimada::Dayly.first
    assert_equal [["2015-04-22 12:00", 1.6969999999999998], ["2015-04-22 12:05", 1.665]],
            Graph::Ondotori::Base.new(dayly).arry_of_data_objects[12*12,2]#one_day(dayly)[12*12,2]
  end
  must "温度データのReationをmulti_daysに与えると" do
    puts __LINE__
    Hyums[0,5].each{|hyum| Shimada::Dayly.load_trz(hyum)}
    dayly = Shimada::Dayly.where(date: "2015-4-4", ch_name_type: "1F休憩所-温度")
    assert_equal [["2015-04-04 12:00", 14.9, 65.0, 11.02],
                  ["2015-04-04 12:05", 15.2, 65.0, 11.24]],
      Graph::Ondotori::Base.new(dayly).arry_of_data_objects[12*12,2]#multi_days(dayly)[12*12,2]
  end
  must "電力データのReationをmulti_daysに与えると" do
    puts __LINE__
    Shimada::Dayly.load_trz(TD0423svr)
    dayly = Shimada::Dayly.where(date: "2015-4-23", ch_name_type: "サーバー-電圧")
    dayly.kind_of? ActiveRecord::Relation
    assert_equal [["2015-04-23 01:00", 1.851],
                  ["2015-04-23 01:05", 1.842]],
      Graph::Ondotori::Base.new(dayly).arry_of_data_objects[1*12,2]#multi_days(dayly)[12*12,2]
  end
  must "" do
    puts __LINE__
    Shimada::Dayly.load_trz Hyum0423
    Shimada::Dayly.load_trz TD0423svr
    dayly = Shimada::Dayly.where(date: "2015-4-23")
    pp dayly.size
    gob = Graph::Ondotori::Base.new([dayly])
    assert_equal ["52BC036E", "52C204E9"],
      gob.arry_of_data_objects.keys

    assert_equal [["2015-04-23 01:00", 11.1, 8.47],  ["2015-04-23 01:05", 10.9, 8.61]],
      gob.arry_of_data_objects["52BC036E"][12,2]
    
    assert_equal [["2015-04-23 01:00", 1.851],  ["2015-04-23 01:05", 1.842]],
      gob.arry_of_data_objects["52C204E9"][12,2]

  end
end

