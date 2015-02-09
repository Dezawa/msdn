# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::RoleTest < ActiveSupport::TestCase
  fixtures "hospital/roles"
  must "資格" do
    assert_equal [["Aチーム", 9], ["Bチーム", 10]],Hospital::Role.shikaku
end
  must "勤務区分" do
    assert_equal [["日勤", 6], ["三交代", 7], ["パート", 8], ["共通", 14]],Hospital::Role.kinmukubun
end
  must "職種" do
    assert_equal [["看護師", 4], ["準看護師", 5]],Hospital::Role.shokushu
end
  must "職位" do
    assert_equal [["看護師長", 1], ["主任", 2], ["リーダー", 3]],Hospital::Role.shokui
end
end
