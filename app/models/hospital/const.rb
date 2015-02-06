# -*- coding: utf-8 -*-
module Hospital
module Const
  HtmlCell # rake test で HtmlText がnot defined にならなくするおまじない
  ItemsDefine =
      [HtmlText.new(  :hospital_name    ,"保険医療機関名"),
       HtmlSelect.new(:hospital_Koutai  ,"交代勤務",  :correction => %w(二交代 三交代)     ),
       HtmlText.new(  :hospital_bed_num ,"病床数"    ,:size =>3  ),
       HtmlText.new(  :kubun            ,"届出区分"      ,:size =>3, 
                      :comment => "対１入院基本料"),
       HtmlSelect.new(:KangoHaichi_addition,"看護配置加算の有無" ,
                      :correction => %w(有 無), :include_blank=> true),
       HtmlSelect.new(:Kyuuseiki_addition  ,"急性期看護補助体制加算の届出区分",
                      :correction => %w(25 50 75),:include_blank=> true),
       HtmlSelect.new(:Yakan_Kyuuseiki_addition,"夜間急性期看護補助体制加算の届出区分",
                      :correction => %w(50 100),:include_blank=> true),
       HtmlSelect.new(:night_addition  ,"看護職員夜間配置加算の有無"  , 
                      :correction => %w(有 無),:include_blank=> true),
       HtmlSelect.new(:KangoHojo_additon   ,"看護補助加算の届出区分",
                      :correction => %w(30 50 75),:include_blank=> true),
       HtmlText.new(  :weekly_hour,"常勤職員の週所定労働時間",:size => 3)
      ]
  ItemsDefine2 =
      [[HtmlText.new(:patient_num        ,"届出時入院患者数"  ,:size =>3,:align => :right)],
       [HtmlText.new(:average_patient    ,"１日平均入院患者数",:size =>3,:align => :right)],
       [HtmlText.new(:patient_start_year ,"算出期間 年"       ,:size =>3,:align => :right),
        HtmlText.new(:patient_start_month,"月～"              ,:size =>1,:align => :right),
        HtmlText.new(:patient_stop_year  ,"年"                ,:size =>3,:align => :right),
        HtmlText.new(:patient_stop_month ,"月"                ,:size =>1,:align => :right)],
       [HtmlText.new(:average_Nyuuin     ,"平均在院日数"      ,:size =>3,:align => :right)],
       [HtmlText.new(:Nyuuin_start_year  ,"算出期間 年"       ,:size =>3,:align => :right),
        HtmlText.new(:Nyuuin_start_month ,"月～"              ,:size =>1,:align => :right),
        HtmlText.new(:Nyuuin_stop_year   ,"年"                ,:size =>3,:align => :right),
        HtmlText.new(:Nyuuin_stop_month  ,"月"                ,:size =>1,:align => :right)]
    ]
  ItemsDefineAll =  (ItemsDefine + ItemsDefine2).flatten


  LimitOfNurceCandidateList = 6
  Size_of_NurceCombinationList = 3
  Factor_of_safety_NurceCandidateList = 1.1

  MultiSolution  = 2        #  3 複数解求める。最初の解も求める。これは save する
  SingleSolution = 3        #  1 解を一つだけ求める
  SecondAndLater = false    #  2 複数求めるが、最初の解は求めない。これは別のルーチンで求める


  Idou =  [["新人",1],["中途",2],["異動",3]]
  Bunrui = Hash[1,'職位',2,'職種',3,'勤務区分',4,'資格']
  Bunrui2Id = Bunrui.invert
  Weekday  = 2
  Weekend = 3
  Daytype = [ ["毎日",1],["平日",Weekday],["土日休",Weekend]]

  AvoidWeight = [ 1.0,  1.3,  1.7,  2.2,  2.9,  3.7,  4.8,   6.3,   8.2, 10.6, 13.8,
                 17.9, 23.3, 30.3, 39.4, 51.2, 66.5, 86.5, 112.5, 146.2, 190.0]

  Timeout     = 2.minute
  TimeoutMult = 3.minute
  Sleep       = 30

  Shift0 ,Shift1 ,Shift2 ,Shift3  = Shift0123 = [0,1,2,3]
  Sshift0,Sshift1,Sshift2,Sshift3 = Sshift0123 = %w(0 1 2 3)
  Sshift123  = %w(1 2 3)
  ShiftName  = Hash[ Sshift1,"日勤", Sshift2, "準夜" ,Sshift3 ,"深夜",
                     :kinmu_total , "勤務計",:night_total,"夜勤計"] 

  if ENV['RAILS_ENV'] == 'test'
    Kangoshi,Leader = [4,3]
     MarginLimit   = Hash.new{ |h,k| h[k] = 11}               # 夜、全 の余裕が
    MarginLimit.merge!(Hash[ [Kangoshi,:night_total],5 ,   #[10,10]できる
                             [Kangoshi,:kinmu_total],5 ,   #[8,10] も、まあまあ 28"
                             [Leader  ,:night_total],5 ,    #[7,10] きついNG 
                             [Leader  ,Sshift2]      ,1 ,    #[7,13] 18",[7,12] 22" [7,11] 80"
                             [Leader  ,Sshift3]      ,1      
                           ] )        #  要員数警告
 else
    Kangoshi,Leader = %w(看護師 リーダー).map{ |name| Hospital::Role.find_by_name(name).id}
    MarginLimit   = Hash.new{ |h,k| h[k] = 20}               # 夜、全 の余裕が
    MarginLimit.merge!(Hash[ [Kangoshi,:night_total],15  ,   #[10,10]できる
                             [Kangoshi,:kinmu_total],30  ,   #[8,10] も、まあまあ 28"
                             [Kangoshi,Sshift2],15  ,   #[8,10] も、まあまあ 28"
                             [Leader  ,:night_total] ,10  ,    #[7,10] きついNG 
                             [Leader  ,Sshift2]      ,10,    #[7,13] 18",[7,12] 22" [7,11] 80"
                             [Leader  ,Sshift3]      ,10     
                           ] )        #  要員数警告
  end
  
  #end

  # 全勤務余裕      10    11  12  13 |    10 25 35  45  67   77  527人日
  # 夜勤余裕    10  NG    86         | 57                    31
  #              9  48    18  18     | 50    NG 33  31  31   31
  #              8  NG,28            | 47                    32
  #              7  NG    80  22  18 | 46                    NG
  #              6  NG               | 44                   160 
  #          124人日                  217人日

  Cost = 
    [
     [], # 残り少なくなると急激にコストが上がる。タイトなroleを持つほどコストが上がる。
        # iランクタイト ＞ 残り1少、2ランクタイト＞残り１少、3ランクタイト<残り１少
        #(0..6).map{|j| ((0..19).map{|i| (1.3**i * 1.1**j*20).to_i}<<nil).reverse}
     [ nil,2923, 2249, 1730, 1330, 1023, 787, 605, 465, 358, 275, 212, 163, 125, 96, 74, 57, 43, 33, 26, 20], 
     [ nil,3216, 2474, 1903, 1463, 1126, 866, 666, 512, 394, 303, 233, 179, 138, 106, 81, 62, 48, 37, 28, 22], 
     [ nil,3537, 2721, 2093, 1610, 1238, 952, 732, 563, 433, 333, 256, 197, 151, 116, 89, 69, 53, 40, 31, 24], 
     [ nil,3891, 2993, 2302, 1771, 1362, 1048, 806, 620, 477, 366, 282, 217, 167, 128, 98, 76, 58, 44, 34, 26], 
     [ nil,4280, 3292, 2533, 1948, 1498, 1152, 886, 682, 524, 403, 310, 238, 183, 141, 108, 83, 64, 49, 38, 29],
     [ nil,4708, 3622, 2786, 2143, 1648, 1268, 975, 750, 577, 444, 341, 262, 202, 155, 119, 91, 70, 54, 41, 32], 
     [ nil,5179, 3984, 3064, 2357, 1813, 1395, 1073, 825, 634, 488, 375, 289, 222, 171, 131, 101, 77, 59, 46, 35]
    ]
     #[nil, 3216, 2474, 1903, 1463, 1126, 866, 666, 512, 394, 303, 233, 179, 138, 106, 81, 62, 48, 37, 28, 22], 
     #[nil, 3537, 2721, 2093, 1610, 1238, 952, 732, 563, 433, 333, 256, 197, 151, 116, 89, 69, 53, 40, 31, 24],
     #[nil, 3891, 2993, 2302, 1771, 1362, 1048, 806, 620, 477, 366, 282, 217, 167, 128, 98, 76, 58, 44, 34, 26], 
     #[nil, 4280, 3292, 2533, 1948, 1498, 1152, 886, 682, 524, 403, 310, 238, 183, 141, 108, 83, 64, 49, 38, 29], 
     #[nil, 4708, 3622, 2786, 2143, 1648, 1268, 975, 750, 577, 444, 341, 262, 202, 155, 119, 91, 70, 54, 41, 32], 
     #[nil, 5179, 3984, 3064, 2357, 1813, 1395, 1073, 825, 634, 488, 375, 289, 222, 171, 131, 101, 77, 59, 46, 35],
     #[nil, 5697, 4382, 3371, 2593, 1994, 1534, 1180, 908, 698, 537, 413, 317, 244, 188, 144, 111, 85, 65, 50, 38]
    #
     #
end
end
