# -*- coding: utf-8 -*-
# 
module Hospital::ReEntrant
  include Hospital::Const

  def assign_night(day,opt = { })
    return true if day > lastday

      dbgout("HP ASSIGN #{day}日entry-1")
      dbgout dump("  HP ASSIGN ")

    if opt[:dipth] 
#pp ["opt[:dipth]",opt[:dipth]]
      return true  if opt[:dipth] ==0
       opt[:dipth] -= 1
    end

    nurce_combinations_for_shift23 = opt[:nurce_combinations] ||
      candidate_combination_for_shift23_selected_by_cost(day)

    return false unless nurce_combinations_for_shift23

    if nurce_combinations_for_shift23 != :fill 
      nurce_combinations_for_shift23.each{ |nurce_combinations|
        nurces = nurce_combinations.values.flatten.uniq
        # 現状保存
        shifts_short_role = save_shift(nurces,day)

        next unless night.all?{ |sft_str| assign_night_shift(day,sft_str,nurce_combinations[sft_str]) }
        return true if assign_night(day+1,opt)
        restore_shift(nurces,day,shifts_short_role)
      }
    else ;return true if assign_night(day+1,opt)
    end
    
    return false
  end

  # 与えられた combination にしたがって、day の shiftを割り付ける
  # long_patern も試みる
  def assign_night_shift(day,sft_str,nurce_combination)
#pp [day,sft_str,nurce_combination.map(&:id)]
    # 長い割付が可能なら割り付ける
    long_plan_combination(need_nurces_shift(day,sft_str),Hospital::Nurce::LongPatern[@koutai3][sft_str].size).
      each{|idx_list_of_long_patern|  # [0,2]

      shifts_short_role = save_shift(nurce_combination,day)

      ret = assign_patern(nurce_combination,day,sft_str,idx_list_of_long_patern)
      #pp ret
      case ret
      when :cannot_assign_this_patern
        restore_shift(nurce_combination,day,shifts_short_role)
        next
      when false # 長い割付の「割り付け時チェック」で失敗。次の長い割付へ
        @count_fail[sft_str] += 1
        #@count_cause[:long][sft_str] += 1
        restore_shift(nurce_combination,day,shifts_short_role)
        next # long_patern
       else  # 成功: ここに入っても、shift1不足でダメなこともある 
        return true
       end
    }
    false
  end

  def assign_night_reentrant(day)
    candidate_combination_for_shift23_selected_by_cost(day).each{ |nurce_combinations|
      # 現状保存
      shifts_short_role = save_shift(nurce_combinations[sft_str],day)
      log_eval_combination day,nurce_combinations
      ret = assign_shift_by_reentrant(nurce_combinations,day,sft_str)
      case ret
      when true; return true # 全割付成功
      when false;            # この看護師組み合わせでは破綻したので次の組み合わせへ
        restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
        return false #next
      else      ; raise "HP #{day}:#{shift} ここにはこないはず assign_daytime_by_re_entrant123"
      end
    }

  end

  # shift分の再帰
  def assign_shift_by_reentrant(nurce_combinations,need_nurces,day,sft_str,single=SecondAndLater)
    raise TimeoutError,"timed out"  if @limit_time < Time.now
 #pp ["########## assign_shift_by_reentrant",need_nurces]
   @entrant_count += 1
    # 長い割付が可能なら割り付ける
