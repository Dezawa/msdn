# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
require 'testdata/result_copy/result_copy_data.rb'
class UbeSkdHozenTest < ActiveSupport::TestCase
  fixtures :ube_plans,:ube_products,:ube_operations,:ube_holydays,:ube_change_times,:ube_maintains
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]

  def make_skd(ids=[])
    skd=UbeSkd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< UbePlan.find(id) }
    skd.yojoko
    skd.set_yojoKo_object#sorted_plan
    skd
  end
  
  
  must "実績の無い保守は削除される" do
    skd=make_skd([90,20,92]) #S1切替（前）実績あり、S1コタタキ(東原)、S1切替（後）
    skd.delete_hozen_ubeplan_unless_resulted
    assert_equal [90,20], skd.ube_plans.map(&:id)
  end
  

  must "保守は削除された保守はDBには残っている" do
    skd=make_skd([90,20,92]) #S1切替（前）実績あり、S1コタタキ(東原)、S1切替（後）
    plan = UbePlan.find(92).dup
    skd.delete_hozen_ubeplan_unless_resulted
    assert UbePlan.find(92).ube_product_id == 0
  end
  
  must "実績の無い保守は sorted_resulted_plans で削除される" do
    skd=make_skd([91,20,92]) #S1切替（前）実績あり、S1コタタキ(東原)、S1切替（後）
    skd.sorted_resulted_plans(:kakou)
    assert_equal [20], skd.ube_plans.map(&:id)
  end
end