# -*- coding: utf-8 -*-
require 'test_helper'

class Sola::DaylyTest < ActiveSupport::TestCase

  TRZ = "test/testdata/sola/ondotori_pw.trz"
  def setup
    Sola::Dayly.delete_all
  end

  must " peak_graph data" do
    Sola::Dayly.load_trz TRZ
    assert_equal [["2013-09-01", 0.1242], ["2013-09-02", 0.1231], ["2013-09-03", 0.1237], 
                  ["2013-09-04", 0.121], ["2013-09-05", 0.1191], ["2013-09-06", 0.1219] ], 
    Sola::Dayly.all.order("date").pluck(:date, :peak_kw).map{ |d,v| [d.strftime("%Y-%m-%d"),v]}
  end

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

