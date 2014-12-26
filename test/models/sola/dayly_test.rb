# -*- coding: utf-8 -*-
require 'test_helper'

class Sola::DaylyTest < ActiveSupport::TestCase

  TRZ = "test/testdata/sola/ondotori_pw.trz"
  def setup
    Sola::Dayly.delete_all
  end

  must "load_trz" do
    dayly =  Sola::Dayly.load_trz TRZ
    assert_equal [1, 2, 3, 4, 5, 6, 7],Sola::Dayly.all.map{ |d| d.date.day}
    first =  Sola::Dayly.first
    #pp Sola::Dayly.first.kws.compact.sort
    #puts first.kws.compact.average
    #puts first.date
    last = Sola::Dayly.last
    assert_equal 2883.43,Sola::Dayly.first.kwh_day,"t一日の発電量"
    assert_equal 123.3,Sola::Dayly.first.peak_kw,"peak"
    assert_equal [123.3, 124.2, 123.1, 123.7, 119.1, 121.9, -1753.6],Sola::Dayly.all.map(&:peak_kw)
    assert_equal 2883.43,Sola::Monthly.find_by( month: "2013-9-1").kwh01
  end
end
