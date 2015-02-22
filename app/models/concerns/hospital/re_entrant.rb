# -*- coding: utf-8 -*-
# 
module Hospital::ReEntrant
  include Hospital::Const

  def assign_night(day,opt = { })
    return true if day > lastday
    #refresh
    logger.debug("HOSPITAL ASIGN:(#{__LINE__})10日の必要ロール数："+
                 night.map{ |sft| sft+":["+roles_count_short(10,sft).join(",")}.join("] ")+
                 "]"
                 )
      dbgout("HP ASSIGN #{day}日entry-1")
      dbgout dump("  HP ASSIGN ")

    if opt[:dipth] 
#pp ["opt[:dipth]",opt[:dipth]]
      return true  if opt[:dipth] ==0
       opt[:dipth] -= 1
    end

    logger.debug("HOSPITAL ASIGN:(#{__LINE__})必要ロール数："+
                 night.map{ |sft| sft+":["+roles_count_short(day,sft).join(",")}.join("] ")+
                 "]"
                 )
    nurce_combinations_for_shift23 = opt[:nurce_combinations] ||
      candidate_combination_for_shift23_selected_by_cost(day)

    return false unless nurce_combinations_for_shift23

    if nurce_combinations_for_shift23 != :fill 
    
      logger.debug("HOSPITAL ASIGN:(#{__FILE__}:#{__LINE__})看護師組み合わせ"+
                   nurce_combinations_for_shift23.map{ |nurce_combinations|
                     night.map{ |sft| sft+":["+nurce_combinations[sft].map(&:id).join(",")
                     }.join("] ")+ "]"
                   }.join("///")
                   )
      nurce_combinations_for_shift23.each{ |nurce_combinations|
        nurces = nurce_combinations.values.flatten.uniq
        # 現状保存
        shifts_short_role = save_shift(nurces,day)
        
        logger.debug("HOSPITAL::ASSIGN(#{__LINE__})割付試行 "+
                     "#{night.map{ |sft| sft+':'+ nurce_list(nurce_combinations[sft])}.join('/')} ")
        next unless night.all?{ |sft_str| assign_night_shift(day,sft_str,nurce_combinations[sft_str]) }
        return true if assign_night(day+1,opt)
        restore_shift(nurces,day,shifts_short_role)
      }
    else ;return true if assign_night(day+1,opt)
    end
    
    return false
  end


  def assign_shift1(day,opt={ })
    @night_mode = false
    tight = assign_tight_daies_first
    dbgout("HP ASSIGN (#{__LINE__})return from assign_tight_daies_first with #{tight}")
    tight && assign_shift1_by_re_entrant(day,opt)
  end


  def ddassign_shift1_by_re_entrant(day)
    #@day = day
    return true     if day > @lastday 
    raise TimeoutError,"timed out"  if @limit_time < Time.now

    ### Begin  New Day ###########
    log_newday_entrant(day)
    combinations ,need_nurces, short_roles = ready_for_day_reentrant(day)
    return false unless combinations

    ncm = nCm(combinations[Sshift1].size,need_nurces_shift(day,Sshift1).size)
    comb ,need =  combinations[Sshift1].size,need_nurces_shift(day,Sshift1).size
    try = 0 
    nurce_combination_shift1(combinations,need_nurces,short_roles,day){|nurce_combinations| 
      unless nurce_combinations
        assign_log(day,Sshift1,nil,__LINE__, @msg)
        return false
      end
      #return false if @night_mode && not_enough_for_shift1(nurce_combinations,need_nurces,short_roles,day)

      dbgout("HP AASIGN #{day}:#{Sshift1} Try #{try += 1} of #{ncm} need #{comb}C#{need}")
      return true if assign_day_reentrant(day,nurce_combinations,need_nurces,Sshift1)
    }
    # 全組み合わせを調べてうまく行かないときは、前の日に戻る
    #     restore_shift(comb_nurces,day,shifts_short_role,shift)
    assign_log(day,Sshift1,nil,__LINE__,nil,"BACK: hk全候補終了")
    false
  end


  def assign_tight_daies_first #Hospital::Assign.create_assign(1,Date.new(2013,2,1))
    dbgout("HP AASIGN TIGHT_DAY FIRST")
    tight_daies = (1..@lastday).
      map{|day| 
      [assinable_nurces(day,Sshift1,[[@Kangoshi,Sshift1]]).size-short_role_shift[day][[@Kangoshi,Sshift1]].first,day] }.
      sort_by{ |c,day| c }

    most_tight_daies = tight_daies.map{ |c,day| "#{day}:#{c} " if c<4 }.compact.join(',')
    dbgout("HP ASSIGN MOST TIGHT_DAYs are #{most_tight_daies}")

    return false if tight_daies[0].first < 0
    dbgout("HP AASIGN TIGHT_DAY FIRST do tight days ")
    ret = true
    tight_daies.each{ |yoyuu,day|
      dbgout("HP AASIGN TIGHT_DAY FIRST do #{day}日 余裕#{yoyuu} ")
      if  yoyuu > 3
        ret= true
        break
      else 
        unless assign_shift1_by_re_entrant(day,:dipth => 1) #assign_single_day(day,"1")
          ret= false
          break
        end
      end
    }
    dbgout("HP AASIGN TIGHT_DAY FIRST exit ")
    #@longest =  [0,0]
    ret
  end

  def assign_single_day(day,sft_str)
    dbgout("HP ASSIGN #{day}日entry-0")
    dbgout("assign_single_day")
    dbgout dump("  HP ASSIGN ")
    combinations,need_nurces,short_roles = ready_for_day_reentrant(day)
    return false unless combinations
    ncm = nCm(combinations[sft_str].size,need_nurces_shift(day,sft_str).size)
    try = 0 
    nurce_combination_shift1(combinations,need_nurces,short_roles,day){|nurce_combinations|
      dbgout("HP AASIGN #{day}:#{sft_str} Try #{try += 1} of #{ncm}")
      ret = assign_shift_by_reentrant(nurce_combinations,need_nurces,day,sft_str,true)
      dbgout("HP AASIGN MOST TIGHT_DAY #{day}日 結果#{ ret}")
      return true if ret
    }
    false
  end

  def assign_shift1_by_re_entrant(day,opt = { })
    return true if day > lastday

      dbgout("HP ASSIGN #{day}日entry-1")
      dbgout dump("  HP ASSIGN ")

    if opt[:dipth] 
