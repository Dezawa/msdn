# -*- coding: utf-8 -*-
#
ID = "$Id: assign.rb,v 1.1.2.87 2013-08-23 07:49:54 dezawa Exp $"
#
require 'extentions'
# 
#
LogPuts,LogDebug,LogInfo = 1,2,4

# ARではない
# 割付を行うためのclass. 
# 一職場の全職員とその一月分の勤務状況を取り込んで、表示、割付を行う
# 
# 割付は再帰で行う。
# assign_day_by_re_entrant123にて日の再帰を行い、そこから呼ばれる assign_shift_by_reentrant にて
# 各勤務を再帰する。
#  与えられた制限時間を越えるとTimeout例外が発生する。この例外は再帰の起動元assign_days_by_re_entrantが
#  キャッチし、それまでに達した一番深い割付として終了する。
#
# 割付順は 231,231,231 と毎日を順に割り付ける
#   22222, 33333, 11111もしくは 23,23,23,23 11111 と夜勤を割り付けてから日勤を割付た方が早い。
#   しかし、運が悪いと1が足りない日を作ってしまうことが有る。その場合大幅にやり直しが必要となり
#   timeoutしてしまう。その防止のため日ごとに決めることとした
# 
###########################  高速化やり直し #################
# 病棟看護師数が増えると、nCm が巨大になるため、渋滞停止。
# 
# 高速化準備作業
#  #assign_month の下部構造を見る
# 
#  assign_month_mult
#   assign_mult
#    + assign_days_by_re_entrant
#    |  + assign_days_by_re_entrant123(day)
#    |  |  + short_role(day,3,true)   # この日のこのshiftの看護師の必要数と不足role
#    |  |  + short_role_shift_of(day) # 看護師の必要数
#    |  |      ここまでlogに出て止まる。
#    |  |  
#    |  |  + nurce_combination_by_tightness # shift 1,2,3 各々の看護師組み合わせの配列を作る
#    |  |      + nurces.combination(need_nurces)   9Ｃ20 ->  9C30 -> 
#    |  |           sort_by{  cost_of_nurce_combination  }
#    |  |      
#    |  |  + combination_combination_for_123{ # shift 2,3 の組み合わせの組み合わせを一つずつ作る
#    |  |  | {
#    |  |  +   assign_shift_by_reentrant
#    |  |  |     + long_plan_combination  
#    |  |  |     |  { 
#    |  |  |     |    assign_test_patern 
#    |  |  |     |      + nurce_set_patern
#    |  |  |     |      + long_check_later_days
#    |  |  |     |      |    + too_many?
#    |  |  |     |    assign_patern  
#    |  |  |     |    case
#    |  |  |     |       assign_day_by_re_entrant123
#    |  |  |     |       assign_shift_by_reentrant
#    |  |  |     |   } 
#    |  |  | } 
#    |
#    + restore_shift(@nurces,day,@longest[1]) if @longest
# 
#  nurce_combination_by_tightness が巨大過ぎるのが原因
#    conbination.select.sort   select で 3C30、2C30、10C30 が残る
#       3C30 = 30*29*28/6 = 140*30 = 4060
#       2C30 = 30*29/2             =  435
#      10C30                       = 7.3 * 10^25
# 
#       3C20 = 20*19*18/6 = 1140
#       2C20 = 20*19/2    =  190
#      10C20 =            =   6.7 * 10^11
# 
#(1) shift 1 については nurce_combination_by_tightness を作らないことにしよう
#(2) アサイン可能な看護師の数を、優先度順で20人程度に絞る
#(3) shift2,3も、top 50位に減らそう
# 
# 
# 
# 
# 
#############################################################
# 高速化は次の視点で行われた
# 1. 評価の高速化
# 1.1. 看護師毎の制約の評価の高速化
# 1.2. 日の制約の評価の高速化
# 2. 評価回数の減少
# 2.1. 候補数の縮退
# 2.2. やり直しの防止
#
# 1. 評価の高速化
# 1.1. 看護師毎の制約の評価の高速化
#        一月の勤務状態を 29～32Byte(月の日数+1)の文字列として表し、
#        制約条件を正規表現で表し、matchすれば抵触。
# 1.2. 日の制約の評価の高速化
#       この評価を行わなくても済むように2で工夫した。
#       ただし
#         220,220330の様な長い割付を行う場合は、二日目以降は評価した。long_check_later_days
#         
# 2. 評価回数の減少
# 2.1. 候補数の縮退
#     下記の方法で、割付を試みる各shiftの看護師群を選ぶ。
#     ここで選ばれたものは日の制約も看護師の制約もクリアしているので1.2の評価は不要。
#     ただし、この日を起点に220、330、220330の割り振りを試みる場合は2日目以降については
#     追加の評価を行う必要が有る。long_check_later_days
#  (1)看護師の絞り込み  assinable_nurces
#       その日にそのshiftを割り当てても制約に抵触しない看護師で
#       かつ、そのshiftに不足しているroleを少なくとも一つ持つ者
#  (2)看護師組み合わせの絞り込み
#       その看護師群から必要人数の組み合わせを作る。
#       その中で、必要なロールが揃うもの
#  (3)看護師の組み合わせの組み合わせの絞り込み
#        shift1,2,3の看護師組み合わせの組み合わせを作る
#        その中で、各shiftdの看護師が重複しないもの
# 
# 2.2. やり直しの防止
#        やり直し とは、割付が破綻したときに一つ前のshift、日に戻って
#        次の候補について評価を行うこと。
#  (1)看護師に その日そのshift を割り当てる場合のcostを定義する。
#  (2)看護師の組み合わせのcostは看護師のcostの総計とする。
#  (3)この組み合わせのcostが小さい順に 2.1(2)の「看護師の組み合わせ」をsortする
#  (4)costの総計でsortされた2.1(2)の各shiftの順で2-1(3)の組み合わせの組み合わせを作る
#       正確にはちょっと違うが
#  costは
#  (i)それぞれのshiftでどのroleが余裕が少ないか調べそのTop3を得る
#  (ii)看護師のroleがそのTop3のどれを持つか、によってcost Baseが決まる
#  (iii)看護師がそのroleをあといくつ持つか、でcostが決まる
# 
# コストには以下も考慮が必要と思われる
#  看護師長、主任であるかどうか：
#  2,3シフト毎だけでなく、夜勤総数残
#     Hospital::Assign
class Hospital::Assign
  include Hospital::WhichPatern
  include Hospital::Const
  include Hospital::NurceCombination
  delegate :logger, :to=> "ActiveRecord::Base"
  #delegate :breakpoint, :to=>"ActiveRecord::Base"
  attr_accessor :nurces,:kangoshi,:Kangoshi,:needs,:count_role_shift,:nurce_assignd,:need_patern,:error,:roles
  attr_accessor :restore_count, :entrant_count, :loop_count, :shortcut
  attr_accessor :exit_confition,:month
  attr_accessor :night_mode, :avoid_list

  # 未使用トライアル中な、combination_combination_tightness にて使われる、
  # 低コスト割付優先すべき看護師群の shift2,3の組み合わせを実際に作ってコストで
  # sortする、という場合に、top何組ずつで組み合わせるか、を決める
  Top = 3
  SelectedMax = 20-1 #(2) assign可能な看護師が多数居るとき、コストからみて最初の何人かで組み合わせを作る
  # 指定された時間  Hospital::Const::Timeout 経過したとき発生させるエラー
  class TimeoutError < StandardError
  end

  def self.create_assign(busho_id,month,all=nil)
    assign = self.new(busho_id,month)
    #begin
      assign.assign_month_mult(all)
    #rescue => a
    #  logger(a)
    #  true
    #end
  end

  def initialize(arg_busho_id,arg_month)
    $HP_DEF = Hospital::Define.create

    @Kangoshi = Hospital::Role.find_by_name("看護師").id
    
    @koutai3 = Hospital::Define.koutai3?
    @shifts_int= @koutai3 ? Shift0123 : Shift0123[0..-2]
    @shifts = @koutai3    ? Sshift0123 : Sshift0123[0..-2]
    @shifts123 = @koutai3 ? Sshift123  : Sshift123[0..-2]
    @shiftsmx = @shifts123[-1] #  Sshift2 or Sshift3
    @night  = @shifts123[1..-1] # [Sshift2] or [Sshift2,Sshift3]
    @shifts_night = { true =>  @night, false => [Sshift1], nil => [Sshift1]}
    #dbgout("FOR_DEBUG(#{__LINE__}) init @night=#{@night},@koutai3:#{@koutai3} @shifts#{@shifts}")

    if arg_busho_id
      @month = arg_month.to_date
      @busho_id = arg_busho_id
      @lastday=@month.end_of_month.day
      @nurces = Hospital::Nurce.by_busho(@busho_id)
      @kangoshi = @nurces.select{|nurce| nurce.shokushu_id == @Kangoshi }
      @needs  = needs_all_days
      @count_role_shift = count_role_shift     # [[[[role,shift],[role,shift],,],[day  ],[day]],[nurce],[nurce] ]
      #@nurces.each{|nurce| nurce.monthly(@month).day2shift}
      @HospitalRolecount = Hospital::Need.roles.size #Hospital::Role.count
      @RoleShift = #(1..@HospitalRolecount).to_a.product(@shifts123)
                   Hospital::Need.roles.product(@shifts123)
    end
    @basename = File.join( RAILS_ROOT,"tmp","hospital",
                          "Shift_%02d_%02d_"%[@busho_id,@month.month]) if @month

    @avoid_list = Hospital::AvoidCombination.all.map{ |ab| [[ab.nurce1_id,ab.nurce2_id],ab.weight]}
    clear_stat
  end

  def clear_stat
    # 統計
    #  復元回数           再帰回数          評価回数
    @restore_count = @entrant_count = @loop_count = 0

    #  shift毎の、評価回数、失敗数、失敗原因
    @count_back  = Hash.new{|h,k| h[k] = 0 }
    @count_eval  = Hash.new{|h,k| h[k] = 0 }
    @count_fail  = Hash.new{|h,k| h[k] = 0 }
    @count_cause = Hash.new{|h,k| h[k] = Hash.new{|h,k| h[k] = 0 } }
    @missing_roles= Hash.new{|h,k| h[k] = 0 }
  end

  def missing_roles(sft_str,m_roles)
    m_roles.each{ |role_id|  @missing_roles[[role_id,sft_str]] += 1 }
  end

  def nurce_by_id(id)
    case id
    when Integer ;    @nurces.select{|n| n.id == id}.shift
    when Array    ;   id.map{|i|  @nurces.select{|n| n.id == i}.shift }
    end
  end

  # 自動割付分を削除する。このmethodではDBにまでは反映しない。
  def clear_assign
    #@nurces.each{|nurce| nurce.clear_assign }
    #self
    @nurces.each{|nurce|
      (1..@lastday).each{|day|
        nurce.set_shift(day,"_") if nurce.monthly.days[day].want.nil? || nurce.monthly.days[day].want<1
      }
      nurce.shifts.gsub!(/L/,Sshift2)
      nurce.shifts.gsub!(/M/,Sshift3)
    #dbgout("Nurce#clear_assign nurce=#{ nurce.id} shifts =#{ nurce.shifts} ") 
    }
    
  #@nurces.each{|nurce| 
      #dbgout("clear_assign nurce #{nurce.id}")
  #    nurce.clear_assign }
    self
  end

  def clear_assign_all
    clear_assign
    unlink_mults("clear_assign_all")
    self
  end


  #######################################################################
  # 一番深くまで割り付けた時の状態を保存する
  def longest ;  @longest ||=  [0,0] ;end

  # 一月の割付を行う
  # まず主任の1クールを割り付けた後、再帰を呼び出す
  def assign_month(day=1)
    @start = Time.now
    @limit_time = @start + Hospital::Const::Timeout
    logger.info("HOSPITAL ASSIGN START ON "+Time.now.to_s)
    @basename = File.join( RAILS_ROOT,"tmp","hospital",
                          "Shift_%02d_%02d_"%[@busho_id,@month.month])
    File.unlink(*Dir.glob(@basename+"*"))
    dbgout("HOSPITAL ASSIGN Delete #{@basename} by assign_month")

    assign_mult(1)
    self
  end

  ############################################################
  def unlink_mults(msg)
    File.unlink(*Dir.glob(@basename+"*"))
    dbgout("HOSPITAL ASSIGN Delete #{@basename} by #{msg}")
  end

  def assign_month_mult(all=nil)
    unlink_mults("assign_month_mul")
    dbgout("HOSPITAL ASSIGN MULT START ON "+Time.now.to_s)
    logger.info("HOSPITAL ASSIGN MULT IS STARTED ON "+Time.now.to_s)
    begin
      assign_mult(all)
      logger.info("HOSPITAL ASSIGN MULT IS FINISHED ON "+Time.now.to_s)
    rescue TimeoutError
      logger.info("HOSPITAL FINISHED BY TIMED OUT Finaly================================")
      restore_shift(nurces,1,@longest[1])
      @fine = Time.now;log_stat(:head => "=== Timed Out ===")
      save
    end      
    self
  end 

  # 複数解を求めるルーチ*ン
  # 3つのケースがある
  #  1 解を一つだけ求める                                          
  #  2 複数求めるが、最初の解は求めない。これは別のルーチンで求める
  #  3 複数解求める。最初の解も求める。これは save する。           
  # single :: false,nil  case 2
  #        :: 2          case 3
  #        :: 1          case 1           

  def assign_mult(single = SecondAndLater,day=1)
    set_instance_valiables_for_assign_loop
    ncm,combinations,need_nurces,short_roles= size_of_combinations_of_first_day(day)

    #### Loop counter
    try = 0
    @count = -1
    count_max = combinations[Sshift2].size * combinations[Sshift3].size

    ######## LOOP
    sft_str = Sshift2
    nurce_combination_shift23(combinations,need_nurces,short_roles,day){|nurce_combinations|
      dbgout("single/count/数  single && count < 0 => #{ single}/#{@count}/#{count_max}/#{ single && @count < 0}")

      if !single && @count < 0 # case 2 でかつ最初の解(の可能性)
        @count += 1
        next
      end

      dbgout("HP ASSIGN #{day}日entry-1")
      dbgout dump("  HP ASSIGN ")

      # set limit for this turn
      @limit_time = Time.now + Hospital::Const::Timeout
      dbgout("HP ASSIGN (#{__LINE__})#{day}:#{sft_str} Try #{try += 1} of #{ncm}")
      @night_mode = true
      
      refresh
      combinations,need_nurces,short_roles = ready_for_day_reentrant(day)

      begin 
        if assign_day_reentrant(day,nurce_combinations,need_nurces,Sshift2) &&
            assign_shift1(day)

          log_stat_and_save_result
          return true #if single == SingleSolution
        end
      rescue TimeoutError
        logger.info("HOSPITAL FINISHED BY TIMED OUT ==================================================")
      end
      raise TimeoutError if @limit_mult < Time.now

      dbgout("HOSPITAL AS NEXT 次候補 ")
      clear_assign
    }
    open( @basename + "FINE" ,"w"){ |fp| fp.puts "ASSIGN_MULT IS FINISHED" }
  end

  def assign_shift1(day)
    @night_mode = false
    tight = assign_tight_daies_first
    dbgout("HP ASSIGN (#{__LINE__})return from assign_tight_daies_first with #{tight}")
    tight && assign_shift1_by_re_entrant(day)
  end

  def log_stat_and_save_result
          @fine = Time.now ; log_stat( ) 
          #if count == 0
          dbgout("HP ASSIGN (#{__LINE__})output to file #{ @basename + "%04d"%@count}")
          open( @basename + "%04d"%@count ,"w"){ |fp| fp.puts dump }
          dbgout("HP ASSIGN (#{__LINE__})output done")
          #end
          save
  end

  def set_instance_valiables_for_assign_loop
    @basename = File.join( RAILS_ROOT,"tmp","hospital",
                          "Shift_%02d_%02d_"%[@busho_id,@month.month])
    @start = @start_mult = Time.now
    @limit_mult = @start_mult + Hospital::Const::TimeoutMult
  end

  def size_of_combinations_of_first_day(day=1)
    @night_mode = true 
    combinations,need_nurces,short_roles = ready_for_day_reentrant(day)
    shifts_short_role = save_shift(nurces,day)
    [[combinations[Sshift2].size,1].max *  [combinations[Sshift3].size,1].max,
     combinations,need_nurces,short_roles]
  end


  def assign_day_reentrant(day,nurce_combinations,need_nurces,sft_str)
    ################## RE_ENTRANT START ###################
    #nurce_combinations = [nil,nurce_comb,nil,nil]
    # 現状保存
    shifts_short_role = save_shift(nurce_combinations[sft_str],day)

    log_eval_combination day,nurce_combinations
    dbgout("  #{__LINE__} nurce_combinations[shift] #{nurce_list(nurce_combinations[sft_str])}")

    ret = assign_shift_by_reentrant(nurce_combinations,need_nurces,day,sft_str)
    case ret
    when true; return true # 全割付成功
    when false;            # この看護師組み合わせでは破綻したので次の組み合わせへ
      restore_shift(nurce_combinations[sft_str],day,shifts_short_role)
      return false #next
    else      ; raise "HP #{day}:#{shift} ここにはこないはず assign_daytime_by_re_entrant123"
    end
  end

  # shift分の再帰
  def assign_shift_by_reentrant(nurce_combinations,need_nurces,day,sft_str,single=SecondAndLater)
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
        @longest = [day*10+10-sft_str.to_i,save_shift(@nurces,day)] if day*10+10-sft_str.to_i > longest[0]

        return true if single

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
      return :cannot_assign_this_patern
    end
    long_check_later_days(day,merged_patern(list_of_long_patern),sft_str) &&
      avoid_check(nurces,sft_str,day,list_of_long_patern)
  end

  def assign_patern_if_possible(nurces,day,sft_str,idx_list_of_long_patern)
    # この長い割付が可能か                                                # [0,2]
    list_of_long_patern = 
      assign_test_patern(nurces,day,sft_str,idx_list_of_long_patern)
    return false unless list_of_long_patern
    (0..nurces.size-1).each{|idx|
      nurce_set_patern(nurces[idx],day,list_of_long_patern[idx].patern)
    }
    list_of_long_patern
  end

  def log_newday_entrant(day)
    dbgout("HP ASSIGN #{day}日entry")
    dbgout("assign_by_re_entrant")
    dbgout dump("  HP ASSIGN ")
  end

  def assign_night_by_re_entrant(day)
    #@day = day
    return true     if day > @lastday 
    raise TimeoutError,"timed out"  if @limit_time < Time.now

    ### Begin  New Day ###########
    log_newday_entrant(day)
    combinations ,need_nurces, short_roles = ready_for_day_reentrant(day)
    return false unless combinations
    
    ncm = nCm(combinations[Sshift2].size,need_nurces_shift(day,Sshift2).size)
    comb ,need =  combinations[Sshift2].size,need_nurces_shift(day,Sshift2).size
    try = 0 
    nurce_combination_shift23(combinations,need_nurces,short_roles,day){|nurce_combinations| 
      unless nurce_combinations
        assign_log(day,Sshift2,nil,__LINE__, @msg)
        return false
      end
      #return false if @night_mode && not_enough_for_shift1(nurce_combinations,need_nurces,short_roles,day)

      dbgout("HP AASIGN #{day}:#{Sshift2} Try #{try += 1} of #{ncm} need #{comb}C#{need}")
      return true if assign_day_reentrant(day,nurce_combinations,need_nurces,Sshift2)
    }
    # 全組み合わせを調べてうまく行かないときは、前の日に戻る
    #     restore_shift(comb_nurces,day,shifts_short_role,shift)
    assign_log(day,Sshift2,nil,__LINE__,nil,"BACK: hk全候補終了")
    false
  end


  def assign_shift1_by_re_entrant(day)
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

  def ready_for_day_reentrant(day)
    as_nurces_selected,need_nurces, short_roles = need_nurces_roles(day)
    return false unless as_nurces_selected
    ##########################
    # 各シフトの、看護師の組み合わせ の組み合わせ
    # 先頭の nil は indexの位置合わせのためのdumy。
    #(0)combinations = [nil]+[1,2,3].map{|shift|   #(1)
    combinations = { }
    if @night_mode
      @night.each{|sft_str|     #(1)
        combinations[sft_str] = 
        nurce_combination_by_tightness(as_nurces_selected[sft_str],#[0..SelectedMax],
                                       need_nurces_shift(day,sft_str),short_roles[sft_str],sft_str)
      }
    else 
      combinations["1"] = as_nurces_selected["1"].sort_by{|n| n.cost("1",tight_roles("1"))}
    end
    log_combination __LINE__,day,combinations
    [combinations ,need_nurces, short_roles]
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

  #Hospital::Assign.new(1,Date.new(2013,2,1)).clear_assign.save

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
        unless assign_single_day(day,"1")
          ret= false
          break
        end
      end
    }
    dbgout("HP AASIGN TIGHT_DAY FIRST exit ")
    #@longest =  [0,0]
    ret
  end

  # 夜モードのときに調べる。
  # 夜にアサインしても、日勤分の看護師が残っているか調べる
  def not_enough_for_shift1(combination1,combination2,combination3,need_nurces,short_roles,day)
    for_1 = combination1
    for_night = (combination2 + combination3).uniq
    dbgout("HP ASSIGN not_enough_for_shift1 #{day}日 need for_1 #{nurce_list(for_1)} ")
    dbgout("HP ASSIGN not_enough_for_shift1 #{day}日 need for_night #{nurce_list( for_night)} ")
    dbgout("HP 6ASSIGN not_enough_for_shift1 need #{need_nurces_shift(day,'1')} but #{(for_1 - for_night).size} ")
    if (for_1 - for_night).size < need_nurces_shift(day,'1')
      true
    else ;false
    end
  end 

  def log_eval_combination(day, nurce_combinations)
    @shifts_night[@night_mode].each{ |sft_str|  shift=sft_str.to_i
      next if !sft_str || nurce_combinations[sft_str] == true 
      dbgout("  (#{__LINE__})HP #{day}日#{sft_str} 看護師評価組み合わせ:#{nurce_list(nurce_combinations[sft_str])}"+
             "保持role[ #{ role_list(nurce_combinations[sft_str])}" ,
             LogPuts|LogDebug
             )
    }

  end

  def log_combination(line,day,combinations)
    if  @night_mode
      @night.each{|sft_str| comb=combinations[sft_str]
        dbgout("HP ASSIGN(#{line}) #{day}:#{sft_str} tight:#{tight_roles(sft_str)} ["+
               comb.map{|nurces| 
                 "[" + 
                 nurces.map{|nurce| [nurce.id,nurce.cost(sft_str,tight_roles(sft_str))].join(':') }.join(",") +
                 "]" }.join(",") +
               "]"
               )
      }
    else
      dbgout("HP ASSIGN(#{__LINE__}) #{day}:#{1} tightroles=#{tight_roles("1")} #{combinations["1"].size}人["+
             combinations["1"].map{|n| [n.id,n.cost("1",tight_roles("1"))].join(':')}.join(', ')+
             "]")
    end

  end 

  def assignable_nurces_enough_for_needs(day,need_nurces,as_nurces_selected)
    ## tryal
    #if (@night_mode ? @shifts123 : @shifts_night[@night_mode]).
    if  @shifts_night[@night_mode].
        inject([]){ |ary,sft_str| ary + as_nurces_selected[sft_str] }.uniq.size < 
        need_nurces.values.inject(0){|sum,n| n ? sum + n : sum}
      # 割付可能な看護師の実数が各shiftに必要な人数の合計より少ない場合は人数不足で失敗
      assign_log(day,0,nil,nil,__LINE__,"shift[#{ @shifts_night[@night_mode].join(',')}]:Assignable Nurces are not enough")
      #raise if @day==15
      false
    else
      true
    end
  end

  def refresh
    nurces.each{ |nurce| nurce.refresh }
    role_remain true
    margin_of_role
    role_used true
    roles_required
    short_role_shift true
    count_role_shift true
  end

  def need_nurces_shift(day,sft_str)
    short_role_shift_of(day)[[@Kangoshi,sft_str]][0]
  end

  def need_nurces_roles(day)
    if @night_mode
      need_nurces_roles_night(day)
    else 
      need_nurces_roles_day(day)
    end
  end

  def need_nurces_roles_night(day)
    # この日のこのshiftの看護師の必要数と不足role
    short_role(day,Sshift3,true)
    # 看護師の必要数,不足role
    short_role_shift_of_day = short_role_shift_of(day)
    need_nurces = { }   # 看護師の必要数
    short_roles = { }   # 不足role
    as_nurces_selected = { }   # アサイン可能看護師リスト
    ## tryal
    #(@night_mode ? @shifts123 : @shifts_night[@night_mode]).each{ |sft_str|
    @shifts_night[@night_mode].each{ |sft_str|
      need_nurces[sft_str] = short_role_shift_of_day[[@Kangoshi,sft_str]][0]
      short_roles[sft_str] = short_role(day,sft_str)
    }
    @shifts_night[@night_mode].each{ |sft_str|
      as_nurces_selected[sft_str] = 
      (need_nurces_shift(day,sft_str)==0) ? [] :
      assinable_nurces_by_cost_size_limited(sft_str, day, short_roles[sft_str])
    }
    @shifts_night[@night_mode].each{|sft_str| next unless
      entry_log(day,sft_str,__LINE__,need_nurces_shift(day,sft_str),short_roles[sft_str],as_nurces_selected[sft_str])
    }
    if assignable_nurces_enough_for_needs(day,need_nurces,as_nurces_selected)
      [as_nurces_selected,need_nurces, short_roles]
    else 
      false
    end
  end
  def need_nurces_roles_day(day)
    # この日のこのshiftの看護師の必要数と不足role
    short_role(day,Sshift3,true)
    # 看護師の必要数,不足role
    short_role_shift_of_day = short_role_shift_of(day)
    need_nurces = { }   # 看護師の必要数
    short_roles = { }   # 不足role
    as_nurces_selected = { }   # アサイン可能看護師リスト
    ## tryal
    #(@night_mode ? @shifts123 : @shifts_night[@night_mode]).each{ |sft_str|
      need_nurces[Sshift1] = short_role_shift_of_day[[@Kangoshi,Sshift1]][0]
      short_roles[Sshift1] = short_role(day,Sshift1)
    
      as_nurces_selected[Sshift1] = 
      (need_nurces[Sshift1]==0) ? [] :
      assinable_nurces_by_cost_size_limited(Sshift1, day, short_roles[Sshift1])

      entry_log(day,Sshift1,__LINE__,need_nurces_shift(day,Sshift1),short_roles[Sshift1],as_nurces_selected[Sshift1])
    if assignable_nurces_enough_for_needs(day,need_nurces,as_nurces_selected)
      [as_nurces_selected,need_nurces, short_roles]
    else 
      false
    end
  end


  #割り当て可能なnurseをcostの低いほうから何人か選ぶ。
  #何人選ぶか
  # shift2,3の場合はshift2+3の5割り増し、shift1の場合はshift1の5割り増し
  #ただし必要ロールがそろう様にするために持っているロールで分ける。
  # これが必要なのは割りあて可能な人数が「何人か」より多い場合
  def assinable_nurces_by_cost_size_limited(sft_str,day,short_roles_this_shift )
    as_nurce = assinable_nurces(day,sft_str,short_roles_this_shift)
    limit = limit_of_nurce_candidate(sft_str,day)
    if as_nurce.size <= limit
      as_nurce.sort_by{|nurce| nurce.cost(sft_str,tight_roles(sft_str))} 
    else
      array_merge(gather_by_each_group_of_role(as_nurce,sft_str,short_roles_this_shift))[0,limit]
    end
  end

  def gather_by_each_group_of_role(as_nurce,sft_str,short_role_of_this_shift)
    nurces_group_by = as_nurce.group_by{ |nurce| (nurce.role_ids & short_role_of_this_shift).sort}
    logger.debug("GATHER_BY_EACH_GROUP_OF_ROLE shift=#{sft_str}:as_nurce = #{as_nurce.map(&:id).join(',')}")
    nurces =  nurces_group_by.to_a.  # 持ってるroleで層別し
      sort_by{ |roles,nurce_list|  roles_cost(roles,tight_roles(sft_str))}.
      map{ |roles,nurce_list|                                # 各々の層をcostで並べる
      nurce_list.sort_by{|nurce| nurce.cost(sft_str,tight_roles(sft_str)) 
      }
    }
    logger.debug("GATHER_BY_EACH_GROUP_OF_ROLE [#{nurces.map{|ns| ns.map(&:id).join(',')}.join('],[')}]")
    nurces
  end # of case

  def limit_of_nurce_candidate(sft_str,day)
    case sft_str
    when Sshift2,Sshift3 ; limit_of_nurce_candidate_night(day)
    when Sshift1         ; limit_of_nurce_candidate_day(day)
    end # of case    
 end

  def limit_of_nurce_candidate_night(day)
    [((need_nurces_shift(day,Sshift2) + (need_nurces_shift(day,Sshift3) || 0)) * Factor_of_safety_NurceCandidateList).ceil,
     LimitOfNurceCandidateList].max
  end

  def  limit_of_nurce_candidate_day(day)
    (need_nurces_shift(day,Sshift1) * 1.5).ceil
  end

  def array_merge(aryary)
    return [] if aryary==[]
    return aryary[0] if aryary.size==1
    maxsize = aryary.map{|ary| ary.size}.max
    merged = aryary[0]+[nil]*(maxsize-aryary[0].size)
    aryary[1..-1].inject(merged){|merg,ary| merg.zip(ary)}.flatten.compact
  end


  # 再帰が失敗して戻るときに、元にもどすための状況保存
  # 保存するもの
  #   看護師の状況 Hospital::Nurceに任せる  nurces_save
  #   一月分の各日・shiftのroleの不足状況   short_role_shift_dup
  #   消費したroleの数                      role_used_dup
  #   まだ使えるroleの数                    role_remain_dup
  #
  # 看護師は初め全nurceを保存したが、該当するshiftで変更の有るnurceだけにした。速度、メモリー消費
  # アルゴリズム検討の歴史が残っているので、今や不要もあるかも。消費したroleが怪しい
  def save_shift(nurces,day)
    return nil if nurces == true
    nurces_save = nurces.map{|nurce| nurce.save_shift }
    short_role_shift_dup= (day..[day+8,@lastday].min).map{|d| 
      srs=Hash.new
      short_role_shift[d].each_pair{|key,ary| srs[key] = ary.dup}
    }
    role_used_dup = role_used.dup
    role_remain_dup = role_remain.dup
    [ nurces_save,   count_role_shift[day].dup,  short_role_shift_dup ,
      role_used_dup, role_remain_dup]
  end

  def restore_shift(nurces,day,shifts_short_role,sft_str=Sshift3)
    return if nurces == true
    @restore_count += 1

    nurces.each_with_index{|nurce,idx| 
      nurce.restore_shift(shifts_short_role[0][idx])}
    count_role_shift[day] = shifts_short_role[1]
    shifts_short_role[2].each_with_index{|srs,d| 
      short_role_shift[day+d] = srs 
    }
    
    role_used = shifts_short_role[3]
    role_remain = shifts_short_role[4]
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
      long_patern,errorlist =  
      nurce_list[idx].
      long_check(day,sft_str,
                 Hospital::Nurce::LongPatern[@koutai3][sft_str][idx_set_of_long_patern[idx]])
      if long_patern
        long_patern # ,daily_checks]
      else
        # このとき、daily_checkは[item,正規表現の配列
        errorlist.each{|item,reg| @count_cause[item][sft_str]+=1 }
