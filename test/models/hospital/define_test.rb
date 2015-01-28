# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::DefineTest < ActiveSupport::TestCase
  fixtures "hospital/defines"

  must "無けりゃ作る" do
    assert_equal Hospital::Const::ItemsDefineAll.size,Hospital::Define.find_or_create_all.size
  end
end
