# -*- coding: utf-8 -*-
require 'test_helper'
Testdata="./test/testdata/shimada/"
Power01 = Testdata+"dezawa_power01_20150401-191041.trz"
Hyum    = Testdata+"temp-hyumidity-20141223-060422.trz"
TD0424   = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150424-060350.trz"
TD0423   = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
TD0423svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150423-060853.trz"
TD0424svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150424-060837.trz"

class Shimada::DaylyTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"
  def setup
    Shimada::Dayly.delete_all
  end

  must "serialの一覧" do
    assert_equal ["52BC036F", "52BC036F", "52C204E9", "52BC036E", "52BC036E", "52C215FA"],
      Shimada::Dayly.serials
  end

  must "Power01を取り込むと:base_name,:serialは" do
   ondotori = Ondotori::Recode.new(Power01)
   assert_equal ["dezawa", "529C0541"],
   [:base_name,:serial].map{|sym| ondotori.send(sym)}
  end
  must "Power01は valid_trzか" do
   ondotori = Ondotori::Recode.new(Power01)
   assert_equal true,Shimada::Dayly.valid_trz(ondotori)
  end
  must "Power01のchannnelは" do
   ondotori = Ondotori::Recode.new(Power01)
   assert_equal ["power01-電圧"],ondotori.channels.keys
  end
  
  must "Power01のchannnel power01-電圧 のserial,measurement_typeは" do
   ondotori = Ondotori::Recode.new(Power01)
   assert_equal ["52C215FA", "146"],
     [:serial,:type].map{|sym| ondotori.channels["power01-電圧"].send(sym)}
  end
  must "Power01は Instrumentに有るか" do
   ondotori = Ondotori::Recode.new(Power01)
   assert_equal true,
     Shimada::Dayly.serials. #instrument.all.pluck(:serial).
     include?(ondotori.channels["power01-電圧"].serial)
  end
