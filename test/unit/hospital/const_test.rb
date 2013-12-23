require 'test_helper'
# -*- coding: utf-8 -*-

class Hospital::ConstTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "1" do
    assert_equal "新人",Hospital::Const::Idou.rassoc(1)[0]
  end
end
# -*- coding: utf-8 -*-
