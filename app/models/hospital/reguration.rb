# -*- coding: utf-8 -*-
module Hospital
  module Reguration
  include Hospital::Const


  Reguration =         # item  => [[正規表現,何日前から見るか,何日分見るか]
    {                  #item  => [[正規表現,nil,max]  その月全体を調べる
     true =>  #三交代  #              正規表現を削除した 残りが max 以下かどうか
       [ #0 全シフト   #
         {   # 
          :renkin   => [/[1-8LM]{6,}/,5,11,"連続勤務5日まで"] , ### 半日勤務をどうするか未定
          :after_nights =>  [/[2L3M56]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
          },
         # 1 日勤
          { },
         # 2 準夜
        {
          :yakinrenzoku => [/([2L5]{2}.[2L5])/,3,5,"22022は避ける"],
         },
        # 3 深夜
        {
          :yakinrenzoku => [/([36]{2}.[36])/,3,5,"33033,22022は避ける"],
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
         :nine_nights => [/[^25]/,nil,4, "夜勤は72時間 計4回まで"] 
      }
      ]
  }
  Wants = { 
    true => #三交代
      [#0
      {},  
      #1
      {
         :interval => [/([2L5][14])|([14][3M6])/,1,3,"勤務間隔12時間以上"]
       },
       #2
       {
         :interval => [/([2L5][14])/,1,3,"勤務間隔12時間以上"]
       },
       #3
       {
         :interval => [/([14][3M6])/,1,3,"勤務間隔12時間以上"]
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


  def set_check_reg 
    
    @Reguration = 
      [
       { :kinmu_total => [/[^1-8LM]/,nil,limit.kinmu_total, "勤務は22日まで"]
       },{
       }, {
         :junya => [/[^25L]/,nil,limits.code2,"順夜が#{limit.code2}を越えた"],
         :nine_nights => [/[^2356LM]/,nil,limit.night_total, "夜勤は72時間 計9回まで"]
       },{ 
         :shinya =>[/[^3M6]/,nil,limits.code3,"深夜が#{limit.code3}を越えた"] ,
         :nine_nights => [/[^2356LM]/,nil,limit.night_total, "夜勤は72時間 計9回まで"]
       }
      ]
    @Wants = [{},{},{},{}] 
    @Reguration_keys = (Shift0..Shift3).map{|shift| @Reguration[shift].keys + @Wants[shift].keys }
    [@Reguration ,    @Wants ,  @Reguration_keys] # retern for TDD
  end

  def check_reg
    return @check_reg if @check_reg
    @check_reg = [{},{},{},{}] 
   @check_reg.each_with_index{ |reguration,idx|
      reguration.merge!(@Reguration[idx]).merge!(@Wants[idx]).
      merge!(Reguration[ Hospital::Define.koutai3?][idx]).
      merge!(Wants[ Hospital::Define.koutai3?][idx])
    }
# [@Reguration ,@Wants,Reguration[ Hospital::Define.koutai3?],Wants[ Hospital::Define.koutai3?] ]
  end

  Raguration_keys = { 
    true => 
    (Shift0..Shift3).map{|shift| Reguration[true][shift].keys +  Wants[true][shift].keys },
    false => 
    (Shift0..Shift2).map{|shift| Reguration[false][shift].keys +  Wants[false][shift].keys }
    }

  
  #Reguration = RegurationThroughLastMonth.merge(RegurationThisMonthOnly).merge(WantsThroughLastMonth)
  RegurationNeed = { 
      true => 
    [
     {
       #:koukyuu => [/^0/, nil,6,"公休6以上、年休１以上"],
       #:renkyuu => [/00/         , nil,nil,"連休がある"]
     },{},{},{}
    ],
      false =>
      []
    }

end
end
