# -*- coding: utf-8 -*-
require 'test_helper'

class Ubr::SoukoPlanTest < ActiveSupport::TestCase
  fixtures :ubr_souko_plans,:ubr_souko_floor_souko_plans,:ubr_souko_floors
  # Replace this with your real tests.
  def setup
    @souko_group =  Ubr::SoukoPlan.find_by_name("123倉庫")
  end

  plan = "123倉庫"
  offset = [20,5]
  stat_offset =  [5,10]
  stat_names  = %w(1A 1B 2 3 2-2F)
  stat_reg = [/^1A/, /^1B/, /^2CD/, /^3/, /^2E/]
  must "#{plan}の" do
    assert_equal offset,Ubr::SoukoPlan.find_by_name(plan).offset,"offsetは#{offset.join(',')}"
    assert_equal stat_offset,Ubr::SoukoPlan.find_by_name(plan).stat_offset
    assert_equal stat_names,Ubr::SoukoPlan.find_by_name(plan).stat_names
    assert_equal stat_reg,Ubr::SoukoPlan.find_by_name(plan).stat_reg
  end

  must "#{plan}の" do
    assert_equal 4,Ubr::SoukoPlan.find_by_name(plan).souko_floors.size,"floor数"
    assert_equal ["1", "2", "2-2", "3"],Ubr::SoukoPlan.find_by_name(plan).souko_floors.map(&:name),"floor名"
    assert_equal "1",Ubr::SoukoPlan.find_by_name(plan).souko_floors.first.name,"floor1 名前"
  end

  must "SoukoPlan.plans" do
    assert_equal 4,Ubr::SoukoPlan.plans.size,"数"
    assert_equal %w(123倉庫 456倉庫 総合倉庫 AP跡),Ubr::SoukoPlan.plans.map(&:name),"名前"
  end
  [false,false,true,false].
    each_with_index{ |bool,idx|
    must "#{idx}のlandscapeは" do
      assert_equal bool, Ubr::SoukoPlan.plans[idx].landscape
    end
  }

  ret = {"3"=>[45.0, 0.0], "2"=>[0.0, 32.5], "1"=>[0.0, 62.5], "2-2"=>[0.0, 113.0]}
  must "floor_offset は" do
    assert_equal 4,@souko_group.floor_offset.size,"数"
    assert_equal ret,@souko_group.floor_offset,"値"
#pp @souko_group.souko_floors.first.name
  end
  
end
