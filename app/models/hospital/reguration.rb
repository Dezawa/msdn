# -*- coding: utf-8 -*-
module Hospital

  module Default
    def check(day,shift_with_last_month)
      reg_expression =~ shift_with_last_month[day-back+4,length]
    end
    def error_check(day,shift_with_last_month)
      day = (reg_expression =~ shift_with_last_month)
      day ? [day-4,1].max : nil
    end
  end
  module Total
    def check(day,shift_with_last_month)
      shift_with_last_month[5,31].gsub(reg_expression,"").size > length
    end
    def error_check(day,shift_with_last_month)
      day = shift_with_last_month[5,31].gsub(reg_expression,"").size > length
      day ? 0 : nil
    end
  end

  class Regrate
    include Hospital::Const
    attr_accessor :comment,:reg_expression,:back,:length,:method
    def initialize(arg_reg,arg_back,arg_length,arg_comment,arg_method = nil)
      @comment = arg_comment
      @reg_expression = arg_reg
      @back = arg_back
      @length = arg_length
      @method = arg_method
    end
    def self.create(arg_reg,arg_back,arg_length,arg_comment,arg_method = nil)
      reg = self.new(arg_reg,arg_back,arg_length,arg_comment,arg_method)
      case reg.method
      when :through
        reg.extend Hospital::Total      
      else
        reg.extend Hospital::Default
      end
      reg
    end
  end

  module Reguration
  include Hospital::Const

  Reguration =         # item  => [[正規表現,何日前から見るか,何日分見るか]
    {                  #item  => [[正規表現,nil,max]  その月全体を調べる
     true =>  #三交代  #              正規表現を削除した 残りが max 以下かどうか
       [ #0 全シフト   #
         {   # 
          :renkin       => Hospital::Regrate.create(/[1-8LM]{6,}/,5,11,"連続勤務5日まで"),### 半日勤務をどうするか未定
          :after_nights => Hospital::Regrate.create(/[2L3M56]{2}[^0_]/,2,5,"連続夜勤明けは休み")
          },
         # 1 日勤
          { },
         # 2 準夜
        {
          :yakinrenzoku => Hospital::Regrate.create(/([2L5]{2}.[2L5])/,3,5,"22022は避ける")
         },
        # 3 深夜
        {
          :yakinrenzoku => Hospital::Regrate.create(/([36]{2}.[36])/,3,5,"33033,22022は避ける")
        }
       ],
    false => #二交代
      [ #0 全シフト
       {   # item  => [[正規表現,何日前から見るか,何日分見るか]
         :renkin   => Hospital::Regrate.create(/[1-8]{6,}/,5,11,"連続勤務5日まで") ### 半日勤務をどうするか未定
       },
       # 1 日勤
       { },
       # 2 準夜
       {
         :yakinrenzoku => Hospital::Regrate.create(/([25]{2}.[25])/,3,5,"22022は避ける"),
         :nine_nights  => Hospital::Regrate.create(/[^25]/,nil,4, "夜勤は72時間 計4回まで",:through)
      },{ }
      ]
  }
  Wants = { 
    true => #三交代
      [#0
      {},  
      #1
      {
         :interval => Hospital::Regrate.create(/([2L5][14])|([14][3M6])/,1,3,"勤務間隔12時間以上")
       },
       #2
       {
         :interval => Hospital::Regrate.create(/([2L5][14])/,1,3,"勤務間隔12時間以上")
       },
       #3
       {
         :interval => Hospital::Regrate.create(/([14][3M6])/,1,3,"勤務間隔12時間以上")
       }
      ],
    false => #三交代
      [#0
       {},  
       #1
       {
         :interval => Hospital::Regrate.create(/[25][14]/,1,3,"勤務間隔12時間以上")
       },
       #2
       {
         :interval => Hospital::Regrate.create(/([25][14])/,1,3,"勤務間隔12時間以上"),
         :after_nights   => Hospital::Regrate.create(/[25]{2}[^0_]/ ,2,5," 夜勤連続の翌日公休")
       },
       { }
      ]
  }


  def set_check_reg 
    
    @Reguration = 
      [
       { :kinmu_total => Hospital::Regrate.create(/[^1-8LM]/,nil,limits.kinmu_total, "勤務は22日まで",:through)
       },{
       }, {
         :junya =>Hospital::Regrate.create( /[^25L]/,nil,limits.code2,"順夜が#{limit.code2}を越えた",:through),
         :nine_nights => Hospital::Regrate.create(/[^2356LM]/,nil,limit.night_total, "夜勤は72時間 計9回まで",:through)
       },{ 
         :shinya =>Hospital::Regrate.create(/[^3M6]/,nil,limits.code3,"深夜が#{limit.code3}を越えた",:through) ,
         :nine_nights => Hospital::Regrate.create(/[^2356LM]/,nil,limit.night_total, "夜勤は72時間 計9回まで",:through)
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
#pp [@Reguration[idx],@Wants[idx],Reguration[ Hospital::Define.koutai3?][idx],Wants[ Hospital::Define.koutai3?][idx]]
      reguration.merge!(@Reguration[idx]).
      merge!(@Wants[idx]).
      merge!(Reguration[ Hospital::Define.koutai3?][idx]).
      merge!(Wants[ Hospital::Define.koutai3?][idx])
    }
#pp @check_reg
# [@Reguration ,@Wants,Reguration[ Hospital::Define.koutai3?],Wants[ Hospital::Define.koutai3?] ]
    @check_reg
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
