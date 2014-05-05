# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::NurceCombinationTest < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes,:hospital_defines
  # Replace this with your real tests.

  Log2_4 = 
"
  HP ASSIGN 34 _220330_______________________
  HP ASSIGN 35 _220330______________________ 4 9
  HP ASSIGN 36 _220330______________________ 4 10
  HP ASSIGN 37 _____________________________ 4 9
  HP ASSIGN 38 _2___________________________ 3 4 9
  HP ASSIGN 39 _3___________________________ 3 4 9
  HP ASSIGN 40 _22__________________________ 3 4 9
  HP ASSIGN 41 ___33________________________ 3 4 9
  HP ASSIGN 42 _____2203____________________ 4 9 10
  HP ASSIGN 43 _____2203____________________ 4 9 10
  HP ASSIGN 44 _____3302____________________ 4 9 10
  HP ASSIGN 45 _22033_______________________ 4 9 10
  HP ASSIGN 46 _22033022____________________ 4   10
  HP ASSIGN 47 _22033022____________________ 3 4   10
  HP ASSIGN 48 _2203303303__________________ 3 4   10
  HP ASSIGN 49 _2203302203__________________ 3 4   10
  HP ASSIGN 50 _220330220330________________ 4 10
  HP ASSIGN 51 _220330220330________________ 4 10
  HP ASSIGN 52 __300____0_0___________0_____ 4 10
"
  def setup
    @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign = Hospital::Assign.new(@busho_id,@month)
    @nurces = extract_set_shifts(Log2_4)
    @assign.refresh
  end

  def nurce_by_id(id,nurces)
    nurces.select{ |n| n.id == id}[0]
  end

  def extract_set_shifts(string)
    nurces=[]
    string.each_line{|line|
      hp,assign,id,data,dmy = line.split(nil,5)
      case id
      when /^\d+$/
        nurces[id.to_i]=@assign.nurce_by_id(id.to_i)
       @assign.nurce_set_patern(nurces[id.to_i],1,data[1..-1].chop)
      when  /ENTRY/
      end
    }
    nurces.compact
  end




  day = 20

  must "2/20の夜勤割り当ての組み合わせ候補" do
    #            [37, 41, 44, 46, 52, 39, 42, 48, 38, 40, 43, 47]
  #  assert_equal 12 * 11 * 10 * 9 / (2*3*4),  # = 495 [37, 38, 39, 52, 40, 41, 44, 43, 42, 46, 47, 48],
  #  @assign.candidate_combination_for_night(day).map{ |comb| comb.map(&:id)}.size
  end

  must "2/20の夜勤割り当ての組み合わせ候補・costで選別" do
    #            [37, 41, 44, 46, 52, 39, 42, 48, 38, 40, 43, 47]
    assert_equal [[37, 38, 39, 52],
                  [37, 38, 39, 40],
                  [37, 38, 39, 41],
                  [37, 39, 52, 40],
                  [37, 38, 52, 40],
                  [37, 38, 52, 41],
                  [37, 39, 52, 41],
                  [37, 39, 40, 41]],
    @assign.candidate_combination_for_night_selected_by_cost(day).map{ |comb| comb.map(&:id)}
  end

  must "2/20のshift2,3の候補の組み合わせを作る。 数" do
    candidate_combination=@assign.candidate_combination_for_shift23(day)
    assert_equal 4*3/2 * 8 , # = 48
      candidate_combination.size
  end

  must "2/20のshift2,3の候補の組み合わせを作る。 shift2,3のコストで選ぶ" do
    candidate_combination=@assign.candidate_combination_for_shift23_selected_by_cost(day)
    assert_equal 4*3/2 * 8 , # = 48
      candidate_combination.map{  |nurces_shift2,nurces_shift3| 
      [nurces_shift2.map(&:id),nurces_shift3.map(&:id)]
    }
  end

 must "2233のとき全夜勤でのコスト" do
    @month  = Date.new(2014,3,1)
    @nurce = Hospital::Nurce.find 38 # 3,4,9
    @nurce.monthly(@month)
    @nurce.shifts = "02233___________________________"
    assert_equal 1813,@nurce.cost(:night_total,[3,4,9])
    assert_equal 1648,@nurce.cost(:night_total,[3,4,10])
  end
  must "2233のとき全勤務でのコスト" do
    @month  = Date.new(2014,3,1)
    @nurce = Hospital::Nurce.find 38 # 3,4,9
    @nurce.monthly(@month)
    @nurce.shifts = "02233___________________________"
    assert_equal 59,@nurce.cost(:kinmu_total,[3,4,9])
    assert_equal 54,@nurce.cost(:kinmu_total,[3,4,10])
  end
  must "月データ読み込み" do
    nurce = nurce_by_id(52,@assign.nurces)
    assert_equal "__300____0_0___________0_____",nurce.shifts
  end

  must "nurce 34 は？？？" do
    nurce = nurce_by_id(34,@assign.nurces)
    assert_equal "_220330______________________",nurce.shifts ,"shifts"
    @assign.refresh
    nurce = nurce_by_id(34,@assign.nurces)
    #assert_equal "",nurce.shifts.gsub(/[^1478]/,"")
    #assert_equal "",nurce.shifts.gsub(/[^9ABC]/,"")
    assert_equal "_220330______________________",nurce.shifts ,"shifts"
  end
 
  must "シフト1使用・残り" do
    assert_equal [0]*19,@nurces.map{ |nurce| nurce.shift_used["1"] },"shift_used"
    assert_equal [20]*19,@nurces.map{ |nurce| nurce.shift_remain(true)["1"] },"shift_remain"
  end
  must "シフト2使用・残り" do
    assert_equal [0,0,0,5,4,5,3,5,3,3,4,3,1,1,3,1,1,1,5],@nurces.map{ |nurce| nurce.shift_remain(true)["2"] }
  end
  must "シフト3使用・残り" do
    assert_equal [0,0,0,5,5,4,5,3,4,4,3,3,3,3,0,2,1,1,4],@nurces.map{ |nurce| nurce.shift_remain(true)["3"] }
  end
  must "シフト:night_total使用・残り" do
    assert_equal [0,0,0,9,8,8,7,7,6,6,6,5,3,3,2,2,1,1,8],@nurces.map{ |nurce| nurce.shift_remain(true)[:night_total] }
  end
          
  must "シフト:kinmu_total使用・残り" do
    assert_equal [18,18,18,22,21,21,20,20,19,19,19,18,16,16,15,15,14,14,21],
    @nurces.map{ |nurce| nurce.shift_remain(true)[:kinmu_total] }
  end


  sft_str = "2"
  must "2/20のshift2の割り当て可能看護師" do
  sft_str = "2"
    assert_equal [37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52],
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  must "2/20のshift3の割り当て可能看護師" do
  sft_str = "3"
