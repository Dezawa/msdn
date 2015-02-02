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
  include ActiveModel::Validations

  extend CsvIo
  include Hospital::Const
  include Hospital::NurceCost
  include Hospital::Reguration

  has_and_belongs_to_many :hospital_roles,:class_name => "Hospital::Role"
  # has_and_belongs_to_many :shokui,:class_name => "Hospital::Role",:conditions => "bunrui = 1"
  # has_and_belongs_to_many :shokushu,:class_name => "Hospital::Role",:conditions => "bunrui = 2"
  # has_and_belongs_to_many :kinmukubun,:class_name => "Hospital::Role",:conditions => "bunrui = 3"
  belongs_to :shokui,:class_name => "Hospital::Role"
  belongs_to :shokushu,:class_name => "Hospital::Role"
  belongs_to :kinmukubun,:class_name => "Hospital::Role"
  belongs_to :limit    ,:class_name => "Hospital::Limit"
  belongs_to :pre_busho,:class_name => "Hospital::Busho"
  belongs_to :busho    ,:class_name => "Hospital::Busho"

  after_find {  set_check_reg }
  before_save { pp "BEFORE_SAVE";save_month }

  LimitDefault =
    { :code0 => 8,:code1 => 20,:code2 => 4,:code3 => 4,:coden => 1,
    :night_total => 9,:kinmu_total => 20
  }
  CheckFail = Class.new(StandardError)

  attr_accessor :month,:shift_used

  validate :shokui_must_be_shokui,:shokushu_must_be_shokushu, :kinmukubun_must_be_kinmukubun
  def shokui_must_be_shokui
    errors.add(:shokui,"職位でないrole") unless shokui.blank? || shokui.bunrui == Bunrui2Id['職位']
  end

  def shokushu_must_be_shokushu
    errors.add(:shokushu,"職種でないrole") unless  shokushu.blank? || shokushu.bunrui == Bunrui2Id['職種']
  end

  def kinmukubun_must_be_kinmukubun
    errors.add(:kinmukubun,"勤務区分でないrole") unless  kinmukubun.blank? || kinmukubun.bunrui ==  Bunrui2Id['勤務区分']
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
    where( ["busho_id = ?",busho_id])
  end
  def self.correction(busho_id,option = {})
     by_busho(busho_id).map{ |nurce| [nurce.name,nurce.id]}
  end

  def ddshokui_id     ; shokui.first ? shokui.first.id         : nil ;end
  def ddshokushu_id   ; shokushu.first ? shokushu.first.id     : nil ;end
  def ddkinmukubun_id ; kinmukubun.first ? kinmukubun.first.id : nil ;end
  def ddshokui_id=(arg_id) 
    if arg_id.blank? || !(role = Hospital::Role.find arg_id)
      self.shokui=[]
    else
      self.shokui=[role]
    end
  end

  def ddshokushu_id=(arg_id)
    if arg_id.blank? || !(role = Hospital::Role.find arg_id.to_i)
      self.shokushu=[]
    else
      self.shokushu=[role]
    end
  end

  def ddkinmukubun_id=(arg_id) 
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
#>>>>>>> HospitalPower

  ########## 月度の割付状況
  # month が指定されていない場合は同じ月度情報を用いる
  #         指定されていても今と同じ月度情報なら再読み込みしない
  #         指定されていて今と違うなら、読み込む。無ければ作る
  #         指定されて居らずかつまだ月度を読んで居ないときは、来月
  def monthly(month=nil)
    return @monthly if @monthly && ( @monthly.month == month || !month)
#<<<<<<< HEAD
#    @month = month || Time.now.beginning_of_month.next_month.to_date
#    @monthly = Hospital::Monthly.find_or_create_by(nurce_id: id, month: @month)
#=======
    @month = month if month
    @monthly = Hospital::Monthly.
      find_or_create_by(nurce_id: id,month: month)
