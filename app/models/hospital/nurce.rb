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
  extend Function::CsvIo
  include Hospital::Const
  include Hospital::NurceCost
  include Hospital::Reguration

  set_table_name 'nurces'
  has_and_belongs_to_many :hospital_roles,:class_name => "Hospital::Role"
  has_and_belongs_to_many :shokui,:class_name => "Hospital::Role",:conditions => "bunrui = 1"
  has_and_belongs_to_many :shokushu,:class_name => "Hospital::Role",:conditions => "bunrui = 2"
  has_and_belongs_to_many :kinmukubun,:class_name => "Hospital::Role",:conditions => "bunrui = 3"
  belongs_to :limit    ,:class_name => "Hospital::Limit"
  belongs_to :pre_busho,:class_name => "Hospital::Busho"
  belongs_to :busho    ,:class_name => "Hospital::Busho"
  
  LimitDefault =
    { :code0 => 8,:code1 => 20,:code2 => 4,:code3 => 4,:coden => 1,
    :night_total => 9,:kinmu_total => 20
  }
  CheckFail = Class.new(StandardError)

  attr_accessor :month,:shift_used


  def after_find
    set_check_reg 
  end


  class AssignPatern
    attr_accessor :patern, :reg, :back,:length,:checks,:target_days
    def initialize(*args)
      @patern, @reg, @back,@length,@checks,@target_days = args.first
    end
  end
  LongPatern = { 
    true => {
      Sshift3 => [  # patern, reg, back,length,[調べるshift],[ [0の割り当て数見る日],[1の][2の],[3の]]
           AssignPatern.new(["330"    , /^[^3M6][0_]_[3_][0_]/,2,5,[Sshift3],[[2],[],[],[1]] ]),
           AssignPatern.new(["30"     , /^[2LM356]_[0_]/       ,1,3,[Sshift3],[[1],[],[],[1]] ]),
           AssignPatern.new(["3"      , /^_/,0,1,["3"],[[],[],[],[]]])
           ],
      Sshift2 => [ #  patern, reg,                back,length,[調べるshift],[ [2の割り当て数見る日],[3の]]
            AssignPatern.new(["220330",/^[^2L5][0_]_[2_][0_][3_]{2}[0_]/,2,8,[Sshift3,Sshift2],[[2,5],[],[1],[3,4]]]),
            AssignPatern.new(["220"   , /^[^2L5][0_]_[2_][0_]/,2,5,[Sshift2],[[2],[],[1],[]] ]),
            AssignPatern.new(["20"    , /^[2L3M56]_[0_]/      ,1,3,[Sshift2],[[1],[],[1],[]] ]),
            AssignPatern.new(["2"     , /^_/                 ,0,1,[Sshift2],[[],[],[],[]]])
           ],
       Sshift1 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
             AssignPatern.new(["1"    , /^_/                 ,0,1,[Sshift1],[[],[],[],[]]])
            ]
       },
     false => { 
       Sshift2 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]
             AssignPatern.new(["220"  , /^[^25][0_]_[2_][0_]/,2,5,[Sshift2],[[2],[],[1],[]] ]),
             AssignPatern.new(["2"    , /^_/                 ,0,1,[Sshift2],[[],[],[],[]]])
            ],
        Sshift1 => [      # reg, back,length,[制約名,,],[ [2の割り当て数見る日],[3の]]  
             AssignPatern.new(["1"    , /^_/                 ,0,1,[Sshift1],[[],[],[],[]]])
             ]
      }     

  }
  


  def self.by_busho(busho_id,option = {})
    all( option.merge({:conditions => ["busho_id = ?",busho_id]}))
  end
  def self.correction(busho_id,option = {})
    all( option.merge({:conditions => ["busho_id = ?",busho_id]})).map{ |nurce| [nurce.name,nurce.id]}
  end

  def shokui_id     ; shokui.first ? shokui.first.id         : nil ;end
  def shokushu_id   ; shokushu.first ? shokushu.first.id     : nil ;end
  def kinmukubun_id ; kinmukubun.first ? kinmukubun.first.id : nil ;end
  def shokui_id=(arg_id) 
    if arg_id.blank? || !(role = Hospital::Role.find arg_id)
      self.shokui=[]
    else
      self.shokui=[role]
    end
  end

  def shokushu_id=(arg_id)
      shokushu=[]
    if arg_id.blank? || !(role = Hospital::Role.find arg_id.to_i)
      self.shokushu=[]
    else
      self.shokushu=[role]
    end
  end

  def kinmukubun_id=(arg_id) 
    if arg_id.blank? || !(role = Hospital::Role.find arg_id)
      self.kinmukubun=[]
    else
      self.kinmukubun=[role]
    end
  end

  def busho_name ; busho ? busho.name : ""          ;end
  def pre_busho_name ; pre_busho ? pre_busho.name : "" ; end
  def idou_name ; (a=Idou.rassoc(idou)) ? a.first : "";end
  def shokui_name; (a=Shokui.rassoc(shokui_id)) ? a.first : "";end
  def pre_shokui_name; (a=Shokui.rassoc(pre_shokui_id)) ? a.first : "";end
  def shokushu_name;(a=Shokushu.rassoc(shokushu_id)) ? a.first : "";end
  def pre_shokushu_name;(a=Shokushu.rassoc(pre_shokushu_id)) ? a.first : "";end
  def kinmukubun_name;(a=Kinmukubun.rassoc(kinmukubun_id)) ? a.first : "";end
  def pre_kinmukubun_name;(a=Kinmukubun.rassoc(pre_kinmukubun_id)) ? a.first : "";end

  def monthly(month=nil)
    return @monthly if @monthly && ( @monthly.month == month || !month)
    @month = month if month
    @monthly = Hospital::Monthly.
      find_or_create_by_nurce_id_and_month(id,month)
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
    case sft_str
    when "0"      ;update_remain(sft_str)
    when "2","3"  ;update_remain(sft_str);update_remain(:night_total);update_remain(:kinmu_total)
    when "1"      ;update_remain(sft_str);update_remain(:kinmu_total)
    end
    monthly.set_shift(day,sft_str)
    self
  end

  def update_remain(sft_str)
    shift_remain[sft_str] -= 1 
    role_ids.each{|role_id| 
      role_used[[role_id,sft_str]] += 1
      role_remain[[role_id,sft_str]] -= 1
    }
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

  def limits
    #limit ||= Hospital::Limit.crate
    return limit if limit
    create_limit(LimitDefault)
    limit 
  end

  def assinable_roles
    return @assinable_roles if @assinable_roles
    @assinable_roles = Hash.new{|h,k| h[k]=0}
    [ [:code1,Sshift1], [:code2,Sshift2], [:code3,Sshift3]].
      each{|sym,sft_str|
      roles.each{|role_id,name| 
        next unless Hospital::Need.roles.include?(role_id)
        @assinable_roles[[role_id,sft_str]] = limits[sym]
      }}
    assinable_total
    @assinable_roles
  end
  def assinable_total
    #@assinable_total = Hash.new{|h,k| h[k]=0}
    [[:kinmu_total,:kinmu_total],[:night_total, :night_total]].
      each{|sym,sft_str|
      roles.each{|role_id,name| 
        next unless Hospital::Need.roles.include?(role_id)
        @assinable_roles[[role_id,sft_str]] = limits[sym]
      }}
    @assinable_roles
  end



  def has_assignable_roles_atleast_one(sft_str,need_roles)
    #logger.debug("### roles & role_ids(#{__LINE__}) #{roles} #{roles.class} & #{role_ids}#{role_ids.class}")
      shift_remain[sft_str]>0 &&
      (need_roles & role_ids).size > 0
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
    @shift_used=Hash.new{|h,k| h[k]=0}

    @shift_used["0"]  =  shifts.gsub(/[^0]/,"").size + shifts.gsub(/[^9ABC]/,"").size*0.5
    @shift_used["1"]  = shifts.gsub(/[^1478]/,"").size + shifts.gsub(/[^9ABC]/,"").size*0.5
    @shift_used["2"]  = shifts.gsub(/[^25]/,"").size
    @shift_used["3"]  = shifts.gsub(/[^36]/,"").size
    @shift_used[:night_total]  = @shift_used["2"] + @shift_used["3"]
    @shift_used[:kinmu_total]  = @shift_used[:night_total] + @shift_used["1"]
    
    %w(0 1 2 3).each{ |sft_str|
      role_ids.each{|role| @role_used[[role,sft_str]] = @shift_used[sft_str] }
    }
    [:kinmu_total,:night_total].each{ |sft_str|
      role_ids.each{|role| @role_used[[role,sft_str]] = @shift_used[sft_str] }
    }
   @role_used
  end

