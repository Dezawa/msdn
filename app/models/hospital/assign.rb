# -*- coding: utf-8 -*-
#
ID = "$Id: assign.rb,v 1.1.2.87 2013-08-23 07:49:54 dezawa Exp $"
#
require 'extentions'
# 
#
LogPuts,LogDebug,LogInfo = 1,2,4


# 未使用トライアル中な、combination_combination_tightness にて使われる、
# 低コスト割付優先すべき看護師群の shift2,3の組み合わせを実際に作ってコストで
# sortする、という場合に、top何組ずつで組み合わせるか、を決める
Top = 3
SelectedMax = 20-1 #(2) assign可能な看護師が多数居るとき、コストからみて最初の何人かで組み合わせを作る

# 指定された時間  Hospital::Const::Timeout 経過したとき発生させるエラー
class TimeToLongError < StandardError ;  end

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
#  assign_month
#    candidate_combination_for_shift23_selected_by_cost
#        assign_night_untile_success_or_timeout
#            assign_night
#                candidate_combination_for_shift23_selected_by_cost
#                assign_night_shift
#                  need_nurces_shift
#                  long_plan_combination
#                  assign_patern
#                     assign_patern_if_possible
#                        assign_test_patern
#                        nurce_set_patern
#                     long_check_later_days
#                     merged_patern 
#                     avoid_check
#        assign_daytime_untile_success_or_timeout
#            assign_shift1
#                assign_tight_daies_first
#                   shift_tight_days 
#                      short_role_shift
#                      assinable_nurces 
#                   assign_shift1_by_re_entrant
#                assign_shift1_by_re_entrant
#                   candidate_combination_for_shift_selected_by_cost
#                   assign_shift_daytime
#                      nurce_set_shift

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
  #include Hospital::WhichPatern
  include Hospital::Const
  include Hospital::NurceCombination
  include Hospital::AssignStatus
  include Hospital::ReEntrant
  include Hospital::AssignLog

  delegate :logger, :to=> "ActiveRecord::Base"
  #delegate :breakpoint, :to=>"ActiveRecord::Base"
  attr_accessor :nurces,:kangoshi,:Kangoshi,:needs,:nurce_assignd,:need_patern,:error,:roles
  attr_accessor :restore_count, :entrant_count, :loop_count, :shortcut
  attr_accessor :exit_confition,:month
  attr_accessor :night_mode, :avoid_list,:limit_time

  #attr_accessor  :koutai3, :shifts_int, :shifts, :shifts123, :shiftsmx, :night, :shifts_night
  attr_accessor  :koutai3, :shifts_int, :shifts, :shifts123, :night, :shifts_night
  attr_accessor  :busho_id, :lastday,  :needs,   :basename
  attr_accessor  :night_mode

  # CTLR から呼ばれる。
  # assign_month を実行し、成否に関わらず Hospital::Monthly に書き出して帰る
  def self.create_assign(busho_id,month,all=nil)
    assign = self.new(busho_id,month)
    assign.assign_month#_mult(all)
    #rescue => a
    #  logger(a)
    #  true
    #end
  end

  def initialize(arg_busho_id,arg_month)
    # 三交代職場かどうか、職種勤務体系がいくつ有るか、資格がいくつあるか
    # などで シフト数や看護師のrole_id が変わる。それをここで決定し インスタンス変数にしまう
    set_shift_constants

    @month = (arg_month||Time.now.beginning_of_month.next_month).to_date

    # 部署毎の条件を設定する
    set_condition_of_this_busyo_month(arg_busho_id) if arg_busho_id
    
    @basename = File.join( Rails.root,"tmp","hospital",
                           "Shift_%02d_%02d_"%[@busho_id,@month.month]) if @month

    @avoid_list = Hospital::AvoidCombination.all.map{ |ab| [[ab.nurce1_id,ab.nurce2_id],ab.weight]}
    @assign_start_at = Time.now
    clear_stat
  end

  # 一月の割付を行う
  # 成否に関わらず Hospital::Monthly に書き出して帰る
  #
  # 一日目の夜勤の候補を複数組用意し、それを順次試す。
  # Timeout 秒の間に結果がでなければ諦めて次の候補を試す
  # すべての候補で失敗した場合は、最も深くまで割り付けられた結果を書き出す。
  def assign_month(day=1)
    statistics_log_title
    log_start_title
    
    @count = 0
    @initial_state = save_shift(@nurces,1)

    first_day_combination = first_day_candidate_combination

    dbgout dump("  HP START  ")
    while first_day_combination.size > 1
      first_day_combination.shift
      @count += 1
      restore_shift(@nurces,1,@initial_state)
      refresh

      @stat = ""
      next unless assign_night_untile_success_or_timeout(first_day_combination)
      next unless assign_daytime_untile_success_or_timeout
      @count += 1
      log_stat_result
      save
      #next
      return true
    end
    restore_shift(@nurces,1,longest[1])
    save
    #raise StandardError
  end

  # 夜勤について割付を行う。Timeoutしたらそこで打ちきる
  # 実際の割付は #assign_night で再帰で行う
  def assign_night_untile_success_or_timeout(candidate_combination,opt ={ })
    @night_mode = true
    @start      = Time.now 
    @limit_time = @start + Hospital::Const::Timeout
    begin
      if assign_night(1,:nurce_combinations => candidate_combination)
        @stat = "%5.2f(成功),"%(Time.now - @start)
      else
        log_statistics( "%5.2f(失敗)"%(Time.now - @start))
        return false
      end
    rescue TimeToLongError # => evar
      log_statistics( "時間切れ")
      return false
    end
  end

  # 日勤について割付を行う。Timeoutしたらそこで打ちきる
  # 実際の割付は #assign_shift1 で再帰で行う
  def assign_daytime_untile_success_or_timeout(opt ={ })
    @night_mode = false
    @start      = Time.now 
    @limit_time = @start + Hospital::Const::Timeout
    begin
      if assign_shift1(1,opt)
        log_statistics( @stat + "%5.2f(成功)"%(Time.now - @start))
        return true
      else
        log_statistics( @stat + "%5.2f(失敗)"%(Time.now - @start))
        return false
      end
    rescue TimeToLongError # => evar
      log_statistics( @stat + "時間切れ")
      return false
    end
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
    assign_mult_old(single = SecondAndLater,day)
  end 
  def assign_mult_new(single = SecondAndLater,day=1)
    set_instance_valiables_for_assign_loop

    #### Loop counter
    try = 0
    @count = -1
    count_max = limit_of_nurce_candidate_night(1)

    ######## LOOP
    sft_str = Sshift2
    day = 1
    candidate_combination_for_shift23_selected_by_cost(day).each{ |candidate|
      
    }
  end

  def set_instance_valiables_for_assign_loop
    @basename = File.join( Rails.root,"tmp","hospital",
                           "Shift_%02d_%02d_"%[@busho_id,@month.month])
    @start = @start_mult = Time.now
    @limit_mult = @start_mult + Hospital::Const::TimeoutMult
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
    roles_required_total
    short_role_shift true
    count_role_shift true
  end

  # def need_nurces_of_night(day)
  #   short_role_shift_of_day = short_role_shift_of(day)
  #   @shifts_night[@night_mode].map{ |sft_str| [sft_str,short_role_shift_of_day[[@Kangoshi,sft_str]][0] ] }.to_h
  # end

  #割り当て可能なnurseをcostの低いほうから何人か選ぶ。
  #何人選ぶかは #limit_of_nurce_candidate にて決める
  #ただしcostだけで選ぶと必要ロールがそろわない恐れがあるので、
  # 持っているロールのパターンで分け、それぞれの中でコストの低い方から必要人数選ぶ。
  # これが必要なのは割りあて可能な人数が「何人か」より多い場合
  def assinable_nurces_by_cost_size_limited(sft_str,day,short_roles_this_shift )
    @assignable_nurce ||= { }
    @assignable_nurce[sft_str] = assinable_nurces(day,sft_str,short_roles_this_shift)
    @limit = limit_of_nurce_candidate(sft_str,day)
    logger.debug("  limit_of_nurce_candidate(sft_str,day) #{sft_str},#{day}")
    logger.debug("    HOSPITAL ASSIGN 可能看護師 shift#{sft_str} Limit=#{@limit}=>#{@assignable_nurce[sft_str].size}人, #{@assignable_nurce[sft_str].map(&:id).join(',')}")
    if @assignable_nurce[sft_str].size <= @limit
      @assignable_nurce[sft_str].
        sort_by{|nurce| nurce.cost(@night_mode ? :night_total : Sshift1,tight_roles(sft_str))} 
    else
      array_merge(gather_by_each_group_of_role(@assignable_nurce[sft_str],sft_str,short_roles_this_shift)
                  )[0,@limit]
    end
  end

  # 持ってるroleで層別し、各々の層をcostで並べる。
  def gather_by_each_group_of_role(as_nurce,sft_str,short_role_of_this_shift)
    nurces_group_by = as_nurce.group_by{ |nurce| (nurce.need_role_ids & short_role_of_this_shift).sort}
    logger.debug("    GATHER_BY_EACH_GROUP_OF_ROLE shift=#{sft_str}:as_nurce = #{as_nurce.map(&:id).join(',')}")
    nurces =  nurces_group_by.to_a.  # 持ってるroleで層別し
      sort_by{ |roles,nurce_list|  roles_cost(roles,tight_roles(sft_str))}.
      map{ |roles,nurce_list|                                # 各々の層をcostで並べる
      nurce_list.sort_by{|nurce| nurce.cost(@night_mode ? :night_total : Sshift1,tight_roles(sft_str)) 
      }
    }
    logger.debug("    GATHER_BY_EACH_GROUP_OF_ROLE [#{nurces.map{|ns| ns.map(&:id).join(',')}.join('],[')}]")
    nurces
  end # of case

  # 候補の数(上限)を決める。
  # 多すぎると時間が掛かる。
  # 少なすぎると割付に失敗する。
  def limit_of_nurce_candidate(sft_str,day)
    case sft_str
    when Sshift2,Sshift3 ; limit_of_nurce_candidate_night(day)
    when Sshift1         ; limit_of_nurce_candidate_day(day)
    end # of case    
  end

  def limit_of_nurce_candidate_night(day)
    [((need_nurces_shift(day,Sshift2)+(need_nurces_shift(day,Sshift3)||0))*Factor_of_safety_NurceCandidateList).ceil,
     LimitOfNurceCandidateList].max
  end

  def  limit_of_nurce_candidate_day(day)
    [ (need_nurces_shift(day,Sshift1) * 1.2).ceil ,need_nurces_shift(day,Sshift1)+1].max
  end

  # 持つロールパターン毎に層別されたデータ(nurces_classified_by_role)から
  # 順次抜き出して一次元のデータにする
  def array_merge(nurces_classified_by_role)
    return [] if nurces_classified_by_role==[]
    return nurces_classified_by_role[0] if nurces_classified_by_role.size==1
    maxsize = nurces_classified_by_role.map{|ary| ary.size}.max
    merged = nurces_classified_by_role[0]+[nil]*(maxsize-nurces_classified_by_role[0].size)
    nurces_classified_by_role[1..-1].inject(merged){|merg,ary| merg.zip(ary)}.flatten.compact
  end


  # 再帰が失敗して戻るときに、元にもどすための状況保存
  # 保存するもの
  #   看護師の状況 Hospital::Nurceに任せる  nurces_save
  #   一月分の各日・shiftのroleの不足状況   short_role_shift_dup
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
    count_role_shift_dup = (day..[day+8,@lastday].min).map{|d| count_role_shift[d].dup }
    role_remain_dup = role_remain.dup
    [ nurces_save,   count_role_shift_dup,  short_role_shift_dup, role_remain_dup]
  end

  def restore_shift(nurces,day,shifts_short_role,sft_str=Sshift3)
    return if nurces == true
    @restore_count += 1

    nurces.each_with_index{|nurce,idx| 
      nurce.restore_shift(shifts_short_role[0][idx])
    }
    shifts_short_role[1].each_with_index{ |crs,d| count_role_shift[d + day] = crs }
    shifts_short_role[2].each_with_index{|srs,d| 
      srs.each_pair{|key,ary| short_role_shift[day+d][key] = ary } 
    }
    
    role_remain = shifts_short_role[3]
  end

  # 禁忌な組み合わせがあるか調べる     [ [LongPatern,LongPatern],daily_checks],[] ]
  def avoid_check(nurces,sft_str,first_day,list_of_long_patern)
    return true 
    return true if sft_str == "1"
    #pp [first_day,list_of_long_patern]
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
  def nurces_have_avoid_combination?(nurces)
    nurce_ids = nurces.map(&:id)
    @avoid_list.inject(0){ |cst,comb_weight| 
      cst + (((comb_weight[0] & nurce_ids)==comb_weight[0]) ? comb_weight[1] : 0)
    }
  end

  # [number_of_nurce] 看護師の人数
  # [number_of_plan]  LongPaternの数
  # 戻り値            [ [0,0,0],[0,0,1],,,,[1,1,1] ]
  def long_plan_combination(number_of_nurce,number_of_plan)
    @long_plan_combination ||= { }
    if @long_plan_combination[[number_of_nurce,number_of_plan]]
      return @long_plan_combination[[number_of_nurce,number_of_plan]] 
    end
    work = (0..number_of_plan-1).to_a
    @long_plan_combination[[number_of_nurce,number_of_plan]] = 
      work.product( *[work]*(number_of_nurce-1))
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
    @need_patern ||= Hospital::Need.need_patern(@busho_id)
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


  ########### log helper ###########
  def dump(header="")
    begin
      @nurces.map{|nurce| header+"#{nurce.id} #{nurce.shifts}"}.join("\n") 
    rescue 
      dbgout @nurces.size
      @nurces.each{|nurce|  dbgout header+"#{nurce.id} #{nurce.shifts}"}
    end
  end

  def leader_need ; Hospital::Limit.need_roles(@busho_id,@month)[[Hospital::Define.define.leader,:night_total]] ;end
  def leader_arrow; Hospital::Limit.arrowable_roles(@busho_id,@month)[[Hospital::Define.define.leader,:night_total]] ;end
  def kangoshi_need;Hospital::Limit.need_roles(@busho_id,@month)[[Hospital::Define.define.kangoshi,:kinmu_total]]    ;end
  def kangoshi_arrow;Hospital::Limit.arrowable_roles(@busho_id,@month)[[Hospital::Define.define.kangoshi,:kinmu_total]];end


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
  def longest ;  @longest ||=  [0,[[]]] ;end

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
    rescue TimeToLongError
      logger.info("HOSPITAL FINISHED BY TIMED OUT Finaly================================")
      restore_shift(nurces,1,@longest[1])
      @fine = Time.now;log_stat(:head => "=== Timed Out ===")
      save
    end      
    self
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


  #private?

  # 三交代職場かどうか、職種勤務体系がいくつ有るか、資格がいくつあるか
  # などで シフト数や看護師のrole_id が変わる。それをここで決定し インスタンス変数にしまう
  def set_shift_constants
    @Kangoshi = Hospital::Role.find_by_name("看護師").id
    @kangoshi_idx_of_need_roles = Hospital::Need.need_role_ids.index(@Kangoshi)
    @koutai3 = Hospital::Define.koutai3?
    @shifts_int= @koutai3 ? Shift0123 : Shift0123[0..-2]
    @shifts = @koutai3    ? Sshift0123 : Sshift0123[0..-2]
    @shifts123 = @koutai3 ? Sshift123  : Sshift123[0..-2]
    @HospitalRolecount = Hospital::Need.roles.size #Hospital::Role.count
    @RoleShift =   Hospital::Need.roles.product(@shifts123)
    # @shiftsmx = @shifts123[-1] #  Sshift2 or Sshift3
    @night  = @shifts123[1..-1] # [Sshift2] or [Sshift2,Sshift3]
    @shifts_night = { true =>  @night, false => [Sshift1], nil => [Sshift1]}
    #dbgout("FOR_DEBUG(#{__LINE__}) init @night=#{@night},@koutai3:#{@koutai3} @shifts#{@shifts}")
  end

  # 部署毎の条件を設定する
  def set_condition_of_this_busyo_month(arg_busho_id)
    @busho_id = arg_busho_id
    @lastday=@month.end_of_month.day
    @nurces = Hospital::Nurce.by_busho(@busho_id,:month => @month)
    @nurces.each{ |nurce| nurce.monthly @month}
    @needs  = needs_all_days
    # @count_role_shift = count_role_shift     # [[[[role,shift],[role,shift],,],[day  ],[day]],[nurce],[nurce] ]
    # @nurces.each{|nurce| nurce.monthly(@month).day2shift}
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

  def logout_stat(msg)
    open( File.join( Rails.root,"tmp","hospital","log","stat"),"a"){ |fp|
      fp.puts msg
    }
  end

  def save_shift_log(save_shift = nil)
    save_shift ||= @initial_state
    #logger.debug( [0,2,5].map{ |id| @initial_state[1,3]})
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
