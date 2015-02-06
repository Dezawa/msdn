# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::DefineTest < ActiveSupport::TestCase
  fixtures "hospital/defines"

  must "無けりゃ作る" do
    assert_equal Hospital::Const::ItemsDefineAll.size,Hospital::Define.find_or_create_all.size
  end

  must "Hospital::Define.define は" do
    HD=Hospital::Define.define
    assert_equal [true,    [0,1,2,3],  ["0","1","2","3"],  ["1","2","3"], "3",     ["2","3"]],
    [             :koutai3,:shifts_int,:shifts ,           :shifts123,   :shiftsmx, :night].
      map{|sym| HD.send(sym) }
  end
end
