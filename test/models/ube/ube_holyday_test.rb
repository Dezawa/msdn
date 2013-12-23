# -*- coding: utf-8 -*-
require 'test_helper'
require 'testdata/holyday.rb'
class UbeHolydayTest < ActiveSupport::TestCase
 fixtures  "ube/holydays","ube/constants" # Replace this with your real tests.
  #test "the truth" do ;    assert true ;  end

  
  [:shozow,:shozoe,:dryo,:dryn,:kakou].each{| real_ope |
    must "#{real_ope} ６月の休日" do
      skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
      assert_equal  Holyday[real_ope],skd.holydays[real_ope]
    end
  }

end
