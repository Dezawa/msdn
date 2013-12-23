# -*- coding: utf-8 -*-
require 'test_helper'

class UbeProductTest < ActiveSupport::TestCase
  fixtures "ube/products"
  must "UbeProduct.size is " do
    assert_equal 77,Ubeboard::Product.count
  end
end
