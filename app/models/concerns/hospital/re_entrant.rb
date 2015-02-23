# -*- coding: utf-8 -*-
# 
module Hospital::ReEntrant
  include Hospital::Const

  def assign_night(day,opt = { })
    return true if day > lastday
    raise TimeToLongError,"timed out"  if @limit_time < Time.now
    #refresh
      dbgout("### Hospital ASSIGN #{day}日 entry ###")
      dbgout dump("  HP ASSIGN ")
    save_log

    if opt[:dipth] 
#pp ["opt[:dipth]",opt[:dipth]]
      return true  if opt[:dipth] ==0
       opt[:dipth] -= 1
    end

    logger.debug("  HOSPITAL ASIGN:(#{__LINE__})必要ロール数："+
                 night.map{ |sft| sft+":["+roles_count_short(day,sft).join(",")}.join("] ")+
                 "]"
                 )
    nurce_combinations_for_shift23 = opt.delete(:nurce_combinations) ||
      candidate_combination_for_shift23_selected_by_cost(day)

    return false unless nurce_combinations_for_shift23

    if nurce_combinations_for_shift23 != :fill 
    
      logger.debug("  HOSPITAL ASIGN:(#{__FILE__}:#{__LINE__})看護師組み合わせ"+
                   nurce_combinations_for_shift23.map{ |nurce_combinations|
                     night.map{ |sft| sft+":["+nurce_combinations[sft].map(&:id).join(",")
                     }.join("] ")+ "]"    }.join("///")      )
      nurce_combinations_for_shift23.each{ |nurce_combinations|
        nurces = nurce_combinations.values.flatten.uniq
        # 現状保存
        shifts_short_role = save_shift(nurces,day)
        
        logger.debug("  HOSPITAL::ASSIGN(#{__LINE__})#{day}日割付試行 "+
                     "#{night.map{ |sft| sft+':'+ nurce_list(nurce_combinations[sft])}.join('/')} ")
        next unless night.all?{ |sft_str| assign_night_shift(day,sft_str,nurce_combinations[sft_str]) }

        logger.debug("    HOSPITAL ASIGN:(#{__LINE__})#{day}日 看護師組み合わせ ["+
                     nurce_combinations.values.map{ |comb| comb.map(&:id).join(",")}.join("][") +
                     "] は成功")
        return true if assign_night(day+1,opt)
        logger.debug("    HOSPITAL ASIGN:(#{__LINE__})#{day}日 看護師組み合わせ ["+
                     nurce_combinations.values.map{ |comb| comb.map(&:id).join(",")}.join("][") +
                     "] は成功したが、後ろの日ができないのでやり直し")
        
        restore_shift(nurces,day,shifts_short_role)
      }
    else 
      logger.debug("    HOSPITAL ASIGN:(#{__LINE__}) #{day}日は既にOK")
      return true if assign_night(day+1,opt)
    end
    logger.debug("    ＃HOSPITAL::ASSIGN(#{__LINE__})#{day}日 割付候補終了。#{day-1}日に戻る ")    
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

      list_of_long_patern = assign_patern(nurce_combination,day,sft_str,idx_list_of_long_patern)
      #pp ret
      case list_of_long_patern
      when :cannot_assign_this_patern
        restore_shift(nurce_combination,day,shifts_short_role)
        next
      when false # 長い割付の「割り付け時チェック」で失敗。次の長い割付へ
        @count_fail[sft_str] += 1
        #@count_cause[:long][sft_str] += 1
        restore_shift(nurce_combination,day,shifts_short_role)
        next # long_patern
       else  # 成功: ここに入っても、shift1不足でダメなこともある 
        logger.debug("    HOSPITAL::ASSIGN(#{__LINE__}) パターン"+
                     "[#{list_of_long_patern.map(&:patern).join(',')}]は成功")
        return true
       end
    }
    false
  end


  # 看護師の勤務制限は満たしていても、2日目以降の日々の制限は確認していない。
  # 長い勤務を割り当てたときに、二日目以降に重大な支障が有るか否かを確認する。
  # [day] Integer 割付の最初の日付。
  # [sft_str]  1,2,3。割り付けるsft_str
  # [list_of_long_patern_and_dayly_check]   #assigned: [ [LongPatern,daily_checks],[LongPatern,daily_checks],[] ]
  #                       『Hospital::Nurce::LongPatern[sft_str][patern_番号]』
  def assign_patern(nurces,day,sft_str,idx_list_of_long_patern)
    return :done if nurces == true
    @count_eval[sft_str] += 1
    unless list_of_long_patern = assign_patern_if_possible(nurces,day,sft_str,idx_list_of_long_patern)
      #logger.debug("    HOSPITAL ASIGN:(#{__LINE__})看護師組み合わせ")
      return :cannot_assign_this_patern
    end
    unless long_check_later_days(day,merged_patern(list_of_long_patern),sft_str)
             logger.debug("      HOSPITAL::ASSIGN(#{__LINE__}) パターン"+
                          "[#{list_of_long_patern.map(&:patern).join(',')}]は取り消し")
      return false
    end
    unless  avoid_check(nurces,sft_str,day,list_of_long_patern)
        logger.debug("      HOSPITAL::ASSIGN(#{__LINE__}) パターン"+
                          "[#{list_of_long_patern.map(&:patern).join(',')}]は 組み合わせ禁忌。取り消し")
        return false
    end
    list_of_long_patern #true
  end

  def assign_patern_if_possible(nurces,day,sft_str,idx_list_of_long_patern)
    # この長い割付が可能か                                                # [0,2]
    list_of_long_patern = 
      assign_test_patern(nurces,day,sft_str,idx_list_of_long_patern)
