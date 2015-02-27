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
  def candidate_combination_for_shift23_selected_by_cost(day)
    #return :fill unless short?(day,:night_total)
    fill = @night.map{ |sft_str| !short?(day,sft_str)}
    begin
      candidate_combinations = 
        case fill
        when  [true,true]  ; return :fill 
        when [true,false]  ; candidate_combination_for_shift_selected_by_cost(day,Sshift3,:null => Sshift2)
        when [false,true]  ; candidate_combination_for_shift_selected_by_cost(day,Sshift2,:null => Sshift3)
        else               ; candidate_combination_for_shift23(day)
        end

      return nil unless candidate_combinations
      return :fill if candidate_combinations == :fill
      candidate_combinations.
        sort_by{ |hash_of_combination| 
        cost_of_nurce_combination(hash_of_combination["2"],Sshift2,tight_roles(Sshift2)) +
        cost_of_nurce_combination(hash_of_combination["3"],Sshift3,tight_roles(Sshift3))
      }[0,limit_of_nurce_candidate_night(day)]
   rescue NoCandidateError
      return nil
   end
  #     candidate_combinations = candidate_combination_for_shift23(day)
  #     candidate_combinations = candidate_combination_for_shift_selected_by_cost(day,Sshift3,:null => Sshift2)
  #     return nil unless candidate_combinations
  #     candidate_combinations.
  #       sort_by{ |hash_of_combination| cost_of_nurce_combination(hash_of_combination[Sshift3],Sshift3,tight_roles(Sshift3))
  #     }[0,limit_of_nurce_candidate_night(day)]
  #   else
  #     candidate_combinations = candidate_combination_for_shift23(day)
  #     return nil unless candidate_combinations
  #     candidate_combinations.
  #       sort_by{ |hash_of_combination| 
  #       cost_of_nurce_combination(hash_of_combination["2"],Sshift2,tight_roles(Sshift2)) +
  #       cost_of_nurce_combination(hash_of_combination["3"],Sshift3,tight_roles(Sshift3))
  #     }[0,limit_of_nurce_candidate_night(day)]
  #   end
  end

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

  def candidate_combination_for_shift23(day)
    need2 = need_nurces_shift(day,Sshift2)
    candidate = 
      candidate_combination_for_shifts(day,Hospital::Define.define.night).map{ |comb2,comb3|
          { "2" => comb2, "3" => comb3 }
    }
  end

  def candidate_combination_for_night(day)
    candidate_combination_for_shifts(day,Hospital::Define.define.night)
  end


  def candidate_combination_for_shifts(day,shifts)
    shifts = [shifts] if shifts.class == String
    combary = shifts.map{  |sft_str|
      candidate_combination_for_shift_with_enough_role(day,sft_str)
    }
    if shifts.size == 2
      candidate_combination = combary.first.to_a.product(combary.last.to_a).                      # 225
        select{ |comb2,comb3| (comb2 & comb3).empty? }#.
      return candidate_combination if candidate_combination.size > 0

      logger.debug("    HOSPITAL ASSIGN NoCandidate Dup: shift2,3で同じ看護師が重なるものばかり #{day}日 ")
      raise NoCandidateError,"shift2,3で同じ看護師が重なるものばかり"

    elsif  shifts.size == 1
      return [[]] unless combary.first.first
      combary.sort_by{ |comb|  cost_of_nurce_combination(comb.first,shifts.first,tight_roles(shifts.first))}
    else
      raise "Hospital#candidate_combination_for_shifts シフト数が1,2以外"
    end
  end
  
  def candidate_combination_for_shift_with_enough_role(day,sft_str)
    candidate = candidate_combination_for_shift(day,sft_str). 
      select{ |comb| roles_filled?(day,sft_str,comb).max == 0 }
    if candidate.size == 0
      logger.debug("    HOSPITAL ASSIGN NoCandidate ROLE:#{day}日 shift#{sft_str}：ロールを満たす組み合わせがない")
      raise NoCandidateError
    end
    return candidate
  end

  def candidate_combination_for_shift(day,sft_str)
    need_nurces = need_nurces_shift(day,sft_str)
    assinable_nurces = assinable_nurces_by_cost_size_limited(sft_str,day,short_role(day,sft_str))
    #assinable_nurces = assinable_nurces(day,sft_str,short_role(day,sft_str))
    assinable_nurces.combination(need_nurces)
  end

  # 最適化を行うとどの位のコストとなるのか？
  # ５Fを例にとると、
  #  limit_of_nurce_candidate_night = (4+3)*2 = 14
  #  comb2 14 13 12 11/(4 3 2) = 2261
  #  comb3 14 13 12 /(3 2)     =  364
  #  各々の limit_of_nurce_candidate_night = (4+3)*2 = 14 を選び oprduct
  #  14 * 14 = 196
  #
  def nurce_combination_shift1(combinations,need_nurces,short_roles,day,&block)
    tight = tight_roles(Sshift1)
    count=2
    combinations[Sshift1].
      combination(need_nurces_shift(day,Sshift1)).
      sort_by{ |nurces| cost_of_nurce_combination(nurces,Sshift1,tight) }.
      each{|cmb1|
        block.call({ Sshift1 => cmb1})
          count -= 1
          return if count < 1
      }
  end
  def enough?(day,sft_str,nurces)
    is_assignables?(sft_str,nurces) && 
      roles_filled?(day,sft_str,nurces).max == 0
  end

  def is_assignables?(sft_str,nurces)
    @assignable_nurce[sft_str] and nurces == nurces
  end

  def  roles_filled?(day,sft_str,nurces)
    return [0]  if nurces.size == 0
    roles_count_short(day,sft_str).sub(roles_count_assigned(nurces)). #(nurces)).
      map{ |count| count < 0 ? 0 : count }
  end

  def roles_count_assigned(nurces)
    nurces.map(&:have_need_role_patern).inject{ |sum,roles| sum.add roles }
  end

  # def nurce_combination_for_shift23(day)

  # end

  # 指定された日、shiftに割付可能な看護師の配列
  # その日割付まだされておらず、かつそのshiftを割り付けても勤務制約を越えず
  # 足りないroleを少なくとも一つ持っている
  # 足りないroleが無いとき（既に満たされている)は空を返す
  def assinable_nurces(day,sft_str,short_roles,reculc=false)
    logger.debug("ASSINABLE_NURCES check_at_assign of id 11,17,20 "+
                 "#{nurce_by_id([11,17,20]).map{ |nurce| nurce.check_at_assign(day,sft_str)}.join(',')}"
                 ) if day==1 && @busho_id == 3 
    return [] if roles_count_short(day,sft_str).max == 0
    nurce_not_assigned(day).
      select{|nurce| 
        !nurce.check_at_assign(day,sft_str) && 
        nurce.has_assignable_roles_atleast_one(sft_str,short_roles.map{|r,mi_max| r })
    }
  end

  def nurce_not_assigned(day)
    @nurces.select{|nurce| nurce.monthly.shift[day,1] == "_" }
  end

end
