# -*- coding: utf-8 -*-
# 
module Hospital::ReEntrant
  include Hospital::Const

  def assign_night(day,opt = { })
    return true if day > lastday
    raise TimeToLongError,"timed out"  if @limit_time < Time.now
    #refresh
      dbgout("HP ASSIGN #{day}日entry-1")
      dbgout dump("  HP ASSIGN ")
    save_log

    if opt[:dipth] 
#pp ["opt[:dipth]",opt[:dipth]]
      return true  if opt[:dipth] ==0
       opt[:dipth] -= 1
    end

    logger.debug("HOSPITAL ASIGN:(#{__LINE__})必要ロール数："+
                 night.map{ |sft| sft+":["+roles_count_short(day,sft).join(",")}.join("] ")+
                 "]"
                 )
    nurce_combinations_for_shift23 = opt.delete(:nurce_combinations) ||
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
    raise TimeToLongError  if @limit_time < Time.now

      dbgout("HP ASSIGN #{day}日entry-1")
      dbgout dump("  HP ASSIGN ")
    save_log

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

end
