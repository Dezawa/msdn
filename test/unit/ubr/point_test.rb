# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::PointTest < ActiveSupport::TestCase
  # Replace this with your real tests.
<<<<<<< HEAD
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
=======
  def setup
    Ubr::Waku.waku(true) 
      @point = Ubr::Point.new nil,"20130304"
  end
  
  OKPAT = %w(1D23 7A99 0A33)
  NGPAT = %w(97A9 90AG)
  must "全体は" do
    reg = /^[1-6]|^7[A-D]|^0[A-GJ-L]/
    OKPAT.each{ |pat|       assert reg =~ pat ,pat    }

    NGPAT.each{ |pat|       assert reg !~ pat ,pat    }

  end
 
  must "init" do
    @point.save
  end

  must "5/23のとき 2014/2/3は月度" do
    today = Date.new(2014,5,23)
    assert_equal [Date.new(2014,2,1),Date.new(2014,3,1)],@point.from_to(today,Date.new(2014,2,3))[0,2]
  end

  must "5/23のとき 2013/2/3は2012年度" do
    today = Date.new(2014,5,23)
    assert_equal [Date.new(2012,4,1),Date.new(2013,4,1)],@point.from_to(today,Date.new(2013,2,3))[0,2]
  end

  must "5/23のとき 2012/2/3は2011年度" do
    today = Date.new(2014,5,23)
    assert_equal [Date.new(2011,4,1),Date.new(2012,4,1)],@point.from_to(today,Date.new(2012,2,3))[0,2]
  end

  (12..24).each{ |day|
    must "2014/5/#{day}は日" do
      today = Date.new(2014,5,23)
      assert_equal false,@point.from_to(today,Date.new(2014,5,day))
    end
  }

  (1..4).each{ |day|
    must "2014/5/#{day}は週" do
      today = Date.new(2014,5,23)
      assert_equal [d=Date.new(2014,4,28),d+7.day],@point.from_to(today,Date.new(2014,5,day))[0,2]
    end
  }
  (5..11).each{ |day|
    must "2014/5/#{day}は週" do
      today = Date.new(2014,5,23)
      assert_equal [d=Date.new(2014,5,5),d+7.day],@point.from_to(today,Date.new(2014,5,day))[0,2]
    end
  }
  (1..30).each{ |day|
    must "2014/4/#{day}は週" do
      today = Date.new(2014,5,23)
      from,to = @point.from_to(today,Date.new(2014,4,day))
      assert_equal to,from+7.day
    end
  }
  (1..3).each{ |month|
    must "2014/#{month}/4 は月" do
      today = Date.new(2014,5,23)
      from,to = @point.from_to(today,Date.new(2014,month,4))
      assert_equal to,from+1.month
    end
  }
  (10..12).each{ |month|
    must "2013/#{month}/4 は月" do
      today = Date.new(2014,5,23)
      from,to = @point.from_to(today,Date.new(2013,month,4))
      assert_equal to,from+1.month
    end
  }
  (4..9).each{ |month|
    must "2013/#{month}/4 は月" do
      today = Date.new(2014,5,23)
      from,to = @point.from_to(today,Date.new(2013,month,4))
      assert_equal to,from+3.month
    end
  }
  
end
__END__
>>>>>>> HospitalPower