pp ["errorlist",errorlist]
        return false
      end
    }
    #return paterns if avoid_check(nurce_list,sft_str,day,paterns)
    #false
  end
  
  # 禁忌な組み合わせがあるか調べる     [ [LongPatern,LongPatern],daily_checks],[] ]
  def avoid_check(nurces,sft_str,first_day,list_of_long_patern)
    return true if sft_str == "1"
    last_day = first_day+list_of_long_patern.map{ |long_patern| long_patern.patern.size}.max-1
logger.debug("#### AVOID_CHECK first_day,last_day=#{ first_day},#{last_day} @avoid_list=#{@avoid_list.flatten.join(',')}")
    @shifts_night.each{ |sft_str|
      (first_day..last_day).each{ |day| 
        nurce_ids = nurce_ids_of_the_day_shift(nurces,day,sft_str)
        logger.debug("#### AVOID_CHECK        nurce_ids=#{nurce_ids==[]} SIZE=#{@avoid_list.map{ |al,weight| ( nurce_ids & al)==al }}")
        return false if @avoid_list.map{ |al,weight| al unless (nurce_ids & al).size == al.size }.compact.size > 0 
      }
    }
    true
  end

  def nurce_ids_of_the_day_shift(nurces,day,sft_str)
    nurces.map{ |nurce| nurce.id if nurce.shifts[day,1] == sft_str}.compact
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

  # 2日目以降に重大な支障が出ないか調べる。
  # 調べるshiftと調べるべき日は daily_checksに格納されている
  # [daily_checks] Hospital::Nurce::LongPaternの第６項目、調べるべきshiftと調べるべき日(のofset)
  # 
  # 現在のチェック項目
  #   roleの割り当てすぎ：roleを使いすぎると以降の日の割付が厳しくなる
  #   休日の入りすぎ：休を入れすぎるとその日の看護師が足りなくなる
  #   当日、前日のシフト１は看護師が足りるか
  def long_check_later_days(day,daily_checks,shift_str)
    #@short_roles=

    @shifts.each{|sft_str|  
      daily_checks[sft_str.to_i].each{|d|
        next if day+d > @lastday
        dbgout("FOR_DEBUG(#{__LINE__}) 長割後日チェック too_many?(#{day+d}日,shift:#{sft_str}) #{too_many?(day+d,sft_str)}")
        case too_many?(day+d,sft_str)
        when -1 ; return false
        when 0
          case sft_str
          when Sshift2,Sshift3
            s_r = short_role(day+d,sft_str).size ==0 ? "なし" :  short_role(day+d,sft_str).join
            dbgout("長割後日チェック(#{__LINE__}) (#{ day}+#{d}):#{sft_str} ロール不足#{ s_r }")
            return false if short_role(day+d,sft_str).size >0
          end
        end
      }
    }
    #   当日、前日のシフト１は看護師が足りるか
    unless shift_str == "1"
      dbgout("長割後日チェック(#{__LINE__}) (#{ day})への割付で日勤要員不足ありや #{assinable_nurces(day,"1",short_role(day,'1')).size }")
      dbgout("長割後日チェック(#{__LINE__}) (#{ day-1})への割付で日勤要員不足ありや #{assinable_nurces(day-1,"1",short_role(day-1,'1')).size }")
      if short_role_shift[day][[@Kangoshi,Sshift1]][0] > assinable_nurces(day,Sshift1,short_role(day,Sshift1)).size ||
          short_role_shift[day-1][[@Kangoshi,Sshift1]][0] > assinable_nurces(day-1,Sshift1,short_role(day-1,Sshift1)).size 
        dbgout("長割後日チェック(#{__LINE__}) (#{ day})への割付で日勤要員不足")
        return false
      end
    end
    true
  end


  # shiftの割り付けがmaxを越えていないか。needs_all_days[day][key][1] - role_shift[day][key]
  #  key == [ role, sft_str ]
  def too_many?(day,sft_str)
    #指定日のシフトは人の余裕あるか
    case sft_str
    when Sshift0,Sshift2,Sshift3 ;    short_role_shift[day][[@Kangoshi,sft_str]][1] <=> 0
    when Sshift1         ;    
    end
  end

  # 与えられた看護師群から指定された人数の組み合わせを作る。
  # 必要なroleを満たさない組み合わせを取り除き、
  # costの小さい順に並べる。
  def nurce_combination_by_tightness(nurces,need_nurces,need_roles,sft_str)
    # puts "shift=#{shift}"

    combinations = nurces.combination(need_nurces).select{|combination| 
      # role不足
      (need_roles - (need_roles & roles_of(combination))).size <= 0
    }.sort_by{|nurces| cost_of_nurce_combination(nurces,sft_str,tight_roles(sft_str))}
    if combinations.size == 0
      missing_roles(sft_str,need_roles - roles_of(nurces))      
    end
    combinations #(2)Dで削除
  end

  def roles_cost(roles,tight)
    tight.inject(0){ |cost,role| cost * 2 + (roles.include?(role) ? 1 : 0 )}
  end
  # 看護師群のcostの総計
  def cost_of_nurce_combination(nurces,sft_str,tight)
    nurces.inject(2.0){|cost,nurce| cost + nurce.cost(sft_str,tight) }*
      AvoidWeight[[nurces_have_avoid_combination?(nurces),AvoidWeight.size-1].min]
  end

  def nurces_have_avoid_combination?(nurces)
    nurce_ids = nurces.map(&:id)
    @avoid_list.inject(0){ |cst,comb_weight| 
      cst + (((comb_weight[0] & nurce_ids)==comb_weight[0]) ? comb_weight[1] : 0)
    }
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

  # 指定された日、shiftに割付可能な看護師の配列
  # その日割付まだされておらず、かつそのshiftを割り付けても勤務制約を越えず
  # 足りないroleを少なくとも一つ持っている
  def assinable_nurces(day,sft_str,short_roles,reculc=false)
    logger.debug("ASSINABLE_NURCES check_at_assign of id 11,17,20 "+
                 "#{nurce_by_id([11,17,20]).map{ |nurce| nurce.check_at_assign(day,sft_str)}.join(',')}"
                 ) if day==1
    nurce_not_assigned(day).
      select{|nurce| !nurce.check_at_assign(day,sft_str) && 
      nurce.has_assignable_roles_atleast_one(sft_str,short_roles.map{|r,mi_max| r })
    }
  end

  def nurce_not_assigned(day)
    @nurces.select{|nurce| nurce.monthly.shift[day,1] == "_" }

  end


  # Hospital::Nurce::LongPatern に定義されたpaternはshiftによって数が異なる
  # また処理時間との兼ね合いなどで変化する可能性も高い。
  # 看護師の人数分のパターンの組み合わせについて割付を試すにあたり、その
  # 組み合わせを都度作るのはコストがかかる。
  # しかしパターンの数に応じてパターンをプログラムで定義するのも間違いの元となる。
  # そこで、パターンの組み合わせをメモ化することにした。
  # [number_of_nurce] 看護師の人数
  # [number_of_plan]  LongPaternの数
  # 戻り値            [ [0,0,0],[0,0,1],,,,[1,1,1] ]
  def long_plan_combination(number_of_nurce,number_of_plan)
    @long_plan_combination ||= {}
    return @long_plan_combination[[number_of_nurce,number_of_plan]] if @long_plan_combination[[number_of_nurce,number_of_plan]]
    
    work = (0..number_of_plan-1).to_a
    combination = work.map{|w| [w] }
    (number_of_nurce-1).times{ combination = combination.product(work)}
    @long_plan_combination[[number_of_nurce,number_of_plan]] = 
      combination.map{|c| c.flatten}
  end


  # 指定された看護師の指定された日以降にpaternな勤務を割り当てる
  # paternは0123からなる文字列。
  # このパターンを割り当てても制約を満たすことを事前に確認されていること
  def nurce_set_patern(nurce,day,patern)
    logger.info("HOSPITAL::ASSIGN(#{__LINE__})#長い割付=#{day}日,patern#{patern}:Nurce #{nurce.id} roles#{nurce.roles.map{|id,nm| id}}")
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
    #logger.info("HOSPITAL::ASSIGN(#{__LINE__})#割付=#{day},#{shift_str} #{nurce.id} #{nurce.roles.map{|id,nm| id}}")
    #puts ("HOSPITAL::ASSIGN(#{__LINE__})#割付=#{day},#{shift_str} nurce #{nurce.id} [#{nurce.roles.map{|id,nm| id}.join(',')}]")
    nurce.set_shift(day,shift_str)
    count_role_shift[day] = count_role_shift_of(day)
    short_role_shift[day] = short_role_shift_of(day)
    nurce.role_ids.each{|role_id,name| 
      #role_used[[role_id,shift_str.to_i]] += 1 
      role_remain[[role_id,shift_str]] -= 1
      #      margin_of_role[[role_id,shift_str.to_i]] -= 1
    }
    shift_str
  end


  # 着目している @monthlyの各日毎に、必要な　role毎の人数を保存する
  # [ [role,日準深]=>[min,max],, ,,,]
  def needs_all_days(reculc = false)
    return @needs_all_days if @needs_all_days && !reculc
    return @needs_all_days = Hospital::Need.needs_all_days(@month,@busho_id)
  end

  # 平日か土日祝かで勤務必要数が変わる。
  # それを返す。
  # 戻り値 [ [ [資格,sft_str]=>[最低数、最大数], []=>[], []=>[] ],[ 土日の分] ]
  def need_patern
    return @need_patern if @need_patern 
    @need_patern = Hospital::Need.need_patern(@busho_id)
  end

  # 指定日に割り当て不足な [role,shift] の数
  def short_role_shift_of(day)
    s_r = Hash.new{|h,k| h[k]=[0,0]}
    rs=count_role_shift
    begin
      needs_all_days[day].keys.each{|need_patern|  #need_patern ===> [role,sft_str]
        s_r[need_patern][0] = needs_all_days[day][need_patern][0] - rs[day][need_patern]
        s_r[need_patern][1] = needs_all_days[day][need_patern][1] - rs[day][need_patern]
      }
    rescue