def role_remain(recalc=false)
    return @role_remain if @role_remain && !recalc
    role_used true
    @role_remain = Hash.new{|h,k| h[k]=0}
    assinable_roles.each_pair{|role_shift,assinable|
      @role_remain[role_shift] = assinable - role_used[role_shift]
    }
    @role_remain
  end

  def shift_remain(recalc=false)
    return @shift_remain if @shift_remain && !recalc
    role_used true
    @shift_remain = Hash[*Sshift0123.
                         zip([limits.code0,limits.code1,limits.code2,limits.code3]).flatten
                        ]
    @shift_remain[:night_total] = limits.night_total - @shift_used[:night_total]
    @shift_remain[:kinmu_total] = limits.kinmu_total - @shift_used[:kinmu_total] 
    ["0","1","2","3"].each{ |sft_str|  @shift_remain[sft_str] -= @shift_used[sft_str]}
    
    @shift_remain
  end

  def roles
    @roles ||=
      hospital_roles.map{|role| [role.id,role.name]}.uniq #+ 
    #(shokui_id ? [shokui_id+100,shokui.name] : [])
  end
  def role_ids 
    @role_ids ||= (hospital_roles.map(&:id).uniq & Hospital::Need.roles)
  end
  def roles_by_id
    @rolls_by_id ||= Hash[*roles.flatten]
  end

  def role?(rolename)
    roles[hospital_roles.find_by_name(rolename).id]
  end

  def role_id?(role_id);role_ids.include?(role_id) #.to_i);
  end

  def role_shift(month=nil,reculc=false)
    return @role_shift if @role_shift  && !reculc && (!month ||month == monthly.month)
    #return @role_shift if @role_shift && month == monthly.month && !reculc
    @role_shift=
      monthly(month).shift.split("").map{|sft_str| role_shift_of(sft_str)  }
    @role_shift
  end
  def role_shift_of(sft_str)
    r_s = role_ids.map{|role_id| [ role_id , sft_str] }.compact
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
      inject(0){|sum,kinmu| sum + kinmu.shift1 }
      #[:am,:pm,:am2,:pm2].inject(0){|s,sym| s +  kinmu.shift1 } #(kinmu.kinmucode ? kinmu.kinmucode[sym] : 0) }
      #}
  end 
  def shift2
    monthly.days.
      inject(0){|sum,kinmu| sum +  kinmu.shift2 } #(kinmu.kinmucode ? kinmu.kinmucode.night + kinmu.kinmucode.night2 : 0 )}
  end 
  def shift3
    monthly.days.
      inject(0){|sum,kinmu| sum + kinmu.shift3 } #(kinmu.kinmucode ? kinmu.kinmucode.midnight + kinmu.kinmucode.midnight2 : 0)}
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
    return [[:no_space,true]] unless  monthly.shift[day,1] == "_"
    save = monthly.shift[day,1]
    monthly.shift[day,1] = sft_str
    ret = check(day,sft_str,imidiate)  
    monthly.shift[day,1] = save
    #pp [day,shift,ret] if id==36
    return ret.size > 0 ? ret : nil
  end

  def long_check(day,sft_str,long_patern,imidiate=true)
    #patern,reg,back,length,checks,daily_checks = long_patern
    offset,len = long_patern.back ? [day - long_patern.back + 4,long_patern.length] : [5,31] 

    # そもそもそのlong_paternを入れる予知があるか見る
    if long_patern.reg =~ shift_with_last_month[offset,len]
      shiftsave = shifts.dup#[day,long_patern.patern.size]
      shifts[day,long_patern.patern.size] = long_patern.patern

      ret,errors = long_check_sub(day,long_patern.checks,imidiate)
      shifts= shiftsave #[day,long_patern.patern.size] = shiftsave
      if ret ;        return [long_patern ]
      else   ;        return [false ,errors]
      end
    end
    #    errors.each{|item,d| @count_cause[item] += 1
    [false,[[:no_space]]]
  end

  def long_check_sub(day,checks,imidiate=true)
    ret = []
    checks.each{|sft_str|   ret += check(day,sft_str,imidiate)
      #return false if ret.size > 0
    }
    [ret.size == 0,ret]
  end

  def check(day,sft_str,imidiate=true)
    ret = []
    [0,sft_str.to_i].each{|s|
      check_reg[s].each_pair{|item,regration|
        d = regration.check(day,shift_with_last_month)
        if d
          ret << [item,d]
          return ret if imidiate
        end
      }
    }
    ret
  end

  def check_sub(day,item,regration)
    #reg,back,length,msg =regration# @Reguration[item]
    #     shift_with_last_month  0123456789
    #                     shift       12345
    #                                   +   3-1+4 = 6
    #offset,len = back ? [day-back+4,length] : [5,31] #[0,31] 
    #(reg =~ shift_with_last_month[offset,len])
    if back
      (reg =~ shift_with_last_month[day-back+4,length])
    else
#pp limit
      shift_with_last_month[5,31].gsub(reg,"").size > length
    end
  end

  def error_check
    ret = []
    #[@Reguration,@Wants,Reguration,Wants].each{|reguretion|
    check_reg.each{|reg_hash| # { :after_nights =>  [/[2356]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
      reg_hash.values.each{|regration|  # [/[2356]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
        #reg,back,length,msg = reg_arry # 
        day=regration.error_check(day,shift_with_last_month)
        ret << [name,regration.comment,day,shift_with_last_month]  if day
        #if back
        #  match = (reg =~ shift_with_last_month)
        #  ret <<  [name,msg,[match-4,1].max,shift_with_last_month] if match && match-4+back>0
        #else
        #  ret <<  [name,msg,0,shift_with_last_month] if shifts.gsub(reg,"").size > length
        #end
      }
    }
    ret.uniq
  end

end
