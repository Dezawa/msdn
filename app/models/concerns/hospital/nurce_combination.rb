# -*- coding: utf-8 -*-
# 

class NoCandidateError < StandardError ; end

module Hospital::NurceCombination
  include Hospital::Const

  # shift2,3各々の看護師の組み合わせのproductを一つずつ block に渡す
  # 渡す前に可能性を評価して可能性無いものはパスする
  #   ＊すなわち＊　長割りでなければ、この日の割付は必ず成功する組み合わせが返る
  #   調べる可能性
  #     shift2,3で同じ看護師が選ばれているもの
  #     必要roleを満たせない看護師の組み合わせ(combinationsが既にそうなっている)
  # 
  # 実装
  #   shift2,3の必要人数を needs23 とする
  #   看護師からnightの残っている人を、コスト準に needs23 x 安全係数だけ集める
  #   needs23人の組み合わせを作り、夜勤残数をベースのコストでソートし、最初の何組かを選ぶ
  #     needs2、need3 に分ける組み合わせを作り
  #       シフト残数ベースのコストでソートし
  #         必要roleを満たせる看護師の組み合わせの時、blockを呼ぶ
  #
  # def ddnurce_combination_shift23(candidate_combination_for_shift23,need_nurces,short_roles,day,&block)
  #   candidate_combination_for_shift23.each{ |combs| 
  #     block.call(combs ) }
  # end 


  # day日のshift2,3の看護師組み合わせの候補。
  #  [ [shift2_候補,shift3_候補],[shift2_候補,shift3_候補],,,]
  # 以下が考慮されている
  #   shift2_候補,shift3_候補に重複はない
  #   各々のshiftの必要roleは満たされる
  #   そのシフトに割り当てても、各看護師の勤務制約に抵触しない
  #   コストの少ない方から選んでいる
  #   候補数の上限は limit_of_nurce_candidate
  def candidate_combination_for_shift23_selected_by_cost(day)
    #return :fill unless short?(day,:night_total)
    fill = @night.map{ |sft_str| !short?(day,sft_str)}
    begin
      #candidate_combinations = 
        case fill
        when [true ,true ] ;  :fill 
        when [true ,false]; candidate_combination_for_shift_selected_by_cost(day,Sshift3,:null => Sshift2)
        when [false,true ]; candidate_combination_for_shift_selected_by_cost(day,Sshift2,:null => Sshift3)
        else              
          candidate_combinations = candidate_combination_for_shift23(day)
          return nil unless candidate_combinations
          return :fill if candidate_combinations == :fill
          candidate_combinations.sort_by{ |hash_of_combination| 
              cost_of_nurce_combination(hash_of_combination["2"],Sshift2,tight_roles(Sshift2)) +
              cost_of_nurce_combination(hash_of_combination["3"],Sshift3,tight_roles(Sshift3))
           }[0,limit_of_nurce_candidate_night(day)]
        end
   rescue NoCandidateError
      return nil
    end
  end

  # 指定日指定シフトの看護師組み合わせの候補群を作る
  # 以下が考慮されている
  #   必要roleは満たされる
  #   そのシフトに割り当てても、各看護師の勤務制約に抵触しない
  #   コストの少ない方から選んでいる
  #   候補数の上限は limit_of_nurce_candidate
  def candidate_combination_for_shift_selected_by_cost(day,shift,opt={ })
    return :fill unless short?(day,shift)
    candidate_combinations = candidate_combination_for_shifts(day,shift)
    unless candidate_combinations.size > 0
      return nil 
    end
    combinations = 
      candidate_combinations.first.sort_by{ |combination| 
      cost_of_nurce_combination(combination,shift,tight_roles(shift))
    }[0,limit_of_nurce_candidate(shift,day)]

    case null_sft = opt[:null]
    when nil     ; combinations.map{ |comb| { shift => comb}}
    else         ; combinations.map{ |comb| { null_sft => [], shift => comb}}
    end
  end

  # day日のshift2,3の看護師組み合わせの候補をHashに変換
  #  [ [shift2_候補,shift3_候補],[shift2_候補,shift3_候補],,,]
  # 以下が考慮されている
  #   shift2_候補,shift3_候補に重複はない
  #   各々のshiftの必要roleは満たされる
  #   そのシフトに割り当てても、各看護師の勤務制約に抵触しない
  def candidate_combination_for_shift23(day)
    need2 = need_nurces_shift(day,Sshift2)
    candidate = 
      candidate_combination_for_shifts(day,Hospital::Define.define.night).map{ |comb2,comb3|
          { "2" => comb2, "3" => comb3 }
    }
  end

  # 指定日指定シフト(複数も可)の看護師組み合わせの候補群を作る
  # 以下が考慮されている
  #   複数shiftの候補に重複はない      <- このmethodで実施
  #   必要roleは満たされる
  #   そのシフトに割り当てても、各看護師の勤務制約に抵触しない
  def candidate_combination_for_shifts(day,shifts)
    shifts = [shifts] if shifts.class == String

    if shifts.size == 2
      candidate_combination = 
        candidate_combination_for_shift_with_enough_role(day,shifts.first).
        to_a.product(candidate_combination_for_shift_with_enough_role(day,shifts[1])).
        select{ |comb2,comb3| (comb2 & comb3).empty? }#.
      return candidate_combination if candidate_combination.size > 0

      logger.debug("    HOSPITAL ASSIGN NoCandidate Dup: shift2,3で同じ看護師が重なるものばかり #{day}日 ")
      raise NoCandidateError,"shift2,3で同じ看護師が重なるものばかり"

    elsif  shifts.size == 1
      [ candidate_combination_for_shift_with_enough_role(day,shifts.first) ]
    else
      raise "Hospital#candidate_combination_for_shifts シフト数が1,2以外"
    end
  end
  

  # 指定日指定シフトの看護師組み合わせの候補群を作る
  # 以下が考慮されている
  #   必要roleは満たされる     <- このmethodで実施
  #   そのシフトに割り当てても、各看護師の勤務制約に抵触しない
  def candidate_combination_for_shift_with_enough_role(day,sft_str)
    candidate = candidate_combination_for_shift(day,sft_str). 
      select{ |comb| roles_filled?(day,sft_str,comb).max == 0 }
    if candidate.size == 0
      logger.debug("    HOSPITAL ASSIGN NoCandidate ROLE:#{day}日 shift#{sft_str}：ロールを満たす組み合わせがない")
      raise NoCandidateError
    end
    return candidate
  end

  
  # 指定日指定シフトの看護師組み合わせの候補群を作る
  # 以下が考慮されている
  #   そのシフトに割り当てても、各看護師の勤務制約に抵触しない
  def candidate_combination_for_shift(day,sft_str)
    need_nurces = need_nurces_shift(day,sft_str)
    assinable_nurces = assinable_nurces_by_cost_size_limited(sft_str,day,short_role(day,sft_str))
    #assinable_nurces = assinable_nurces(day,sft_str,short_role(day,sft_str))
    assinable_nurces.combination(need_nurces)
  end

  # 初日の看護師組み合わせ候補を作る。
  # assign_monthのループに入る毎にshiftして前回使った先頭の組み合わせを捨てている
  # このため、candidate_combination_for_shift23_selected_by_cost の戻りの頭に
  # 捨て石を置く
  def first_day_candidate_combination
    combination = candidate_combination_for_shift23_selected_by_cost(1)
    combination.unshift(nil)
    combination
  end


  # 最適化を行うとどの位のコストとなるのか？
  # ５Fを例にとると、
  #  limit_of_nurce_candidate_night = (4+3)*2 = 14
  #  comb2 14 13 12 11/(4 3 2) = 2261
  #  comb3 14 13 12 /(3 2)     =  364
  #  各々の limit_of_nurce_candidate_night = (4+3)*2 = 14 を選び oprduct
  #  14 * 14 = 196
  #

  # 必要なロールが揃っているか
  def  roles_filled?(day,sft_str,nurces)
    return [0]  if nurces.size == 0
    roles_count_short(day,sft_str).sub(roles_count_assigned(nurces)). #(nurces)).
      map{ |count| count < 0 ? 0 : count }
  end

  # 指定された看護師達がもつrole数の合計
  # 戻り値 :: [ 0, 2, 2, 1 ] の様な配列。 要素数とその順は、Hospital::Need.need_role_ids 
  def roles_count_assigned(nurces)
    nurces.map(&:have_need_role_patern).inject{ |sum,roles| sum.add roles }
  end

  # 指定された日、shiftに割付可能な看護師の配列
  # その日割付まだされておらず、かつそのshiftを割り付けても勤務制約を越えず
  # 足りないroleを少なくとも一つ持っている
  # 足りないroleが無いとき（既に満たされている)は空を返す
  def assinable_nurces(day,sft_str,short_roles,reculc=false)
    logger.debug("ASSINABLE_NURCES check_at_assign of id 11,17,20 "+
                 "#{nurce_by_id([11,17,20]).map{ |nurce| nurce.check_at_assign(day,sft_str)}.join(',')}"
                 ) if day==1 && @busho_id == 3 
    return [] if roles_count_short(day,sft_str).max == 0

    @nurces.select{|nurce| nurce.assignable?(day,sft_str,short_roles.map{|r,mi_max| r }) }
  end


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

  # 持つロールパターン毎に層別されたデータ(nurces_classified_by_role)から
  # 順次抜き出して一次元のデータにする
  def array_merge(nurces_classified_by_role)
    return [] if nurces_classified_by_role==[]
    return nurces_classified_by_role[0] if nurces_classified_by_role.size==1
    maxsize = nurces_classified_by_role.map{|ary| ary.size}.max
    merged = nurces_classified_by_role[0]+[nil]*(maxsize-nurces_classified_by_role[0].size)
    nurces_classified_by_role[1..-1].inject(merged){|merg,ary| merg.zip(ary)}.flatten.compact
  end


  # 看護師群のcostの総計
  def cost_of_nurce_combination(nurces,sft_str,tight = nil)
    tight ||= tight_roles(sft_str)
    nurces.inject(2.0){|cost,nurce| cost + nurce.cost(@night_mode ? :night_total : Sshift1,tight) }*
      AvoidWeight[[nurces_have_avoid_combination?(nurces),AvoidWeight.size-1].min]
  end

  def cost_of_nurce_combination_with_avoid(nurces,sft_str,tight)
    cost_of_nurce_combination(nurces,sft_str,tight)*
      AvoidWeight[[nurces_have_avoid_combination?(nurces),AvoidWeight.size-1].min]
  end

  def cost_of_nurce_combination_of_combination(comb2,comb3)
    if comb3.nil?
      comb2,comb3 = comb2
    end 
    cost_of_nurce_combination(comb2,Sshift2,tight_roles(Sshift2)) +
      (comb3 ? cost_of_nurce_combination(comb3,Sshift3,tight_roles(Sshift3)) : 0) 
  end
end