#pp need_patern
      dbgout("needs_all_days day:(#{__LINE__})#{day} need_patern=#{need_patern}")
      raise
    end
    s_r
  end

  def set_shifts_by_file(path)
    File.read(path).each_line{ |line|
      id,shift = line.split
      nurce=nurces.find{ |nurce| nurce.id == id.to_i 
      }
      nurce.shifts=shift
    }
    save
  end


  #########################################################################
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

  def role_remain(recalc=false)
    return @role_remain if @role_remain && !recalc
    @role_remain = Hash.new{|h,k| h[k]=0}
    @nurces.each{|nurce| 
      nurce.role_remain.each_pair{|role_shift,remain|
        @role_remain[role_shift] += remain
      }
    }
    @role_remain
  end

  # roleの余裕数
  #  まだ割り付けられていない看護師のrole数 role_remain - まだ割り付けられていない日のrole数
  def margin_of_role
    return @margin_of_role if @margin_of_role 
    @margin_of_role=Hash.new{|h,k| h[k]=0}
    
    @RoleShift.each{|role_sftstr| 
      @margin_of_role[role_sftstr] = role_remain[role_sftstr]  - roles_required[role_sftstr]
    }
    @margin_of_role
  end


  def role_used(recalc=false)
    return @role_used if @role_used && !recalc
    @role_used = Hash.new{|h,k| h[k]=0}
    @nurces.each{|nurce| 
      nurce.role_used.each_pair{|role_shift,used|
        @role_used[role_shift] += used
      }
    }
    @role_used
  end


  def roles_required
    return @roles_required  if @roles_required 
    @roles_required = Hash.new{|h,k| h[k] =0 }
    needs_all_days[1..-1].each{|need_of_day|
      @RoleShift.each{|key|    @roles_required[key] += (need_of_day[key] || [0])[0]
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


  ################################################################################
  # 割付の後処理群
  #################################################################################

  # 文字列になっている割付データを Nurce#monthlyに書き戻す
  def save
    @nurces.each{|nurce| nurce.monthly.restore_days.save }
    self
  end

  ################################################################################
  # 割付の後処理群      終わり
  #################################################################################


  # [ [role_id,[minに対する不足,maxに対する不足]], [,[]],  [,[]]]
  def short_role_of_day_shift(day,shift,reculc=false)
    short_role_shift(reculc)[day].
      select{|role_shift,min_max| role_shift.last == shift }.
      map{|role_shift,min_max| [role_shift.first,min_max]}
  end

  def short_role(day,sft_str,reculc=false)
    #short_role_shift(true) if recalc || ! @short_role
    #@short_role[day]
    #logger.debug("short_role_shift(reculc)[day].to_a #{short_role_shift(reculc)[day].to_a.join(',')}")
    short_role_shift(reculc)[day].to_a.map{|role_shift,min_max| 
      role_shift.first if min_max.first>0 && role_shift.last == sft_str}.compact.sort
  end
  def short?(day,sft_str)
    short_role_shift_of(day).to_a.map{|role_shift,min_max| 
      role_shift.first if role_shift.last == sft_str && min_max.first>0}.compact.size > 0
  end

  def short_role_name(day,shift)
    short_role(day,shift).map{|role| Hospital::Role.find(role).name }
  end

  # 各日の [role,shift] を得る
  # shift はstring
  def count_role_shift(reculc=false)
    return @count_role_shift if @count_role_shift && !reculc
    @count_role_shift = (0..@lastday).map{|day| 
      count_role_shift_of(day,reculc)
    }
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
    nurces.each{|nurce|  nurce.role_ids.each{|role_id| ret[role_id] += 1}}
    ret
  end

  def needs_all_kinms(reculc=false)
    return @needs_all_kinms if @needs_all_kinms && !reculc
    needs_all_days
  end

  # unsed only by nurce_paterning_test
  def need(day,role_id,kinmucode_id)
    @needs[day][[role_id,kinmucode_id]] || [0,0]
  end

  def error_check
    dbgout dump("ERROR_CHECK ")
    ret = [error_days , error_nurces]
    dbgout("ERROR_CHECK #{ret}")
    ret
  end
  def error_days
    (1..@lastday).map{|day| error_day(day) }.compact
  end
  def error_day(day)
    ret = Sshift123.map{|shift| 
      srn = short_role_name(day,shift)
      "#{day}日 #{['','日勤','準夜','深夜'][shift.to_i]}:#{srn.join(',')} " if srn.size > 0
    }.compact
    ret.size > 0 ? ret : nil
  end
  def error_nurces
    @nurces.map{|nurce| nurce.error_check }.delete_if{|ary| ary.size==0}
  end

  ###########  helper ###########

  # 与えられた看護師群が持つroleのidのリスト。
  def roles_of(nurces)
    nurces.map{|nurce|  nurce.role_ids}.flatten.uniq.sort
  end



  ########### log helper ###########
  def dump(header="")
    begin
      @nurces.map{|nurce| header+"#{nurce.id} #{nurce.shifts}"}.join("\n") 
    rescue 
      dbgout @nurces.size
      @nurces.each{|nurce|  dbgout header+"#{nurce.id} #{nurce.shifts}"}
    end
  end

  def leader_need ; Hospital::Limit.need_roles(@busho_id,@month)[[$HP_DEF.leader,:night_total]] ;end
  def leader_arrow; Hospital::Limit.arrowable_roles(@busho_id,@month)[[$HP_DEF.leader,:night_total]] ;end
  def kangoshi_need;Hospital::Limit.need_roles(@busho_id,@month)[[$HP_DEF.kangoshi,:kinmu_total]]    ;end
  def kangoshi_arrow;Hospital::Limit.arrowable_roles(@busho_id,@month)[[$HP_DEF.kangoshi,:kinmu_total]];end




  def log_stat(opt ={ })
    head = opt.delete(:head) || ""
    msg = "FINISHED #{Hospital::Busho.find(@busho_id).name} #{@month.strftime('%Y/%m')}月" +
      "   shift分再帰 %3d回, 評価%4d回 %5.1f秒 ON "%[@entrant_count,@loop_count,@fine-@start]+
      Time.now.strftime("%Y-%m-%d %H:%M:%S")+"\n"+
      " [実数/必要数]：リーダー #{leader_arrow}/#{leader_need}人日、"+
      "看護師 #{kangoshi_arrow}/#{kangoshi_need}人日" 
    msgstat0 = "#{head} STAT shift  評価 失敗 戻り" + @count_cause.keys.map{ |k| "%8s"%k}.join(" ") +"\n"
    msgstat1 = 
      @shifts123.map{|sft_str|
      "       %s    %4d %4d %4d"%[sft_str,@count_eval[sft_str],@count_fail[sft_str],@count_back[sft_str]] +
      @count_cause.keys.map{ |k| "%9d"%@count_cause[k][sft_str]}.join

    }
    msgmissing = @missing_roles.size == 0 ? "" :
      "\n   不足Role "+@missing_roles.to_a.
      map{ |id_shift,count| "  [%s] %d回"%[id_shift.join("-"),count]}.join(",") 
    # msgstat += @count_cause.keys.map{ |k| "%9d"%@count_cause[k][shift]}.join

    dbgout("#{head} #{msg}")
    dbgout(head+msgstat0+head+msgstat1.join("\n#{head}\n")+@count_fail.to_s + msgmissing)
    
    logout_stat "#{msg}\n" +msgstat0+msgstat1.join("\n") + msgmissing
    
  end

  # 与えられた看護師群が持つroleのidのlog用の文字列
  def role_list(nurces)
    if nurces == true ; "[]"
    else
      "[" +roles_of(nurces).join(',') +"]"
    end
  end

  # 与えられた看護師群のidのlog用の文字列
  def nurce_list(nurces) 
    if nurces == true ; "[oo]"
    elsif nurces      ; "[" + nurces.map(&:id).join(',') + "]" 
    else              ; ""
    end
  end


  def assign_log(day,shift,nurces,line,patern=nil,msg="",sw=(LogPuts|LogInfo))
    dbgout("HP ASSIGN LOG (#{line}) #{day}:#{shift}" + (patern ? "(%4s)"%patern.to_s : "    ") +
           ' '*day + nurce_list(nurces) + " "*(34-day)+msg ,
           sw)
  end

  def entry_log(day,shift,line,need_nurces,short_roles,as_nurces,sw=(LogPuts|LogInfo))
    dbgout("HP ASSIGN(#{line})  #{day}:#{shift} [] [] ENTRY  必要看護師数 #{need_nurces}"+
           " 不足role["+short_roles.join(",")+ "] 可能看護師"+ nurce_list(as_nurces),
           sw
           )
  end


  ####


  def nCm(n,m)
    (1..m).inject(1){|nCm,i| nCm * (n+1-i)/i}
  end
  ########################### 姥捨山 ####################3
  def self.create_assign_test
    Hospital::Assign.create_assign(1,Date.new(2013,2,1),2,6)
  end
  def self.logger(*args)
    open("/tmp/assigntest.log","w"){ |fp| fp.puts args}
  end 

end

def logout_stat(msg)
  open( File.join( RAILS_ROOT,"tmp","hospital","log","stat"),"a"){ |fp|
    fp.puts msg
  }
end

def dbgout(msg,sw=(LogPuts|LogInfo))
  puts msg         if sw & LogPuts
  if sw & LogInfo
    logger.info  msg 
  elsif sw & LogDebug
    logger.debug msg  
  end

end

__END__
reculc=false
assign = Hospital::Assign.new(1,Date.new(2013,2,1))
assign. short_role(day,sft_str) # 1211
assign.    short_role_shift(reculc)[day] #1166
assign.      count_role_shift[day]
assign.      short_role_shift_of(day)  #1067
assign.         needs_all_days[day]
assign.short_role_shift[day] # 1216 ここに 0=>[0, 0],
assign.short_role_shift_of(day)       #1169 ここにはない
assign.short_role_shift(reculc)[day].to_a.map{|role_shift,min_max| 
      role_shift.first if min_max.first>0 && role_shift.last == sft_str}
