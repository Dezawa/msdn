# -*- coding: utf-8 -*-
# 
module Hospital::NurceCombination
  include Hospital::Const

  # shift1,2,3各々の看護師の組み合わせのproductを一つずつ block に渡す
  # 渡す前に可能性を評価して可能性無いものはパスする
  #   ＊すなわち＊　長割りでなければ、この日の割付は必ず成功する組み合わせが返る
  #   調べる可能性
  #     shift1,2,3で同じ看護師が選ばれているもの
  #     必要roleを満たせない看護師の組み合わせ(combinationsが既にそうなっている)
  # shift1,2,3各々の組み合わせ群は role残り数による評価順に並んでいる
  # 
  # 実装
  #  productを作ってしまうと巨大な配列が、再帰毎に作られてしまう。それを避けるため
  #  eachループで順次作ってblockを呼んでいる。
  #  shoft23の組み合わせに於いては、組み合わせでの順番最適化を図るケースとそうではないケースを検討
  #   図らない場合 combination_combination_for_123
  #   図る場合     combination_combination_tightness
  #     shift2と3の低コストTop3のproductを作って最適化した後shift1とeachで組み合わせる。
  #      Top3同士以外はloopで行う
  def nurce_combination_shift23(combinations,need_nurces,short_roles,day,&block)
    @msg = nil
    if @night_mode
      dbgout("FOR_DEBUG(#{__LINE__})case #{need_nurces[Sshift2]} [#{short_roles[Sshift2]} #{need_nurces[Sshift3]} [#{short_roles[Sshift3]}] #{@koutai3} ")
      case [need_nurces[Sshift2] == 0 && short_roles[Sshift2] ==[],
            need_nurces[Sshift3] == 0 && short_roles[Sshift3] ==[] || !@koutai3 ]
      when [true,true]  # shift2,3共に既に足りている
        @msg =  "ALLREDY filled for 2,3 " 
        block.call( {Sshift2 => true,Sshift3 => true })
        
      when [true,false] # shift2は既に足りている
        #nurce_combination_by_tightness(as_nurce["3"],need_nurces["3"],short_roles["3"],3)
        if combinations[Sshift3].size==0 
          @msg =  "(#{__LINE__})NO Abaiable combination set for shift 3" 
          block.call false
        end
        combinations[Sshift3].each{|cmb3|
          #next if not_enough_for_shift1(combinations["1"],[],cmb3,need_nurces,short_roles,day)
          block.call({Sshift2 => true,Sshift3 => cmb3 })
        }
        
      when [false,true]  # shift3は既に足りている
        if combinations[Sshift2].size==0 
          @msg =  "(#{__LINE__})NO Abaiable combination set for shift 2" 
          block.call false
        end
        combinations[Sshift2].each{|cmb2| 
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
        # 組み合わせ順の最適化を行わない
        combinations[Sshift3].each{|cmb3|
          combinations[Sshift2].each{|cmb2|
            next unless (cmb3 | cmb2).size == cmb3.size+cmb2.size
            #next if not_enough_for_shift1(combinations["1"],cmb2,cmb3,need_nurces,short_roles,day)
            block.call({Sshift2 => cmb2,Sshift3 => cmb3 })
          }
        }
      end
    else #daytime
      combinations[Sshift1].combination(need_nurces[Sshift1]).each{|cmb1|
        block.call({ Sshift1 => cmb1})
      }
    end
  end

  def combination(busho_id,month)
    
  end

end
