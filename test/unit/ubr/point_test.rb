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
end
__END__
