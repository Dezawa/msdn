# -*- coding: utf-8 -*-
# 
module Hospital::ReEntrant
  include Hospital::Const

  # 夜勤の割付を再帰で行う
  # opt
  #  :dipth 再帰の回数。 0 になったら終わり。debug、test用
  #  :nurce_combinations  看護師の組み合わせの候補。
  #     本来は再帰の中で再帰毎(割り当てshift毎)に作る。
  #     初日だけは親から与えられる。これは次の二つの理由から
  #      (1)timeoutしたとき次の初日候補を与えるのは、例外を補足するmethod
  #      (2)複数の解を作るバージョンでは、初日候補を順に与える必要がある
  def assign_night(day,opt = { })
    return true if lastday_or_reentrant_limit_or_timeout(day,opt)
    #refresh
    log_newday_entrant(day)
    log_need_roles_of(day,night,__LINE__)

    nurce_combinations_for_shift23 = opt.delete(:nurce_combinations) ||
      candidate_combination_for_shift23_selected_by_cost(day)

    case nurce_combinations_for_shift23
    when nil   
      logger.debug("  HOSPITAL ASIGN:(#{__LINE__}) #{day}日.看護師の組み合わせができない")
      return false 
    when :fill
      logger.debug("    HOSPITAL ASIGN:(#{__LINE__}) #{day}日は既にOK")
      return true if assign_night(day+1,opt)
    else
      logout_nurce_combinations(nurce_combinations_for_shift23,__LINE__)
      ######
      nurce_combinations_for_shift23.each{ |nurce_combinations|
        shifts_short_role = save_shift(nurces,day)
        return true if try_assign_by_this(nurce_combinations,day,opt)
        restore_shift(nurces,day,shifts_short_role)
      }
      #####
    end
    logger.debug("    ＃HOSPITAL::ASSIGN(#{__LINE__})#{day}日 割付候補終了。#{day-1}日に戻る ")    
    return false
  end

  def try_assign_by_this(nurce_combinations,day,opt)
        nurces = nurce_combinations.values.flatten.uniq
        logger.debug("  HOSPITAL::ASSIGN(#{__LINE__})#{day}日割付試行 "+
                     "#{night.map{ |sft| sft+':'+ nurce_list(nurce_combinations[sft])}.join('/')} ")
        return false unless night.all?{ |sft_str| assign_night_shift(day,sft_str,nurce_combinations[sft_str]) }

        logger.debug("    HOSPITAL ASIGN:(#{__LINE__})#{day}日 看護師組み合わせ ["+
                     nurce_combinations.values.map{ |comb| comb.map(&:id).join(",")}.join("][") +
                     "] は成功") 
        save_longhest(day,:night)

        return true if assign_night(day+1,opt)
        logger.debug("    HOSPITAL ASIGN:(#{__LINE__})#{day}日 看護師組み合わせ ["+
                     nurce_combinations.values.map{ |comb| comb.map(&:id).join(",")}.join("][") +
                     "] は成功したが、後ろの日ができないのでやり直し")
    false
  end
  # 再帰の終了判定を行う。
  # 月の最終日を過ぎたら終了。
  # もしくは再帰に入るときにしていした再帰回数 opt[:dipth]に達したら終了。
  # もしくはtimeoutなら 例外発生
  def lastday_or_reentrant_limit_or_timeout(day,opt={ })
    raise TimeToLongError,"timed out"  if @limit_time < Time.now

    return true if day > lastday
    if opt[:dipth]
      return true  if opt[:dipth] ==0
      opt[:dipth] -= 1
    end
    false
  end

  # 日勤の割付を再帰で行う
  # 余裕の少ない日をまず割付け #assign_tight_daies_first
  # 残りの日を再帰で行う
  def assign_shift1(day,opt={ })
    @night_mode = false
    tight = assign_tight_daies_first
    dbgout("HP ASSIGN (#{__LINE__})return from assign_tight_daies_first with #{tight}")
    tight && assign_shift1_by_re_entrant(day,opt)
  end

  def assign_tight_daies_first #Hospital::Assign.create_assign(1,Date.new(2013,2,1))
    dbgout("HP AASIGN TIGHT_DAY FIRST")
    # while (tight_daies = shift_tight_days) && tight_daies.first && tight_daies.first.first < 4
    while tight_daies = remain_tight_days(4)
      most_tight_daies = tight_daies.map{ |c,day| "#{day}:#{c} " if c<4 }.compact.join(',')
      dbgout("HP ASSIGN MOST TIGHT_DAYs are #{most_tight_daies}")
      if tight_daies[0].first < 0
        dbgout("HP AASIGN TIGHT_DAY FIRST 失敗 ")
        return false 
      end
      dbgout("HP AASIGN TIGHT_DAY FIRST do tight days ")
      yoyuu,day = tight_daies.first
      ret = true
      #tight_daies.each{ |yoyuu,day|
      dbgout("HP AASIGN TIGHT_DAY FIRST do #{day}日 余裕#{yoyuu} ")
      unless assign_shift1_by_re_entrant(day,:dipth => 1)
        dbgout("HP AASIGN TIGHT_DAY FIRST 失敗 ")
        return false
      end
    end
    dbgout("HP AASIGN TIGHT_DAY FIRST exit ")
    #@longest =  [0,0]
    true
  end

  def remain_tight_days(yoyuu_suu)
    tight_daies = shift_tight_days
    return nil unless tight_daies.first && tight_daies.first.first < yoyuu_suu
    tight_daies
  end

  def shift_tight_days(sft_str = Sshift1)
    (1..@lastday).
      map{|day|
      needs = short_role_shift[day][[@Kangoshi,sft_str]].first
      [ assinable_nurces(day,sft_str,[[@Kangoshi,sft_str]]).size - needs ,
        day  ]  if  needs > 0
    }.compact.sort_by{ |c,day| c }
  end

  def night_tight_days
    (1..@lastday).
      map{|day|
      needs = @night.map{ |sft_str| short_role_shift[day][[@Kangoshi,sft_str]].first}
      assignable = @night.map{ |sft_str|  assinable_nurces(day,sft_str,[[@Kangoshi,sft_str]]).size}
     [ assignable.sub(needs).min, day ] if needs.max>0
     }.compact.sort_by{ |c,day| c }
  end


  def assign_shift1_by_re_entrant(day,opt = { })
    return true if lastday_or_reentrant_limit_or_timeout(day,opt)
    log_newday_entrant(day)

    nurce_combinations_for_shift = opt[:nurce_combinations] ||
      candidate_combination_for_shift_selected_by_cost(day,"1")

    case nurce_combinations_for_shift
    when nil
      logger.debug("  HOSPITAL ASIGN:(#{__LINE__}) #{day}日.看護師の組み合わせができない")
      return false 
    when :fill
      logger.debug("    HOSPITAL ASIGN:(#{__LINE__}) #{day}日は既にOK")
      return true if  assign_shift1_by_re_entrant(day+1,opt)
    else
      nurce_combinations_for_shift.each{ |nurce_combination|
        # 現状保存
        shifts_short_role = save_shift(nurces,day)

        nurces = nurce_combination["1"]
        next unless assign_shift_daytime(day,nurces)
        save_longhest(day,:daytime) unless opt[:dipth]
        return true if assign_shift1_by_re_entrant(day+1,opt)

        restore_shift(nurces,day,shifts_short_role)
      }
    end
    return false
  end

  # 与えられた combination にしたがって、day日 の日勤を割り付ける
  def assign_shift_daytime(day,nurce_combination)
    nurce_combination.each{ |nurce| nurce_set_shift(nurce,day,"1")}
  end

  # 与えられた combination にしたがって、day日 の夜勤を割り付ける
  # long_patern 長い割付が可能なら割り付ける
  #  可能とは
  #    既に希望などで割り付けられた本人の勤務と衝突しない
  #    連続勤務、夜勤上限などに抵触しない
  #    明日以降で、他の人の勤務を合わせても割り当て上限を越えることがない
  # 以下の事はここでは見ていないので、このmethodのあとで呼び元が調べ直す
  #    今日と昨日に日勤を割り付ける余裕がない
  #    明日以降の夜勤で、割り付けが偏ってroleが足りなくなる日がでる
  def assign_night_shift(day,sft_str,nurce_combination)
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


  # 指定された看護師の指定された日以降にpaternな勤務を割り当てる
  # paternは0123からなる文字列。
  # このパターンを割り当てても制約を満たすことを事前に確認されていること
  def nurce_set_patern(nurce,day,patern)
    logger.info("    HOSPITAL::ASSIGN(#{__LINE__})#長い割付仮設定=#{day}日,patern #{patern} :Nurce #{nurce.id} roles#{nurce.roles.map{|id,nm| id}}")
    (0..patern.size-1).each{|d| 
      nurce_set_shift(nurce,day+d,patern[d,1])
    }
    patern
  end

  # 指定された看護師の指定された日に勤務 sft を割り当てる。
  # sft は 0123 な文字かInteger。
  # 割り当てたあと、 割付methodが値の更新の責任を取るべき method,インスタンス変数の更新を行う
  # 
  def nurce_set_shift(nurce,day,shift_str)
    nurce.set_shift(day,shift_str)
    count_role_shift[day] = count_role_shift_of(day)
    short_role_shift[day] = short_role_shift_of(day)
    nurce.need_role_ids.each{|role_id,name| 
      role_remain[[role_id,shift_str]] -= 1
      #      margin_of_role[[role_id,shift_str.to_i]] -= 1
    }
    shift_str
  end

  # long_patenの配列から2日目以降のチェック指示部分を抜きだし、
  # 同じ内容のものは一つにまとめる。チェックの重複防止
  # [list_of_long_patern_and_dayly_check] 看護師各々に割り当てた long_patenの配列
  #                  [ [LongPatern,daily_checks],[LongPatern,daily_checks],[] ]
  def merged_patern(list_of_long_patern)
    @shifts_int.map{|shift| 
      list_of_long_patern.inject([]){|ary,long_patern|  
        ary + long_patern.target_days[shift]
      }.uniq 
    }
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
        return false unless roles_able_be_filled?(day+d,sft_str)
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
      assinable = assinable_nurces(day,Sshift1,[[@Kangoshi,Sshift1]]).size
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

  # その日はロールが満たされたか、もしくは
  # 将来満たすことが可能か
  # すなわち
  #   残り看護師数 < 足りないロール数
  # ということはないか
  # とりあえず、不足人数分の看護師が居るかどうかだけみる。shift2,3での潰し合いは見ない
  def roles_able_be_filled?(day,sft_str)
    return true if sft_str == "0"
    roles_count = roles_count_short(day,sft_str)
    return true if roles_count.max <= roles_count[@kangoshi_idx_of_need_roles]
    logger.debug("    HOSPITAL ASSIGN: ロール不足数>看護師必要数 [#{roles_count.join(',')}]")
    false
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

  def  save_longhest(day,day_or_night = :daytime)
    #     31日のshift3より 1日のshift1の方が大きくなるようにする
    new_longest = (day_or_night == :night ? 0 : 100)  + day 
    if new_longest > longest[0]
      @longest = [new_longest,save_shift(@nurces,day)]
      logger.debug("    ## set longest #{day} #{day_or_night} #{new_longest}")
    end
  end
end
