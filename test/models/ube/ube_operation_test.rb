# -*- coding: utf-8 -*-
require 'test_helper'

class Ube::UbeOperationTest < ActiveSupport::TestCase
  fixtures "ube/operations"
  must "UbeOperation.count" do
    assert_equal 30,Ubeboard::Operation.count
  end
end