puts 3
    assert_equal [37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 49, 50, 51, 52],
    @assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  #  4      34
  # 34
  #  49     35  37
  # 349         41    39 38 40
  #  4910       44    42 43 45
  #  410    36  46 52        51 50
  # 3410              48 49 47
  # 
  # 
  must "2/20のshift2の割り当て可能看護師gather_by" do
  sft_str = "2"
    assert_equal [37, 41, 44, 46, 52, 39, 42, 48, 38, 43, 50, 40, 45, 49, 51, 47],
    @assign.gather_by_each_group_of_role(@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)),
                                         sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end
  must "2/20のshift3の割り当て可能看護師gather_by" do
  sft_str = "3"
    assert_equal [37, 38, 42, 46, 52, 40, 43, 47, 39, 44, 49, 41, 45, 51, 50],
    @assign.gather_by_each_group_of_role(@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)),
                                         sft_str,@assign.short_role(day,sft_str)).map(&:id)
  end

  must "2/20のshift2の割り当て可能看護師 数制限" do
  sft_str = "2"
    assert_equal [37, 41, 44, 46, 52, 39, 42, 48],
    @assign.assinable_nurces_by_cost_size_limited(@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)),
                                                  sft_str,day,
                                                  @assign.short_role(day,sft_str)).map(&:id)
  end
  sft_str = "3"
  must "2/20のshift3の割り当て可能看護師 数制限" do
  sft_str = "3"
    assert_equal [37, 38, 42, 46, 52, 40, 43, 47],
    @assign.assinable_nurces_by_cost_size_limited(@assign.assinable_nurces(day,sft_str,@assign.short_role(day,sft_str)),
                                                  sft_str,day,
                                                  @assign.short_role(day,sft_str)).map(&:id)
  end

  must "2/20の夜勤割り当て候補" do
    #            [37, 41, 44, 46, 52, 39, 42, 48, 38, 40, 43, 47]
    assert_equal [37, 38, 42, 46, 52, 40, 43, 47, 41, 44, 39, 48].sort,
      @assign.candidate_for_night(day).map(&:id).sort
  end

  must "2/20の夜勤割り当て候補 ソート" do
    #            [37, 41, 44, 46, 52, 39, 42, 48, 38, 40, 43, 47]
    assert_equal [37, 38, 39, 52, 40, 41, 44, 43, 42, 46, 47, 48],
      @assign.candidate_for_night(day).map(&:id)
  end

  must "夜勤の時のタイトロール" do
    assert_equal [3,9,10],@assign.tight_roles(:night_total).sort
  end

end
