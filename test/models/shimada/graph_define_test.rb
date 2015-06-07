#-*- coding: utf-8 -*-
require 'test_helper'

class Shimada::GraphDefineTest < ActiveSupport::TestCase
  fixtures "shimada/graph_defines"
  GraphDefine = Shimada::GraphDefine
  
  must "全部で３つ" do
    assert_equal( 3, GraphDefine.count)
  end

  must "工場1 graph_type 岐阜気象庁 " do
    assert_equal "全電力と温度・蒸気圧", GraphDefine.find_by(factory_id: 1,name: "全電力・気温").title
  end

  must "serial は serializeされている" do
    assert_equal %w(52BC036F 52BC036E), GraphDefine.find_by(factory_id: 1,name: "全電力・気温").serials
  end

  must "serial に String でいれると serializeされて入る" do
      graphdefine = GraphDefine.find_by(factory_id: 1,name: "全電力・気温")
      graphdefine.serials = "52BC036F 52BC036E"
      graphdefine.save
    assert_equal %w(52BC036F 52BC036E), GraphDefine.find_by(factory_id: 1,name: "全電力・気温").serials
  end

  
  # test "the truth" do
  #   assert true
  # end
end
