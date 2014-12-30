# -*- coding: utf-8 -*-
require 'test_helper'

class Sola::MonthlyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  must "kwh_dayをしまう" do
    monthly = Sola::Monthly.new
    monthly["kwh02"] = 2.0
    monthly.save
    assert_equal 2.0 ,Sola::Monthly.first.kwh02
  end
    
end
