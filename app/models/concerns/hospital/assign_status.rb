# -*- coding: utf-8 -*-
# 割付候補選定に用いる、指標の作成を行う
#   
module Hospital::AssignStatus
  include Hospital::Const

  # 重要
  #   ここに有るmethodが返すインスタンス変数は、割付毎に割り付けるmethodの
  #   責任に於いて値の更新を行わなければならない
  #
  #   ここに有るmethodは参照毎に評価するととてもコストがかかるので、
  #   メモ インスタンス変数を返すようにしてある。
  #   しかしその値は 割付毎に変化するものである。
  #   そこで
  #   初期化と参照はこのmethodを通して行うが、そのインスタンス変数の値は
  #   割付methodで更新を行う
  #
  #   role_remain margin_of_role
  ##########################################################################
  # cost計算に関わるものの更新作業が必要
  #  tight_roles -> role_order_by_tightness -> role_remain -> Nurce#role_remain
  #  Nurce#role_remain -> role_used -> shifts
  #  Nurce#cost -> shift_remain -> shifts
  #
  #  nurce_set_shift にて、tnurce.set_shiftを実行した時に、
  #     role_remain を更新する
  #  Nurce#set_shiftを実行した時に shift_remain, role_remain を更新する
  #    はて、、、 shift_remainに縮退できそうだが <- しにくい
  ##########################################################################

  ###############################################################
  # このセクションは、月ごとに決まるが割付の進行では変わらない
  ###############################################################

  # 割り当て可能なroleの数。(まだ割り当て前の状態)
  # { [role_id,シフト] => 数 }。  
  def roles_assignable
    return @roles_assignable if @roles_assignable
    @roles_assignable = Hash.new{|h,k| h[k]=0}
    @nurces.each{|nurce| 
      nurce.assinable_roles.each{ |role_sft,v| @roles_assignable[role_sft] += v  }
    }
    @roles_assignable    
  end

  # 今月必要とされるrole数合計    
  # { [role_id,シフト] => 数 }。  
  def roles_required_total
    return @roles_required_total  if @roles_required_total 
    @roles_required_total = Hash.new{|h,k| h[k] =0 }
    needs_all_days[1..-1].each{|need_of_day|
      @RoleShift.each{|key|    @roles_required_total[key] += (need_of_day[key] || [0])[0]
      }
    }
    
    @roles_required_total 
  end

  ####################################################


  # まだ使われて居らず割り当て可能なroleの数
  # { [role_id,シフト] => 数 }。
  def role_remain(recalc=false)
    return @role_remain if @role_remain && !recalc
    @role_remain = Hash.new{|h,k| h[k]=0}
    @nurces.each{|nurce| 
      nurce.need_role_ids.each{ |role_id|
        nurce.shift_remain.keys.each{ |sft_str|
          @role_remain[[role_id,sft_str]] += nurce.shift_remain(recalc)[sft_str]
        }
      }
    }
    @role_remain
  end

  # roleの余裕数
  #  まだ割り付けられていない看護師のrole数 role_remain - まだ割り付けられていない日のrole数
  def margin_of_role(recalc=false)
    return @margin_of_role if @margin_of_role  && !recalc
    @margin_of_role=Hash.new{|h,k| h[k]=0}
    
    @RoleShift.each{|role_sftstr| 
      @margin_of_role[role_sftstr] = role_remain[role_sftstr]  - roles_required[role_sftstr]
    }
    @margin_of_role
  end

  # 割り当てられたrole数
  # { [role_id,シフト] => 数 }。  
  def roles_assigned(recalc=false)
    return @roles_assigned if @roles_assigned && !recalc
    @roles_assigned = Hash.new{|h,k| h[k]=0}
    @nurces.each{|nurce| 
      nurce.need_role_ids.each{ |role_id|
        nurce.shift_used.keys.each{ |sft_str|
          @roles_assigned[[role_id,sft_str]] += nurce.shift_used(recalc)[sft_str]
        }
      }
    }
    @roles_assigned
  end

  # 現時点でまだ割り付けが終わっていない、これから必要とされる roleの数
  # { [role_id,シフト] => 数 }
  def roles_required(reculc=false)
    return @roles_required  if @roles_required && !reculc  
    @roles_required = Hash.new{|h,k| h[k] =0 }
    short_role_shift[1..-1].each{|short_role_of_day|
      @RoleShift.each{|key|    @roles_required[key] += (short_role_of_day[key] || [0])[0]
      }
    }
    @roles_required
  end

  # 各日の [role,shift] を得る
  # [ { [role,sft_srt]=>[min,max], , ,}, { day_data }, { day_data },,, ] 
  def short_role_shift(reculc=false)
    return @short_role_shift if @short_role_shift && !reculc
    count_role_shift(reculc)
    @short_role_shift = (0..@lastday).map{|day| short_role_shift_of(day) }
    @short_role_shift

  end

  # 指定日の割り当て不足な [role,shift] の数
  def short_role_shift_of(day,reculc=false)
    s_r = Hash.new{|h,k| h[k]=[0,0]}
    rs=count_role_shift(reculc)
    begin
      needs_all_days[day].keys.each{|need_patern|  #need_patern ===> [role,sft_str]
        s_r[need_patern][0] = [0,needs_all_days[day][need_patern][0] - rs[day][need_patern]].max
        s_r[need_patern][1] = [0,needs_all_days[day][need_patern][1] - rs[day][need_patern]].max
      }
    rescue
      dbgout("needs_all_days day:(#{__LINE__})#{day} ")
      raise
    end
    s_r
  end


  # 割り当てられたnurceのroleの集計
  # shift はstring
  def count_role_shift(reculc=false)
    return @count_role_shift if @count_role_shift && !reculc
    @count_role_shift = (0..@lastday).map{|day| 
      count_role_shift_of(day,reculc)
    }
  end

  # ある日の、割り当てられたnurceのroleの集計
  # shift はstring
  def count_role_shift_of(day,reculc=false)
    r_k = Hash.new{|h,k| h[k]=0}
    @nurces.each{|nurce|
      nurce.role_shift(@month,reculc)[day].
      each{|role_sftstr| r_k[role_sftstr] += 1}
    }
    r_k
  end

  ################################################################################
  # 割付methodが値の更新の責任を取るべき method,インスタンス変数の定義終わり
  #################################################################################


  # [ [role_id,[minに対する不足,maxに対する不足]], [,[]],  [,[]]]
  def short_role_of_day_shift(day,shift,reculc=false)
    short_role_shift(reculc)[day].
      select{|role_shift,min_max| role_shift.last == shift }.
      map{|role_shift,min_max| [role_shift.first,min_max]}
  end

  def short_role(day,sft_str,reculc=false)
    short_role_shift(true) if reculc || ! @short_role
    @short_role ||= []
    @short_role[day] ||= { }
    #logger.debug("short_role_shift(reculc)[day].to_a #{short_role_shift(reculc)[day].to_a.join(',')}")
    @short_role[day][sft_str] ||= 
      short_role_shift(reculc)[day].to_a.
      map{|role_shift,min_max| role_shift.first if min_max.first>0 && role_shift.last == sft_str}.
      compact.sort
  end
  def short?(day,sft_str)
    sfts = sft_str == :night_total ? @night : [sft_str]
    short_role_shift_of(day).to_a.map{|role_shift,min_max| 
      role_shift.first if sfts.include?(role_shift.last) && min_max.first>0}.compact.size > 0
  end

  def short_role_name(day,shift)
    short_role(day,shift).map{|role| Hospital::Role.find(role).name }
  end

  # ある日の [role,shift] 毎の不足人数を集計する
  def shiftsum(day)
    (@shiftsum ||=
     @days
     )[day]
  end

  def need(day,role,shift)
    @needs[day][[role,shift]]
  end

  def role_count(nurces)
    ret = Hash.new{|h,k| h[k]=0}
    nurces.each{|nurce|  nurce.need_role_ids.each{|role_id| ret[role_id] += 1}}
    ret
  end

  # unsed only by nurce_paterning_test
  def need(day,role_id,kinmucode_id)
    @needs[day][[role_id,kinmucode_id]] || [0,0]
  end

  def need_nurces_shift(day,sft_str)
    short_role_shift_of(day)[[@Kangoshi,sft_str]][0]
  end

  def roles_count_short(day,sft_str)
    short_role = short_role_shift_of(day)
    Hospital::Need.need_role_ids.map{ |role_id| short_role[[role_id,sft_str]].first }
  end


  # 指定日に割り当て不足な [role,shift] の数

  def short_roles_of_night(day)
    @shifts_night[@night_mode].map{ |sft_str| [sft_str, short_role(day,sft_str)]  }.to_h
  end

  # 現時点で逼迫しているroleのTop3のrole_idを返す
  # 逼迫具合の評価はrole_order_by_tightnessで行い、その中で
  # 日々の割付に要求されるrole(Hospital::Need.roles)を抜き出す。
  def tight_roles(sft_str)
    (role_order_by_tightness(sft_str) & Hospital::Need.roles)[0,3]
  end

  # 割り当てずに残っているrole数の少ない順に並べる
  #   これは margin_of_role(ロールの余裕度)に変えるべきかも。
  def role_order_by_tightness(sft_str)
    role_remain.select{|r_s,remain|  r_s[1]==sft_str }.
      sort_by{|r_s,remain| remain }.
      map{|r_s,remain| r_s[0] }
  end

  def roles_cost(roles,tight)
    tight.inject(0){ |cost,role| cost * 2 + (roles.include?(role) ? 1 : 0 )}
  end
end
