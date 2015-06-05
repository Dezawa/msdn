# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'

class Sola::DaylyTest < ActiveSupport::TestCase
  fixtures "sola/instruments"
  
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

  must "同じ日を二度読んでもデータ数は変わらない" do
    Sola::Dayly.load_trz "test/testdata/sola/dezawa_power01_20141227-161022.trz"
    assert_difference( 'Sola::Dayly.count',0 ){
      Sola::Dayly.load_trz("test/testdata/sola/dezawa_power01_20141227-161022.trz")
    }
  end
  must "Dezawa01を取り込むと二日分のデータができる" do
    assert_difference( 'Sola::Dayly.count',2 ){
      Sola::Dayly.load_trz(Dezawa01)
    }
  end
end

