# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'
#require 'need'

class Hospital::AssignTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies","hospital/defines"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @nurces=@assign.nurces
    srand(1)
  end
  def newmonth(month)
    @month  = Date.new(2013,month,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @nurces=@assign.nurces
    srand(1)
  end
    
  def extract_set_shifts(string)
    nurces=[]
    string.each_line{|line|
      hp,assign,id,data,dmy = line.split(nil,5)
      next unless hp == "HP"
      case id
      when /^\d+$/
        nurces[id.to_i]=@assign.nurce_by_id(id.to_i)
       @assign.nurce_set_patern(nurces[id.to_i],1,data[1..-1].chop)
      when  /ENTRY/
      end
    }
    nurces#.compact
  end

  must "Kangoshi定数" do
    assert_equal 4,@assign.Kangoshi
  end
  must " 看護師数" do
    assert_equal 18,@assign.kangoshi.size
  end
  must "need_patarn" do
    assert_equal [{[3, "2"]=>[1, 1], [3, "3"]=>[1, 1], [4, "3"]=>[2, 2], [4, "2"]=>[2, 2], [4, "1"]=>[9, 11], [9, "3"]=>[1, 2], [9, "2"]=>[1, 2], [9, "1"]=>[1, 2], [10, "3"]=>[1, 2], [10, "2"]=>[1, 2], [10, "1"]=>[1, 2], [4, "0"]=>[0, 5]}, {[3, "2"]=>[1, 1], [3, "3"]=>[1, 1], [4, "3"]=>[2, 2], [4, "2"]=>[2, 2], [4, "1"]=>[6, 7], [9, "3"]=>[1, 2], [9, "2"]=>[1, 2], [9, "1"]=>[1, 2], [10, "3"]=>[1, 2], [10, "2"]=>[1, 2], [10, "1"]=>[1, 2], [4, "0"]=>[0, 8]}
                 ],@assign.need_patern
  end

  must "5月の role_order_by_tightness" do
    sft_str = "2"
    newmonth(5)
    @assign.nurces = extract_set_shifts(Log5_5)
    assert_equal [9, 3, 10, 4] ,@assign.role_order_by_tightness(sft_str)
  end
  must "5月の tight_roles" do
    sft_str = "2"
    newmonth(5)
    @assign.nurces = extract_set_shifts(Log5_5)
    assert_equal [9, 3, 10] ,@assign.tight_roles(sft_str)
  end

  must "5月の shift_remain" do
    sft_str = "2"
    newmonth(5)
    nurces = extract_set_shifts(Log5_5)
    assert_equal( [2, 1, 1, 3, 3, 5, 5, 5, 5, 5, 5, 4, 5, 5, 4, 5, 5, 4, 3],
                  @assign.nurces.map{ |n| n.shift_remain[sft_str]}
                  )
  end
  must "5月の shift_remain 看護師合計 の" do
    sft_str = "2"
    newmonth(5)
    nurces = extract_set_shifts(Log5_5)
    assert_equal( 75,
                  @assign.nurces.inject(0){ |s,n| s + n.shift_remain[sft_str]}
                  )
  end

  must "不足role" do
    ret = {[3, "2"]=>[1, 1], [3, "3"]=>[1, 1], [4, "3"]=>[2, 2], [4, "2"]=>[2, 2], [4, "1"]=>[9, 11], [9, "3"]=>[1, 2], [9, "2"]=>[1, 2], [9, "1"]=>[1, 2], [10, "3"]=>[1, 2], [10, "2"]=>[1, 2], [10, "1"]=>[1, 2], [4, "0"]=>[0, 4]}
    assert_equal ret,@assign.short_role_shift_of(1)
  end

  must "必要看護師ロール" do
    assert_equal [{"1"=>9},{"1"=>[4, 9, 10]}],@assign.need_nurces_roles(1)[1..2]

  end

  Cost = Hospital::NurceCost::ClassMethods::Cost
  must " 2/4:2 2の使用数の違う38,39のcostが同じなのはなぜ？" do
    #pp @assign.nurce_by_id([38,39]).map(&:shift_remain)
    nurces = extract_set_shifts(Log2_3)
    #pp @assign.nurce_by_id([38,39]).map(&:shift_remain)
    shift = "2"
    margin = {[1, 2]=>14, [2, 2]=>23, [3, 2]=>0, [4, 2]=>15, [5, 2]=>24 }.to_a.sort
    assert_equal "_1____0______________________",nurces[38].shifts,"shift設定"
    #assert_equal margin,
    #  @assign.margin_of_role.select{|k,v| k[1]==shift}.sort,
    #  "残りrole総数"
    tight = [3, 9, 10]
    assert_equal tight,@assign.tight_roles(shift).sort,"逼迫ロール"
    assert_equal [{"3"=>5, "2"=>5, "1"=>19.0, "0"=>6.0, :kinmu_total => 21, :night_total=>9}, 
                  {"3"=>5, "2"=>4, "1"=>18.0, "0"=>8.0, :kinmu_total => 19, :night_total=>8}], # 本当は[7,19,5,5] だが、初めからある0を二度引いてしまうから
       [38,39].map{|id| nurces[id].shift_remain},   "看護師の残りシフト全体像"

    assert_equal [5,4], [38,39].
      map{|id| nurces[id].shift_remain[shift]},  "看護師のshift#{shift}残数"

    assert_equal [[3,4,9],[3,4,9]],  [38,39].
      map{|id| nurces[id].need_role_ids}, "看護師の role"

    assert_equal [Cost[6][5],Cost[6][4]],[38,39].map{|id| nurces[id].cost(shift,tight).to_i }, "看護師のcost"
    #nurces[38].
    #  nurces[39].
  end


  must " 5/5 3の使用数の違う50,47のcostが同じなのはなぜ？" do
    remain0= {[4, "0"]=>144.0, [4, "1"]=>360.0, [4, "2"]=>81, [4, "3"]=>81, [4, :night_total]=>147, [4, :kinmu_total]=>396.0, [9, "0"]=>80.0, [9, "1"]=>200.0, [9, "2"]=>47, [9, "3"]=>47, [9, :night_total]=>85, [9, :kinmu_total]=>220.0, [10, "0"]=>96.0, [10, "1"]=>240.0, [10, "2"]=>57, [10, "3"]=>57, [10, :night_total]=>103, [10, :kinmu_total]=>264.0, [3, "0"]=>80.0, [3, "1"]=>200.0, [3, "2"]=>50, [3, "3"]=>50, [3, :night_total]=>90, [3, :kinmu_total]=>220.0}.to_a.sort
#,:kinmu_total =>18,:night_total =>8}
    margin0= {[3,"2"]=>19,[4,"2"]=>19,[9,"2"]=>16,[10,"2"]=>26 }.to_a.sort
    require0={[3,"2"]=>31,[4,"2"]=>62,[9,"2"]=>31,[10,"2"]=>31 }.to_a.sort
    used   = {[3,"2"]=> 6,[4,"2"]=>10,[9,"2"]=> 5,[10,"2"]=> 5 }.to_a.sort
    remain = {[3,"2"]=>44,[4,"2"]=>76,[9,"2"]=>42,[10,"2"]=>52 }.to_a.sort
    margin = {[3,"2"]=>16,[4,"2"]=>29,[9,"2"]=>14,[10,"2"]=>23 }.to_a.sort
    require= {[3,"2"]=>25,[4,"2"]=>52,[9,"2"]=>26,[10,"2"]=>26 }.to_a.sort
    # 31-4 -3=24    62-8-6=48         31-7=24  31-9=22
    newmonth(5)
    shift = "2"
    assert_equal remain0  ,
      @assign.role_remain.to_a.sort #.select{|k,v| k[1]==shift}.sort,"開始前利用可能ロール総数"
    assert_equal require0 ,
      @assign. roles_required.select{|k,v| k[1]==shift}.sort,"開始前必要ロール数"
    assert_equal margin0,
      @assign.margin_of_role.select{|k,v| k[1]==shift}.sort,  "開始前余裕ロール数"
      # @nurces.each{|nurce| puts nurce.shifts+nurce.role_used[[1,3]].to_s }
    nurces = extract_set_shifts(Log5_5)
    # @nurces.each{|nurce| puts nurce.shifts+nurce.role_used[[1,3]].to_s }
    # @assign.role_used true
    # assert_equal used  ,
    #  @assign.role_used.select{|k,v| k[1]==shift}.sort,
    #  "使用ロール総数"
    
    # assert_equal remain,
    #  @assign.role_remain.select{|k,v| k[1]==shift}.sort,
    #  "残りrole総数"

    tight = [3,9,10]
    assert_equal tight,@assign.tight_roles(shift).sort,"逼迫ロール"
    assert_equal [{"3"=>5, "2"=>3, "1"=>20.0, "0"=>7.0,:kinmu_total =>20,:night_total =>7},
                  {"3"=>4, "2"=>5, "1"=>20.0, "0"=>8.0,:kinmu_total =>21,:night_total =>8}],
        [38,39].map{|id| nurces[id].shift_remain},   "看護師の残りシフト全体像"
    assert_equal [5,5,5,4,1],
     [50,47,49,48,36].map{|id| nurces[id].shift_remain[shift]},  "看護師のshift#{shift}残数"
    assert_equal [[3, 4,10], [3, 4,10], [3, 4,10], [3, 4,10], [4,10]],  
      [50,47,49,48,36].map{|id| nurces[id].need_role_ids}, "看護師の role"
    assert_equal [5,5,5,4] .map{|r| Cost[5][r]},
    [50,47,49,48].map{|id| nurces[id].cost(shift,tight).to_i }, "看護師のcost"
    assert_equal Cost[1][1],nurces[36].cost(shift,tight).to_i , "看護師 36のcost"
                    #nurces[38].
                    #  nurces[39].
  end

  must " shortのてすと 2/1 の、1,2,3,:night" do
    @assign.nurces = extract_set_shifts(Log2_3)
    assert_equal [false,true,false,true] ,["1","2","3",:night_total].map{ |sft_str| @assign.short?(1,sft_str)}
    assert_equal [false,false,false,false] ,["1","2","3",:night_total].map{ |sft_str| @assign.short?(3,sft_str)}
  end
   #######

end
