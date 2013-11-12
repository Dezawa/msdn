require 'test_helper'

class Hospital::ConstTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "1" do
    assert_equal "新人",Hospital::Const::Idou.rassoc(1)[0]
  end
end