#pp ["pp list_of_long_patern",idx_list_of_long_patern,list_of_long_patern]
    return false unless list_of_long_patern
    (0..nurces.size-1).each{|idx|
      nurce_set_patern(nurces[idx],day,list_of_long_patern[idx].patern)
    }
    list_of_long_patern
  end


  # 評価する看護師組み合わせはその日の分は制限をみたしているが、
  # その日を起点とした長い割付を行う場合2日目以降は確認していない。
  # assign_test_paternで その看護師の勤務制限を満たしているか調べ
  # 満たしているものについてassign_paternで割付を試みる。
  # 
  # 元々は3日以上の割付パターンについて行う予定であったが、プログラムの
  # 簡潔化のために、1日の割付もここで行うことにした。
  # [long_patern]  『Hospital::Nurce::LongPatern[shift]』の何番目を試すのか、を
  #                 看護師分用意した配列。要素はInteger [0,2]
  def  assign_test_patern(nurce_list,day,sft_str,idx_set_of_long_patern)
    #[ LongPatern,LongPatern]
    paterns = (0..nurce_list.size-1).map{|idx|
    #pp [@koutai3,sft_str,nurce_list.map(&:id),idx_set_of_long_patern,idx]
      long_patern,errorlist =  
      nurce_list[idx].long_check(day,sft_str,
                                 Hospital::Nurce::LongPatern[@koutai3][sft_str][idx_set_of_long_patern[idx]])
      if long_patern
        long_patern # ,daily_checks]
      else
        # このとき、daily_checkは[item,正規表現の配列
#pp [errorlist]
        errorlist.each{|item,reg| @count_cause[item][sft_str]+=1 }
        return false
      end
    }
    #return paterns if avoid_check(nurce_list,sft_str,day,paterns)
    #false
  end
  
  # 2日目以降に重大な支障が出ないか調べる。
  # 調べるshiftと調べるべき日は daily_checksに格納されている
  # [daily_checks] Hospital::Nurce::LongPaternの第６項目、調べるべきshiftと調べるべき日(のofset)
  # 
  # 現在のチェック項目
  #   roleの割り当てすぎ：roleを使いすぎると以降の日の割付が厳しくなる
  #   休日の入りすぎ：休を入れすぎるとその日の看護師が足りなくなる
  #   当日、前日のシフト１は看護師が足りるか
  def long_check_later_days(day,daily_checks,shift_str)
    @shifts.each{|sft_str|  
      daily_checks[sft_str.to_i].each{|d|
        next if day+d > @lastday
        return false unless too_many_assigned?(day+d,sft_str)
      }
    }
    return false unless shift1_is_enough?(day,shift_str)
    true
  end

  #   当日、前日のシフト１は看護師が足りるか
  def shift1_is_enough?(theday,shift_str)
    return true if  shift_str == "1"
    days = theday == 1 ? [0] : [0,1]
    days.all?{ |d|
      day = theday - d
      short     = short_role_shift[day][[@Kangoshi,Sshift1]][0] 
      assinable = assinable_nurces(day,Sshift1,short_role(day,Sshift1)).size
      if short - assinable > 0
        dbgout("      長割後日チェック(#{__LINE__}) #{theday}日への割付で#{day}日の日勤要員不足発生する。" +
               "　　#{short}人必要な所可能なのは#{assinable}人\n" +
               "    この割付は取り消し")
        return false
      else
        true
      end
    }
    dbgout("      長割後日チェック(#{__LINE__}) #{theday}日への割付で日勤要員不足発生せず")
    true
  end

  def too_many_assigned?(day,sft_str)
    case too_many?(day,sft_str)
    when -1 ; 
      dbgout("      FOR_DEBUG(#{__LINE__}) "+
             "長割後日チェック(#{day}日,shift:#{sft_str}) 割り当て最大値を越えた")
      return false
    when 0
      case sft_str
      when Sshift2,Sshift3
        s_r = short_role(day,sft_str).size ==0 ? "なし" :  short_role(day,sft_str).join
        #pp("長割後日チェック(#{__LINE__}) (#{ day}):#{sft_str} ロール不足#{ s_r }")
        if short_role(day,sft_str).size >0
          dbgout("      長割後日チェック(#{__LINE__}) (#{ day}):#{sft_str} ロール不足#{ s_r }")
          return false 
        end
      end
    when 1 ; dbgout("      FOR_DEBUG(#{__LINE__}) 長割後日チェック割り当て最大値以下(#{day}日,shift:#{sft_str})")

    end
    true
  end

  # shiftの割り付けがmaxを越えていないか。needs_all_days[day][key][1] - role_shift[day][key]
  #  key == [ role, sft_str ]
  def too_many?(day,sft_str)
    #指定日のシフトは人の余裕あるか
    case sft_str
    when Sshift0,Sshift2,Sshift3 ; 
       needs_all_days[day][[@Kangoshi,sft_str]][1] <=> count_role_shift[day][[@Kangoshi,sft_str]]
    when Sshift1         ;    
    end
  end

end
