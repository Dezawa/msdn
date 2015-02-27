# -*- coding: utf-8 -*-
module Hospital
module Const
  HtmlCell # rake test で HtmlText がnot defined にならなくするおまじない
  ItemsDefine =
      [HtmlText.new(  :hospital_name    ,"保険医療機関名"),
       HtmlSelect.new(:hospital_Koutai  ,"交代勤務",  :correction => %w(二交代 三交代)     ),
       HtmlText.new(  :hospital_bed_num ,"病床数"    ,:size =>3 ),
       HtmlText.new(  :kubun            ,"届出区分"  ,:size =>3 , :comment => "対１入院基本料"),
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

  LimitOfNurceCandidateList = 10
  Size_of_NurceCombinationList = 3
  Factor_of_safety_NurceCandidateList = 1.3

  Timeout     = 30 #.minute
  TimeoutMult = 3.minute
  Sleep       = 30
  MultiSolution  = 1        #  3 複数解求める。最初の解も求める。これは save する
  SingleSolution = 1        #  1 解を一つだけ求める
  SecondAndLater = false    #  2 複数求めるが、最初の解は求めない。これは別のルーチンで求める


  Idou =  [["新人",1],["中途",2],["異動",3]]
  Bunrui = Hash[1,'職位',2,'職種',3,'勤務区分',4,'資格']
  Bunrui2Id = Bunrui.invert
  Weekday  = 2
  Weekend = 3
  Daytype = [ ["毎日",1],["平日",Weekday],["土日休",Weekend]]

  AvoidWeight = [ 1.0,  1.3,  1.7,  2.2,  2.9,  3.7,  4.8,   6.3,   8.2, 10.6, 13.8,
                 17.9, 23.3, 30.3, 39.4, 51.2, 66.5, 86.5, 112.5, 146.2, 190.0]


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

end
end
