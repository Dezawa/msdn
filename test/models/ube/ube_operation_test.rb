# -*- coding: utf-8 -*-
require 'test_helper'

class UbeOperationTest < ActiveSupport::TestCase
  fixtures :ube_operations
  must "UbeOperation.count" do
    assert_equal 30,UbeOperation.count
  end
end