#>>>>>>> HospitalPower
    @monthly.nurce=self
    @lastday=@month.end_of_month.day
    @monthly
  end

  def shift(day) ;    monthly.shift[day,1] ;  end
  def shifts     ;    monthly.shift ;end #|| ""        ;  end
  def shifts=(shft) ; monthly.shift=shft   ;  end

  def assigned?(day) ;  
    #logger.debug("FOR_DEBUG(#{__LINE__}) monthly.shift #{monthly.shift.size},day #{day},")
    monthly.shift[day,1] != "_"
  end
  def days_not_assigned(month=nil)
    #puts monthly.shift  if id == 35 || id == 36 
    monthly.shift.gsub(/[^_]/,"").size-1
  end

  def shift_with_last_month
    if !@lastmonth || @lastmonth.month + 1.month != monthly.month
      @lastmonth = Hospital::Monthly.find_or_create_by(nurce_id: id ,month: @month-1.month)#.month)
    end
    @lastmonth.shift[-5..-1]+monthly.shift[1..-1]
  end

  ########### 割付 #############
  def clear_assign
    #pp "Nurce#cleat_assign nurce=#{id} shifts =#{shift} "
    (1..@lastday).each{|day|
      if self.monthly.days[day].want.nil? || self.monthly.days[day].want == 0
        self.set_shift(day,"_")
      end
    }
    #pp "Nurce#cleat_assign nurce=#{id} shifts =#{shift} "
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

# <<<<<<< HEAD
#   ########### 割付に当たっての評価 #########
#   # return: {[role,shift] => 回数 }
#   def role_used(recalc=false)
#     return @role_used if @role_used && !recalc
#     @role_used=Hash.new{|h,k| h[k]=0}
#     #    role_shift.each{|day_rs| day_rs.each{|rs| @role_used[rs] += 1}}
#     [/[^0]/,/[^1478]/,/[^25]/,/[^36]/].each_with_index{|reg,shift|
#       used = shifts.gsub(reg,"").size
#       role_ids.each{|role| @role_used[[role,shift.to_s]] = used }
#     }
#    @role_used
#   end

#   def role_remain(recalc=false)
#     return @role_remain if @role_remain && !recalc
#     @role_remain = Hash.new{|h,k| h[k]=0}
#     assinable_roles.each_pair{|role_shift,assinable|
#       @role_remain[role_shift] = assinable - role_used[role_shift]
#     }
#     @role_remain
#   end

#     # この看護師を選ぶに当たってのポイントを評価する。
#     # 考慮するのは
#     #   1 不足ロールと持ってるロールのマッチング、
#     #   2 割り当てようとしている勤務の残り数
#     #   3 未割り当ての日数
#     #   4 リーダの 要否とリーダかどうか
#     # 1,2 は100点満点、3は100～200点満点、4は場合による。
# =======
  def update_remain(sft_str)
    shift_remain[sft_str] -= 1 
  end

  def save_shift #; [shifts.dup  ,role_remain.dup,shift_remain.dup];end
  [shifts.dup  ,shift_remain.dup]
  end
  def restore_shift(saved_shift)
    #dbgout( "HP  restore_shift前 #{id}:#{shifts} #{role_shift.to_a.flatten.join(' ')}")
    self.shifts = saved_shift[0]
    @shift_remain= saved_shift[1]

    @role_shift=(self.shifts||"").split("").map{|sft_str|   role_shift_of(sft_str) }
    self
  end

  def shift(day) ;    monthly.shift[day,1] ;  end
  def shifts     ;    monthly.shift ;end #|| ""        ;  end
  def shifts=(shft) ; monthly.shift=shft   ;  end
#>>>>>>> HospitalPower

    def ddlimits
      #limit ||= Hospital::Limit.crate
    return limits if limits
    create_limit(LimitDefault)
    limits 
  end

  def assinable_roles
    return @assinable_roles if @assinable_roles
    @assinable_roles = Hash.new{|h,k| h[k]=0}
# <<<<<<< HEAD
#     [ [:code0,"0"],[:code1,"1"], [:code2,"2"], [:code3,"3"]].
#       each{|sym,sft_str|
#       roles.each{|role_id,name| 
#         @assinable_roles[[role_id,sft_str]] = limit[sym]
# =======
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
#>>>>>>> HospitalPower
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
    shift_remain true
  end

# <<<<<<< HEAD

#   def shift_remain(recalc=false)
#     return @shift_remain if @shift_remain && !recalc
#     @shift_remain = Hash[*%w(0 1 2 3).
#                          zip([limit.code0,limit.code1,limit.code2,limit.code3]).flatten]
#     [ /[^0]/,  /[^1478]/ , /[^25]/ , /[^36]/].
#       each_with_index{|reg,shift| @shift_remain[shift.to_s] -= shifts.gsub(reg,"").size }
#     @shift_remain["0"] -= shifts.gsub(/[^9ABC]/,"").size*0.5
#     @shift_remain["1"] -= shifts.gsub(/[^9ABC]/,"").size*0.5
#     @shift_remain
#   end

