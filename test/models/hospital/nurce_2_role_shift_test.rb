# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

#################
class Hospital::NurceRoleShiftTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
    srand(1)
  end

  #### シフト残のテスト #########
  InitShift = {"3"=>5, "2"=>5, "1"=>20.0, "0"=>8.0, :kinmu_total => 22, :night_total=>9}
  # 全勤務22日、全夜勤9日 、準夜深夜5日、休み8日の人に
  # 日勤、半日勤、準夜、深夜、休暇をアサインしたときの shift残数
  Day = {"3"=>5, "2"=>5, "1"=>19.0, "0"=>8.0, :kinmu_total => 21, :night_total=>9}
  HDy = {"3"=>5, "2"=>5, "1"=>19.5, "0"=>7.5, :kinmu_total => 21.5, :night_total=>9}
  Jun = {"3"=>5, "2"=>4, "1"=>20.0, "0"=>8.0, :kinmu_total => 21, :night_total=>8}
  Sin = {"3"=>4, "2"=>5, "1"=>20.0, "0"=>8.0, :kinmu_total => 21, :night_total=>8}
  All = {"3"=>5, "2"=>5, "1"=>20.0, "0"=>8.0, :kinmu_total => 22, :night_total=>9}
  Holyday = {"3"=>5, "2"=>5, "1"=>20.0, "0"=>7.0, :kinmu_total => 22, :night_total=>9}
  
  # 勤務コード 1,2,.... をアサインしたときに、shift残数は幾つになるか
  ([
    Day,Jun,Sin,Jun,Sin, #1,2,3,L2,L3
    Day,Day,Day,Day,Day, # 会,会,早,遅出,遅出
    HDy,HDy,Day,Day,Day, # Z,G,R1,Z/R,R/G
    Jun,Sin,Day,Jun,Sin, # R2,R3,H1,H2,H3
    Day,Jun,Sin,Day,     # イ1,イ2,イ3,1/セ
    Day,Day,Day,HDy,HDy, # 出,出/1,1/出,出/G,Z/出
    Day,Day,Day,         # 4,会,会
    Jun,Day,HDy,HDy,     # 管,早,Z,G
    Day,Day,Day,Day,     # R1,Z/R,R/G,J1
    Day,Day,Day,HDy,HDy, # 出,出/1,1/出,出/G,Z/出
    Day,Day,Day,Day,Day, # P4,4.5,5,6,7     
    Day,Day,Day,Jun,Sin, # セ,P/セ,1,L2,L3
    All,All,All,Day,Day, # 拘束3,Z/R,R/G
    Day,All,All,All,     # 4,拘束3
    Day,Day,Holyday,Day,Day,Day] +   # Z/R, R/G 公 遅早外
   [Holyday]*10         # 71〜80
  ).each_with_index{|ret,code|
    must "勤務code #{code+1}をアサインするとshift残は" do
      nurce41 = nurce(41)
      assert_equal InitShift,nurce41.shift_remain,"アサイン前のrole残"
        set_code(nurce41,:day10,code+1); 
        assert_equal ret,nurce41.shift_remain(true),
      "code #{code+1} shift #{nurce41.shifts[10,1]} は#{ret.to_a.map{ |s_r| '%s=>%d'%s_r}.join(',')}"
    end
  }

  ########## role_shift :: アサインされた ロールの記録
  #  [[3,"1"],[4,"1"],[9,"1"]]  role 3,4,9 を持つ人に"1" をアサインしたとき
  DayR = [[3,"1"],[4,"1"],[9,"1"]] 
  JunR = [[3,"2"],[4,"2"],[9,"2"]]
  SinR = [[3,"3"],[4,"3"],[9,"3"]]
  HDyZ = [[3,"9"],[4,"9"],[9,"9"]]
  HDyG = [[3,"A"],[4,"A"],[9,"A"]]
  NonR = [[3,"3"],[4,"3"],[9,"3"]]
  DayZ = [[3,"8"],[4,"8"],[9,"8"]]
  DayG = [[3,"7"],[4,"7"],[9,"7"]]
  JunN = [[3,"5"],[4,"5"],[9,"5"]]
  SinN = [[3,"6"],[4,"6"],[9,"6"]]
  DayN = [[3,"4"],[4,"4"],[9,"4"]]
  HRdZ = [[3,"C"],[4,"C"],[9,"C"]]
  HRdG = [[3,"B"],[4,"B"],[9,"B"]]
  HDyR = [[3,"B"],[4,"B"],[9, "B"]] # 半日系は病院に聞いてから
  NonR = [[3,"F"],[4,"F"],[9, "F"]]
  HolyR= [[3,"0"],[4,"0"],[9, "0"]]
  ([DayR,JunR,SinR,JunR,SinR, #1,3,3,L3,L3  1-5
    DayR,DayR,DayR,DayR,DayR, #6-10 会,会,早,遅出,遅出
    HDyZ,HDyG,DayN,DayZ,DayG, #11-15 Z,G,R1,Z/R,R/G
    JunN,SinN,DayN,JunN,SinN, #16-20 R2,R3,H1,H2,H3
    DayN,JunN,SinN,DayN,DayN, #21-25 イ1,イ2,イ3,1/セ,出,
    DayZ,DayG,HRdZ,HDyR,      #26-29 出/1,1/出,出/G,Z/出
    DayR,DayR,DayR,           #30-32 4,会,会
    JunN,DayR,HDyZ,HDyG,      #33-36 管,早,Z,G
    DayN,DayZ,DayG,DayN,      #37-40 R1,Z/R,R/G,J1
    DayN,DayZ,DayG,HRdZ,HRdG, #41-45 出,出/1,1/出,出/G,Z/出
    DayR,DayR,DayR,DayR,DayR, #46-50 P4,4.5,5,6,7     
    DayR,DayR,DayR,JunR,SinR, #51-55 セ,P/セ,1,L2,L3
    NonR,NonR,NonR,DayN,DayN, #56-60 拘束3,Z/R,R/G
    DayR,NonR,NonR,NonR,      #61-64 4,拘束3
    DayN,DayN,HolyR,DayR,DayR,DayR]+ #65-70 Z/R, R/G 公 遅早外
    [HolyR]*10             # 71〜80    
  ).each_with_index{|ret,code|
    must "勤務code #{code+1}を入れるとrole_shiftは" do
      # nurce(41)藤原トキエ shokui nil,shokushu 4, kinmukubun 7,role 9
      nurce41 = nurce(41)
      set_code(nurce41,:day10,code+1); 
      assert_equal ret,nurce41.role_shift(@month,true)[10].sort, #month月10日の
      "code #{code+1}  shift #{nurce41.shifts[10,1]} は#{ret.join(',')}"
    end
  }

end
