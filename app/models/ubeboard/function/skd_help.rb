# -*- coding: utf-8 -*-
require 'pstore'
require 'pp'
require 'nkf'
module Ubeboard::Function
  #UbeSkd.make_plan の下請けたち。
  #
  #保守、製造の割り当てを仮に押さえるmethod群
  #temp_assign_all_plan   :: 1ロット乾燥終了までを仮押さえ。抄造-養生-乾燥の工程間待ち時間の制約を考慮する。
  #temp_assign_maint_plan :: 保守・切替 と 製造を合わせて仮押さえ。
  #temp_assign_maint      :: 保守、切り替えの仮押さえ
  #temp_assign_yojo_maint :: 養生の保守、切り替えの仮押さえ。実態はすぐリターン
  #temp_assign_plan       :: 製造の割付を仮押さえする
  #temp_assign_shozo      :: 抄造の仮押さえ temp_assign_plan の下請け
  #temp_assign_dry        :: 乾燥の仮押さえ temp_assign_plan の下請け
  #temp_assign_plan_yojo  :: 養生の仮押さえ temp_assign_plan の下請け
  #
  #
  #
  # 仮押さえを元に割り当てを行う method : assign_maint_plan_by_temp
  #
  #
  #ロット間インターバルを求めるmethod群
  #maintain      :: 保守による制限(次工程前lot終了時刻 + その時すべき保守作業所要時間)
  #change_time   :: 切り替えによる制限（次工程 前lot終了時刻 + 前後工程品種）
  #transfer_time :: （現lot 前工程終了時刻 + 移動時間) 
  # 
  #3つの開始可能時間を比べもっとも遅い時間を採用する
  #
  #この評価には 次工程前lot の情報が必要。それを pre_condition に残す
  #pre_condition :: 各工程最終製品の UbePlan