#pp ["opt[:dipth]",opt[:dipth]]
      return true  if opt[:dipth] ==0
       opt[:dipth] -= 1
    end

    nurce_combinations_for_shift = opt[:nurce_combinations] ||
      candidate_combination_for_shift_selected_by_cost(day,"1")

    return false unless nurce_combinations_for_shift

    if nurce_combinations_for_shift != :fill 
      nurce_combinations_for_shift.each{ |nurce_combination|
        nurces = nurce_combination["1"]
        # 現状保存
        shifts_short_role = save_shift(nurces,day)

        assign_shift_daytime(day,nurces)
        return true if assign_shift1_by_re_entrant(day+1,opt)
        restore_shift(nurces,day,shifts_short_role)
      }
    else ;return true if assign_shift1_by_re_entrant(day+1,opt)
    end
    
    return false
  end

  # 与えられた combination にしたがって、day の shiftを割り付ける
  # long_patern も試みる
  def assign_shift_daytime(day,nurce_combination)
    nurce_combination.each{ |nurce| nurce_set_shift(nurce,day,"1")}
  end

  def assign_night_shift(day,sft_str,nurce_combination)
#pp [day,sft_str,nurce_combination.map(&:id)]
    # 長い割付が可能なら割り付ける
    return true if (need_nurces = need_nurces_shift(day,sft_str)) == 0
    long_plan_combination(need_nurces,Hospital::Nurce::LongPatern[@koutai3][sft_str].size).
      each{|idx_list_of_long_patern|  # [0,2]

    logger.debug("HOSPITAL ASIGN:(#{__LINE__})10日の必要ロール数:loop long_patern："+
                 night.map{ |sft| sft+":["+roles_count_short(10,sft).join(",")}.join("] ")+
                 "]"
                 )
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
    logger.debug("HOSPITAL ASIGN:(#{__LINE__})10日の必要ロール数:loop long_patern restore_shift ："+
                 night.map{ |sft| sft+":["+roles_count_short(10,sft).join(",")}.join("] ")+
                 "]"
                 )
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
