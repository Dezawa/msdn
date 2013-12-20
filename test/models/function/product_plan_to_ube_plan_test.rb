# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'

#require 'result_copy_data.rb'
class Function::ProductPlanToUbePlanTest < ActiveSupport::TestCase
  fixtures "ube/holydays","ube/maintains","ube/products","ube/operations"
  #fixtures :ube_products,:ube_operations
  #fixtures :ube_plans,:ube_named_changes,:ube_change_times
  #Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  #              real_ope,from,to,time 
  
  CSV = "test/testdata/productplan_h24.csv"
  CSV ="test/testdata/SeisanKeikaku.xls"
  def setup
    #@skd = Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),
    #                     :skd_to => Time.parse("2012/6/30"))
    #csvio = open(CSV,"r")
    @ProductPlan = Ubeboard::Function::ProductPlanToUbePlan.new(CSV)
  end

  must "CSV ファイル" do
    assert_equal 37,@ProductPlan.csvfiles.size
  end

  must "月度は " do
    assert_equal Time.parse("2012/11/1"),@ProductPlan.year_month
  end

  must "UbePlan作成" do
    plans = @ProductPlan.make_ube_plans
    assert_equal [16, 17, 30, 34, 35, 36, 50, 53, 54, 55],
    plans.map(&:ube_product_id).uniq.sort
  end

  must "UbePlan作成時のerror" do
    plans = @ProductPlan.make_ube_plans
    assert_equal [],@ProductPlan.errors.uniq
  end

  #must "最後のデータ行は" do
  #  assert_equal 31,@ProductPlan.last_row_no 
  #end

  #must "データ行数は " do
  #  assert_equal 13,@ProductPlan.data_rows.size #map{|r| r[1]}
  #end

  must "データ" do
    cnt = Hash.new{|h,k| h[k]=0}
    #pp @ProductPlan.products.first
    assert_equal 26,@ProductPlan.products.size
  end
end
# -*- coding: utf-8 -*-
