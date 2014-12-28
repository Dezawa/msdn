# -*- coding: utf-8 -*-
require 'test_helper'

class Sola::DaylyTest < ActiveSupport::TestCase

  TRZ = "test/testdata/sola/ondotori_pw.trz"
  def setup
    Sola::Dayly.delete_all
  end

  # must "load_trz" do
  #   dayly =  Sola::Dayly.load_trz TRZ
  #   assert_equal [1, 2, 3, 4, 5, 6],Sola::Dayly.all.map{ |d| d.date.day}
  #   first =  Sola::Dayly.first
  #   last = Sola::Dayly.last
  #   #pp first.kws.compact.sort.join(" ")
  #  # pp first.kws
  #  # pp first.kws.compact.inject(0.0){ |s,v| s+v }
  #   assert_equal 2.88672,first.kwh_day,"t一日の発電量"
  #   assert_equal 0.1242 ,first.peak_kw,"peak"
  #   assert_equal [0.1242, 0.1231, 0.1237, 0.121, 0.1191, 0.1219],Sola::Dayly.all.map(&:peak_kw)
  #   assert_equal 2.88672,Sola::Monthly.find_by( month: "2013-9-1").kwh01
  # end

  must "同じ日を二度読む" do

    Sola::Dayly.load_trz "test/testdata/sola/dezawa_power01_20141227-121022.trz"
    dayly2 = Sola::Dayly.find_by(date: "2014-12-27")
    assert_equal 0.248,dayly2.kws[12*60],"12:00" #12:00

    # ondotori = Sola::Dayly.ondotori_load("test/testdata/sola/dezawa_power01_20141227-161022.trz")
    # assert_equal "2014-12-27 16:10:19",ondotori.channels["power01-電圧"].times.last.strftime("%Y-%m-%d %H:%M:%S")
    # times_values = Sola::Dayly.times_values_group_by_day(ondotori.channels["power01-電圧"])
    # assert_equal ["2014-12-27"] , times_values.keys.map{ |t| t.strftime("%Y-%m-%d") },"2014-12-27"
    # assert_equal [Time.local("2014",12,27,16,10,19),0.0815],times_values.values.last.last,"最後のデータ"
    # day,time_values = times_values.first
    # pp day
    # dayly = Sola::Dayly.find_or_create_by(:date => day)

    # time,value = time_values.first
    # min = (time.seconds_since_midnight/60).to_i
    # dayly.kws ||= []
    # dayly.kws[min] =   value 
    # pp [min,dayly.kws[min] ]
    # #dayly = Sola::Dayly.find_or_create_and_save(day,time_values)
    # assert_equal 0.248,dayly.kws[12*60],"12:00"
    # assert_equal 0.2454,dayly.kws[731],"12:11"
    Sola::Dayly.load_trz "test/testdata/sola/dezawa_power01_20141227-161022.trz"
    dayly = Sola::Dayly.find_by(date: "2014-12-27")
    assert_equal 0.0815,dayly.kws[16*60+10],"16:10"
  end
end