#pp ["長い割付が可能なら割り付ける",day,need_nurces,sft_str]
    dbgout("FOR_DEBUG(#{__LINE__}): shift=#{sft_str} need_nurces[sft_str] #{need_nurces[sft_str]}"+
           "Hospital::Nurce::LongPatern[@koutai3][Sshift2].size",
           Hospital::Nurce::LongPatern[@koutai3][Sshift2].size
           )
    long_plan_combination(need_nurces_shift(day,sft_str),Hospital::Nurce::LongPatern[@koutai3][sft_str].size).
      each{|idx_list_of_long_patern|  # [0,2]
      @loop_count += 1

      # 現状保存
      shifts_short_role = save_shift(nurce_combinations[sft_str],day)

      case assign_patern(nurce_combinations[sft_str],day,sft_str,idx_list_of_long_patern)
      when :cannot_assign_this_patern
        restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
        next
      when false # 長い割付の「割り付け時チェック」で失敗。次の長い割付へ
        @count_fail[sft_str] += 1
        #@count_cause[:long][sft_str] += 1
        restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
        next # long_patern
        
      else  # 成功(または既に満たされていた)時は次のshiftへ再帰
        assign_log(day,sft_str,nurce_combinations[sft_str],__LINE__,idx_list_of_long_patern,"SUCCESS")
        return true if single

        #     31日のtshif3より 1日のshift1の方が大きくなるようにする
        #     shift * 100  100,200,300
        new_longest = 1000 + day - sft_str.to_i * 100
        @longest = [new_longest,save_shift(@nurces,day)] if new_longest > longest[0]

        case [sft_str,@koutai3]
        when [Sshift2,true]
          logger.debug("====combination of shift 3 #{nurce_combinations["3"].map(&:id).join(',')}") if nurce_combinations[Shift3].class == Array
          ret = assign_shift_by_reentrant(nurce_combinations,need_nurces,day,Sshift3)

        when [Sshift3,true],[Sshift2,false]
          ret  =  assign_night_by_re_entrant(day+1)
        when [Sshift1,true],[Sshift1,false]
          ret  =  assign_shift1_by_re_entrant(day+1)
        end

        case ret
        when true; 
          dbgout("    (#{__LINE__})HP #{day}:#{sft_str}。TRUE これから後は全部OK。割付終了")
          return true    # これから後は全部OK。割付終了
        when false    # このパターンではこの後の方で破綻;
          restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
          next
        else      ; raise "HP #{day}:#{sft_str} ここにはこないはず long_patern2"
        end
      end
    }
    assign_log(day,sft_str,nurce_combinations[sft_str],__LINE__,nil,"FALSE")
    @count_back[sft_str] += 1
    return false
  end


########################################################################################

  # shift分の再帰
  def assign_shift_by_reentrant_old(nurce_combinations,need_nurces,day,sft_str,single=SecondAndLater)
    raise TimeoutError,"timed out"  if @limit_time < Time.now
    @entrant_count += 1
    # 長い割付が可能なら割り付ける
    dbgout("FOR_DEBUG(#{__LINE__}): shift=#{sft_str} need_nurces[sft_str] #{need_nurces[sft_str]} Hospital::Nurce::LongPatern[@koutai3][Sshift2].size #{Hospital::Nurce::LongPatern[@koutai3][Sshift2].size} ")
    long_plan_combination(need_nurces_shift(day,sft_str),Hospital::Nurce::LongPatern[@koutai3][sft_str].size).
      each{|idx_list_of_long_patern|  # [0,2]
      @loop_count += 1

      # 現状保存
      shifts_short_role = save_shift(nurce_combinations[sft_str],day)

      case assign_patern(nurce_combinations[sft_str],day,sft_str,idx_list_of_long_patern)
      when :cannot_assign_this_patern
        restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
        next
      when false # 長い割付の「割り付け時チェック」で失敗。次の長い割付へ
        @count_fail[sft_str] += 1
        #@count_cause[:long][sft_str] += 1
        restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
        next # long_patern
        
      else  # 成功(または既に満たされていた)時は次のshiftへ再帰
        assign_log(day,sft_str,nurce_combinations[sft_str],__LINE__,idx_list_of_long_patern,"SUCCESS")
        return true if single

        #     31日のtshif3より 1日のshift1の方が大きくなるようにする
        #     shift * 100  100,200,300
        new_longest = 1000 + day - sft_str.to_i * 100
        @longest = [new_longest,save_shift(@nurces,day)] if new_longest > longest[0]

        case [sft_str,@koutai3]
        when [Sshift2,true]
          logger.debug("====combination of shift 3 #{nurce_combinations["3"].map(&:id).join(',')}") if nurce_combinations[Shift3].class == Array
          ret = assign_shift_by_reentrant(nurce_combinations,need_nurces,day,Sshift3)

        when [Sshift3,true],[Sshift2,false]
          ret  =  assign_night_by_re_entrant(day+1)
        when [Sshift1,true],[Sshift1,false]
          ret  =  assign_shift1_by_re_entrant(day+1)
        end

        case ret
        when true; 
          dbgout("    (#{__LINE__})HP #{day}:#{sft_str}。TRUE これから後は全部OK。割付終了")
          return true    # これから後は全部OK。割付終了
        when false    # このパターンではこの後の方で破綻;
          restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
          next
        else      ; raise "HP #{day}:#{sft_str} ここにはこないはず long_patern2"
        end
      end
    }
    assign_log(day,sft_str,nurce_combinations[sft_str],__LINE__,nil,"FALSE")
    @count_back[sft_str] += 1
    return false
  end
end
