# -*- coding: utf-8 -*-
module Hospital
module Const
  
  MultiSolution  = 2        #  3 複数解求める。最初の解も求める。これは save する
  SingleSolution = 3        #  1 解を一つだけ求める
  SecondAndLater = false    #  2 複数求めるが、最初の解は求めない。これは別のルーチンで求める


  Idou =  [["新人",1],["中途",2],["異動",3]]

  Daytype = [ ["毎日",1],["平日",2],["土日休",3]]

  AvoidWeight = [ 1.0,  1.3,  1.7,  2.2,  2.9,  3.7,  4.8,   6.3,   8.2, 10.6, 13.8,
                 17.9, 23.3, 30.3, 39.4, 51.2, 66.5, 86.5, 112.5, 146.2, 190.0]

  Timeout     = 1.minute
  TimeoutMult = 3.minute
  Sleep       = 30

  Shift0 ,Shift1 ,Shift2 ,Shift3  = Shift0123 = [0,1,2,3]
  Sshift0,Sshift1,Sshift2,Sshift3 = Sshift0123 = %w(0 1 2 3)
  Sshift123  = %w(1 2 3)
  ShiftName  = Hash[ Sshift1,"日勤", Sshift2, "準夜" ,Sshift3 ,"深夜",
                     "kinmu_total" , "勤務計","night_total","夜勤計"] 

  Kangoshi,Leader = %w(看護師 リーダー).map{ |name| Hospital::Role.find_by_name(name).id}
  MarginLimit   = Hash.new{ |h,k| h[k] = 11}               # 夜、全 の余裕が
  MarginLimit.merge!(Hash[ [Kangoshi,"night_total"],500 ,   #[10,10]できる
                           [Kangoshi,"kinmu_total"],500 ,   #[8,10] も、まあまあ 28"
                           [Leader  ,"night_total"],500 ,    #[7,10] きついNG 
                           [Leader  ,Sshift2]      ,1 ,    #[7,13] 18",[7,12] 22" [7,11] 80"
                           [Leader  ,Sshift3]      ,1      
                         ] )        #  要員数警告

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
