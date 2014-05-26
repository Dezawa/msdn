# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::PointTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  def setup
    Ubr::Waku.waku(true) 
      @point = Ubr::Point.new nil,"20130304"
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
