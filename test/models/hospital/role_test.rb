# -*- coding: utf-8 -*-
require 'test_helper'
# -*- coding: utf-8 -*-

class Hospital::RoleTest < ActiveSupport::TestCase
  fixtures "hospital/roles"

  must "Hospital::Role.shokushu" do
    assert_equal [["看護師", 2], ["準看護師", 3]],Hospital::Role.shokushu
  end
  must "Hospital::Role.kinmukubun" do
    assert_equal [["日勤", 7], ["三交代", 8], ["二 交代", 9], ["パート", 10]],Hospital::Role.kinmukubun
  end
  must "Hospital::Role.shikaku" do
    assert_equal [["Aチーム", 4], ["Bチーム", 5]],Hospital::Role.shikaku
  end
  must "Hospital::Role.shokui" do
    assert_equal [["リーダー", 1], ["看護師長", 6]],Hospital::Role.shokui
  end
end
# -*- coding: utf-8 -*-
