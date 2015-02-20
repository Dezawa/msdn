# -*- coding: utf-8 -*-
module Hospital

  module Default
    def check(day,shift_with_last_month)
      reg_expression =~ shift_with_last_month[day-back+4,length]
    end
    def error_check(shift_with_last_month)
      day = (reg_expression =~ shift_with_last_month[5-back .. -1])
      day ? [day-4,1].max : nil
    end
  end
  module Total
    def check(day,shift_with_last_month)
      shift_with_last_month[5,31].gsub(reg_expression,"").size > length
    end
    def error_check(shift_with_last_month)
      day = shift_with_last_month[5,31].gsub(reg_expression,"").size > length
      day ? 0 : nil
    end
  end

  class Regrate
    include Hospital::Const
    attr_accessor :comment,:reg_expression,:back,:length,:method
    def initialize(arg_reg,opt={ }) #arg_back,arg_length,arg_comment,arg_method = nil)
      @comment = opt.delete(:comment)
      @reg_expression = arg_reg
      @back = opt.delete(:back)
      @length = opt.delete(:length)
      @method = opt.delete(:method)
    end
    def self.create(arg_reg,opt={ })
      opt = { method: Hospital::Default}.merge opt
      reg = self.new(arg_reg,opt)
      reg.extend reg.method

      reg
    end
  end

  module Reguration
    include Hospital::Const

    RegConst = { 
      :renkin => Hospital::Regrate.create(/[1-8LM]{6,}/,
                                          back: 5, length: 11,
                                          comment: "連続勤務5日まで"),### 半日勤務をどうするか未定
      :after_nights => Hospital::Regrate.
                                  create(/[2L3M56]{2}[^0_]/,
                                         back: 2, length:  5,
                                         comment: "連続夜勤明けは休み"),
         :nine_nights  => Hospital::Regrate.create(/[^25]/,
                                                   length: 4,method: Hospital::Total,
                                                   comment: "夜勤は72時間 計4回まで"),
          :junyarenzoku => Hospital::Regrate.
                                  create(/([2L5]{2}[0_][2L5])/,
                                         back: 3, length: 5,
                                         comment: "2202 は避ける"),
          :sinyarenzoku => Hospital::Regrate.
                                  create(/([36]{2}[0_][36])/,
                                         back: 3,  length: 5,
                                         comment: "3303 は避ける"),
         :interval => Hospital::Regrate.create(/([2L5][14])|([14][3M6])/,
                                               back: 1, length: 3,
                                               comemnt: "勤務間隔12時間以上")
      
      
    }
    Reguration =         # item  => [[正規表現,何日前から見るか,何日分見るか]
    {                  #item  => [[正規表現,nil,max]  その月全体を調べる
     true =>  #三交代  #              正規表現を削除した 残りが max 以下かどうか
       [ #0 全シフト   #
         {   # 
          :renkin       => RegConst[:renkin],
          :after_nights => RegConst[:after_nights]
          },
         # 1 日勤
          { },
         # 2 準夜
        {
          :yakinrenzoku => RegConst[:junyarenzoku]
         },
        # 3 深夜
        {
          :yakinrenzoku => RegConst[:sinyarenzoku]
        }
       ],
    false => #二交代
      [ #0 全シフト
       {   # item  => [[正規表現,何日前から見るか,何日分見るか]
         :renkin   => RegConst[:renkin],
       },
       # 1 日勤
       { },
       # 2 準夜
       {
         :yakinrenzoku =>  RegConst[:junyarenzoku],
         :nine_nights  => RegConst[:nine_nights]
      },{ }
      ]
  }
  Wants = { 
    true => #三交代
      [#0
      {},  
      #1
      {
         :interval => RegConst[:interval]
       },
       #2
       {
         :interval => RegConst[:interval]
       },
       #3
       {
         :interval => RegConst[:interval]
       }
      ],
    false => #三交代
      [#0
       {},  
       #1
       {
         :interval => RegConst[:interval]
       },
       #2
       {
         :interval => RegConst[:interval],
         :after_nights   => RegConst[:after_nights]
       },
       { }
      ]
  }


  def set_check_reg 
    
    @Reguration = 
      [
       { :kinmu_total => Hospital::Regrate.create(/[^1-8LM]/,
                                                  length: limits.kinmu_total,method: Hospital::Total,
                                                  comment: "勤務は22日まで")
       },{
       }, {
         :junya =>Hospital::Regrate.create( /[^25L]/,
                                            length: limits.code2,method: Hospital::Total,
                                            comment: "順夜が#{limit.code2}を越えた"),
         :nine_nights => Hospital::Regrate.create(/[^2356LM]/,
                                                  length: limit.night_total,method: Hospital::Total,
                                                  comment: "夜勤は72時間 計9回まで")
       },{ 
         :shinya =>Hospital::Regrate.create(/[^3M6]/,
                                            length: limits.code3,method: Hospital::Total,
                                            comment: "深夜が#{limit.code3}を越えた") ,
         :nine_nights => Hospital::Regrate.create(/[^2356LM]/,
                                                  length: limit.night_total,method: Hospital::Total,
                                                  comment: "夜勤は72時間 計9回まで",)
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
  
      reguration.merge!(@Reguration[idx]).
      merge!(@Wants[idx]).
      merge!(Reguration[ Hospital::Define.koutai3?][idx]).
      merge!(Wants[ Hospital::Define.koutai3?][idx])
    }
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
