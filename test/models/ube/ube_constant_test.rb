# -*- coding: utf-8 -*-
require 'test_helper'

class UbeConstantTest < ActiveSupport::TestCase
  fixtures :ube_constants

  must "Constant数" do
    assert_equal 13,UbeConstant.count
  end
end