#   # 各日の [[role_id,shift],,,[]] が日数分
#   #   何に使っているのだろう。。。わかるまでテストなし
# =======
  def shift_used(recalc=false)
    return @shift_used if @shift_used && !recalc
    @shift_used=Hash.new{|h,k| h[k]=0}

    @shift_used["0"]  =  shifts.gsub(/[^0]/,"").size + shifts.gsub(/[^9ABC]/,"").size*0.5
    @shift_used["1"]  = shifts.gsub(/[^1478]/,"").size + shifts.gsub(/[^9ABC]/,"").size*0.5
    @shift_used["2"]  = shifts.gsub(/[^25]/,"").size
    @shift_used["3"]  = shifts.gsub(/[^36]/,"").size
    @shift_used[:night_total]  = @shift_used["2"] + @shift_used["3"]
    @shift_used[:kinmu_total]  = @shift_used[:night_total] + @shift_used["1"]
    @shift_used
  end

  def shift_remain(recalc=false)
    return @shift_remain if @shift_remain && !recalc
    shift_used true
    @shift_remain = Hash[*Sshift0123.
                         zip([limits.code0,limits.code1,limits.code2,limits.code3]).flatten
                        ]
    @shift_remain[:night_total] = limits.night_total - shift_used[:night_total]
    @shift_remain[:kinmu_total] = limits.kinmu_total - shift_used[:kinmu_total] 
    ["0","1","2","3"].each{ |sft_str|  @shift_remain[sft_str] -= shift_used[sft_str]}
    
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
    roles[hospital_roles.find_by(name: rolename).id]
  end

  def role_id?(role_id);role_ids.include?(role_id) #.to_i);
  end

#>>>>>>> HospitalPower
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

  ############### 統計、集計 ############
  def shift_count(shift)
    case shift
    when 1 ;shifts.gsub(/[^1478]/,"").size + shifts.gsub(/[^9ABC]/,"").size * 0.5
    when 2 ;shifts.gsub(/[^25]/,"").size
    when 3 ;shifts.gsub(/[^36]/,"").size
    end
  end

  def shift1
    monthly.days.
# <<<<<<< HEAD
#       inject(0){|sum,kinmu| sum + [:am,:pm,:am2,:pm2].inject(0){|s,sym| s + kinmu.send(sym) }
#       }
#   end 
#   def shift2
#     monthly.days.inject(0){|sum,kinmu|  sum + kinmu.night+kinmu.night2     }
#   end 
#   def shift3
#     monthly.days.inject(0){|sum,kinmu|  sum + kinmu.midnight+kinmu.midnight2     }
# =======
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
#>>>>>>> HospitalPower
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

  # 
  def check(day,sft_str,imidiate=true)
    ret = []
# <<<<<<< HEAD
#     check_regulation.each{|regulation|
#       [0,sft_str.to_i].each{|s|
#         regulation[s].each_pair{|item,reg_arry|
#           d = check_sub(day,item,reg_arry)
#           if d
#             ret << [item,d]
#             return ret if imidiate
#           end
#         }
# =======
    [0,sft_str.to_i].each{|s|
      check_reg[s].each_pair{|item,regration|
        d = regration.check(day,shift_with_last_month)
        if d
          ret << [item,d]
          return ret if imidiate
        end
#>>>>>>> HospitalPower
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
# <<<<<<< HEAD
#     #[@Reguration,@Wants,Reguration,Wants].each{|regulation|
#     check_regulation.each{|regulation|
#       regulation.each{|reg_hash| # { :after_nights =>  [/[2356]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
#         reg_hash.values.each{|reg_arry|  # [/[2356]{2}[^0_]/,2,5,"連続夜勤明けは休み"]
#           reg,back,length,msg = reg_arry # 
#           if back
#             match = (reg =~ shift_with_last_month)
#             ret <<  [name,msg,[match-4,1].max,shift_with_last_month] if match && match-4+back>0
#           else
#             match = (reg =~ shifts)
#             ret <<  [name,msg,match,shift_with_last_month] if match
#           end
#         }
# =======
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
#>>>>>>> HospitalPower
      }
    }
    ret.uniq
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

end
