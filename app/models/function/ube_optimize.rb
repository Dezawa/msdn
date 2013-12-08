# -*- coding: utf-8 -*-
module Function
  #
  #立案時に次に抄造割り当てを行うべき製品を決める。
  # 立案には、優先順モードと優先順尊重モードとがあるが、尊重モードの時に呼ばれる
  #   実際には、次に割り当てを行う「製品」(ロット)ではなく、ラウンドを決める。
  #   尊重モードの時は、1ロット毎の順序決めではなく、ラウンド(同じ製品連続)単位行うから。
  # 決定のアルゴリズム
  #   いくつかの方法を試したが、現在のものはoptimizeすなわち
  #     『乾燥機空き優先』「乾燥機を決め、抄造の早く終わるものを選ぶ」
  #   になった。
  # 再検討
  #	ライン組み合わせの４グループのうち、優先順の最も早いものを選ぶ
  #	それを仮割付し「乾燥待ちで抄造開始を遅らせる」ことが
  #	無ければ採用
  #	　　そのラウンドの中で待ちが起きたらそこで打ち切る
  #	有ったら、違う乾燥ラインのグループから優先度の早い方を選ぶ
  #
  # さらに
  #
  #
  #
  module UbeOptimize
  

  Shozo  = [:shozow,:shozoe]
  Dry    = [:dryo,:dryn]
  ShzDry = [:shozow,:shozoe].product [:dryo,:dryn]
  ShzDryByDry = {:dryo => Shozo.product([:dryo]),:dryn => Shozo.product([:dryn])}

    ShzDrys = { 
      :dryo => [[:shozoe,:dryn],[:syozow,:dryn]],
      :dryn => [[:shozoe,:dryo],[:syozow,:dryo]]
    }
  h = {}
  ShzDry.zip([:shozow,:shozoe].product [:dryn,:dryo]).each{|k,v| h[k]=v}
  CompShzDry = h

  def next_shozo_dry(grouped_plans,shozo_drys)
    shozo_dry = shozo_dry_of_first_jun_of_grouped_plans(grouped_plans,shozo_drys)
    begin
      plans = grouped_plans[shozo_dry][0]    # 最初のraund
      plan  = plans[0]                       # 最初のraundの最初のplan
    rescue
      return [nil,true,shozo_dry]
    end
    # 仮割り付けし、抄造の割付の結果をみる。
    # 結果が 成功のときはそのラウンドを返す。
    yojoKo      = get_yojoko(plan) 
    plan.yojoKo = yojoKo if yojoKo
    shozo,yojo,dry,shozo_aki_jikan = temp_assign_all_plan(plan)
    if shozo
      logger.info("INFO:   OPTIMIZE 抄造時間予測 #{plan.lot_no} 開始　#{shozo[1][0].mdHM}")
      return  [shozo_dry,shozo_aki_jikan]
    else
      logger.info("INFO:   OPTIMIZE 抄造割当不可")
      return [nil,true,shozo_dry]      
    end
  end

  def shozo_dry_of_first_jun_of_grouped_plans(grouped_plans,shozo_drys)
    shozo_drys.sort_by{|shozo_dry|
      grouped_plans[shozo_dry] && 
      grouped_plans[shozo_dry][0] ? grouped_plans[shozo_dry][0][0].jun : 1000000
    }[0]
  end

  # ライン組み合わせの４グループのうち、優先順の最も早いものを選ぶ
  # それを仮割付し「乾燥待ちで抄造開始を遅らせる」ことが
  # 無ければ採用
  #  そのラウンドの中で待ちが起きたらそこで打ち切る
  # 有ったら、違う乾燥ラインのグループから優先度の早い方を選ぶ
  def optimize #_jun_skip_if_drier_waiting
    logger.info("=========================================================
INFO:#{Time.now.strftime '%Y/%m/%d-%H:%M'}:OPTIMIZE start")
    @log = nil
    plan_shzdry = {}

    # 優先度の早いgroupを選ぶ
    #   ライン毎にラウンドを分けてある。その先頭ラウンドの先頭ロットの順を比べ
    #   優先順の高いラウンドを選ぶ
    shzdry0,wait,key = next_shozo_dry(grouped_plan_shzdry,grouped_plan_shzdry.keys)
    if shzdry0
      logger.info("=== INFO:   OPTIMIZE LINE：ライン選択 #{shzdry0.join(':')} "+
                  "Lot #{grouped_plan_shzdry[shzdry0][0].map{|plan| plan.lot_no}.join(' ')}"+
                  "\n========================================================="
                  )
      return  grouped_plan_shzdry[shzdry0].shift
    end

    # 失敗の時は、違う乾燥の2ラウンドを選び
    # 仮割り付けし、抄造の割付の結果をみる。
    #ShzDrys[shzdry[1]]
    logger.debug("key #{key.join(' ')}")
    shzdrys = ShzDrys[key[1]]
    shzdry,wait = next_shozo_dry(grouped_plan_shzdry,shzdrys)
    if shzdry
      logger.info("=== INFO:   OPTIMIZE LINE：ライン選択 #{shzdry.join(':')} "+
                  "Lot #{grouped_plan_shzdry[shzdry][0].map{|plan| plan.lot_no}.join(' ')}"+
                  "\n========================================================="
                  )
      return  grouped_plan_shzdry[shzdry].shift
    end

    # それもダメなら残りの一つを試す
    shzdrys.delete(shzdry)
    shzdry,wait = next_shozo_dry(grouped_plan_shzdry,shzdrys)
    if shzdry
      logger.info("=== INFO:   OPTIMIZE LINE：ライン選択 #{shzdry0.join(':')} "+
                  "Lot #{grouped_plan_shzdry[shzdry][0].map{|plan| plan.lot_no}.join(' ')}"+
                  "\n========================================================="
                  )
      return  grouped_plan_shzdry[shzdry].shift
    else
      logger.info("=== INFO:   OPTIMIZE LINE：ライン選択失敗 \n" + "="*30)
      return nil
    end
  end


  #東西原新ラウンドの先頭のどちらを割り付けるか決める
  # 『乾燥機空き優先』乾燥機が先に空き、抄造が早く終わる ものを選ぶ
  #1. ラウンドを抄造と乾燥の4つの組み合わせに分ける。
  #2. 原新どちらの乾燥機の方が先に空いているか見る。
  #3. 早く空く乾燥機を使うラウンド群二つのうち、先頭ロットを仮割付し
  #   抄造が早く終わる方をえらぶ。
  #
  #    空くのが同じなら、優先順で選ぶ
  #戻り値
  #  選ばれたラウンドの plan の配列
  #  工程の空き時間がなく、割り当て不能の場合は nil
  #副作用
  # ラウンド群の配列がshiftされる。 
  def optimize_shzdry_dryspace
    logger.info("=========================================================
INFO:#{Time.now.strftime '%Y/%m/%d-%H:%M'}:OPTIMIZE start")
    @log = nil
    plan_shzdry = {}

    # 早く空く乾燥機の方を選ぶ.同じだったら順を比べる.
    #  のだが、簡単な方法がみつから無いから、とりあえずサボる
    dryer = pre_condition[:dryo].plan_dry_to < pre_condition[:dryn].plan_dry_to ? :dryo :  :dryn   

    # この乾燥機のはもう終わってるかもしれないので、確認。
    if ShzDryByDry[dryer].map{|shzdry| 
        grouped_plan_shzdry[shzdry][0]}.compact.size == 0
      dryer =  dryer == :dryo ? :dryn : :dryo
    end

    logger.info("INFO:   OPTIMIZE DRYER：乾燥機選択 #{dryer} "+
                "dryo終了 #{pre_condition[:dryo].plan_dry_to.mdHM}"+
                "dryn終了 #{pre_condition[:dryn].plan_dry_to.mdHM}"
                )

    # 抄造が早く終わる方を選ぶgrouped_plan[shzdry]
    ShzDryByDry[dryer].each{|shzdry| 
      plan_shzdry[shzdry] = 
      if  grouped_plan_shzdry[shzdry] && grouped_plan_shzdry[shzdry][0]
        plan        = grouped_plan_shzdry[shzdry][0][0] # 最初のraundの最初のplan
        unless (msg=plan.ube_product_error?)==""
          errors.add(:nil,msg)
          logger.info("ERROR: #{Time.now.strftime('%Y/%m/%d-%H:%M')}:#{msg}")
          [nil,time_to+1.month,100000]
        else
          logger.debug("optimize: plan #{plan.lot_no} 養生庫 #{plan.yojoko}")
          yojoKo      = get_yojoko(plan) 
          plan.yojoKo = yojoKo if yojoKo
          shozo,yojo,dry = temp_assign_all_plan(plan,yojoKo)
          logger.info("INFO:   OPTIMIZE 抄造時間予測 #{plan.lot_no} 開始　#{shozo ? shozo[1][0].mdHM : '割当不可'}")
          shz_to = shozo[1][1] rescue time_to   # shozo[0]は保守。[1][1] は抄造終了
          [plan.lot_no,shz_to,plan.jun]
        end
      else
        [nil,time_to+1.month,100000]
      end
    }

    #### 抄造あり同士では一番早い方、同じなら順。
    ####  plan_shzdr = {[:shozow,:dryo] => [lot_no,plan_shozo_to,jun] } 
    shzdry,plan_sd =  plan_shzdry.sort{|a,b| 
      (a[1][1] <=> b[1][1])*4 + (a[1][2] <=> b[1][2])*2 }[0]
    #
    # 抄造あり同士では順。
    #shzdry,plan_sd =  plan_shzdry.sort_by{|a| a[1][2]}[0] # a = [ [:shozow,:dryo],[lot_no,plan_shozo_to,jun] ]

    plans = grouped_plan_shzdry[shzdry].shift
    return nil if !plan_shzdry[shzdry][0] # || !plans || plans.size==0
    logger.info("INFO OPTIMIZE: 順序決定    #{shzdry}\n\t"+
                     ShzDryByDry[dryer].map{|sd| 
                       "#{sd}:#{plan_shzdry[sd][0]} #{plan_shzdry[sd][1].mdHM} "
                     }.compact.join("\n\t")
                     )
    
    logger.debug("##### grouped_plan size #{grouped_plan_shz.inject(0){|s,gp| s += gp.size}}")
    plans    
  end

  # 東西のうち抄造終了が最初のものを選ぶ
  def optimize_shozo_shzend
        @log = nil
        plan_shzdry = {}
        Shozo.each{|shzdry| 
          plan_shzdry[shzdry] = 
          if  grouped_plan_shz[shzdry] && grouped_plan_shz[shzdry][0]
            plan        = grouped_plan_shz[shzdry][0][0] 
            yojoKo      = get_yojoko(plan) 
            plan.yojoko = yojoKo.no if yojoKo
            shozo,yojo,dry = temp_assign_all_plan(plan,yojoKo)
            shz_to = shozo[1][1] rescue time_to
            [plan.lot_no,shz_to,plan.jun]
          else
            [nil,time_to+1.month,100000]
          end
        }
        
    # 抄造あり同士では一番早い方、同じなら順。
        shzdry,plan_sd =  plan_shzdry.sort{|a,b| 
          (a[1][1] <=> b[1][1])*4 + (a[1][2] <=> b[1][2])*2 }[0]

        plans = grouped_plan_shz[shzdry].shift
        return nil if !plan_shzdry[shzdry][0] # || !plans || plans.size==0
        logger.debug("==== PRE ===== 順序決定    #{shzdry}\n\t"+
                     Shozo.map{|sd| 
                       "#{sd}:#{plan_shzdry[sd][0]} #{plan_shzdry[sd][1].mdHM} "
                     }.join("\n\t")
                     )

        #grouped_plan.delete(shzdry) if  grouped_plan[shzdry].size == 0
        logger.debug("##### grouped_plan size #{grouped_plan_shz.inject(0){|s,gp| s += gp.size}}")
        #cmp_plan = grouped_plan[CompShzDry[shzdry]][0] rescue nil
        #if cmp_plan && plans[0].jun > cmp_plan[0].jun
        #  msg = "乾燥待ちで抄造が遅れるので順を変えました。["+
        #	    cmp_plan.map(&:lot_no).join(' ') +"の前に["+
        #	    plans.map(&:lot_no).join(' ')    +"]を製造。"
        #  logger.debug("### #{msg}")
        #  errors.add(:nil,msg)
        #end
    plans    
  end

  # 東西のうち抄造開始が最初のものを選ぶ
  def optimize_shozo_shz
        @log = nil
        plan_shzdry = {}
        Shozo.each{|shzdry| 
          plan_shzdry[shzdry] = 
          if  grouped_plan_shz[shzdry] && grouped_plan_shz[shzdry][0]
            plan        = grouped_plan_shz[shzdry][0][0] 
            yojoKo      = get_yojoko(plan) 
            plan.yojoko = yojoKo.no if yojoKo
            shozo,yojo,dry = temp_assign_all_plan(plan,yojoKo)
            shz_from = shozo[1][0] rescue time_to
            [plan.lot_no,shz_from,plan.jun]
          else
            [nil,time_to+1.month,100000]
          end
        }
        
        # 抄造あり同士では一番早い方、同じなら順。
        shzdry,plan_sd =  plan_shzdry.sort{|a,b| 
          (a[1][1] <=> b[1][1])*4 + (a[1][2] <=> b[1][2])*2 }[0]

        plans = grouped_plan_shz[shzdry].shift
        return nil if !plan_shzdry[shzdry][0] # || !plans || plans.size==0
        logger.debug("==== PRE ===== 順序決定    #{shzdry}\n\t"+
                     Shozo.map{|sd| 
                       "#{sd}:#{plan_shzdry[sd][0]} #{plan_shzdry[sd][1].mdHM} "
                     }.join("\n\t")
                     )

        #grouped_plan.delete(shzdry) if  grouped_plan[shzdry].size == 0
        logger.debug("##### grouped_plan size #{grouped_plan_shz.inject(0){|s,gp| s += gp.size}}")
        #cmp_plan = grouped_plan[CompShzDry[shzdry]][0] rescue nil
        #if cmp_plan && plans[0].jun > cmp_plan[0].jun
        #  msg = "乾燥待ちで抄造が遅れるので順を変えました。["+
        #	    cmp_plan.map(&:lot_no).join(' ') +"の前に["+
        #	    plans.map(&:lot_no).join(' ')    +"]を製造。"
        #  logger.debug("### #{msg}")
        #  errors.add(:nil,msg)
        #end
    plans    
  end

  # ShozoDry_DryFirst :: 
  # 東西原新のうち乾燥終了が最初のものを選ぶ
  def optimize_shzdry#(grouped_plan)
        @log = nil
        plan_shzdry = {}
        ShzDry.each{|shzdry| 
          plan_shzdry[shzdry] = 
          if  grouped_plan[shzdry] && grouped_plan[shzdry][0]
            plan        = grouped_plan[shzdry][0][0] 
            yojoKo      = get_yojoko(plan) 
            plan.yojoko = yojoKo.no if yojoKo
            shozo,yojo,dry = temp_assign_all_plan(plan,yojoKo)
            dry_from = dry[1][0]   rescue time_to
            shz_from = shozo[1][0] rescue time_to
            [plan.lot_no,dry_from,plan.jun,shz_from]
          else
            [nil,time_to+1.month,100000,time_to+1.month]
          end
        }
        # ShozoDry_DryFirst
        # 乾燥あり同士では一番早い方、同じなら順。乾燥有り無しでは乾燥のある方、
        # 無し同士では抄造の早いほう,
        shzdry,plan_sd =  plan_shzdry.sort{|a,b| 
          (a[1][1] <=> b[1][1])*4 + (a[1][2] <=> b[1][2])*2 + (a[1][3] <=> b[1][3])
        }[0]

        plans = grouped_plan[shzdry].shift
        return nil if !plan_shzdry[shzdry][0] || !plans || plans.size==0 || plan_sd[3] >= time_to
        logger.debug("==== PRE ===== 順序決定    #{shzdry}\n\t"+
                     ShzDry.map{|sd| 
                       "#{sd}:#{plan_shzdry[sd][0]} #{plan_shzdry[sd][3].mdHM} #{plan_shzdry[sd][1].mdHM} "
                     }.join("\n\t")
                     )

        #grouped_plan.delete(shzdry) if  grouped_plan[shzdry].size == 0
        logger.debug("##### grouped_plan size #{grouped_plan.inject(0){|s,gp| s += gp.size}}")
        cmp_plan = grouped_plan[CompShzDry[shzdry]][0] rescue nil
        if cmp_plan && plans[0].jun > cmp_plan[0].jun
          msg = "乾燥待ちで抄造が遅れるので順を変えました。["+
	    cmp_plan.map(&:lot_no).join(' ') +"の前に["+
	    plans.map(&:lot_no).join(' ')    +"]を製造。"
          logger.debug("### #{msg}")
          errors.add(:nil,msg)
        end
    plans    
  end
end
end

__END__
$Id: ube_optimize.rb,v 2.20 2012-10-22 17:10:02 dezawa Exp $