module SkdHelp
  # 抄造時間を遅らせる調整をしてまで割り付けるモード
  OptimizeShozo = 0100 # 64

  YojokoMsg = { true => "決定",false => "仮割付",nil =>  "仮割付"}
  def yojoko_log(yojoko,msg)
    logger.debug("=== YOJOKO 養生庫#{YojokoMsg[@log]} === #{yojoko.no} #{yojoko.size} #{msg}")
  end

  #養生庫を決める
  ##選定条件
  #1. 抄造開始時点で空いていること
  #2. 抄造ロットサイズの物がよい
  #   なければラウンドの製造量が満たされる様にする
  #   それもなければ早く空いたもの
  #   それもなければ、抄造を遅くする。
  #       
  #のために 
  #1. 各ロットの 製造数量は規格化されている(x0.75,1.00,1.25))
  #2. mass の他に、x0.75,1.00,1.25 を入れた　n_mass もある
  #3. round の総量を求め、養生庫数(規格化された数量)を求める
  #4. 製造数量は UbeSkd#make_plan7 で規格化されている
  #
  #Round について先に決めておくのはやめる
  #
  #<b>理由</b>
  #
  #酸洗の入るのを予測するのはコストがかかる。
  #ラウンドの量の調整はここでは行わず、make_plan　で行うことにする
  #4 roundの全lotについて
  #  使用可能で(数量+過不足)と容量が一致する養生庫を探す。
  #  複数有ったら next_start が一番早いもの
  #  無かったら、数量が一致するものを探す
  #  それも無かったら、より大きいもので一番早いもの。
  #  それも無かったら、一番早いもの。
  #  養生庫の容量によって、過不足を修正
  #  過不足が残ったら、最終ロットに加えておく
  # 
  #<b>パラメーター</b>
  #   round_plans : ラウンドの plan の配列
  # 
  # 戻り値
  #   養生庫
  def get_yojoko(plan,mod=0.0)
   #logger.debug("get_yojoko: #{plan.lot_no}")
    #   # このラウンドの全製造数と全規格数
 #   sum_mass = plans.inject(0){|sum,pln| sum += pln.mass}
 #   sum_nmass= plans.inject(0){|sum,pln| sum += pln.n_mass}
 #

    shozo_startable_by_pre_shozo = shozo_startable_time_by_pre_shozo(plan)
    shozo_startable_by_dry = shozo_startable_time_by_dry_startable(plan)
    yojo_from = yojo_startable(shozo_startable_by_pre_shozo,shozo_startable_by_dry)
    @msg= "\t抄造開始可能時間=#{yojo_from.mdHM} "+
      "乾燥開始可能-(72+40+24)=#{shozo_startable_by_dry.mdHM} "+
      "前の抄造終わり+保守=#{shozo_startable_by_pre_shozo.mdHM} "
    logger.debug("get_yojoko: #{plan.lot_no} #{@msg} 前回割り当てられた養生庫 #{plan.yojoko || '無'}")

    # もし、前回割り当てられた養生庫があり、n_mass が一致し、かつそれが使用可能なら、それを使う
    if last_assigned_yojoko_enable(plan,yojo_from)
      yojoko_log(plan.yojoKo,"前回割り当てられた養生庫")
      return plan.yojoKo #yojoko[plan.yojoko] 
    end

    # yojo_fromの時点から使用可能な養生庫を得る
    if yjk = aviable_when_yojo_from(plan,yojo_from)
      yojoko_log(yjk, "養生開始に間に合うものを選択。可能なら同じ n_mass")
      return yjk #yojoko[plan.yojoko] 
    end

    # できるだけ早く開く養生庫を探す
    if yjk = first_aviable_yojoko
      yojoko_log(yjk, "できるだけ早く開く養生庫を選択")
      return yjk #yojoko[plan.yojoko] 
    end

    logger.debug("  get_yojoko:養生庫割り当て失敗")
    return nil
  end 

  def first_aviable_yojoko
    aviable_yojoko_list_by_time(skd_to).first
  end

  def aviable_when_yojo_from(plan,yojo_from)
    return nil if(yojokos = yojoko_list_by_time(yojo_from)).size == 0
    select_yojoko_by_n_mass(yojokos,plan.n_mass) || yojokos[0]
  end

  def aviable_yojoko_list_by_time(yojo_from)
    yojoko_list_by_time(yojo_from)
  end

  def aviable_yojoko_list_by_time_old(yojo_from)
    @msg += " ** 前回の養生庫"
    yojokos = yojoko_list_by_time(yojo_from)
    if  yojokos.size > 0
      @msg += "\n\t"+
        yojokos.map{|yojoko| ("    %2d " % yojoko.no) + 
        yojoko.size.to_s + yojoko.next_start.strftime("  %m/%d-%H:%M\n")
      }.join 
    else
      yojokos =  yojoko_list_by_time(skd_to)
      return nil if yojokos.size == 0
      @msg += "  空いている養生庫が無いので。一番早く空くのを探す\n"+
        yojokos.map{|yojoko| ("    %2d " % yojoko.no) + 
        yojoko.size.to_s + yojoko.next_start.strftime("  %m/%d-%H:%M\n")
      }.join
    end
    yojokos
  end

  def select_yojoko_by_n_mass(yojokos,n_mass)
    return nil unless yojokos
    yjks = yojokos.select{|yjk| yjk.size == n_mass }.first
    if yjks
      logger.debug("GET_YOJOKO n_mass一致：n_mass=#{n_mass},yjks=#{yjks}")
      return yjks 
    end
    
    yjks = yojokos.first
    if yjks
      logger.debug("GET_YOJOKO n_mass不一致,最速を選定：n_mass=#{n_mass}->#{yjks.size},yjks=#{yjks}")
      return yjks
    end
    nil
  end

  def shozo_startable_time_by_pre_shozo(plan)
    change = change_time(plan,plan.shozo?) # [所要時間,[[pro_id,保守コード],[],,,[]] ]
    maintain = maintain_time(plan,plan.shozo?)
    pre_condition[plan.shozo?].plan_shozo_to +
      change.longer(maintain).periad
  end
  def shozo_startable_time_by_dry_startable(plan)
    pre_condition[plan.dry?].plan_dry_end+plan.ope_length(plan.dry?)[0]-(72+40+24).hour
  end
  def yojo_startable(shozo_startable_by_pre_shozo,shozo_startable_by_dry)
    [shozo_startable_by_pre_shozo,shozo_startable_by_dry,skd_from].max
  end

  def last_assigned_yojoko_enable(plan,yojo_from)
    plan.yojoKo && #yojoko[plan.yojoko] && 
      plan.n_mass == plan.yojoKo.size && #yojoko[plan.yojoko].size &&
      plan.yojoKo.next_start <= yojo_from
  end

 # debug 用出力
  #  Round list
  # 　lotno n_mass
  #   lotno n_mass
  #  Yojo list by get_yjokos
  #   No size next_start
  #   No size next_start
  #   No size next_start
  #   No size next_start
  # 
  # Result
  #  lot_no n_mass YojoNo next_start
  # 
  def get_yojo_pre(round_plans,yojokos,from)
    "Round list\n" +
      round_plans.map{|plan| "   #{plan.lot_no}  #{plan.n_mass}\n"}.join + 
      "Yojo list by get_yojokos  #{from}\n"+
      yojokos.map{|yojoko| ("    %2d " % yojoko.no) + 
      yojoko.size.to_s + yojoko.next_start.strftime("  %m/%d-%H:%M\n")
    }.join
  end

  def get_yojo_post(plans,yojokos)
    "Post get_yojoko\n"+ 
      plans.zip(yojokos).map{|plan,yojoko|
      "#{plan.lot_no}  #{plan.n_mass}" + ("  %3d " % yojoko.no) + 
      plan.plan_shozo_from.strftime("%m/%d-%H:%M   ")+
      yojoko.next_start.strftime("%m/%d-%H:%M\n")
    }.join
  end

  #製造番号の最大値。を返す
  # 1M0001、1W0001 からの追い番。1は年号１位。MWは東西
  #- 新規ロットの製造番号をつけるために、現存の最大の製造番号を得る。
  #- 既存の番号が無い場合は、0000 をつけ、0001 から始まるようにする。
  #- 既存 とは取り込まれた前月度の完了、仕掛かりロット
  #
  #年度初めの時は少し厄介かも
  #- 既存が有っても１月は 0000 にリセットする。
  #- 1月度の実績が入ってからはリセットされると番号が重複する
  #- 1月度立案の時、12月30日とか前年に食い込んで立案するかもしれない
  def max_lot
    unless @max_lot
      # まず前月度から作る
      @max_lot=Hash.new{|h,k| h[k]=""}
      [[:shozow,"W"],[:shozoe,"M"]].each{|real_ope,lbl|
        @max_lot[real_ope] = ube_plans.map(&:lot_no).select{|l| l =~ /\d#{lbl}\d\d\d\d/}.sort[-1]
        @max_lot[real_ope] = (skd_from.year % 10).to_s+"#{lbl}0000"  unless @max_lot[real_ope] 
      }
      # 1月度か否かみる。12月に食い込んでる可能性が有るので、期間の中央日で判断する
      if (skd_from + (skd_to - skd_from)/2).month == 1
        # 新年度で作って @maxlot と比べる。大きければ置き直す。小さければもう実績。何もしない
        year = (skd_from + (skd_to - skd_from)/2).year % 10
        [[:shozow,"W"],[:shozoe,"M"]].each{|real_ope,lbl|
          lot = "#{year}#{lbl}0000"
          logger.debug("max_lot @max_lot[real_ope]=#{@max_lot[real_ope]} lot = #{lot} #{lot > @max_lot[real_ope]}")
          @max_lot[real_ope] = lot if lot > @max_lot[real_ope]
        }
      end
    end
    @max_lot
  end

  #pre_condition 設定
  # 実績のあるロットについて、pre_condition を設定する。
  #<tt>real_ope</tt> :: この工程まで実績が入っている。ここまで設定する。
  def set_pre_condition_for_done(plan,real_ope)
    shozo=plan.shozo?
    dry=plan.dry?
    opes = UbeSkd::Ope.dup; opes[0]=shozo ;opes[2]=dry
    opes = case real_ope
           when :shozo,:shozow,:shozoe ; opes[0..0]
           when :yojo           ; opes[0..1]
           when :dry,:dryo,:dryn ; opes[0..2]
           when :kakou          ; opes[0..3]
           end
    opes.each{|ope| 
      return unless times = UbeSkd::PlanTimes[ope][3]
      #periad,maintain = maintain_time(plan,ope)
      #pre_condition[ope]=[periad,maintain,plan]
      pre_condition[ope] = plan
    }
  end

  #保守・切り替えの UbeProduct#id から A?? 番号を返す
  def pro_id_2_lot_no(pro_id)
    @proid2lotno ||= Hash.new
    @proid2lotno[pro_id] ||= (Product.find(pro_id).ope_condition rescue nil)
  end


  # 
  def assign_yojo(plan)
    from = plan.transfer_time(self,:yojo)
    to   = from + 40.hour
    plan.set_plan(:yojo,[from,to])
  end
  

  ##########################################################


  #保守要否評価        maintain_time(plan,real_ope)　 → 所要時間、Pro_id
  #  plan,real_ope ← 今割り付けが終わったもの
  #  戻り値は ［ 保守所用時間, ［保全情報, 保全情報,保全情報,,,,]]
  #  保全情報は ［UbeProduct.id, 製造番号]
  #
  #各工程で以下の保守作業を自動的に割り付ける。
  #* どういう名称にするか、は UbeProduct に登録する
  #* 所要時間は UbeOperation で定義する。ここにあるのは打ち合わせでの情報
  #* その割付要否を判断し、 必要なら上記を、不要なら空配列 [ ] を返す
  #    
  #抄造                                 
  #1. 始業終業作業　　　　　（休日前明け）　　　　　　　３ｈ ← Function::UbeSkdFreelist#freeList で処理
  #2. 酸洗い　　　　　　　　毎日（午前）　　　　　　　　２ｈ ← do_sanasen? で処理 
  #3. ウェットフェルト替え　18万～20万枚生産後　　　　２４ｈ  
  #4. プレスフェルト替え　　稼働時間1000時間　　　　　２４ｈ  
  #5. サラン替え　　　　　　12・15高級品後、定期清掃　８ｈ    
  #6. 乾燥　刃物替え　　　　2週間に1回。140,000枚     ４ｈ     
  #7. 　　　後養生　　　　　　　　　　　　　　　　　24時間 ← transfer にて処理
  #8. 加工　予防保全　　　　水曜午前                  ４ｈ     
  #      
  #下記「酸洗で問題発生」の結果、
  #一旦仮割付したのち、酸洗の要否を再度確認する、ということにした。
  #このために、酸洗要否判断用にmethod do_sansen? を分離した。
  #
  #
  #<b>重要な変更</b>
  #
  #この評価のタイミングを、前ロット終了時から次ロット開始時に変更する
  #
  #理由：「次のロットを終えると1000時間越えるなら、交換する」に対応するため
  #1. このため、引数 plan は前ロット から 次(現)ロットとなる。← これ要らないな
  #2. 前ロット情報は pre_condition[2]。pre_condition[0..1]は意味なくなるので、配列止めよう
  #<b>重要な変更</b>
  #
  #失敗、、、、
  #- WF、PF、刃物替えは実際にasaignされたときに累積時間|枚数をリセットする方がよい。
  #- なぜならこのmethodが呼ばれるのは、候補探しであって絶対行われるとは限らないから。
  # 
  #<b>酸洗で問題発生</b>
  #
  #酸洗が入らないことがある。
  #1. 月度初めやしばらく抄造があいてしまったときなど。
  #   酸洗をいれる条件が、「8時以降でまだ酸洗してなくて休日明けではない」
  #   この、8時以降 に引っかかってしまうことがある。（前ロットが0～8に終わるとき
  #   この条件を取ると0～8時に酸洗が入ってしまう。
  # 
  #2. 確実なのは、抄造を割り当てたときに8時以降だったら　なのだが
  #   これだと「後で決めたい抄造割り当て」を先に行うことになり、ややこしくなる
  #  「割当て可能時間が8時以降」でいけるか？
  #   割当て可能時間は、「ポインタ」　今は「先のロットの終わり」、
  #   立案期間の初めも初期値としてはあり、これだと 「長い抄造開き」の後に対応できない
  #   .
  #   割り当てて見るしかなさそう
  #   　maintainでは評価しない。
  #   　保守製造を仮確保し、洗うか評価。
  #   　保守が2時間以上なら良し、以下の時は延ばせば良い？
  #   
  #   
  def maintain_time(plan,real_ope)
    case real_ope
    when :yojo,:dryo,:dryn ; Ubeboard::Maintain.null #[0,[nil]] 
    when :shozow,:shozoe   ; maintain_time_shozo(plan,real_ope)
    when :kakou            ; maintain_time_kakou(plan,real_ope)
    else                   ; raise "real_ope間違い"
    end
  end

    # 酸洗：毎日午前、予防保全：水曜午前
    # WF：18万枚～20万枚、PF：1000時間 #####、刃物：14万枚
    #   ただし、酸洗は上に述べた問題解決のためにここでは割り当てない
  def maintain_time_shozo(plan,real_ope)
    # ===稼働時間での保守
    # 抄造1000時間でも PF替え、抄造 18～20万枚でのWF替え
    # 18～20万枚というのが難しい、、、、18万枚で設定している。
    pf_change(plan,real_ope) + wf_change(plan,real_ope)
  end
  
  def wf_change(plan,real_ope)
    if plan.proname =~ /^S1/ &&
        running["running_wf_#{real_ope}"]+plan.mass >= UbeSkd::RunShozoS3Cnt
      Ubeboard::Maintain.hozen_data("WF替",real_ope)
    elsif running["running_wf_#{real_ope}"]+plan.mass >= runshozocount(real_ope)
      Ubeboard::Maintain.hozen_data("WF替",real_ope)
    else
      Ubeboard::Maintain.null#[nil] #[0,[nil]]
    end
  end

  def pf_change(plan,real_ope)
    if running["running_pf_#{real_ope}"]+plan.ope_length(real_ope)[0]  >= self["limit_pf_"+real_ope.to_s].hour
      Ubeboard::Maintain.hozen_data("PF替",real_ope)
    else
      Ubeboard::Maintain.null # [nil] #[0,[nil]]
    end
  end

  
  # 予防保全：水曜午前
  def maintain_time_kakou(plan,real_ope)
    ope_to = pre_condition[real_ope].plan_kakou_to rescue time_from
    if ope_to.hour >=8 && ope_to.wday==3  && # 午前中で水曜
        hozen_date[:kakou] != ope_to.day #&&  # まだ予防保全してない
      Ubeboard::Maintain.hozen_data("予防保全",real_ope)
    else
      Ubeboard::Maintain.null #[0,[nil]]
    end
  end
  #酸洗要否を判断する。
  #- その日はまだ酸洗していない
  #    ! holyday?(plan.shozo?,ope_to.yesterday)
  #- かつ
  #  休日開けではない.休日:0800～翌日0800
  def do_sansen?(shozo_assign,real_ope)
    plan_from = shozo_assign[0]
    date = plan_from.ube_date #(plan_from-8.hour).day  # 抄造開始時刻の稼働日(8:00～)計算
    logger.debug("TAAP do_sansen? hozen_date #{ hozen_date[real_ope]} 抄造日#{date}")
    hozen_date[real_ope] != date && 
      ! holyday?(real_ope,(shozo_assign[0]-8.hour).beginning_of_day)
  end

  #稼働累積で実施する保守(WF替,PF替,刃物替 A08,A11,A13)を行ったとき
  #累積をリセットする
  #
  #あら、、、reset_running　とダブってる？
  def reset_runtime(real_ope,pro_id,lot_no)
    pre_plan = pre_condition[real_ope]
    case lot_no
    when "A08"
      #WF替
      runtime = "running_wf_#{real_ope}"
      info = "Maintain-WF替:#{pre_plan.lot_no}の後 #{real_ope} #{running[runtime]}枚"
      if running[runtime] < Skd::RunShozoS3Cnt
        info += " #{UbeSkd::Id2RealName[real_ope]} #{pre_plan.lot_no}の後 : #{runshozocount(real_ope)}枚にならないが、S1抄造のため実施する" 
        @message << "WF替: #{UbeSkd::Id2RealName[real_ope]} #{pre_plan.lot_no}の後 : #{runshozocount(real_ope)}枚にならないが、S1抄造のため実施する" 
      end
      logger.info("Maintain-WF替:#{pre_plan.lot_no}の後 #{real_ope} #{running[runtime]}枚")
      running[runtime] = 0
    when "A11"
      #PF替
      runtime = "running_pf_#{real_ope}"
      logger.info("Maintain-PF替:#{pre_plan.lot_no}の後 #{real_ope} #{running[runtime]}時間")
      running[runtime] = 0
    when "A13"
      #刃物替
      runtime = "running_#{real_ope}"
      logger.info("Maintain-刃物替:#{pre_plan.lot_no}の後 #{real_ope} #{running[runtime]}枚")
      running[runtime] = 0
    end
  end


  # WF,PF,刃物替えのとき累積をリセットする。 
  # 実施済みの処理の時呼ばれる
  #
  # あら、、、reset_runtime　とダブってる？
  def reset_running(lot_no,real_ope,from,stop)
    return unless from && stop && from > time_from
    case real_ope
    when :shozow,:shozoe
      running["running_pf_"+real_ope.to_s] = 0 if lot_no == "A11"
      running["running_wf_"+real_ope.to_s] = 0 if lot_no == "A08"
    when :dryo,:dryn
      running["running_"+real_ope.to_s]    = 0 if lot_no == "A13"
    end
  end

  #切り替え時間の長さと記名切替の UbeProduct.id の配列を返す。
  #  記名でないときは ["切替"] を返す。これはログのため。
  def change_time(plan,real_ope)
      plan.change_time_concider_meigara(real_ope,pre_condition[real_ope],self)
  end
  

  #UbePlan#set_planを呼び出して予定を入れ
  #稼働累計を更新する
  def plan_set(plan,real_ope,plans)
    plan.set_plan real_ope,plans
    sum_running(plan,real_ope,plans[0],plans[1]) if plans[0] > time_from
  end


  #仕掛かり品を最後まで割り付ける。
  #1. 乾燥が終わっているものは、加工をそのままわりつければOK
  #*     assign_maint_and_plan で割付
  #2. 養生が終わっているものは、乾燥、加工をそのままわりつけ、その後養生庫の next_start を設定する
  #*  temp_assign_dry → assign_maint_plan_by_temp と assign_maint_and_plan
  #3. 型板 だったら、
  #   抄造が終わっているものは、養生から入る。どの養生庫を使うか？
  #   　抄造を割り付けるときに養生庫も決まっている
  #   　　　そうでないと数量が決まらないから。
  # 　　システム利用開始時は、手動で決めておくことにする。　
  # 　　つまり仕掛品の養生庫は立案開始時にクリアしないこと
  #*                     ← assign_if_resulted ではそうなってる
  #   
  def procceed_stock
    # 加工待ちは加工を行う
    sorted_plan[1].select{|plan| !plan.hozen? && plan.next_ope == :kakou
    }.sort_by{|plan| plan.plan_dry_to}.each{|plan|  
      assign_kakou(plan,plan.result_dry_to || plan.plan_dry_to )
    }
      
    #乾燥待ちは乾燥から先を行う。　型板は乾燥待ちにならないからここにこないので処理不要
    sorted_plan[1].select{|plan| plan.next_ope == :dry && !plan.hozen? 
    }.sort_by{|plan| plan.plan_yojo_to
    }.each{|plan|
      assign_dry_kakou(plan)
    }

    #抄造が終わっているものは、養生以下を仮割り付けして処理する。
    sorted_plan[1].each{|plan| next unless plan.current == :shozo && !plan.hozen?
      assign_yojo_dry_kakou(plan)
    }
  end
  
  # 
  def assign_kakou(plan,current_to=nil)
    kakou = temp_assign_kakou(plan,current_to)
    assign_maint_plan_by_temp(plan,:kakou,kakou) if kakou
  end

  def assign_dry_kakou(plan)
      dry = temp_assign_dry(plan,plan.plan_yojo_to)
      return nil unless dry
      assign_maint_plan_by_temp(plan,plan.dry?,dry)
      # 乾燥が設定できたので養生庫の next_start を設定する
      yojoko[plan.yojoko].assign(plan) if yojoko[plan.yojoko]

      logger.info("procceed_stock[yojo] plan == #{plan.id} #{plan.lot_no} #{plan.meigara} #{plan.current} ")
      assign_kakou(plan) if ! plan.done? && dry
  end

  def assign_yojo_dry_kakou(plan)
      set_pre_condition_for_done(plan,:shozo)
      yojoKo = plan.yojoKo
      logger.info("procceed_stock[shozo] plan == #{plan.id} #{plan.lot_no} #{plan.meigara} #{plan.current}")
      assign_temp_and_real(plan,[[],[plan.plan_shozo_from,plan.plan_shozo_to]])
  end
  # 仮押さえした時間をもらい、その時刻で割付を行う。
  def assign_maint_plan_by_temp(plan,real_ope,temp)
    return unless temp
    maint_times,plan_times = temp
    #                     start           end           array_hozen_code
    logger.debug("assign_maint_plan_by_temp PRO_IDS #{maint_times[2]}") if maint_times
    assign_maint(real_ope,maint_times[0],maint_times[1],maint_times[2]) if real_ope != :yojo

    # 製造を割り付ける
    freeList[real_ope].assignFreeList(plan_times[0],plan_times[1])
    plan_set(plan,real_ope,plan_times)
    #plan.set_plan(real_ope,plan_times)
    #sum_running(plan,real_ope,plan_times[0],plan_times[1])

    # 保守要否評価  maintain_time　 → 所要時間、Pro_id これは次ロット開始時に移る
    #periad,hozencode = maintain_time(plan,real_ope)
    # hozencode は [[ "A10",real_ope],,,,] 
    #pre_condition[real_ope] = [periad,hozencode,plan] 
    pre_condition[real_ope] = plan
  end   

  #時間の仮押さえ：乾燥までの仮時間を確保する。養生庫は指定されている
  #-  抄造開始可能時間 shozo_fromの初期値として、前ロットの抄造終了時刻を用いる
  #-  temp_assign_maint で処理する
  ###  抄造→養生→乾燥 の間隔が適切ではない場合に、補正してやり直す。
  ###    補正は、養生の時間を調整する。
  ###    抄造を調整する必要が有ったら 失敗で帰る。
  ###    ただし、その調整をしてまで割り付けるモードを用意する。　@jun_only & OptimaizeShozo
  ###     抄造→養生 < 72hr、養生→乾燥 < 24hr
  ###    補正した結果酸洗を行うべきかどうかが変わる可能性がある。このため酸洗要否を再確認する
  ### オプションパラメーター shozoDone は、抄造の割り付けが済んでいる場合に true にする
  ###   procceed から呼ばれたとき
  def temp_assign_all_plan(plan,shozoDone=nil)
    wait = nil
    shozo_maint,shozo_plan =  shozoDone || temp_assign_shozo(plan)
    #logger.debug("temp_assign_all_plan PRO_IDS #{shozo_maint[2]}") if shozo_maint
    # 抄造がとれないときは、帰る
    return nil unless shozo_plan

    #  ├ 抄造の時間を仮に確保　←[1]
    #  ├ 養生の時間を仮に確保
    # 指定された養生に保守は無いので、直接製造を仮割り当てする
    yojo_plan = temp_assign_plan_yojo(plan,shozo_plan[1])

    # 養生が確保できないときは、抄造だけで返す
    return [ [shozo_maint,shozo_plan] ] unless yojo_plan

    # 型板のときは乾燥無し
    return  [ [shozo_maint,shozo_plan],[nil,yojo_plan]]  if plan.condition == "型板"

    #  ├ 乾燥の時間を仮に確保
    dry_maint,dry_plan = temp_assign_dry(plan,yojo_plan[1])
    # 乾燥が確保でき
    return [ [shozo_maint,shozo_plan],[nil,yojo_plan]] unless dry_maint
    logmsg="INFO TEMP ASSIGN 乾燥仮押え #{plan.lot_no}　#{dry_plan[0].mdHM}-#{dry_plan[1].mdHM}"
    ###### 抄造→養生→乾燥 の間隔評価
    # 抄造→養生 < 72hr + 40 + 24
    if dry_plan[0] - yojo_plan[1] > 24.hour   # 養生終了から乾燥開始までが広すぎたら養生を遅らせる
      y_old=yojo_plan.dup
      yojo_plan = temp_assign_plan_yojo(plan,dry_plan[0]-64.hour)
      logmsg +="\n   後置き長いので 養生遅らせる  \n"+
        " 　　　 養生                 乾燥                    後置き\n"+
        "    旧 #{y_old[0].mdHM}-#{y_old[1].mdHM}  #{dry_plan[0].mdHM}-#{dry_plan[1].mdHM} #{(dry_plan[0] - y_old[1]).hm}\n"+
        "    新 #{yojo_plan[0].mdHM}-#{yojo_plan[1].mdHM}  #{dry_plan[0].mdHM}-#{dry_plan[1].mdHM} #{(dry_plan[0] - yojo_plan[1]).hm}\n"

    end
    # 抄造終了から養生開始までが広すぎたら(抄造の割り付けが既に済んでいるのでなければ）
    ###    抄造を調整する必要が有ったら 失敗で帰る。
    ###        ただし、その調整をしてまで割り付けるモードをそのうち用意する。　@jun_only & OptimaizeShozo
    if !shozoDone && yojo_plan[0] - shozo_plan[1] > 72.hour #&& (@jun_only & OptimaizeShozo)
      #wait = true
      #抄造開始を遅らせる。抄造の保守との間が開くが、我慢。
      logmsg += "   前置きが長くなりすぎるので抄造遅らせる  #{plan.lot_no} 抄造開始-養生終了 #{shozo_plan[0].mdHM}"+
                   "- #{yojo_plan[1].mdHM}=#{(yojo_plan[0] - shozo_plan[1])/1.hour}"
      s_old=shozo_plan.dup
      shozo_plan= temp_assign_plan(plan,plan.shozo?,yojo_plan[0]-72.hour,shozo_maint[1])

      logmsg +="\n   前置きが長いので 抄造遅らせる  "+
        " 　　　 抄造　　　　　　　　乾燥                    前置き\n"+
        "    旧 #{s_old[0].mdHM}-#{s_old[1].mdHM}  #{yojo_plan[0].mdHM}-#{yojo_plan[1].mdHM} #{(yojo_plan[0] - s_old[1]).to_i.hm}\n"+
        "    新  #{shozo_plan[0].mdHM}-#{shozo_plan[1].mdHM}  #{yojo_plan[0].mdHM}-#{yojo_plan[1].mdHM} #{(yojo_plan[0] - shozo_plan[1]).to_i.hm}\n"
      wait = (shozo_plan[0]-s_old[0])/1.minute
      logmsg += "\n→取り直し時刻#{shozo_plan[0].mdHM}～#{shozo_plan[1]}。遅れ #{wait}分"

      #酸洗確認しなおす
      sansen_hozen_data = Ubeboard::Maintain.hozen_data("酸洗",plan.shozo?)
      date = (shozo_plan[0]-8.hour).day
       if do_sansen?(shozo_plan, plan.shozo?)  # 酸洗する場合
        # 保全・切り替えが酸洗時間以上
        if  (shozo_maint[1]-shozo_maint[0]) < sansen_hozen_data.periad
          #抄造開始の酸洗時間前からの割り当てにする
          start,stop = freeList[plan.shozo?].
            searchfree( shozo_plan[0]-sansen_hozen_data.periad ,sansen_hozen_data.periad,true)
          sansen = [start,stop,sansen_hozen_data.hozen_code_list]
          #sansen = [shozo_plan[0]-hd[0] ,shozo_plan[0],hd[1]]
          logmsg += "\n   酸洗を入れる必要が出たので、抄造さらに取り直す #{shozo_plan[0].mdHM}～#{shozo_plan[1]}"
        end
        #hozen_date[real_ope]=shozo_plan[0].day
      end 
    end
    
    logger.info logmsg

    shozo_maint = sansen if sansen

    [ [shozo_maint,shozo_plan],[nil,yojo_plan],[dry_maint,dry_plan],wait]
  end


  #抄造の仮押さえを行う
  #* temp_assign_maint_plan にて保守、製造の仮押さえを行い
  #* 酸洗要否を調べ、
  #* 必要なら製造をとりなおす。
  def temp_assign_shozo(plan)
    yojoKo = plan.yojoKo#yojoko[plan.yojoko]
    logger.debug("TEMP_ASSIGN_SHOZO:#{plan.lot_no} yojoko =#{yojoKo}")
    return nil unless yojoKo
    real_ope = plan.shozo?
    
    shozo_maint = temp_assign_maint(plan,real_ope)
    logger.debug("TEMP_ASSIGN_SHOZO:#{plan.lot_no} shozo_maint=#{shozo_maint}")
    return nil unless shozo_maint
    shozo_plan = temp_assign_plan(plan,real_ope,nil,shozo_maint[1])
    logger.debug("TEMP_ASSIGN_SHOZO:#{plan.lot_no} shozo_plan =#{shozo_plan}")
    return nil unless shozo_plan

    #logger.debug("TEMP ASSIGN 抄造仮押え trans=#{trans.mdHM} shozo_maint[1]=#{shozo_maint[1].mdHM}")
    logmsg = "INFO      TEMP ASSIGN 抄造仮押え  #{plan.lot_no} #{shozo_plan[0].mdHM}-#{shozo_plan[1].mdHM}"
    logger.debug logmsg

    # 酸洗すべきか判断する
    date = shozo_plan[0].ube_date #(shozo_plan[0]-8.hour).day
    
    sansen = nil
    sansen_hozen_data = Ubeboard::Maintain.hozen_data("酸洗",real_ope)
    logger.debug("TAAP 酸洗する? #{plan.lot_no} #{do_sansen?(shozo_plan,real_ope)}")
    if do_sansen?(shozo_plan,real_ope)  # 酸洗する場合
      logger.debug("TAAP 酸洗する #{plan.lot_no} ")
      # 保全・切り替えが酸洗時間以上
      #if (shozo_maint[1]-shozo_maint[0]) >= hd[0]
      #  保管の保全と重なるときは、明記なし
      #else　# 以下だったら取り直し
      unless  (shozo_maint[1]-shozo_maint[0]) >= sansen_hozen_data.periad
        #抄造の保守だが、酸洗は休日にはしない
        start,stop = freeList[real_ope].searchfree(pre_condition[real_ope].plan_shozo_to,sansen_hozen_data.periad,true)
        logger.debug("TAAP 酸洗する #{plan.lot_no} 取得酸洗時刻 #{start.mdHM}-#{stop.mdHM}")
        shozo_maint=sansen = [start,stop,sansen_hozen_data.hozen_code_list]
        shozo_plan = temp_assign_plan(plan,real_ope,nil,stop)
        if shozo_plan
          logmsg += "\n         酸洗を入れるので取り直した#{shozo_plan[0].mdHM}-#{shozo_plan[1].mdHM}" 
        else
          logmsg += "\n         酸洗を入れるので取り直したが取れなかった"
        end
      end
      #hozen_date[real_ope]=shozo_plan[0].day
    end 
    logger.info logmsg
    logger.debug "DEBUG      TEMP ASSIGN 抄造仮押え  #{plan.lot_no} #{shozo_plan[0].mdHM}-#{shozo_plan[1].mdHM}"
    [shozo_maint,shozo_plan]
  end


  #乾燥の仮押さえ
  #- 乾燥開始可能時間が、前の品種の終了時間より前か後かで割り付けが異なる
  #- 前の場合は前の乾燥投入終了時刻にまでに食い込めるので、確保時間は短くなる
  def temp_assign_dry(plan,force_from_time=nil)
    real_ope = plan.dry?
    plan_startable, dry_maint,trans = dry_plan_startable_time(plan,real_ope,force_from_time)
    return nil unless plan_startable
    logger.debug("DRY plan_from候補 #{plan.lot_no} #{plan_startable.mdHM}")
    period,stay,err = plan.ope_length(real_ope)
    if_error(err)

    # 乾燥開始可能時間が、前の品種の終了時間より前か後かで割り付けが異なる
    if is_dry_overup_startable?(plan_startable,real_ope)
      plan_from,plan_to = search_dry_overup_plan(real_ope,plan_startable,period)
      #plan_from,plan_to = freeList[real_ope].searchfree( last_to, period-(last_to-plan_startable))
      logger.debug("DRY plan_from食い込みでの検索結果 #{plan.lot_no} #{plan_from.mdHM}-#{plan_to.mdHM}") if plan_from
      logger.debug("DRY plan_from食い込みでの調整結果 #{plan.lot_no} #{plan_from.mdHM}-#{plan_to.mdHM}") if plan_from

    else
      # 正規の時間で取る
      plan_from,plan_to = freeList[real_ope].searchfree(plan_startable,period)
    end	

    return nil unless plan_from 
    logmsg = "INFO      TEMP ASSIGN 乾燥仮押え  #{plan.lot_no} #{plan_from.mdHM}-#{plan_to.mdHM}"
    if @log
      logger.debug("==== 製造仮割付 #{UbeSkd::Id2RealName[real_ope]} "+
                   "#{plan_from.mdHM}--#{plan_to.mdHM}\n" +
                   "\t移動　#{trans.mdHM}  保守 #{dry_maint[1].mdHM}" +
                   (shozo?(real_ope) ? "養生 #{yojoko[plan.yojoko].next_start}" : "")
                   )
    end
    return [dry_maint,[plan_from,plan_to,plan_from + stay, plan_to - stay ]]
  end  
 
  #加工の仮押さえ：保守・切り替え と 製品製造の時間を押さえる
  #- │ 　前のロットに対し、切替制約評価
  #- │ 　前のロットに対し、保守候補と切替の遅い方で 時間を仮に確保
  #- │ 　前の工程に対し、　移動による制約評価
  #- │ 　移動と保守・切替の遅い方を開始時間にしてPlanの時間を仮に確保
  #* 戻り値 [ [保守開始、終了、保全code],[製造開始、終了]]
  #  　　　　時間を押さえられなかったときは nil
  #<tt>current_to</tt> :: このロットの前工程の.終了時間
  #                       省略時： plan_***_to が使われる。抄造の場合は time_from
  def temp_assign_kakou(plan,force_from_time=nil)
    kakou_maint = temp_assign_shozo_kakou_maint(plan,:kakou) #temp_assign_maint(plan,:kakou,force_from_time)
    return nil unless kakou_maint

    plan_times  = temp_assign_plan(plan,:kakou,force_from_time,kakou_maint[1])

    return nil unless plan_times
    return [kakou_maint,plan_times]
  end



  # 時間の仮押さえ：切り替え・保守の時間を仮に確保する
  # -  保守候補と切替の遅い方を採る。
  #    　ただし、UbeNamedChange にて複数の　にある物は併記する
  # -  保守は候補が pre_condition[0..1] に格納済み。
  # -  この工程の前品種の終了時間は  pre_condition[4]に格納済み。これが切り替えの開始可能時間
  # -  始業作業と重なる場合、長い方にする。
  # 
  # <tt>real_ope</tt>   :: 時間を確保する 実工程
  # <tt>current_to</tt> :: real_ope工程の一つ前のロットの終了時間。
  #                     :: nil の場合は plan_***_to が使われる。抄造の場合は time_from
  # <tt>戻り値</tt>      :: ［start,stop,hozencode]
  #                     :: hozencode は [ube_product_id]
  #                     :: 　　割り当てに失敗した時は nil
  # 
  def temp_assign_maint(plan,real_ope,current_to=nil)
     if real_ope == :yojo
        [current_to,current_to,nil] #ddtemp_assign_yojo_maint(plan,current_to) 
     elsif real_ope == :dryo || real_ope == :dryn
       temp_assign_dry_maint(plan,real_ope)     
    else 
       temp_assign_shozo_kakou_maint(plan,real_ope)
     end
  end

  def temp_assign_dry_maint(plan,real_ope)
    change = change_time(plan,real_ope) # [所要時間,[[pro_id,保守コード],[],,,[]] ]
    maintain = maintain_time(plan,real_ope)

    # 乾燥の保全は刃物替え 30分だけだが、これと切り替えは同時にできるので
    # 自動の割り付けではあつかわないことにした。。

    plan_end = (pre_condition[real_ope] ? pre_condition[real_ope].plan_dry_end : time_from) || time_from
    plan_to = pre_plan_to(real_ope)
      # 切り替えはplan_end から始まるが、空き時間リストはplan_toまで塞がっている
      # plan_end + periad が plan_to を越えないときは searchfree は不要
      if plan_end+change.periad <= plan_to
        start,stop = [plan_end,plan_end+change.periad] 
      else
        logger.info("  乾燥保守仮割付: #{plan.lot_no} 検索開始時間 #{plan_to}"+
                    " 期間 #{(change.periad-(plan_to - plan_end))/60}分")
        start,stop = freeList[real_ope].searchfree(plan_to  ,
                                                   change.periad-(plan_to - plan_end),true)
        logger.info("                    1      start #{start},stop #{stop}")
        if start == plan_to
          # 開始時間が plan_to であったら開始時間を plan_endに戻す.
          start = plan_end if start 
        else
          # 休日などで間が開いたのだろうから、前ロットに重ならない。ので正規の長さで取り直し
          start,stop = freeList[real_ope].searchfree(plan_to  ,change.periad,true)
          logger.info("                     2     start #{start},stop #{stop}")
        end
      end
    logger.info("  乾燥保守仮割付決定： #{plan.lot_no} #{real_ope} "+
                "#{start.mdHM}～#{stop.mdHM} [#{change.arranged_code.join(',')}]") if start
    start ? [start,stop,change.arranged_code] : nil
  end

  def temp_assign_shozo_kakou_maint(plan,real_ope)
    #periad,array_hozencode = longer_change_maint(plan,real_ope)
    maint =  longer_change_maint(plan,real_ope)
    start,stop = freeList[real_ope].searchfree(pre_plan_to(real_ope)  ,maint.periad,true )
    logger.debug("TEMP_ASSIGN_SHOZO_KAKOU_MAINT: #{plan.lot_no} maint=#{maint.inspect}:start/stop=#{start}/#{stop}")
    #start ? [start,stop,hozencode_arrange(maint.hozen_code_list)] : nil
    start ? [start,stop,maint.arranged_code] : nil
  end
  # 時間の仮押さえ： 製品製造の時間を押さえる
  # - 抄造と乾燥はややこしいから外に出したのだが、まだ残ってる。これは削除すべきや？
  #   　　引数で与えられる、保守・切り替え終了時間と、移動時間制約による開始可能時間との
  #   　　遅い方を開始可能時間として製品の時間を確保する。
  # <tt>real_ope</tt>;;時間を確保する 実工程
  # <tt>current_to</tt>;;このロットのreal_opeの前の工程の終了時間
  # <tt>maint_to</tt>;;仮確保した保守の終了時間
  # 戻り値 ［plan_from, plan_to, plan_out, plan_end]
  # plan_from :: 工程開始時間
  # plan_to   :: 工程終了時間　　　　　　　　　　　　　　　 一覧に載せる時間
  # plan_out  :: 搬出開始時間 乾燥以外は plan_from と同じ
  # plan_end  :: 搬入終了時間 乾燥以外は plan_to   と同じ。 assignFree で割り当てる時間
  def temp_assign_plan(plan,real_ope,force_from_time,maint_to)
    return temp_assign_plan_yojo(plan,force_from_time) if real_ope == :yojo
    return temp_assign_plan_dry(plan,real_ope,force_from_time,maint_to) if dry?(real_ope)
    return temp_assign_plan_shozo_kakou(plan,real_ope,force_from_time,maint_to) if shozo?(real_ope)
    return temp_assign_plan_shozo_kakou(plan,real_ope,force_from_time,maint_to) if real_ope == :kakou
  end
  def temp_assign_plan_shozo_kakou(plan,real_ope,force_from_time,maint_to)
    #return nil if plan.condition=="型板" and real_ope
    # 移動による制約評価
    trans = plan.transfer_time(self,real_ope,force_from_time)
    logger.info("  temp_assign_plan: id=#{plan.id} #{plan.lot_no} #{real_ope} trans #{trans} mint_to #{maint_to}")
    plan_from = plan_from_save = trans > maint_to ? trans : maint_to
    period,stay,err = plan.ope_length(real_ope)
    logger.debug("  temp_assign_plan: id=#{plan.id} #{plan.lot_no} #{real_ope} 数量 #{plan.mass} 所要時間 #{period.hm}")
    if_error(err)

    unless real_ope == :kakou
      # 抄造の場合は、養生の空き具合を確認し、遅い方にする
      #plan_from = yojoko[plan.yojoko].next_start if plan_from < yojoko[plan.yojoko].next_start-72.hour 
      logger.debug("  temp_assign_plan: id=#{plan.id} #{plan.lot_no} plan_from=#{plan_from.mdHM}yojoKo.next_start=#{plan.yojoKo.next_start.mdHM}")
      plan_from = plan.yojoKo.next_start if plan_from < plan.yojoKo.next_start-72.hour 
    end
    plan_from,plan_to = freeList[real_ope].searchfree(plan_from,period)
    return nil unless plan_from 
    if @log
      logger.debug("==== 製造仮割付 #{UbeSkd::Id2RealName[real_ope]} "+
                   "#{plan_from.mdHM}--#{plan_to.mdHM}\n" +
                   "\t移動　#{trans.mdHM}  保守 #{maint_to.mdHM}" +
                   (shozo?(real_ope) ? "養生 #{yojoko[plan.yojoko].next_start}" : "")
                   )
    end

    return [plan_from,plan_to,plan_from + stay, plan_to - stay ]
    #end
  end
  def temp_assign_plan_dry(plan,real_ope,force_from_time,maint_to)
    trans = plan.transfer_time(self,real_ope,force_from_time)
    logger.info("  temp_assign_plan: id=#{plan.id} #{plan.lot_no} #{real_ope} trans #{trans} mint_to #{maint_to}")
    plan_from = plan_from_save = trans > maint_to ? trans : maint_to
    period,stay,err = plan.ope_length(real_ope)
    logger.debug("  temp_assign_plan: id=#{plan.id} #{plan.lot_no} #{real_ope} 数量 #{plan.mass} 所要時間 #{period.hm}")
    if_error(err)
    # 乾燥開始可能時間が、前の品種の終了時間より前か後かで割り付けが異なる
    if plan_from < (last_to = pre_condition[real_ope].plan_dry_to)
      # 前の場合は前の乾燥に食い込んで行うので、確保時間は短くなる
      plan_from,plan_to = freeList[real_ope].searchfree(plan_from,period-(last_to-plan_from))
      if  plan_from
        if plan_from > last_to
          # 結果、開始が前の乾燥終了以降だったら、間に休みなど入ったのだから、
          # 正規の時間で取り直す
          plan_from,plan_to = freeList[real_ope].searchfree(plan_from,period)
        else
          # 開始時間を調整する
          plan_from = plan_to - period
        end
      end
    else
      # 正規の時間で取る
      plan_from,plan_to = freeList[real_ope].searchfree(plan_from_save,period)
    end
    [plan_from,plan_to,plan_from + stay, plan_to - stay ]
    #   end
  end
  # 時間の仮押さえ：養生の場合： 製品製造の時間を押さえる
  # 指定された養生庫の使用開始可能時間と、抄造終了時間から決定する
  # 保守が割り込んで居ないことを確認する必要があるが今回は手抜く

  def temp_assign_plan_yojo(plan,shozo_to)
    yojoKo = plan.yojoKo
    startable = yojoKo.next_start > shozo_to ? yojoKo.next_start : shozo_to
    start = plan.transfer_time(self,:yojo,startable)
    logger.info("INFO      TEMP ASSIGN 養生仮押え #{plan.lot_no} #{start.mdHM}-#{(start+40.hour).mdHM}:"+
                "養生庫#{yojoKo.no} 利用可能 #{yojoKo.next_start.mdHM} 抄造終了時間 #{shozo_to.mdHM} 移動考慮した開始時間 #{start.mdHM}")
    [start,start+40.hour]
  end

  ########################
  # 稼働時間の累計
  def sum_running(plan,real_ope,from,stop)
    return unless from && stop
    case real_ope
    when :shozow,:shozoe
      running["running_pf_"+real_ope.to_s] += (stop - from)
      running["running_wf_"+real_ope.to_s] += plan.mass
    when :dryo,:dryn
      running["running_"+real_ope.to_s]    += plan.mass
    end
  end
  
  # この製品を製造可能状態かどうかしらべる
  #
  def we_can_do?(plans)
    #if plans[0].proname =~ /^S1/
    #  run = (running["running_wf_shozoe"] || 0)
    #  if plans.inject(run){|sum,plan| sum += plan.mass } > 150000
    #    false
    #  else
    #    true
    #  end
    #else
    true
    #end  
  end

  ##############
  # 一つ前の立案結果から、仕掛かり・未開始と各工程の最終製造になるplanを抜き出す
  def stock
    # 一つ前の立案結果。開始日が一番遅くかつ今回の開始日前のもの。同じ期間のが複数有ったらID最大
    skd = UbeSkd.find(:first,:order => "skd_from desc,id desc",:conditions=>["skd_from < ?",skd_from])
    return [] if skd.nil?

    # 累積の取得
    UbeSkd::Running.each{|ing,run| self[run]=skd[ing]} 

    # 仕掛かりと未開始。完成でないもので製品、または期間内の保守
    stocks = skd.ube_plans.select{|plan|
      !plan.result_done? && !plan.hozen? || #&& plan.plan_shozo_from|| 
      plan.hozen? && plan.included(time_from,time_to) 
    }
    plans_to_be_delete=
      stocks.select{|plan| plan.plan_shozo_from.nil? }
    logger.info("DBG to_be_delete = #{plans_to_be_delete.size} ")
    stocks -= plans_to_be_delete

    #
    if plans_to_be_delete.size > 0
      logger.info("=== INFO : 先月度開始予定のない製品を削除する ===\n    " +
                  plans_to_be_delete.map(&:id).join(",")
                  )
      skd.ube_plans.delete plans_to_be_delete
      plans_to_be_delete.each{|plan| 
        plan.ube_product_id=nil;plan_lot_no=nil;plan.jun=nil
        plan.save
      }
    end
      
    # 各工程最終製品を選ぶ
    dones = UbeSkd::ResultTimes.map{|r_o,from,to| 
      skd.ube_plans.find(:first,:order => "#{from} desc",:conditions => ["mass > 1 "] )
    }
    #養生の最終製品を選び直す
    yojo = skd.ube_plans.map(&:yojoko).map{|yojokoNo|
      skd.ube_plans.select{|plan| plan.yojoko == yojokoNo && plan.result_yojo_from
      }.sort{|a,b| b.result_yojo_from <=> a.result_yojo_from}.first
    }
    if (stocks + dones+yojo).size>0
      (stocks + dones+yojo).uniq.compact
    else
      []
    end

  end

  # 休日に順を入れて、しかるべき所に表示されるようにする
  # - 　工程毎に開始時間でソートし、A01 を探す。その前の順＋５
  def set_jun_for_holiday
    make_plans_of_holyday_and_maintain

    UbeSkd::RealOpe.each{|real_ope| 
      plan_from = UbeSkd::PlanTimes[real_ope][0]
      jun = 0
      ube_plans.select{|plan| plan[plan_from] 
      }.sort_by{|plan| plan[plan_from] 
      }.each{|plan| 
        if  plan.hozen? 
          plan.jun = jun + 5
        else
          #logger.debug(" #{plan.lot_no}(#{plan.id})=#{plan.jun}")
          jun = plan.jun if plan.jun
          next
        end
      }
    }
  end
  
  def make_plans_of_holyday_and_maintain
    i=0
    holydays.each{|real_ope,hldys| 
      hldys.each{|holyday|
        hc = UbeProduct.holyday_code[holyday[2..3]]
        plan = create_hozen_plan(holyday[3],holyday[0],holyday[1],hc[0])
        i += 1
      }
    }
    UbeSkd::RealOpe.each{|real_ope|
      hc = UbeProduct.holyday_code[["A15",real_ope]]
      maintain[real_ope].each{|plan_start,plan_end,maintain|
        plan = create_hozen_plan(real_ope,plan_start,plan_end,hc[0])
        i += 1
      }
    }
    return
  end

  #=====統計集計(sumtime)
  #
  #稼働時間、予定製造時間、保守、切り替え、実績などの統計を取り、保存する。
  #下請けにsumtimeをつかう。
  #
  #統計:順は重要。changetimeはmaintainを使う。
  def sumtimes
    %w(_shozo_w _shozo_e _yojo _dry_o _dry_n _kakou).each_with_index{|sym,idxs|
      %w(runtime plantime freetime mainttime changetime donetime).each_with_index{|time,idxt|
        self[time+sym] = sumtime(time,UbeSkd::RealOpe[idxs])
      }
    }
  end

  #=====統計集計下請け(sumtime(type,ope))
  #集計メソッドを呼ぶ。
  #
  #params
  #type :: String  runtime plantime など、集計メソッドの名前 
  #ope  :: Symbol  集計対象の工程 
  def sumtime( type,ope)
    @sumtime ||= Hash.new
    @sumtime[[type,ope]] ||= send(type,ope)/1.minute
    @sumtime[[type,ope]] 
  end

  #===== 予定製造時間累計(plantime(real_ope))
  #製造予定の累計。予定時間が一部でも立案期間に掛かっているものを累計する。
  #はみ出している部分は控除していないので、そういうのがあると多めの誤差となる。
  #
  #plan_doneを下請けに使って、UbePlanの予定情報を累計している
  def plantime(real_ope)
    plan_done(real_ope,0..1)
  end
  
  #=====実績製造時間集計(donetime)
  #製造予定の累計。予定時間が一部でも立案期間に掛かっているものを累計する。
  #はみ出している部分は控除していないので、そういうのがあると多めの誤差となる。
  #
  #plan_doneを下請けに使って、UbePlanの実績情報を累計している
  def donetime(real_ope)
    plan_done(real_ope,2..3)
  end

  #=====予定、実績製造時間の集計(plan_done)
  #UbePlan#{plan,result}_****_{from|to}を元に製造時間を集計する。
  #
  #乾燥工程は、投入終了から終了(完全排出)までの間に次のロットの乾燥が始まっている
  #場合がある。その場合は重なり部分は二重に累積しないように、控除する。
  #
  def plan_done(real_ope,range)
    from,to = UbeSkd::PlanTimes[real_ope][range]
    unless [:dryo,:dryn].include?(real_ope)
      ube_plans.select{|plan| 
        plan.real_ope?(real_ope) && plan.mass >1 && plan[to]&&plan[from]&&
        # (一部でも)立案期間内に入っている
        plan[to] > time_from && plan[from] < time_to
      }.inject(0){|s,plan| s += plan[to] - plan[from]}
    else
      pre_to = time_from
      plans=ube_plans.select{|plan| 
        #     乾燥機が該当       保全ではなく   開始終了ともデータがあり
        plan.real_ope?(real_ope) && plan.mass >1 && plan[to] && plan[from] &&
        # (一部でも)立案期間内に入っている
        plan[to] > time_from && plan[from] < time_to
        # 開始順に並べて
      }.sort_by{|plan| plan[from]  }
      plans.inject([0,time_from]){|s,plan| 
        #       前ロット終了前に始まってたら　前ロット終了からの時間　でなければこの時間
        s=[ s[0]+(s[1] > plan[from] ? plan[to] - s[1] : plan[to] - plan[from] ),plan[to] ]
      }[0]
    end
  end
  
  #=====稼働時間(runtime(real_ope))
  #立案期間から休日を引いた分。休転は引かない。
  #
  #計算にはholydays[real_ope]を用いる。
  def runtime(real_ope)
    time_to - time_from - holydays[real_ope].inject(0){|s,v| s += (v[1] - v[0])}
  end


  #=====未割り当て(freetime)
  #  予定も切り替えも保守も割り当てられなかった時間
  #  freeListに残っている時間を累計する。
  def freetime(real_ope)
    freeList[real_ope].freetime #.inject{|s,free| s += free[1]-free[0]}
  end

  #=====保守時間累計(mainttime)
  #UbePlan#conditionがA02 A03 A06 A07 A08 A09 A11 A13 であるものを
  #保守として累計する。
  #
  #立案時に「実績のない保守・切り替え」は削除してしまっているので、正しい値になっていない。
  def mainttime(real_ope)
    from,to = UbeSkd::PlanTimes[real_ope][0..1]
    ube_plans.select{|plan| 
      plan.real_ope?(real_ope) && %w(A02 A03 A06 A07 A08 A09 A11 A13).include?(plan.condition)
    }.inject(0){|s,plan| s +=  ( plan[to] && plan[from] ? (plan[to] - plan[from]) : 0) }
  end

  #=====切り替え時間累計(changetime)
  #割り当て中に切り替え時間・保守時間を区別せずに sum_change_timeに
  #累計していたので、そこから保守分を引いて切り替え時間とする。
  def changetime(real_ope)# run - plan - mainain - free
    sum_change_time[real_ope] - sumtime("mainttime",real_ope)
  end

  # デバグ用。
  ## 実績を入れる。plan通りの値
  def set_result_by_plan
    ube_plans.each{|plan| 
      UbeSkd::Ope.each{|ope|  
        p_f,p_t,r_f,r_t = UbeSkd::PlanTimes[ope]
        plan[r_f]=plan[p_f]+0 rescue nil
        plan[r_t] = plan[p_t]+0 rescue nil
      }
      plan.save
    }

  end

  def if_error(err)
    return unless err
    errors.add(:nil,err)
    logger.info(err)
  end

  private
  def search_dry_overup_plan(real_ope,plan_startable,period)
    last_to = pre_condition[real_ope].plan_dry_to
    plan_from,plan_to = freeList[real_ope].searchfree(last_to, period-(last_to-plan_startable))
   if  plan_from
      if plan_from > last_to
        # 結果、開始が前の乾燥終了以降だったら、間に休みなど入ったのだから、
        # 正規の時間で取り直す
        plan_from,plan_to = freeList[real_ope].searchfree(plan_from,period)
      else
        # 開始時間を調整する
        plan_from = plan_to - period
      end
    end
    [plan_from,plan_to]
  end

  def is_dry_overup_startable?(plan_startable,real_ope)
    plan_startable < pre_condition[real_ope].plan_dry_to
  end
  # デバグ用。
  ## 実績を入れ、saveする。plan通りの値
  def set_result_by_plan_save
    set_result_by_plan
    self.save
    ube_plans.each{|plan| plan.save}
  end


  def pre_plan_to(real_ope)
    pre_condition[real_ope] ? pre_condition[real_ope].plans(real_ope,:plan_to) : time_from
  end

  def dry_plan_startable_time(plan,real_ope,force_from_time)
    maint=temp_assign_maint(plan,real_ope,force_from_time)
    return nil unless maint#[0] 
    logger.info("---- temp_assign_maint #{plan.lot_no} #{maint.join('/')}")
    # 移動による制約評価
    trans = plan.transfer_time(self,real_ope,force_from_time)
    [[trans, maint[1]].max,maint,trans]
  end

  def longer_change_maint(plan,real_ope)
    change = change_time(plan,real_ope)
    maintain = maintain_time(plan,real_ope)
    change.longer maintain
  end


end  
end
class Time
  def mdHM
    strftime("%m%d%H%M")
  end
end


__END__
$Id: ube_skd_help.rb,v 2.76 2012-11-24 11:58:36 dezawa Exp $