######### temp_or_hyum? とtime_and_converted_value
  
  must "Hyumを取り込むと12/22日のデータの温度の変換temp_or_hyum?は" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal true ,
      Shimada::Dayly.find_by(date: "2014-12-22",ch_name_type: "フリーザーA-温度").
      temperature?
  end
  must "Hyumを取り込むと12/22日のデータの温度のtime_and_converted_value_with_vaperは" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal 4 ,
      Shimada::Dayly.find_by(date: "2014-12-22",ch_name_type: "フリーザーA-温度").
      time_and_converted_value_with_vaper[0].size
  end

  must "Power01を取り込むと4/1の電力データのtemp_or_hyum?は" do
    Shimada::Dayly.load_trz(Power01)
    dayly1 =  Shimada::Dayly.find_by(date: "2015-04-01" ,ch_name_type: "power01-電圧")
    assert_equal false ,   dayly1.temperature?
  end
  
  must "Power01を取り込むと4/1の電力データのtime_and_converted_valueは" do
    Shimada::Dayly.load_trz(Power01)
    dayly1 =  Shimada::Dayly.find_by(date: "2015-04-01" ,ch_name_type: "power01-電圧")
    assert_equal 2 ,   dayly1.time_and_converted_value[0].size
  end

  ########### 
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
  
  must "Power01を取り込むと4/1の電圧データは" do
    Shimada::Dayly.load_trz(Power01)
    dayly1 =  Shimada::Dayly.find_by(date: "2015-04-01" ,ch_name_type: "power01-電圧")
    assert_equal [0.4908, 0.489, 0.4652, 0.4824, 0.5022, 0.5152, 0.527, 0.5254, 0.5224, 0.5162],
      dayly1.measurement_value[12*60,10]
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
    assert_equal 0,
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
    assert_equal [5,"52BC036E", "208"],
      [:instrument_id,:serial,:measurement_type].map{|sym| dayly22.send(sym)}
  end
  must "Hyumを取り込むと12/22日の湿度データの相棒温度は" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-湿度")
    dayly22tmp = Shimada::Dayly.#find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-温度")
      find_by(date:"2014-12-22",serial: dayly22.serial,measurement_type: 13)
    assert_equal [4,"52BC036E", "13"],
      [:instrument_id,:serial,:measurement_type].map{|sym| dayly22tmp.send(sym)}
  end
  must "Hyumを取り込むと12/22日の湿度の変換後データ" do
    Shimada::Dayly.load_trz(Hyum)
    dayly22 = Shimada::Dayly.find_by(date: "2014-12-22" ,ch_name_type: "フリーザーA-湿度")
    assert_equal [3.31, 3.23, 3.24, 3.12, 3.06, 2.97, 3.14, 2.75, 2.93, 3.23, 2.95, 3.03],
      dayly22.converted_value[12*12,12]
  end

  must "TD0424を取り込むと4/23日の一時間平均温度" do
    Shimada::Dayly.load_trz(TD0424)
    dayly23 = Shimada::Dayly.find_by(date: "2015-4-23" ,ch_name_type: "1F休憩所-温度")
    assert_equal [nil,   nil,   nil,   nil,   nil,   nil,    9.4,  10.53,
                  11.93, 13.54, 15.53, 17.33, 19.08, 20.42, 22.06, 23.1,
                  23.27, 22.15, 18.57, 16.35, 15.55, 15.16, 14.66, 14.28],
    #             [11.90, 13.9, 15.9, 17.2, 19.2
      dayly23.converted_value_hourly
  end

  must "Hyumを取り込むと中部しまだのデータ数は４" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal 4, Shimada::Dayly.by_factory_name("中部シマダヤ").size
  end
     
  must "Hyumを取り込むfactory_id 1のデータ数は４" do
    Shimada::Dayly.load_trz(Hyum)
    assert_equal 4, Shimada::Dayly.by_factory_name("中部シマダヤ").size
  end
  must "TD0424 を Ondotori::Recodeするとbasenameは" do
    ondotori = Ondotori::Recode.new(TD0424)
    assert_equal "ティアンドデイ社屋" , ondotori.base_name
  end
  must "TD0424 を Ondotori::Recodeするとvalid_trzは" do
    ondotori = Ondotori::Recode.new(TD0424)
    assert_equal true , Shimada::Dayly.valid_trz( ondotori)
  end
  must "TD0424 を Ondotori::Recodeするとchannelsは" do
    ondotori = Ondotori::Recode.new(TD0424)
    assert_equal ["1F休憩所-温度", "1F休憩所-湿度"] ,ondotori.channels.keys
  end
  must "TD0424 を Ondotori::Recodeするとtimes_values_group_by_dayは" do
    ondotori = Ondotori::Recode.new(TD0424)
    assert_equal [[2015,4,23],[2015,4,24]].map{|d| Date.new(*d)},
      Shimada::Dayly.times_values_group_by_day(ondotori.channels["1F休憩所-温度"]).keys
  end
  must "TD0424 をfind_or_create_and_saveするとデータ一つ" do
    ondotori = Ondotori::Recode.new(TD0424)
    channel = ondotori.channels["1F休憩所-温度"]

    day,time_values =
      Shimada::Dayly.times_values_group_by_day(channel).to_a[0]
    
    Shimada::Dayly.find_or_create_and_save(day,channel,time_values)
    assert_equal 1,Shimada::Dayly.count
  end
  must "TD0424 を取り込むfactory_id 1のデータ数は４" do
    Shimada::Dayly.load_trz(TD0424)
    assert_equal 4, Shimada::Dayly.by_factory_name("中部シマダヤ").size
  end
  must "TD0424 を取り込むと4/24の温度データの数とインターバル" do
    Shimada::Dayly.load_trz(TD0424)
    dayly =  Shimada::Dayly.by_factory_name("中部シマダヤ").
      where(date: "2015-4-24",ch_name_type: "1F休憩所-温度")[0]
    assert_equal [73, 300], [dayly.measurement_value.size,dayly.interval]
  end
  must "TD0424 を取り込むと4/24の温度データの時間値" do
    Shimada::Dayly.load_trz(TD0424)
    dayly =  Shimada::Dayly.by_factory_name("中部シマダヤ").
      where(date: "2015-4-24",ch_name_type: "1F休憩所-温度")[0]
    assert_equal [13.57, 12.59, 13.98, 14.11, 13.9, 13.66, 13.6]+[nil]*17,
      dayly.converted_value_hourly
  end
  
  must "TD0423,24,svr を取り込みby_factory_id_and_date_order_instrumentを行う" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0424)
    Shimada::Dayly.load_trz(TD0423svr)
    Shimada::Dayly.load_trz(TD0424svr)
    daylies =  Shimada::Dayly.by_factory_id_order_instrument(1)
    assert_equal [[22, "サーバー-電圧"], [22, "1F休憩所-温度"], [22, "1F休憩所-湿度"],
                  [23, "サーバー-電圧"], [23, "1F休憩所-温度"], [23, "1F休憩所-湿度"],
                  [24, "サーバー-電圧"], [24, "1F休憩所-温度"], [24, "1F休憩所-湿度"]],
      daylies.map{|dayly| [dayly.date.day,dayly.ch_name_type]}

  end
  
  must "TD0423,24,svr を取り込みby_factory_id_and_date_order_instrumentを行い4/23を選ぶ" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0424)
    Shimada::Dayly.load_trz(TD0423svr)
    Shimada::Dayly.load_trz(TD0424svr)
    daylies =  Shimada::Dayly.by_factory_id_order_instrument(1).where(date: "2015-4-23")
    assert_equal [ [23, "サーバー-電圧"], [23, "1F休憩所-温度"], [23, "1F休憩所-湿度"]],
      daylies.map{|dayly| [dayly.date.day,dayly.ch_name_type]}

  end
   must "TD0424svrを取り込むとサーバー電圧は" do
    Shimada::Dayly.load_trz(TD0424svr)
    assert_equal [0.001675, 0.001674, 0.00170,  0.001673, 0.001667, 0.00168,
                  0.001701, 0.001691, 0.001698, 0.001681, 0.001672, 0.001678
                 ],
      Shimada::Dayly.by_factory_id(1).
      where(date: "2015-4-23",ch_name_type:"サーバー-電圧")[0].
      measurement_value[8*12,12].map{|v| v.round(6)}
  end
   must "TD0424svrを取り込むとサーバー電力は" do
    Shimada::Dayly.load_trz(TD0424svr)
    assert_equal [1.675, 1.674, 1.7, 1.673, 1.667, 1.68,
                  1.701, 1.691, 1.698, 1.681, 1.672, 1.678
                 ],
      Shimada::Dayly.by_factory_id(1).
      where(date: "2015-4-23",ch_name_type:"サーバー-電圧")[0].
      converted_value[8*12,12].map{|v| v.round(6)}
  end

   must "TD0424svrを取り込むと4/23 7～9時台サーバー平均電力は" do
    Shimada::Dayly.load_trz(TD0424svr)
    assert_equal [1.68, 1.68, 1.72],
      Shimada::Dayly.by_factory_id(1).
      where(date: "2015-4-23",ch_name_type:"サーバー-電圧")[0].
      converted_value_hourly[7,3].map{|v| v.round(6)}
  end

end
