# -*- coding: utf-8 -*-
require 'test_helper'

class Ube::UbeProductTest < ActiveSupport::TestCase
  fixtures "ube/products"
  must "UbeProduct.size is " do
    assert_equal 77,Ubeboard::Product.count
  end
end
