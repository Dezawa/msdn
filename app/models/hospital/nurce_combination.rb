# -*- coding: utf-8 -*-
# 
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
  def nurce_combination_shift23(combinations,need_nurces,short_roles,day,&block)
    @msg = nil
    dbgout("FOR_DEBUG(#{__LINE__}) Shift2:#{need_nurces_shift(day,Sshift2)} [#{short_roles[Sshift2].join(',')}]"+
           "  Shift2:#{need_nurces[Sshift3]}] [#{short_roles[Sshift3].join(',')}] 三直:#{@koutai3} ")
    case [need_nurces_shift(day,Sshift2) == 0 && short_roles[Sshift2] ==[],
          need_nurces_shift(day,Sshift3) == 0 && short_roles[Sshift3] ==[] || !@koutai3 ]
    when [true,true]  # shift2,3共に既に足りている
      @msg =  "ALLREDY filled for 2,3 " 
      block.call( {Sshift2 => true,Sshift3 => true })
      
    when [true,false] # shift2は既に足りている
      #nurce_combination_by_tightness(as_nurce["3"],need_nurces["3"],short_roles["3"],3)
      if combinations[Sshift3].size==0 
        @msg =  "(#{__LINE__})NO Abaiable combination set for shift 3" 
        block.call false
      end
      combinations[Sshift3][0,Size_of_NurceCombinationList].each{|cmb3|
        #next if not_enough_for_shift1(combinations["1"],[],cmb3,need_nurces,short_roles,day)
        block.call({Sshift2 => true,Sshift3 => cmb3 })
      }
      
    when [false,true]  # shift3は既に足りている
      if combinations[Sshift2].size==0 
        @msg =  "(#{__LINE__})NO Abaiable combination set for shift 2" 
        block.call false
      end
      combinations[Sshift2][0,Size_of_NurceCombinationList].each{|cmb2| 
        #next if not_enough_for_shift1(combinations["1"],cmb2,[],need_nurces,short_roles,day)
        block.call({Sshift3 => true,Sshift2 => cmb2 })
      }
      
    when [false,false] #shift2,3共に足りない
      if combinations[Sshift2].size==0 && short_roles[Sshift2].size > 0 
        @msg = "combination 2 is empity"
        return false
      elsif  combinations[Sshift3].size==0 && short_roles[Sshift3].size > 0 
        @msg = "combination 3 is empity"
        block.call false
        #logger.debug("==== [false,false]")
      end

      # 組み合わせ順の最適化を行う
      combinations[Sshift2].product(combinations[Sshift3]).
        sort_by{ |cmb2,cmb3|
        cost_of_nurce_combination_of_combination(cmb2,cmb3)
      }.select{ |cmb2,cmb3|
        (cmb3 | cmb2).size == cmb3.size+cmb2.size
      }[0,Size_of_NurceCombinationList].each{ |cmb2,cmb3|
        block.call({Sshift2 => cmb2,Sshift3 => cmb3 })
      }
    end
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

  def candidate_for_night(day)
    nurces_short = $HP_DEF.night.inject([[],[]]){ 
      |n_s,sft_str|
      short = short_role(day,sft_str)
      n_s[0] += assinable_nurces_by_cost_size_limited(sft_str,day, short)
      n_s[1] += short
      n_s
    }
    short = nurces_short[1].uniq
    nurces = nurces_short[0].uniq.
      sort_by{ |nurce| nurce.cost(:night_total,tight_roles(:night_total))}
  end

  def candidate_combination_for_night(day)
    candidate_for_night(day).combination(need_nurces_shift(day,Sshift2)+need_nurces_shift(day,Sshift3))
  end

  def candidate_combination_for_night_selected_by_cost(day)
    candidate_combination_for_night(day).
      sort_by{ |nurces| 
        cost_of_nurce_combination(nurces,:night_total,tight_roles(:night_total))
      }[0,limit_of_nurce_candidate_night(day)]
  end

  def candidate_combination_for_shift23(day)
    need2 = need_nurces_shift(day,Sshift2)
    candidate_combination_for_night_selected_by_cost(day).map{ |comb|
      comb.combination(need2).map{ |nurce_shift2|
        [nurce_shift2, comb - nurce_shift2]
      }
    }.flatten(1)
  end

  def candidate_combination_for_shift23_selected_by_cost(day)
    candidate_combination_for_shift23(day).
      select{  |nurces_shift2,nurces_shift3| 
      nurces_shift2.all?{ |nurce| nurce.shift_remain[Sshift2] > 0 } &&
      nurces_shift3.all?{ |nurce| nurce.shift_remain[Sshift3] > 0 }

    }.
      sort_by{ |nurces_shift2,nurces_shift3| 
      cost_of_nurce_combination(nurces_shift2,Sshift2,tight_roles(Sshift2)) +
      cost_of_nurce_combination(nurces_shift3,Sshift3,tight_roles(Sshift3))
    }[0,limit_of_nurce_candidate_night(day)]
  end

  def nurce_combination_for_shift23(day)

  end

end
