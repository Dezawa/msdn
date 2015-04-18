# -*- coding: utf-8 -*-
require 'test_helper'
Testdata="./test/testdata/shimada/"
Power01 = Testdata+"dezawa_power01_20150401-191041.trz"

class Sola::DaylyTest < ActiveSupport::TestCase

  TRZ = "test/testdata/sola/ondotori_pw.trz"
  def setup
    Sola::Dayly.delete_all
  end

  must " peak_graph data" do
    Sola::Dayly.load_trz TRZ
    assert_equal [["2013-09-01", (0.1242*Sola::Scale[0]+Sola::Scale[1]).round(6)],
                  ["2013-09-02", (0.1231*Sola::Scale[0]+Sola::Scale[1]).round(6)],
                  ["2013-09-03", (0.1237*Sola::Scale[0]+Sola::Scale[1]).round(6)], 
                  ["2013-09-04", (0.121*Sola::Scale[0]+Sola::Scale[1]).round(6)],
                  ["2013-09-05", (0.1191*Sola::Scale[0]+Sola::Scale[1]).round(6)],
                  ["2013-09-06", (0.1219*Sola::Scale[0]+Sola::Scale[1]).round(6)] ], 
      Sola::Dayly.all.order("date").pluck(:date, :peak_kw).
      map{ |d,v| [d.strftime("%Y-%m-%d"),v]}
  end

  must "同じ日を二度読む" do
    Sola::Dayly.load_trz "test/testdata/sola/dezawa_power01_20141227-161022.trz"
    dayly2 = Sola::Dayly.find_by(date: "2014-12-27")
    assert_equal 0.248*Sola::Scale[0]+Sola::Scale[1],dayly2.kws[12*60] ,"12:00" #12:00
    
    Sola::Dayly.load_trz "test/testdata/sola/dezawa_power01_20141227-161022.trz"
    dayly = Sola::Dayly.find_by(date: "2014-12-27")
    assert_equal 0.0815*Sola::Scale[0]+Sola::Scale[1],dayly.kws[16*60+10],"16:10"
  end
  must "Power01を取り込むと二日分のデータができる" do
    assert_difference( 'Sola::Dayly.count',2 ){
      Sola::Dayly.load_trz(Power01)
    }
  end
end

