# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::PointTest < ActiveSupport::TestCase
  # Replace this with your real tests.
SoukoSort = Ubr::Point::SoukoSort
  def setup
       @label = "年月日"+
      " 穴" + SoukoSort.map{ |name_reg| "10桝以上穴数 5-9桝穴数 1-4桝穴数"}.join(" ") +
      " 重量"+ SoukoSort.map{ |name_reg| name_reg[0]}.join(" ") +
      " 通路" + SoukoSort.map{ |name_reg| %w(通路置き量 通路置き枠数)}.flatten.join(" ") +
      " 原料 再処理 長期"
    @Point = Ubr::Point.new(nil,nil)
    path = Ubr::Lot::SCMFILEBASE+".stat"
    @lines =  File.exist?(path) ? File.read(path).split(/[\n\r]+/).map{ |l| l.split} : []
    header = @lines.shift if @lines[0] && /201\d{5}/ !~ @lines[0][0]
    @lines.each{ |row| row[0] = Time.parse(row[0]).to_date}
  end

  must "20130304～ の週平均" do
    row = @lines.shift
    assert_equal [],
    @Point.average(row, @lines,row[0].beginning_of_week,row[0].beginning_of_week+1.week)
  end
end
