# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

class Hospital::NurceCostTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes","hospital/defines"
  # Replace this with your real tests.
  def setup
    srand(1)
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @nurces = extract_set_shifts(Log2_4)
   end

 must "2233のとき全夜勤でのコスト" do
    @month  = Date.new(2014,3,1)
    @nurce = Hospital::Nurce.find 38 # 3,4,9
    @nurce.monthly(@month)
    @nurce.shifts = "02233___________________________"
    assert_equal 1813,@nurce.cost(:night_total,[3,4,9]).to_i
    assert_equal 1648,@nurce.cost(:night_total,[3,4,10]).to_i
  end

  must "2233のとき全勤務でのコスト" do
    @month  = Date.new(2014,3,1)
    @nurce = Hospital::Nurce.find 38 # 3,4,9
    @nurce.monthly(@month)
    @nurce.shifts = "02233___________________________"
    assert_equal 59,@nurce.cost(:kinmu_total,[3,4,9]).to_i
    assert_equal 54,@nurce.cost(:kinmu_total,[3,4,10]).to_i
  end
tight =  [10, 3, 9]
sft_str = :night_total
  must ":night_totalのタイトロールが [10, 3, 9] であるときの看護師の(tight & role_ids).sort" do
    assert_equal [[], [9], [10], [9], [3, 9], [3, 9], [3, 9], [3, 9],
                  [10, 9], [10, 9], [10, 9], [10, 9], [10], [10, 3],
                  [10, 3], [10, 3], [10, 3], [10, 3], [10, 3]
                 ], @nurces.map{ |n| tight & n.role_ids }
  end

  must "看護師の夜勤 limit" do
    assert_equal [4, 4, 4, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9
                 ] ,@nurces.map{ |n| n.limit.night_total }
  end

  must "看護師のID と夜勤数" do
    assert_equal (34..52).to_a,@nurces.map(&:id)
    assert_equal [4, 4, 4, 0, 1, 1, 2, 2, 3, 3, 3, 4, 6, 6, 7, 7, 8, 8, 1
                 ] ,@nurces.map{ |n| n.shifts.gsub(/[^23]/,"").size }
  end

  must "看護師の準夜勤 勤務数" do
      assert_equal [2, 2, 2, 0, 1, 0, 2, 0, 2, 2, 1, 2, 4, 4, 2, 4, 4, 4, 0
                   ] ,@nurces.map{ |n| n.shifts.gsub(/[^2]/,"").size }
  end

  must "看護師のi深夜勤 勤務数" do
      assert_equal [2, 2, 2, 0, 0, 1, 0, 2, 1, 1, 2, 2, 2, 2, 5, 3, 4, 4, 1
                   ] ,@nurces.map{ |n| n.shifts.gsub(/[^3]/,"").size }
  end

  must "shift_str = 2 のrole残" do
    sft_str = "2"
    assert_equal [0, 0, 0, 5, 4, 5, 3, 5, 3, 3, 4, 3, 1, 1, 3, 1, 1, 1, 5
                 ],@nurces.map{ |nurce| nurce.shift_remain(true)[sft_str]  }
  end
  must "shift_str = 3 のrole残" do
    sft_str = "3"
    assert_equal [0, 0, 0, 5, 5, 4, 5, 3, 4, 4, 3, 3, 3, 3, 0, 2, 1, 1, 4
                 ],@nurces.map{ |nurce| nurce.shift_remain(true)[sft_str]  }
  end

  must ":night_totalのタイトロールが [10, 3, 9] であるときの看護師のshift_remain[2]" do
    assert_equal [0, 0, 0, 5, 4, 5, 3, 5, 3, 3, 4, 3, 1, 1, 3, 1, 1, 1, 5
                 ] ,@nurces.map{ |n| n.shift_remain(true)["2"] }
  end

  must ":night_totalのタイトロールが [10, 3, 9] であるときの看護師のshift_remain[3]" do
    assert_equal [0, 0, 0, 5, 5, 4, 5, 3, 4, 4, 3, 3, 3, 3, 0, 2, 1, 1, 4
                 ] ,@nurces.map{ |n| n.shift_remain(true)["3"] }
  end


  must ":night_totalのタイトロールが [10, 3, 9] であるときの看護師のshift_remain[sft_str]]" do
    assert_equal [0, 0, 0, 9, 8, 8, 7, 7, 6, 6, 6, 5, 3, 3, 2, 2, 1, 1, 8
                 ] ,@nurces.map{ |n| n.shift_remain(true)[sft_str] }
  end

  must ":night_totalのタイトロールが [10, 3, 9] であるときの看護師のcost" do
    @nurces.map{ |n| n.shift_remain(true)[sft_str] }
    # sft_remain [0, 0,  0,  9,  8,    8,    7,    7,    6,    6,    6,     5,   3,  3,    2,    2,    1,    1,    8]
    # role_ids   [[],[9],[A],[9],[3,9],[3,9],[3,9],[3,9],[A,9],[A,9],[A,9],[A,9],[A],[A,3],[A,3],[A,3],[A,3],[A,3],[A,3]
    assert_equal [0, 0,  0, 358, 620, 620,  806,  806, 1152, 1152, 1152, 1498,  2093,2786, 3622, 3622, 4708, 4708, 750],
     @nurces.map{|n| n.cost(:night_total,[10,3,9]).to_i }
  end
  must ":night_totalのタイトロールが [10, 3, 9] であるときの看護師のcost順" do
    @nurces.map{ |n| n.shift_remain(true)[sft_str] }
    #   34  35  36  37  38   39     40    41    42     43     44    45    46   47   48    49    50       51    52  
    # [0.4,0.0,0.1,358,620.2,620.3, 806.4,806.5,1152.4,1152.7,1152.2,1498,2093,2786,3622,3622,4708.1, 4708.2, 750.8
   assert_equal [35, 36,34, 37, 38, 39, 52, 40, 41, 44, 42, 43, 45, 46, 47, 48, 49, 50, 51],
     @nurces.sort_by{|n| n.cost(:night_total,[10,3,9]) }.map(&:id)
  end
  must "shift 2のタイトロールが [10, 3, 9] であるときの看護師のcost" do
    @nurces.map{ |n| n.shift_remain(true)["2"] }
    #                        1    5     2    7      2     8     8     6    8     11  12   10     12    12    12    4
    # role_ids   [[],[9],[A],[9],[3,9],[3,9],[3,9],[3,9],[A,9],[A,9],[A,9],[A,9],[A],[A,3],[A,3],[A,3],[A,3],[A,3],[A,3]
    assert_equal [0 ,0  ,0  ,1023,1771,1362 ,2302 ,1362 ,2533 ,2533 ,1948 ,2533 ,3537,4708,2786 ,4708 ,4708 ,4708,1648],
     @nurces.map{|n| n.cost("2",[10,3,9]).to_i }
  end
  must "shift 3のタイトロールが [3, 10, 9] であるときの看護師のcost" do
    @nurces.map{ |n| n.shift_remain(true)["3"] }
    #                  1    2    4     2   9    5    5   10    10    7   12      13   14   14   8
    # role_ids   [[],[9],[A],[9],[3,9],[3,9],[3,9],[3,9],[A,9],[A,9],[A,9],[A,9],[A],[A,3],[A,3],[A,3],[A,3],[A,3],[A,3]
    assert_equal [0,0,0,1023,1362,1771,1362,2302,1948,1948,2533,2533,2093,2786,0,3622,4708,4708,2143],
     @nurces.map{|n| n.cost("3",[10,3,9]).to_i }
  end
end
