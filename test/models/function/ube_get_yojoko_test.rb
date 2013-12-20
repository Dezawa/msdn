# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
#require 'result_copy_data.rb'
class Function::UbeRenumberTest < ActiveSupport::TestCase
  #fixtures :ube_holydays,:ube_maintains,:ube_products,:ube_operations,:ube_plans,:ube_named_changes,:ube_change_times
 fixtures "ube/products","ube/operations","ube/named_changes","ube/change_times","ube/plans"

# 1   前回と同じものが利用可能ならそれ                   No4 6/10 12:30 => No4
# 2   前回と同じものが使えず、他に利用可能なものがあれば
# 2-1　 同じ n_mass のものでもっとも早く開くもの         No4 11:30 => No2
# 2-2　 なければ、もっとも早くあくもの                   No4 09:00 => No7
# 3   まだ割り当てられておらず、利用可能なものがあれば
# 3-1　 同じ n_mass のものでもっとも早く開くもの         1.0 11:30 => No2
# 3-2　 なければ、もっとも早くあくもの                   1.0 09:00 => No7
# 4   利用可能なものがなければ、もっとも早く開くもの     1.0 04:00 => No7

  Yojoko = [
    [2 ,"6/10-10:00"], #1.0
    [3 ,"6/10-11:00"],
    [4 ,"6/10-12:00"],
    [5 ,"6/10-13:50"],
    [6 ,"6/10-14:50"],
    [7 ,"6/10-05:00"], #0.75
    [8 ,"6/10-06:00"],
    [9 ,"6/10-07:00"],
    [10,"6/10-08:00"],
    [11,"6/10-13:00"],
    [12,"6/10-14:00"],
    [13,"6/11-12:30"], #1.0
    [14,"6/11-10:30"],
    [15,"6/11-11:30"],
    [16,"6/11-12:30"],
    [17,"6/11-10:30"],
    [18,"6/11-11:30"],
    [19,"6/10-09:00"], #1.25
    [20,"6/10-10:00"],
    [21,"6/10-11:00"],
    [22,"6/10-12:00"],
    [23,"6/10-13:00"],
    [24,"6/10-14:00"]
  ]
  Times = 
    "6/10-7:00 6/10-9:00 6/10-11:10 6/10-12:30 6/10-01:00 6/10-3:00".times
  def setup
    @skd =  make_skd 
    #@skd.assign_if_resulted
    #@skd.procceed_stock
    #Yojoko.each{|no,date| @skd.yojoko[no].next_start  date.times.first }
  end
  def make_skd(ids=[])
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2012/6/1"),:skd_to => Time.parse("2012/6/30"))
    skd.after_find_sub
    skd.ube_plans=[]
    ids.each{|id| skd.ube_plans<< Ubeboard::Plan.find(id) }
    skd.yojoko
    Yojoko.each{|no,date| skd.yojoko[no].next_start  date.times.first }
    skd
  end
  def procceed
    @skd.assign_if_resulted
    @skd.procceed_stock
  end    

  def set_plan(no,n_mass,opt={}) #no,n_mass)
    plan=Ubeboard::Plan.new(
                { :ube_product_id => 1,
                  :mass => 2341,
                  :plan_shozo_from => Times[0],
                  :plan_shozo_to   => Times[1]
                }.merge opt
                )
    plan.n_mass  n_mass
    plan.yojoKo = @skd.yojoko[no]
    plan
  end
    
  must "前回の養生庫が使える" do
    #puts "前回の養生庫が使える" 
    plan = set_plan(4,1.0)
    yojo_from = Time.parse("2012/6/10-12:30")
    assert @skd.last_assigned_yojoko_enable(plan,yojo_from)
  end
  must " 前回と同じものが利用可能ならそれ" do
    #puts " 前回と同じものが利用可能ならそれ" 
    pre_plan = set_plan(3,1.0,:result_shozo_from => Times[2],:result_shozo_to => Times[3])
    plan = set_plan(4,1.0)
    @skd.ube_plans = [pre_plan,plan]
    procceed
    assert_equal 4, @skd.get_yojoko(plan).no
  end

  must "前回の養生庫が使えない" do
    #puts "前回の養生庫が使えない" 
    plan = set_plan(4,1.0)
    yojo_from = Time.parse("2012/6/10-11:30")
    assert !@skd.last_assigned_yojoko_enable(plan,yojo_from)
  end

  must " 前回と同じものが使えないなら同じn_mass探す" do
    #puts " 前回と同じものが利用可能ならそれ" 
    pre_plan = set_plan(3,1.0,:result_shozo_from => Times[1],:result_shozo_to => Times[2])
    plan = set_plan(4,1.0)
    @skd.ube_plans = [pre_plan,plan]
    procceed
    assert_equal 2, @skd.get_yojoko(plan).no
  end


  must " 前回と同じものが使えないなら同じn_mass探すが、無いときは" do
    #puts " 前回と同じものが利用可能ならそれ" 
    pre_plan = set_plan(3,1.0,:result_shozo_from => Times[0],:result_shozo_to => Times[1])
    plan = set_plan(4,1.0)
    @skd.ube_plans = [pre_plan,plan]
    procceed
    assert_equal 7, @skd.get_yojoko(plan).no
  end


  must "間に合う養生庫がない" do
    #puts " 前回と同じものが利用可能ならそれ" 
    pre_plan = set_plan(3,1.0,:result_shozo_from => Times[4],:result_shozo_to => Times[5])
    plan = set_plan(4,1.0)
    @skd.ube_plans = [pre_plan,plan]
    procceed
    assert_equal 7, @skd.get_yojoko(plan).no
  end


  must "前回の養生庫が使えない" do
    plan = set_plan(4,1.0)
    yojo_from = Time.parse("2012/6/10-11:30")
    assert !@skd.last_assigned_yojoko_enable(plan,yojo_from)
  end

  must "前回の養生庫が使えない,同じn_massあり" do
    #puts "前回の養生庫が使えない,同じn_massあり" 
    plan = set_plan(4,1.0)
    yojo_from = Time.parse("2012/6/10-10:30")
    assert_equal 2, @skd.aviable_when_yojo_from(plan,yojo_from).no
  end

  must "前回の養生庫が使えない,同じn_massなし  " do
    #puts "前回の養生庫が使えない,同じn_massなし" 
    plan = set_plan(4,1.0)
    yojo_from = Time.parse("2012/6/10-9:00")
    assert_equal 7, @skd.aviable_when_yojo_from(plan,yojo_from).no
  end
end

