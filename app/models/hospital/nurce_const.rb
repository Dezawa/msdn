# -*- coding: utf-8 -*-
module Hospital::Nurce::Const

  Reguration = 
    { 
     true =>  #三交代
       [ #0 全シフト
         {   # item  => [[正規表現,何日前から見るか,何日分見るか]
          :renkin   => [/[1-8]{6,}/,5,11,"連続勤務5日まで"] ### 半日勤務をどうするか未定
          },
         # 1 日勤
          { },
         # 2 準夜
        {
          :yakinrenzoku => [/([25]{2}.[25])/,3,5,"22022は避ける"],
          :nine_nights => [/([2356][^2356]*){10}/,nil,nil, "夜勤は72時間 計9回まで"]
        },
        # 3 深夜
        {
          :yakinrenzoku => [/([36]{2}.[36])/,3,5,"33033,22022は避ける"],
          :nine_nights => [/([2356][^2356]*){10}/,nil,nil, "夜勤は72時間 計9回まで"]
        }
       ],
    false => #二交代
      [ #0 全シフト
       {   # item  => [[正規表現,何日前から見るか,何日分見るか]
         :renkin   => [/[1-8]{6,}/,5,11,"連続勤務5日まで"] ### 半日勤務をどうするか未定
       },
       # 1 日勤
       { },
       # 2 準夜
       {
         :yakinrenzoku => [/([25]{2}.[25])/,3,5,"22022は避ける"],
         :nine_nights => [/([25][^25]*){4}/,nil,nil, "夜勤は72時間 計4回まで"]
       }
      ]
  }
  Wants = { 
    true => #三交代
      [#0
      {},  
      #1
      {
         :interval => [/([25][14])|([14][36])/,1,3,"勤務間隔12時間以上"]
       },
       #2
       {
         :interval => [/([25][14])/,1,3,"勤務間隔12時間以上"],
         :after_nights   => [/[2356]{2}[^0_]/ ,2,5," 夜勤連続の翌日公休"]
       },
       #3
       {
         :interval => [/([14][36])/,1,3,"勤務間隔12時間以上"],
         :after_nights   => [/[2356]{2}[^0_]/ ,2,5," 夜勤連続の翌日公休"]
       }
      ],
    false => #三交代
      [#0
       {},  
       #1
       {
         :interval => [/[25][14]/,1,3,"勤務間隔12時間以上"]
       },
       #2
       {
         :interval => [/([25][14])/,1,3,"勤務間隔12時間以上"],
         :after_nights   => [/[25]{2}[^0_]/ ,2,5," 夜勤連続の翌日公休"]
       }
      ]
  }

  Raguration_keys = { 
    true => 
    (0..3).map{|shift| Reguration[true][shift].keys +  Wants[true][shift].keys },
    false => 
    (0..2).map{|shift| Reguration[false][shift].keys +  Wants[false][shift].keys }
    }

  
  #Reguration = RegurationThroughLastMonth.merge(RegurationThisMonthOnly).merge(WantsThroughLastMonth)
  RegurationNeed = { 
      true => 
    [
     {
       :koukyuu => [/(0[^0]*){7}/, nil,nil,"公休6以上、年休１以上"],
       :renkyuu => [/00/         , nil,nil,"連休がある"]
     },{},{},{}
    ],
      false =>
      []
    }

  LongPatern = { 
    true => {
      3 => [  # patern, reg, back,length,[調べるshift],[ [0の割り当て数見る日],[1の][2の],[3の]]
            #["330110220", /^[^39][0_]_[3_][0_][1_]{2}[0_][2_]{2}[0_]/,2,11,
            # [3,2,1],[[2,5,8],[3,4],[6,7],[1]]
            #],
            #["330110", /^[^39][0_]_[3_][0_][1_]{2}[0_]/,2,8,
            # [3,1],[[2,5],[3,4],[],[1]]
            #],
            ["330"       , /^[^36][0_]_[3_][0_]/,2,5,[3],[[2],[],[],[1]] ],
            ["3"         , /^_/,0,1,[3],[[],[],[],[]]]
           ],
      2 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
            #["220330110" , /^[^28][0_]_[2_][0_][3_]{2}[0_][1_]{2}[0_]/,2,11,
            # [3,2,1],[[2,5,8],[6,7],[1],[3,4]]
            #],
            ["220330"    , /^[^25][0_]_[2_][0_][3_]{2}[0_]/,2,8,
             [3,2],[[2,5],[],[1],[3,4]]
            ],
            ["220"       , /^[^25][0_]_[2_][0_]/,2,5,[2],[[2],[],[1],[]] ],
            ["2"         , /^_/                 ,0,1,[2],[[],[],[],[]]]
           ],
       1 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
             #["110220330" , /^[0_]_[1_][0_][2_]{2}[0_][3_]{2}[0_]/,1,10,
             # [3,2,1],[[2,5,8],[1],[3,4],[6,7]]
             #],
             ["1"         , /^_/                 ,0,1,[1],[[],[],[],[]]]
            ]
       },
     false => { 
       2 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
             #["220330110" , /^[^28][0_]_[2_][0_][3_]{2}[0_][1_]{2}[0_]/,2,11,
             # [3,2,1],[[2,5,8],[6,7],[1],[3,4]]
             #],
             ["220330"    , /^[^25][0_]_[2_][0_][3_]{2}[0_]/,2,8,
              [3,2],[[2,5],[],[1],[3,4]]
             ],
             ["220"       , /^[^25][0_]_[2_][0_]/,2,5,[2],[[2],[],[1],[]] ],
             ["2"         , /^_/                 ,0,1,[2],[[],[],[],[]]]
            ],
        1 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
              #["110220330" , /^[0_]_[1_][0_][2_]{2}[0_][3_]{2}[0_]/,1,10,
              # [3,2,1],[[2,5,8],[1],[3,4],[6,7]]
              #],
              ["1"         , /^_/                 ,0,1,[1],[[],[],[],[]]]
             ]
      }     

  }
  

end
