# -*- coding: utf-8 -*-
require 'test_helper'

class Ube::UbeConstantTest < ActiveSupport::TestCase
  fixtures "ube/constants"

  must "Constant数" do
    assert_equal 13,Ubeboard::Constant.count
  end
end
