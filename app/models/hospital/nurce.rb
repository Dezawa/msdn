# -*- coding: utf-8 -*-
# *看護師の登録を行う
# name  :        氏名
# number  :      雇用者番号
# busho_id  :    勤務先
# shokui_id  :  職位：看護師長、主任： Hospital::Const で定義
# shokushu_id  :  資格 看護師、準看護師、看護助手： Hospital::Const で定義
# kinmukubun_id  :  日勤、三交代、パートなど： Hospital::Const で定義
# pre_busho_id  :  前職場 未使用
# pre_shokui_id  :  
# pre_shokushu_id  :  
# pre_kinmukubun_id  :  
# assign_date  :  
# idou  :  異動してきた日。
# limit_id  : 各勤務などの割り当て上限
#
# DBには定義されていないが
# monthly(month=nil) を通して今処理している月の勤務データHospital::Monthlyのインスタンスを
# @monmthに置く
class Hospital::Nurce < ActiveRecord::Base
  extend CsvIo
  #extend Hospital::Nurce::Const

  self.table_name = 'hospital_nurces'
  has_and_belongs_to_many :hospital_roles,:class_name => "Hospital::Role"
  belongs_to :limit    ,:class_name => "Hospital::Limit"
  belongs_to :busho    ,:class_name => "Hospital::Busho"
  
  LimitDefault={:code0 => 8,:code1 => 20,:code2 => 4,:code3 => 4,:coden => 1}
  CheckFail = Class.new(StandardError)

  attr_accessor :month

  Cost = [
   [], # dumy  2    3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20
   [ nil, 106, 80, 71, 61, 50, 46, 41, 36, 27.6,25.6,22.6,20.6,18.6,16.6,14.6,12.6,10.6, 8.6, 5.6, 2],
   [ nil, 204,135,105, 94, 70, 60, 45, 40, 35  ,27.5,25.5,22.5,20.5,18.5,16.5,14.5,12.5,10.5, 8.5, 5.5],
   [ nil, 300,206,150,120,104, 69, 59, 44, 39  ,34.4,27.4,25.4,22.4,20.4,18.4,16.4,14.4,12.4,10.4, 8.4],
   [ nil, 400,266,208,163,133, 93, 68, 58, 43  ,38  ,33,  27.3,25.3,22.3,20.3,18.3,16.3,14.3,12.3,10.3],
   [ nil, 500,334,250,210,162,132,102, 92, 67  ,57  ,42  ,37  ,27.2,25.2,22.2,20.2,18.2,16.2,14.2,12.2],
   [ nil, 600,400,300,250,212,161,131,101, 91  ,66  ,56  ,41  ,36  ,31  ,27.1,25.1,22.1,20.1,18.1,14.1],
   [ nil, 700,466,350,280,244,200,160,130,100  ,90  ,65  ,55  ,40  ,35  ,30  ,27  ,25  ,22  ,20  ,18]
   ]

  Cost2 = [
   [], # dumy  2    3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20
   [ nil, 106, 80, 71, 61, 50, 46, 41, 36, 27.6,25.6,22.6,20.6,18.6,16.6,14.6,12.6,10.6, 8.6, 5.6, 2],
   [ nil, 400,266,208,163,133, 93, 68, 58, 43  ,38  ,33,  27.3,25.3,22.3,20.3,18.3,16.3,14.3,12.3,10.3],
   [ nil, 700,466,350,280,244,200,160,130,100  ,90  ,65  ,55  ,40  ,35  ,30  ,27  ,25  ,22  ,20  ,18]
   ]

  def self.cost_table
    @@Cost ||= make_cost_table
  end
  def self.make_cost_table
    cost = Hash.new{|h,k| h[k]=Hash.new{|hh,kk| hh[kk] = 0 }}
     
    Hospital::Need.combination3.
      each{|cmb| c0,c1,c2 = cmb
        cost[cmb] = Hash.new{|h,k| h[k] = 0 }
        cost[cmb][[c0,c1,c2].sort] = Cost[7]
        cost[cmb][[c0,c1].sort]    = Cost[6]
        cost[cmb][[c0,c2].sort]    = Cost[5]
        cost[cmb][[c1,c2].sort]    = Cost[4]
        cost[cmb][[c0]]       = Cost[3]
        cost[cmb][[c1]]       = Cost[2]
        cost[cmb][[c2]]       = Cost[1]
    }
    cost
  end

  def self.cost_table2
    @@Cost2 ||= make_cost_table2
  end
  def self.make_cost_table2
    cost = Hash.new{|h,k| h[k]=Hash.new{|hh,kk| hh[kk] = 0 }}
     
    Hospital::Need.combination2.
      each{|cmb| c0,c1 = cmb
        cost[cmb] = Hash.new{|h,k| h[k] = 0 }
        cost[cmb][[c0,c1].sort] = Cost[3]
        cost[cmb][[c0]]       = Cost[2]
        cost[cmb][[c1]]       = Cost[1]
    }
    cost
  end

  def after_find
    set_check_regulation
  end

  def cost(sft_str,tight)
    case tight.size
    when 3 ;self.class.cost_table[tight][(tight & role_ids).sort][shift_remain[sft_str]]
    when 2 ;self.class.cost_table2[tight][(tight & role_ids).sort][shift_remain[sft_str]]
    else
      dbgout("Nurce#cost sft_str #{sft_str} tight #{tight}")
      raise
    end
  end
 
  Reguration = 
    { 
     true =>  #三交代
       [ #0 全シフト
         {   # item  => [[正規表現,何日前から見るか,何日分見るか]
          :renkin   => [/[1-8LM]{6,}/,5,11,"連続勤務5日まで"] , ### 半日勤務をどうするか未定
          :after_nights =>  [/[2L3M56]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
          },
         # 1 日勤
          { },
         # 2 準夜
        {
          :yakinrenzoku => [/([2L5]{2}.[2L5])/,3,5,"22022は避ける"],
          :nine_nights => [/([2L3M56][^2356]*){10}/,nil,nil, "夜勤は72時間 計9回まで"]
        },
        # 3 深夜
        {
          :yakinrenzoku => [/([36]{2}.[36])/,3,5,"33033,22022は避ける"],
          :nine_nights => [/([2L3M56][^2356]*){10}/,nil,nil, "夜勤は72時間 計9回まで"]
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
         :nine_nights => [/([25][^25]*){5}/,nil,nil, "夜勤は72時間 計4回まで"]
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
      "3"=> [  # patern, reg, back,length,[調べるshift],[ [0の割り当て数見る日],[1の][2の],[3の]]
            ["330"    , /^[^3M6][0_]_[3_][0_]/,2,5,["3"],[[2],[],[],[1]] ],
            ["30"     , /^[2LM356]_[0_]/       ,1,3,["3"],[[1],[],[],[1]] ],
            ["3"      , /^_/,0,1,["3"],[[],[],[],[]]]
           ],
      "2"=> [ #  patern, reg,                back,length,[調べるshift],[ [2の割り当て数見る日],[3の]]
            ["220330" , /^[^2L5][0_]_[2_][0_][3_]{2}[0_]/,2,8,["3","2"],[[2,5],[],[1],[3,4]]
            ],
            ["220"    , /^[^2L5][0_]_[2_][0_]/,2,5,["2"],[[2],[],[1],[]] ],
            ["20"     , /^[2L3M56]_[0_]/      ,1,3,["2"],[[1],[],[1],[]] ],
            ["2"      , /^_/                 ,0,1,["2"],[[],[],[],[]]]
           ],
       "1" => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
             ["1"         , /^_/                 ,0,1,["1"],[[],[],[],[]]]
            ]
       },
     false => { 
       "2" => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
             ["220"       , /^[^25][0_]_[2_][0_]/,2,5,["2"],[[2],[],[1],[]] ],
             ["2"         , /^_/                 ,0,1,["2"],[[],[],[],[]]]
            ],
        "1" => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]  
             ["1"         , /^_/                 ,0,1,["1"],[[],[],[],[]]]
             ]
      }     

  }
  

  def set_check_regulation
    
    @Reguration = 
      [
       {        },{ },
       {
         :junya => [/([2L5][^25]*){#{limits.code2+1}}/,nil,nil,"順夜が#{limits.code2}を越えた"]
       },{ 
         :shinya =>[/([3M6][^36]*){#{limits.code3+1}}/,nil,nil,"深夜が#{limits.code3}を越えた"] 
       }
      ]
    @Wants = [{},{},{},{}] 
    @Reguration_keys = (0..3).map{|shift| @Reguration[shift].keys + @Wants[shift].keys }
    [@Reguration ,    @Wants ,  @Reguration_keys] # retern for TDD
  end

  def check_regulation
    @check_regulation ||=
      [@Reguration ,@Wants,Reguration[ Hospital::Define.koutai3?],Wants[ Hospital::Define.koutai3?] ]
  end


  def self.by_busho(busho_id,option = {})
    where(  ["busho_id = ?",busho_id] )
  end

  def busho_name ; busho ? busho.name : ""          ;end
  def pre_busho_name ; pre_busho ? pre_busho.name : "" ; end
  def idou_name ; (a=Hospital::Const::Idou.rassoc(idou)) ? a.first : "";end
  def shokui_name; (a=Hospital::Const::Shokui.rassoc(shokui_id)) ? a.first : "";end
  def pre_shokui_name; (a=Hospital::Const::Shokui.rassoc(pre_shokui_id)) ? a.first : "";end
  def shokushu_name;(a=Hospital::Const::Shokushu.rassoc(shokushu_id)) ? a.first : "";end
  def pre_shokushu_name;(a=Hospital::Const::Shokushu.rassoc(pre_shokushu_id)) ? a.first : "";end
  def kinmukubun_name;(a=Hospital::Const::Kinmukubun.rassoc(kinmukubun_id)) ? a.first : "";end
  def pre_kinmukubun_name;(a=Hospital::Const::Kinmukubun.rassoc(pre_kinmukubun_id)) ? a.first : "";end

  def monthly(month=nil)
    return @monthly if @monthly && ( @monthly.month == month || !month)
    @month = month
    @monthly = Hospital::Monthly.
      find_or_create_by(nurce_id: id, month: month)
    @monthly.nurce=self
    @lastday=@month.end_of_month.day
    @monthly
  end

  def clear_assign
#pp "Nurce#cleat_assign nurce=#{id} shifts =#{shift} "
    (1..@lastday).each{|day|
      if self.monthly.days[day].want.nil? || self.monthly.days[day].want<10
        self.set_shift(day,"_")
      end
    }
#pp "Nurce#cleat_assign nurce=#{id} shifts =#{shift} "


  end

  def assigned?(day) ;  
    #logger.debug("FOR_DEBUG(#{__LINE__}) monthly.shift #{monthly.shift.size},day #{day},")
    monthly.shift[day,1] != "_"
  end
  def days_not_assigned(month=nil)
    #puts monthly.shift  if id == 35 || id == 36 
    monthly.shift.gsub(/[^_]/,"").size
  end

  def shift_with_last_month
    if !@lastmonth || @lastmonth.month + 1.month != monthly.month
      @lastmonth = Hospital::Monthly.find_or_create_by_nurce_id_and_month(id,@month-1.month)#.month)
    end
    @lastmonth.shift[-5..-1]+monthly.shift[1..-1]
  end

  def set_shift_days(start_day,shift_list)
    return nil unless shift_list
    (0..shift_list.size-1).each{|day|  set_shift(start_day+day,shift_list[day,1])}
  end

  def set_shift(day,sft_str)
    #logger.info("HOSPITAL:看護割付:#{day}日#{sft_str} #{id}:#{name}")
      sft = sft_str.hex
    
    role_shift[day]=role_shift_of(sft_str)
    if /[0123]/ =~ sft_str
      shift_remain[sft_str] -= 1 
      roles.each{|role_id,name| 
        role_used[[role_id,sft_str]] += 1
        role_remain[[role_id,sft_str]] -= 1
      }
    end
    monthly.set_shift(day,sft_str)
    self
  end

  def save_shift; [shifts.dup ,role_used.dup ,role_remain.dup,shift_remain.dup];end
  def restore_shift(saved_shift)
    #dbgout( "HP  restore_shift前 #{id}:#{shifts} #{role_shift.to_a.flatten.join(' ')}")
    self.shifts = saved_shift[0]
    role_used   = saved_shift[1]
    @role_remain = saved_shift[2]
    @shift_remain= saved_shift[3]

    @role_shift=(self.shifts||"").split("").map{|sft_str|   role_shift_of(sft_str) }
    self
  end

  def shift(day) ;    monthly.shift[day,1] ;  end
  def shifts     ;    monthly.shift ;end #|| ""        ;  end
  def shifts=(shft) ; monthly.shift=shft   ;  end
  # この看護師を選ぶに当たってのポイントを評価する。
  # 考慮するのは
  #   1 不足ロールと持ってるロールのマッチング、
  #   2 割り当てようとしている勤務の残り数
  #   3 未割り当ての日数
  #   4 リーダの 要否とリーダかどうか
  # 1,2 は100点満点、3は100～200点満点、4は場合による。
  def evaluate(short_role,shift)
    # 必要なroleがあるか
    role_match = (short_role & role_ids).size
    return 0 if role_match == 0

    
    value = role_match*25 +       # ロールのマッチング ４つで100点
      (limits[Hospital::Limit::Code[shift]]-shift_count(shift)) * 100 + # 勤務の残り数 ４つで200点
      case [short_role.include?(1),!!role_id?(1)]
      when [true,true] # リーダが必要でかつリーダである
        days_not_assigned*200/30 + # 未割り当ての日数
          0                      # リーダ
      when [true,false] # リーダが必要でかつリーダではない
        days_not_assigned*300/30
      when [false,true] # リーダ不要でリーダである=>割り振りは優先度下げる
        days_not_assigned*30/30
      when [false,false] # リーダ不要でリーダではない
        days_not_assigned*300/30      
      end
    #puts "EVAL:  #{id} #{value} <= #{role_match*25} #{limits[Hospital::Limit::Code[shift]] * 25} #{days_not_assigned*100/30}" if id == 35 || id == 36

    adjust_by_shokui(value)
  end

  def adjust_by_shokui(value)
    {1 => 0.2, 2 => 0.5 , 0 => 1, nil => 1}[shokui_id] * value
  end

  def limits
    #limit ||= Hospital::Limit.crate
    return limit if limit
    create_limit(LimitDefault)
    limit 
  end

  def assinable_roles
    return @assinable_roles if @assinable_roles
    @assinable_roles = Hash.new{|h,k| h[k]=0}
    [ [:code1,"1"], [:code2,"2"], [:code3,"3"]].
      each{|sym,sft_str|
      roles.each{|role_id,name| 
        @assinable_roles[[role_id,sft_str]] = limits[sym]
      }}
    @assinable_roles
  end

  def has_assignable_roles_atleast_one(sft_str,roles)
    #logger.debug("### roles & role_ids(#{__LINE__}) #{roles} #{roles.class} & #{role_ids}#{role_ids.class}")
      shift_remain[sft_str]>0 &&
      (roles & role_ids).size > 0
  end

####################################################################
  def refresh
    role_used true
    role_remain true
    shift_remain true
  end

  def role_used(recalc=false)
    return @role_used if @role_used && !recalc
    @role_used=Hash.new{|h,k| h[k]=0}
#    role_shift.each{|day_rs| day_rs.each{|rs| @role_used[rs] += 1}}
    [/[^0]/,/[^1478]/,/[^25]/,/[^36]/].each_with_index{|reg,shift|
      used = shifts.gsub(reg,"").size
      role_ids.each{|role| @role_used[[role,shift.to_s]] = used }
    }
   @role_used
  end
def role_remain(recalc=false)
    return @role_remain if @role_remain && !recalc
    @role_remain = Hash.new{|h,k| h[k]=0}
    assinable_roles.each_pair{|role_shift,assinable|
      @role_remain[role_shift] = assinable - role_used[role_shift]
    }
    @role_remain
  end

  def shift_remain(recalc=false)
    return @shift_remain if @shift_remain && !recalc
    @shift_remain = Hash[*%w(0 1 2 3).
                         zip([limits.code0,limits.code1,limits.code2,limits.code3]).flatten]
    [ /[^0]/,  /[^1478]/ , /[^25]/ , /[^36]/].
      each_with_index{|reg,shift| @shift_remain[shift.to_s] -= shifts.gsub(reg,"").size }
    @shift_remain["0"] -= shifts.gsub(/[^9ABC]/,"").size*0.5
    @shift_remain["1"] -= shifts.gsub(/[^9ABC]/,"").size*0.5
    @shift_remain
  end

  def roles
    @roles ||=
      hospital_roles.map{|role| [role.id,role.name]}.uniq #+ 
    #(shokui_id ? [shokui_id+100,shokui.name] : [])
  end
  def role_ids   ; @role_ids ||= roles.map{ |r| r[0]};end #hospital_roles.map(&:id)  ; end
def roles_by_id
  @rolls_by_id ||= Hash[*roles.flatten]
end

  def role?(rolename)
    roles[hospital_roles.find_by(name: rolename).id]
  end

  def role_id?(role_id);role_ids.include?(role_id) #.to_i);
  end

  def role_shift(month=nil,reculc=false)
    return @role_shift if @role_shift  && !reculc && (!month ||month == monthly.month)
    #return @role_shift if @role_shift && month == monthly.month && !reculc
    @role_shift=
      monthly(month).shift.split("").map{|sft_str| role_shift_of(sft_str)  }
      #monthly(month).shift.split("").map{|sft| role_shift_of(sft.hex)  }
    #logger.debug("FOR_DEGBUG(#{__LINE__}) #{monthly(month).shift} => role_shift #{role_shift.join(',')}")
    @role_shift
  end
  def role_shift_of(sft_str)
    r_s = role_ids.map{|role_id| [ role_id , sft_str] }.compact
    #r_s = roles.map{|role| [ role[0] , sft_str] }.compact
    #r_s = roles.map{|role| [ role[0] , sft] }.compact
    #r_s << [2,0] if ( sft == "0" || sft== 0 ) && role_id?(2) 
    #r_s
  end

  def shift_count(shift)
    case shift
    when 1 ;shifts.gsub(/[^1478]/,"").size + shifts.gsub(/[^9ABC]/,"").size * 0.5
    when 2 ;shifts.gsub(/[^25]/,"").size
    when 3 ;shifts.gsub(/[^36]/,"").size
    end
  end

  def shift1
    monthly.days.
      inject(0){|sum,kinmu| sum + 
      [:am,:pm,:am2,:pm2].inject(0){|s,sym| s + (kinmu.kinmucode ? kinmu.kinmucode[sym] : 0) }
      }
  end 
  def shift2
    monthly.days.
      inject(0){|sum,kinmu| sum + (kinmu.kinmucode ? kinmu.kinmucode.night + kinmu.kinmucode.night2 : 0 )}
  end 
  def shift3
    monthly.days.
      inject(0){|sum,kinmu| sum + (kinmu.kinmucode ? kinmu.kinmucode.midnight + kinmu.kinmucode.midnight2 : 0)}
  end 
  def nenkyuu
    monthly.days.
      inject(0){|sum,kinmu| sum + (Hospital::Kinmucode.code(:Nenkyu) == kinmu.kinmucode_id ? 1 : 0 )}
  end 

  def shift0
    monthly.days.
      inject(0){|sum,kinmu| sum + (Hospital::Kinmucode.code(:Koukyu) == kinmu.kinmucode_id ? 1 : 0 )}
  end
  def osode
    monthly.days.
      inject(0){|sum,kinmu| sum + (Hospital::Kinmucode.code(:Osode) == (kinmu.kinmucode_id) ? 1 : 0 )}
  end 

  def sankyuu
    monthly.days.
      inject(0){|sum,kinmu| sum + (Hospital::Kinmucode.code(:Sankyu) ==  kinmu.kinmucode_id ? 1 : 0 )}
  end 
  def ikukyuu
    monthly.days.
      inject(0){|sum,kinmu| sum + (Hospital::Kinmucode.code(:Ikukyu) ==  kinmu.kinmucode_id ? 1 : 0 )}
  end 

  ##############################
  KanriJunyaPatern =
    [
     /(^|[^2356])([25][25_]|[25_][25])[0_][3_]{2}[0_]/,
     /(^|[^2356])[25_]{2}[0_](3[3_]|[3_]3)[0_]/,
     /(^|[^2356])([25_][25_])[0_][3_]{2}[0_]/

    ]
  def assign_1_cool(day0=1)
    return nil unless shokui_id == 2
    
    if  day = KanriJunyaPatern[0] =~ shifts[day0..-1] ||
        day = KanriJunyaPatern[1] =~ shifts[day0..-1] ||
        day = KanriJunyaPatern[2] =~ shifts[day0..-1]
      day += day0
      match = $2
      pre   = $1
      patern = case match
               when "5_";
                 day += 1 unless pre == "_"
                 "520330"
               when "52","_2"       ;  day += 1;"520330"
               else                #; day += 1; "250330"
                 day += 1 unless pre == ""
                 "250330"
               end    #pp [day,$1.size,match,patern]
    end
    set_shift_days(day,patern)
    [day,patern]
  end


  # day は暦の日、backはそこから何日前から調べるか
  # (day-back)日から調べるわけだが、それは前月5日分を考慮すると
  #  1日は [5] day日は [4+day]
  #  shift_with_last_monthの(day-back+4)byte目から
  #  例えば、day=8、back=5のとき、3日から調べるが、それは
  #  shift_with_last_month[7]   8-5+4
  # 違反項目がないとき nil が返る
  def check_at_assign(day,sft_str,imidiate=true)
    save = monthly.shift[day,1]
    monthly.shift[day,1] = sft_str
    ret = check(day,sft_str,imidiate)  
    monthly.shift[day,1] = save
    #pp [day,shift,ret] if id==36
    return ret.size > 0 ? ret : nil
  end

  def long_check(day,sft_str,long_patern)
    patern,reg,back,length,checks,daily_checks = long_patern
    offset,len = back ? [day-back+4,length] : [5,31] 
    #pp [day,shift,id,reg,patern,shifts[day,patern.size]]
    if reg =~ shift_with_last_month[offset,len]
      shiftsave = shifts[day,patern.size]
      shifts[day,patern.size] = patern

      ret,errors = long_check_sub(day,checks)
      shifts[day,patern.size] = shiftsave
      if ret
        return [patern ,daily_checks]
      else
        return [false ,errors]
      end
    end
    #    errors.each{|item,d| @count_cause[item] += 1
    [false,[[:no_space]]]
  end

  def long_check_sub(day,checks)
    ret = []
    checks.each{|sft_str|
      ret += check(day,sft_str)
      #return false if ret.size > 0
    }
    #true
    [ret.size == 0,ret]
  end

  def check(day,sft_str,imidiate=true)
    ret = []
    check_regulation.each{|regulation|
      [0,sft_str.to_i].each{|s|
        regulation[s].each_pair{|item,reg_arry|
          d = check_sub(day,item,reg_arry)
          if d
            ret << [item,d]
            return ret if imidiate
          end
        }
      }
    }
    ret
  end

  def check_sub(day,item,reg_arry)
    reg,back,length,msg =reg_arry# @Reguration[item]
    #     shift_with_last_month  0123456789
    #                     shift       12345
    #                                   +   3-1+4 = 6
    offset,len = back ? [day-back+4,length] : [5,31] #[0,31] 
    (reg =~ shift_with_last_month[offset,len])
  end

  def error_check
    ret = []
    #[@Reguration,@Wants,Reguration,Wants].each{|regulation|
    check_regulation.each{|regulation|
      regulation.each{|reg_hash| # { :after_nights =>  [/[2356]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
        reg_hash.values.each{|reg_arry|  # [/[2356]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
          reg,back,length,msg = reg_arry # 
          if back
            match = (reg =~ shift_with_last_month)
            ret <<  [name,msg,[match-4,1].max,shift_with_last_month] if match && match-4+back>0
          else
            match = (reg =~ shifts)
            ret <<  [name,msg,match,shift_with_last_month] if match
          end
        }
      }
    }
    ret.uniq
  end

end
