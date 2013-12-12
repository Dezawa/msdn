# -*- coding: utf-8 -*-
require 'pp'
#== 計画立案(UbeSkd)
#ロットデータ(Ubeboard::Plan)のインスタンスをhabmする。1月1インスタンスが原則。
#
#3つの機能がある。
#[立案準備]
#     立案対象のロットを Ubeboard::Plan::make_plans_from_lips と Function::boad::boad::SkdHelp#stock で用意する。
#     Function::SkdHelp#stockでは前月度の仕掛品、未開始品(及び今月立案に必要な完了品)を取り込む
#[立案]
#     立案する。詳細は後述する。
#[実績登録]
#     日々の計画修正のために、各ロット各工程の実績を登録する
#[作業指示出力]
#     現場に指示するためのPDF出力
#
#==== 立案
#立案は実績が入っていない工程について割付しなおす。
#割付は各工程の最後の実績の後から割り付ける。
#
#立案は3つのステップで行われる。
#[立案前処理]
#     空き時間を初期化(Function::Freelist#freeList)し、
#     既に終了している工程を割付け(sorted_plan)、
#     各工程の最終状態を得る。(assign_if_resulted)
#[仕掛品処理]
#     すべての仕掛品を最終工程まで割り付ける(Function::SkdHelp#procceed_stock)。
#[立案]
#     立案開始日以前の予定は変更しない。初期値は立案期間開始日
#
#     「次に割り付けるロット」を決める方法に優先順モードと優先順尊重モードとがある。
#
#     抄造、養生、乾燥までを仮に割付け、
#     後置き時間、前置き時間をみて調整する(Function::SkdHelp#temp_assign_all_plan)。
#     
#     仮割付した時間で割り付ける。
#
#
#====アルゴリズム
#現最終アルゴリズムは7改 make_plan7
#
#==== 優先順モード・優先順尊重モード
#割付は基本的には「優先順」(Ubeboard::Plan#jun)の順番で行われる。
#
#優先順モードは必ず優先順で行われるが、尊重モードでは概ね順の通りだが
#Function::Optimize#optimizeが決めた順で行われる。
#
#
class Ubeboard::Skd < ActiveRecord::Base
  #require 'function/ube_skd_help'
  include Ubeboard::Function::SkdResultInput
  include Ubeboard::Function::SkdHelp
  include Ubeboard::Function::SkdFreelist
  include Ubeboard::Function::Optimize
  include Ubeboard::Function::SkdCsv
  include Ubeboard::Function::SkdPdf

  self.table_name = 'ube_skds'
  delegate :logger, :to=>"ActiveRecord::Base"

  
  #has_many      :ube_plans ,:dependent => :delete_all
  has_and_belongs_to_many :ube_plans,:class_name => "Ubeboard::Plan"
  validates_presence_of :skd_from, :message =>"立案期間開始が未入力です"
  validates_presence_of :skd_to,  :message =>"立案期間終了が未入力です"

  #attr_accessible :message
  #attr_accessible :runtime_shozo_w ,:plantime_shozo_w,:donetime_shozo_w 
  #attr_accessible :runtime_shozo_e ,:plantime_shozo_e,:donetime_shozo_e 
  #attr_accessible :runtime_dry_o   ,:plantime_dry_o  ,:donetime_dry_o   
  #attr_accessible :runtime_dry_n   ,:plantime_dry_n  ,:donetime_dry_n   
  #attr_accessible :runtime_kakou   ,:plantime_kakou  ,:donetime_kakou   
  #attr_accessible :skd_from, :skd_to,:replan_from, :free_list
  #attr_accessible :skd_f, :skd_t, :holydays
  #attr_accessible :running_wf_shozow,:running_wf_shozoe,:running_pf_shozow,:running_pf_shozoe,
  #:running_dryo,:running_dryn,:limit_wf_shozow,:limit_wf_shozoe
  #attr_accessible :runned_wf_shozow,:runned_wf_shozoe,     :runned_pf_shozow,:runned_pf_shozoe,
  #:runned_dryero,:runned_dryern

  Running = [:running_pf_shozow,:running_pf_shozoe,:running_wf_shozow,:running_wf_shozoe,
             :running_dryo,:running_dryn
            ].zip([:runned_pf_shozow,:runned_pf_shozoe, :runned_wf_shozow,:runned_wf_shozoe,
                   :runned_dryo,:runned_dryn]
                  )
  
  # これは Ubeboard::NamedChange に置くべき性格であるが、Ubeboard::NamedChangeを更新したときに
  # 自動的に反映させるため、立案毎に更新されるように ube_skdに置く
  def named_change_pro_id(real_ope,pre_condition_id,post_condition_id)
    @named_change ||= Hash.new
    @named_change[[real_ope,pre_condition_id,post_condition_id]] ||=
      Ubeboard::Skd.named_change(real_ope,pre_condition_id,post_condition_id)
  end
  
  def self.named_change(real_ope,pre_condition_id,post_condition_id)
    ope = {:shozow => :shozo,:shozoe => :shozo, :dryo => :dryer, :dryn => :dryer}[real_ope]
    ope_name = Id2Ope[Real2Ope[real_ope]]
    sql = "ope_name = ? and ( pre_condition_id = ? and post_condition_id = ? or" +
      " pre_condition_id = ? and post_condition_id is null or "+
      " pre_condition_id is null and post_condition_id = ? )"
    named_changes = Ubeboard::NamedChange.where( [ sql, ope_name,
                                                   pre_condition_id,post_condition_id,
                                                   pre_condition_id,post_condition_id
                                                 ]
                                                 ).order( "jun")
                                       
    if named_changes.size > 0
      named_changes.first[:display].split.map{|a00| 
        up = Ubeboard::Product.where(["ope_condition = ? and #{ope} = ?",a00,Id2RealName[real_ope]])
        up.size > 0 ? up[0][:id] : nil
      }.compact
    else
      []
    end
  end


  ###
  def after_find2
    err =ube_plans.map{|plan| plan.errors.on(:plan_dry_from)}.compact
    errors.add(:nil,"次の製品の乾燥工程が開きすぎています　" + err.sort.join("  ") ) if err.size>0
    err= ube_plans.map{|plan| er=plan.errors.on(:plan_shozo_from)}.compact
    errors.add(:nil,"次の製品は製造開始しませんでした　" + err.sort.join("  ") ) if err.size>0
    err = ube_plans.map{|plan| plan.errors.on(:plan_kakou_from)}.compact
    errors.add(:nil,"次の製品は期間内に完了しませんでした　" + err.sort.join("  ")) if err.size>0
    message.split("\n").each{|msg| errors.add(:nil,msg) } unless message.blank?  
  end

  #稼動累積による保全のための上限値を設定する。
  def after_find
    self[:limit_wf_shozow] = RunShozoCount unless  self[:limit_wf_shozow] && self[:limit_wf_shozow]>0
    self[:limit_wf_shozoe] = RunShozoCount unless  self[:limit_wf_shozoe] && self[:limit_wf_shozoe]>0
    self[:limit_pf_shozow] = RunShozoTime  unless  self[:limit_pf_shozow] && self[:limit_pf_shozow]>0
    self[:limit_pf_shozoe] = RunShozoTime  unless  self[:limit_pf_shozoe] && self[:limit_pf_shozoe]>0
    self[:replan_from]       = skd_from      unless  self[:replan_from]
  end

  def error_check
    ube_plans.each{|plan| plan.after_find2 }
    after_find2
  end

  def before_save
  end

  #### Class Constants ###
  #デバグのときこのロット番号について追いかける
  Lot = %w(1M0067)

  #アルゴリズム５改で、「乾燥工程に空きが出たとき」の判定時間
  DryUnAssign = 10.hour

  #最小ロットサイズ。ロット分割時に半端が出たとき最低この数量を製造する
  MassMin = 700

  #最低製造数。休日前に半端な製造数量となるとき、最低この数量にならないときはやめる。
  MassLimit = 300
  def masslimit
    @masslimit ||=  Ubeboard::Constant.find_by(keyword: "minimum_mass").value rescue MassLimit
  end

  #過労働日の残業時間
  HolydayKarou = 4.hour

  #休日出勤日の出勤時間
  HolydayShukkin=8.hour

  #
  HolydayUnkyu  =16.hour

  #前後のロットの間に休日が入ったかどうか判断するための基準時間
  #この時間に　終業始業作業時間が加わった beyond_holyday で判断する。
  BeyondHolyday = 16 

  #乾燥工程内滞在時間を計算するための定数
  #-  今は乾燥にのみ意味がある。値は乾燥炉内にある枚数。名前は不適切だ
  #-  Ubeboard::Operationで定められる 滞在時間 から、投入間隔＝滞在時間/StayTime
  StayTime = { :shozo => 0 , :yojo => 0, :dry => 1000 , :kakou => 0 }

  #乾燥工程に関わる時間:  投入から乾燥炉に入るまで
  DryLead = 0.minute  

  #  乾燥炉から出るまで
  DryTrail = 15.minute

  #計画時間の丸め
  Round = 5.minute

  #記名切り替えか否かの判定時間。単位分
  #　　　　Namedのない　　加工の最長が60分、乾燥の最長が40分
  #　なので、70分で区切る。 70min=4200sec
  #　手抜きして工程毎の違いを無視しているので、最短と最長がクロスしたら破綻する
  ChangeTimeLimit = 70.minute

  def self.named_mult
  #作業が重なったときに、併記すべき保守・切り替え
  #NamedMult = Ubeboard::Product.all(:conditions => ["proname in (?)",%w(WF替 PF替 サラン替)]).map(&:id)
    begin 
      namedMult = Ubeboard::Product.where( ["proname in (?)",%w(WF替 PF替 サラン替)]).pluck(:id)#to_map(&:id)
    rescue
      namedMult = []
    end
  end
  #NamedMult = namedMult

  #PF替を行う累積抄造時間
  #  DBへのsaveでは 上限、先月末累積、今月末累積いずれも 時間単位
  #  インスタンス上での今月累積は 秒 のまま扱う。
  RunShozoTime =  1000 #.hour

  #WF替を行う累積抄造枚数
  #  上限、先月末、今月末、現累積はDB上も含め単位 枚で扱うが、累積一覧では千枚にして表示する
  RunShozoCount = 180000
  RunShozoCntMax= 200000
  RunShozoS3Cnt = 150000

  #刃物替えを行う、乾燥累積枚数
  #RunDryCount = 1400000

  Ope = [:shozo,:yojo,:dry,:kakou]
  OpeName = %w(抄造 養生 乾燥 加工)
  RealOpeName = %w(西抄造 東抄造 養生 原乾燥 新乾燥 加工)
  RealOpe = [:shozow,:shozoe,:yojo,:dryo,:dryn,:kakou]
  Real2Ope = {:shozow=>:shozo,:shozoe => :shozo,:dryo => :dry, :dryn => :dry,:kakou => :kakou}
  Id2RealName = Hash[*RealOpe.zip(RealOpeName).flatten].merge(:done => "完了")
  Id2Ope = Hash[*Ope.zip(OpeName).flatten].merge(:done => "完了",nil => "未製造")
  RealName2Id = Hash[*RealOpeName.zip(RealOpe).flatten]
  Ope2Id      = Hash[*OpeName.zip(Ope).flatten]
  ResultTimes =  [[:shozo,:result_shozo_from,:result_shozo_to],
                  [:yojo,:result_yojo_from,:result_yojo_to],
                  [:dry,:result_dry_from,:result_dry_to],
                  [:kakou,:result_kakou_from,:result_kakou_to]]
  Reuslts = ResultTimes.map{|times| times[1..-1]}.flatten
  PlanTimes = {:shozo => [:plan_shozo_from,:plan_shozo_to,:result_shozo_from,:result_shozo_to],
    :shozow => [:plan_shozo_from,:plan_shozo_to,:result_shozo_from,:result_shozo_to],
    :shozoe => [:plan_shozo_from,:plan_shozo_to,:result_shozo_from,:result_shozo_to],
    :yojo => [:plan_yojo_from,:plan_yojo_to,:result_yojo_from,:result_yojo_to],
    :dry => [:plan_dry_from,:plan_dry_to,:result_dry_from,:result_dry_to,:plan_dry_out,:plan_dry_end],
    :dryo => [:plan_dry_from,:plan_dry_to,:result_dry_from,:result_dry_to,:plan_dry_out,:plan_dry_end],
    :dryn => [:plan_dry_from,:plan_dry_to,:result_dry_from,:result_dry_to,:plan_dry_out,:plan_dry_end],
    :kakou => [:plan_kakou_from,:plan_kakou_to,:result_kakou_from,:result_kakou_to]
  }
  PlanTimesSym=[:plan_shozo_from,:plan_shozo_to,:plan_yojo_from,:plan_yojo_to,
                :plan_dry_from,:plan_dry_to,:plan_dry_end,:plan_dry_out,
                :plan_kakou_from,:plan_kakou_to
               ]
  PlanStartSym=[:plan_shozo_from,:plan_yojo_from, :plan_dry_from,:plan_kakou_from]
  PTime = {}
  pt = %w(plan_ result_).product(%w(_from _to)).each{|p_r,f_t|
    key = (p_r+f_t).to_sym
    #PTime[[ope,key]] = (p_r + ope.to_s + f_t).to_sym
  }

  HolydayStart = ["運休開始時刻 西抄造","運休開始時刻 東抄造","","運休開始時刻 原乾燥",
                  "運休開始時刻 新乾燥","運休開始時刻 加工"].zip(RealOpe)
  def unkyu_start
    unless @unkyu_start
      unkyu_start = Ubeboard::Constant.all(:conditions => "name like '運休開始時刻 %'")
      @unkyu_start = 
        Hash[*unkyu_start.map{|h| [UbeSkd::RealName2Id[h.name.sub(/運休開始時刻 /,"")],h.value]}.flatten]
    end
    @unkyu_start
  end

  #立案期間開始年月日時刻。 :skd_from +8hr, :skd_to+32hr
  def time_from ; @time_from ||= skd_from.midnight +  8.hour; end

  #立案期間終了年月日時刻。 :skd_from +8hr, :skd_to+32hr
  def time_to   ; @time_to   ||= skd_to.midnight   + 32.hour  ; end

  #立案期間開始年月の文字表記
  #
  #日付としては、終わりの方は +32 しない。

  def str_from  ; @str_from  ||= skd_from.strftime("%Y/%m") ;end
  #立案期間終了年月の文字表記
  #
  #日付としては、終わりの方は +32 しない。
  def str_to    ; @str_to    ||= skd_to.strftime("%Y/%m")   ;end

  #各ラインの保全最終日。
  #
  #毎日、毎週の保全が行われたかどうかを記録する。酸洗(毎日)と予防保全(毎水曜)が対象
  def hozen_date(date=nil)
    @hozen ||= Hash.new{|h,k| h[k]=0}
  end
  
  def log ; @log ||= [] ; end

  #WF交換の上限枚数を東西毎に持つ。
  #
  #defaultは定数で定めてあるが、立案時に変更可能なので、それを保存する。
  def runshozocount(shozo) ; 
    #logger.info("Ubeboard::Skd:runshozocount(#{shozo}) is nil") unless self["limit_wf_#{shozo}"] 
    self["limit_wf_#{shozo}"] || RunShozoCount ; 
  end

  #先月度から取り込まれたplanのうち、先月度に完了しているもの
  def lastmanth
    ube_plans.select{|plan| plan.lastmonth?(time_from)}
  end

  #pre_conditionがないときのダミー。
  def dmy_plan
    unless @dmy
      params = Hash[*RealOpe.map{|real_ope| PlanTimes[real_ope][0..1].zip([time_from,time_from])}.flatten]
      params[:plan_dry_end]=params[:plan_dry_out] = time_from
      params[:ube_product_id]=nil
      @dmy= Ubeboard::Plan.new(params)
    end
    @dmy
  end

  #各ラインの前回製造のplan
  # real_ope → [plan]
  def pre_condition
    @pre_condition ||= Hash.new{|h,k| h[k]= dmy_plan  }
  end

  #稼動累計用の箱。
  # 0,1 。。。時間　　2..5。。。枚数
  def running
    unless @running
      @running =HashWithIndifferentAccess.new
      Running[0..1].each{|ing,runned| @running[ing] = self[runned] ? self[runned].hour : 0 }
      Running[2..5].each{|ing,runned| @running[ing] = self[runned] ? self[runned]      : 0 }
    end
    @running
  end

  #切り替え時間の累積用レジスター。
  #
  #立案時は保守の時間も累積し、立案後保守を引くことで切り替え時間集計とする
  def sum_change_time
    @sum_change_time ||= Hash.new{|h,k| h[k]=0 }
  end

  #shozow なのか shozoe なのか
  def shozo?(real_ope) ;    [:shozow,:shozoe].include?(real_ope) ;  end
  #dryo なのか dryn なのか
  def dry?(real_ope)   ;    [:dryo,:dryn].include?(real_ope) ;end

  #
  def ope?(real_ope) ; Real2Op[real_ope] ; end

  #養生庫の養生庫番号をキーとするハッシュ
  #
  #最初に呼ばれるときに初期化(Ubeboard::Yokojoのインスタンス作成)も行う。
  def yojoko
    unless @yojoko
      @yojoko = Hash.new
      Ubeboard::Yojo::Yojoko.each_key{|no| 
        @yojoko[no]=Ubeboard::Yojo.new(no);@yojoko[no].next_start time_from
      }
    end
    @yojoko
  end

  #養生庫の配列。順は番号どおりではない。
  #
  #Hahsでは使いにくいことも有るので、Arrayにもした。
  def yojoko!
    @yojoArray ||= yojoko.map{|k,v| v}
  end

  #指定の時間に利用可能な養生庫を開始可能時間の早い順に並べて帰す
  def yojoko_list_by_time(yojo_from)
    yojokos = yojoko!.select{|yjk| yjk.next_start <= yojo_from}.
      sort{|a,b| a.next_start <=> b.next_start} 
    if  yojokos.size > 0
      logger.debug "\n\t"+
        yojokos.map{|yojoko| ("    %2d " % yojoko.no) + 
        yojoko.size.to_s + yojoko.next_start.strftime("  %m/%d-%H:%M\n")
      }.join 
    end
    yojokos
  end

  #proname,productid の変換テーブル　使わないな
  def pronamessave
    @pronames ||= Ubeboard::Product.all(:conditions => "hozen = false or hozen is null",
                                 :select => "proname,id"
                                 ).map{ |p| [p.proname,p.id]}
  end

  #Ubeboard::Skdに付いているUbeboard::Planを完了、仕掛、未実施にわけ、
  #各々優先順に並べたもの。planの配列の配列。
  #
  #最初に評価されたときに初期化(分類、ソート、優先順付け、製造番号付け)
  #を行う。
  #
  #立案の初期化で呼ばれる。
  #
  #初期化時
  #1. 予定時刻の扱い
  #    実績があり予定がない                :: 実績を予定にコピーする
  #    実績が無くかつ予定日が立案開始日より前 :: 予定は消す
  #    実績があり予定もある :: 食い違ってもそのまま残す
  #2. 保守、切り替え時間を削除する。ただし、実績が入っているもの、立案開始日以前のものは残す
  #3. 養生庫の空き時間を設定する。
  #
  #完了、仕掛かり、新規に分ける基準
  #     skd_from     skd_to
  #        |<--------->|
  #  --->                 done   完了 最終工程の実績の終了がある
  #     <---->            done   完了 最終工程の実績の終了がある
  #     <-----            stock  仕掛 抄造開始しているが、最終工程の終了がない
  #          <---         stock  仕掛 抄造開始しているが、最終工程の終了がない
  #                       wait   未実施 抄造開始していない
  def sorted_plan
    unless @sort_plan
      delete_hozen_ubeplan_unless_resulted
      copy_result_to_plan_or_eraze_plan
        #養生の実績があるものは、養生庫の空き時間を,設定する。
        #あるものは、養生庫の空き時間を,設定する必要がある、が。
        #　空き時間は乾燥の終了。
        #　乾燥の実績が無い場合は、仕掛かりの割付で行う
        #厄介なので、設定は assign_if_resulted に任せよう
        #plan.yojoko = nil unless plan.result_yojo_from
        #end
        #加工の実績があり、かつ期間開始前は　:done にする
        #加工工程の無いものは、乾燥の実績が期間開始前に終わっていれば　:done にする
        #if plan[:result_kakou_to] && plan[:result_kakou_to] <= time_from ||
        #   plan[:result_dry_to] && 
        #   plan[:result_dry_to] <= time_from && (plan.rate[:kakou]==0.0 || plan.rate[:kakou].blank?)
        # plan.current :done
      set_status_done_if_done

      done,stock,wait = sort_by_status
      @stock = stock + done
      set_yojoKo_object

      ###順をつけなおし
      @jun = 0
      done.each{|plan|   plan.jun = (@jun += 10)  }   #順をつけなおし
      stock.each{|plan| plan.jun = (@jun += 10) }
      wait.each{|plan| plan.jun = (@jun += 10) }
      @junsave = @jun

      #ロット番号振り直しの準備
      #抄造開始していないもの(抄造実績がなく、かつ立案開始以降）の番号を消し、その後max_lotを得る
      ube_plans.each{|plan| plan.lot_no="" unless plan.plan_shozo_from && !plan.hozen?}
      @lot_no={}
     [:shozoe,:shozow].each{|shozo| @lot_no[shozo]=max_lot[shozo]}

      wait.each{|plan|  
        plan.lot_no = (max_lot[plan.shozo?]=max_lot[plan.shozo?].succ) if plan.mass > 1
      }
      @sort_plan =     [done,stock,wait]
    end
    @sort_plan
  end

  #sorted_plan[2] を製品毎にグルーピングする。→ラウンド
  def grouped_plans
    unless @grouped_plan
      @grouped_plan = []
      pro_id = nil; group=[]
      sorted_plan[2].each{|p| 
        if   pro_id == p.ube_product_id ; group << p 
        else 
          @grouped_plan << group if group.size > 0
          pro_id = p.ube_product_id ; group = [p]
        end
      }
      @grouped_plan << group if group.size > 0
    end
    @grouped_plan
  end

  #sorted_plan[2] を製品毎にグルーピングし、東西原新にわける
  #
  #現在のFunction::Optimaize#optimizeで採用されているもの
  def grouped_plan_shzdry
    unless @grouped_plan
      @grouped_plan = {}
      ShzDry.each{|sd| @grouped_plan[sd]= [] }
      pro_id = nil; group=[]
      sorted_plan[2].each{|p| 
        if   pro_id == p.ube_product_id ; group << p 
        else 
          @grouped_plan[[group[0].shozo?,group[0].dry?]] << group if group.size > 0
          pro_id = p.ube_product_id ; group = [p]
        end
      }
      @grouped_plan[[group[0].shozo?,group[0].dry?]] << group if group.size > 0
      logger.debug("GROUPEDPLAN: #{@grouped_plan.keys.join(',')}")
    end
    @grouped_plan
  end


  #sorted_plan[2] を製品毎にグルーピングし、東西にわける
  def grouped_plan_shz
    unless @grouped_plan_shz
      @grouped_plan_shz = {}
      Shozo.each{|sd| @grouped_plan_shz[sd]= [] }
      pro_id = nil; group=[]
      sorted_plan[2].each{|p| 
        if   pro_id == p.ube_product_id ; group << p 
        else 
          @grouped_plan_shz[group[0].shozo?] << group if group.size > 0
          pro_id = p.ube_product_id ; group = [p]
        end
      }
      @grouped_plan_shz[group[0].shozo?] << group if group.size > 0
    end
    @grouped_plan_shz
  end

 
  #指定されたアルゴリズムで立案する。
  #  今実装されているのは、defaultのアルゴリズム7だけ
  #
  #1. 立案する make_plan7の実行
  #2. 作られた休日等のplanインスタンスの 優先順 を設定する
  #   立案結果表示のときに、表示位置を適切にするため
  #3. 統計をとる。  予定、実績、保守、切り替え、空き を累計し、保存
  #4. エラーをまとめ、保存する
  #立案後、統計データを求める.
  #  　エラー、警告を次の立案まで参照できるようにするために、DBに残す
  # 
  #
  def make_plan(option = {})
    opt={:argo=>7,:jun_only => nil}
    opt.merge!(option)
    logger.debug "opt = #{opt.to_a.join(':')}"
    @jun_only = opt[:jun_only]
    @message = []
    #養生庫の初期化
    
    ########立案 ##################################

    send "make_plan#{opt[:argo]}".to_sym
    #########################################
    #休日の優先順を作る
    set_jun_for_holiday

    #puts "#統計計算"
    sumtimes
    #self.save
    ube_plans.each{|plan| plan.save}

    #累計の保存
    Running[2..-1].each{|ing,run| self[ing]=running[ing]} #PF替え以外
    Running[0..1].each{|ing,run|  self[ing]=running[ing]/1.hour}
    #エラーをまとめ、保存する
    self[:message] = if errors[:base]
                       (@message+[errors[:base]].flatten).uniq.join("\n") 
                     else
                       @message.uniq.join("\n") 
                     end
    #debug用 freeListを Ubeboard::Skd.gree_list に保存
    self.free_list = YAML.dump(freeList)
    
    #ごみ掃除
    ######get_yojoko で仮におかれた置かれた、plan_shozo_fromを削除

    renumber
    #[:shozoe,:shozow].each{|shozo| 
    #  ube_plans.select{|plan| plan.shozo? == shozo && plan.jun.blank?  && !plan.hozen? 
    #  }.sort_by{|plan| plan.id}.each{|plan|
    #    plan.lot_no = (lot_no[shozo]=lot_no[shozo].succ)
    #  }
    #}

    self
  end

  def renumber
    ######@jun_only のでない場合はjunの振りなおし
    # lot_noを削除したものにつけなおし
    lot_no,jun = max_lot_no_and_jun_of_assigned #{}
    #[:shozoe,:shozow].each{|shozo| 
    #  lot_no[shozo]=ube_plans.select{|plan| 
    #    plan.shozo? == shozo && !plan.hozen? && !plan.jun.blank?
    #  }.map(&:lot_no).compact.max #sort[-1]
    #}
    plans = unassigned_plans
    [:shozoe,:shozow].each{|shozo| 
      plans[shozo].each{|plan|
      plan.lot_no = (lot_no[shozo]=lot_no[shozo].succ)
      plan.jun    = (jun = jun.succ)
      }
    }
  end

  def unassigned_plans
    plans = {}
    [:shozoe,:shozow].each{|shozo| 
      plans[shozo] = ube_plans.select{|plan| 
        #plan.shozo? == shozo && (plan.jun == 0 || plan.jun.blank?)  && !plan.hozen? 
        plan.shozo? == shozo && plan.plan_shozo_from.nil? && !plan.hozen? 
      }.sort_by{|plan| plan.id}
    }
    plans
  end

  def max_lot_no_and_jun_of_assigned
    lot_no={}
    _jun = {}
    [:shozoe,:shozow].each{|shozo| 
      assigned_plans = ube_plans.select{|plan| 
        plan.shozo? == shozo && !plan.hozen? && !plan.jun.blank?
      }
      lot_no[shozo]=assigned_plans.map(&:lot_no).compact.max #sort[-1]
      _jun[shozo] = assigned_plans.map(&:jun).compact.max
    }
    [lot_no,_jun.values.max]
  end

  #===アルゴリズム7改
  #1. 優先順に割り付けると細かな所まで操作できるが、こつこつやる必要があり
  #   手間がかかる。
  #2. しかし、最適化を試み優先順を変えると、意図的に早く|遅く製造したいという
  #   ような処理に対応できない。（最適化して木阿弥にしてしまう）
  #3. また、最適化も完全ではないので不満がのこる。
  #
  #そこで二つのモードを用意し、これをスイッチで分けることにした
  #
  #優先順 :: 優先順で割り付ける
  #優先順尊重 :: 尊重するが絶対ではない
  #
  #以下の考え方は尊重モードでの考え方を説明する。
  #
  #====考え方
  #* 同じ製品の連続をラウンドととらえ、この単位で割り付ける
  #* 複数のラウンド群の中から、次に割り当てるべきラウンドを選ぶ( Function::Optimize#optimaize)
  #選び方もいくつか検討したが、現在の採用は以下
  #1. ラウンドを東西抄造、原新乾燥の組み合わせの4つにわける。
  #2. 直前の割付の結果、原新で先に空く乾燥ラインを選ぶ。
  #3. 選んだ乾燥ラインの東西抄造の各々先頭のロットを仮に割付てみる 
  #   Function::SkdHelp#temp_assign_maint_plan
  #4. 早く抄造が終わる方のラウンドに決める。
  #  
  #早く空く乾燥ラインを選ぶ理由、先に「始まる」ではなく「終わる」抄造を選ぶ理由
  #については、Function::Ubeboard::Optimize#optimaize を参照されたし。
  #  新乾燥を使うラウンドが続いた後で原乾燥を使うラウンドが来ると
  #  それまでに抄造が埋まってしまうため、原乾燥に大きな空きが
  #  できてしまうことが有る
  #* 先に「始まる」ではなく「終わる」抄造を選ぶ理由
  #  西原の12Fは抄造時間が乾燥時間より非常に長い。
  #  これが続くと乾燥機でロット間の待ち時間が発生してしまう。
  #  これを減らすには12Fは溜めてから乾燥に流すのがよい。
  #  少々遅く始まっても先に抄造が終わる品種を先に乾燥に回すように
  #  する。
  #
  #====手順
  #1. 完了 0 仕掛かり[1] の実績を割り付ける(空き時間から削除する)。
  #   assign_if_resulted。この中で、sorted_plan,freeListの初期化も行われる
  #2. 仕掛かりを終わらせる procceed_stock
  #3. 品種毎の総生産量を求める。これを残り生産量の初期値とする
  #   そのとき製造数を規格化(基準製造量のx0.75,1.00,1.25)する。四捨五入  #
  #4. 優先順モード もしくは 尊重モード で割り付ける。 assign_plans
  #5. 養生庫割り当ての問題で、作り損なったものあれば、それを作る。
  def make_plan7
    logger.info("INFO:#{Time.now.strftime '%Y/%m/%d-%H:%M'}:START MAKE_PLAN")
    #完了 0 仕掛かり[1] の実績を割り付ける
    assign_if_resulted#

    #├ 仕掛かりを終わらせる

    procceed_stock

    logger.info("INFO:#{Time.now.strftime '%Y/%m/%d-%H:%M'}:FINISH procceed_stock")

    debug " procceed_stockの後"

    ####品種毎の総生産量を求める。これを残り生産量とする
    ####  そのとき製造数を規格化する。四捨五入
    ####  最後のロットのサイズは要修正
    ###              製造する毎に減らす。
    sum=sum_of_product #Hash.new{|h,k| h[k] = 0}
    #sorted_plan[2].each{|plan| sum[plan.ube_product_id] += plan.mass}
    sorted_plan[2].each{|plan| plan.mass = plan.n_mass * plan.ube_product.lot_size rescue plan.mass}

    #ロット番号振り直しの準備
    [:shozoe,:shozow].each{|shozo| max_lot[shozo]=@lot_no[shozo]}

    #優先順モード
    logger.debug " 優先順モード #{ @jun_only }"
    if @jun_only
      @log=true
      assign_plans(sorted_plan[2],sum)
    #尊重モード
    else
      while (plans = optimize) #true 
        #break unless (plans = optimize) #(grouped_plan))
        @log=true
        logger.info("INFO:#{Time.now.strftime '%Y/%m/%d-%H:%M'}:==== START ===== 割付開始 \n\t#{plans.map(&:lot_no).join(' ')}")
        assign_plans(plans,sum)
      end #of while
    end #of if @jun_only
    logger.info("======= 養生庫割り当ての問題で、作り損なったものありや ")
    return

  end #of argo=7

  ######################################################

  #実績があったら割り付ける。時刻は実績を用いる
  #1. 開始のみで終了が無い場合は終了時間を計算して入れる
  #2. 養生庫の空き時間を,設定する。
  #稼働累積を計算する
  def assign_if_resulted
    Ope.each{|ope| 
      sorted_resulted_plans(ope).each{|plan|
        real_ope = plan.real_ope(ope)
        next unless plan[PlanTimes[real_ope][0]]  #結果が入っていなければ無視
        #開始時間,終了時間
        from =  plan[PlanTimes[real_ope][2]]   || plan[PlanTimes[real_ope][0]] 

        #終了時間を得る
        #この工程に実績があればそれを用いる。
        #無いときは予定を用いる。
        ope_length=plan.ope_length(ope)
        errors.add(:nil,ope_length[2]) if ope_length[2]
        to = ope_to_time(plan,real_ope)

        #乾燥の場合は養生の空き時間設定
        #　養生庫空き時間は乾燥の終了。ただし型板は養生の終了
        #　　乾燥の実績がないものは、仕掛かりの処理で行う
        if ope == :dry && !plan.hozen? || ope == :yojo && plan.condition == "型板"
          logger.info("assign_if_resulted #{plan.lot_no} #{plan.id} #{plan.yojoko}")
          #yojoko[plan.yojoko].assign(plan,to) #next_start to
          plan.yojoKo.assign(plan,to) #next_start to
        end
        #空き時間テーブルから割り当てる
        #assign_resulted(plan,plan.real_ope(ope),plan[result_from],to)
        logger.info("     assignFreeList #{real_ope} #{from.mdHM} #{to.mdHM}") if real_ope == :dryo
        freeList[real_ope].assignFreeList(from,to) 

        if plan.hozen? #/^A\d\d/ =~ plan.lot_no #保守
          #これが最後の仕掛・完了保守だと、この後の製品の前に再び割り当てられる
          #　ことがありえる。なので、時間ゼロとして、再割り当てを防ぐ。
          #pre_condition[real_ope] = nil
          #保守日設定
          hozen_date[real_ope] = (to-8.hour).day if %w(A02 A03 A06 A08 A09 A10 A11 A12).include?(plan.lot_no)
          reset_running(plan.lot_no,real_ope,from,to) if %w(A08 A10 A13).include?(plan.lot_no)
        else
            plan_set(plan,real_ope,[from,to])
          #end
          pre_condition[real_ope] = plan if pre_condition[real_ope][PlanTimes[real_ope][1]] < plan[PlanTimes[real_ope][1]]
        end         
      }
    }
  end

  def sorted_resulted_plans(real_ope)
    plan_from,plan_to,result_from ,result_to = PlanTimes[real_ope]
    sorted_plan[0..1].flatten.select{|plan| plan.real_ope?(real_ope) && plan[plan_from]
    }.sort_by{|plan| plan[plan_from]}
  end

  def ope_to_time(plan,real_ope)
    ope_length=plan.ope_length(real_ope)
    errors.add(:base,ope_length[2]) if ope_length[2]
    if    plan[PlanTimes[real_ope][3]]; plan[PlanTimes[real_ope][3]] 
    elsif plan[PlanTimes[real_ope][2]]; plan[PlanTimes[real_ope][2]] +plan.ope_length(real_ope)[0]
    elsif plan[PlanTimes[real_ope][1]]; plan[PlanTimes[real_ope][1]] 
    elsif plan[PlanTimes[real_ope][0]]; plan[PlanTimes[real_ope][0]] +plan.ope_length(real_ope)[0]
    else                    ; nil
    end
  end

  #1ロット割り付ける。
  #
  #1. 仮時間を押さえる
  #   このとき、前置き、後置きの時間が超過しないか調べ、超過していたら調整されている
  #2. 仮時間で割り付ける
  #3. 養生庫をassign(空き時間を更新)する
  #
  #params
  #[shozoDone = nil] trueのときは養生から割り付ける。仕掛品の処理の時に使う。
  #戻り値
  #  true  正常終了
  #  数値  休日前打ち切り、最終ロットの製造数量
  #  0     休日前打ち切り。最終ロットの製造数量零。つまり最終はこの一つ前
  #  nil   割付失敗

  def assign_temp_and_real(plan,shozoDone = nil )
    logger.debug(" assign_temp_and_real id=#{plan.id} done? :#{plan.rate[:kakou]} :#{plan.plan_dry_to}") if plan.id==11435
    logger.debug(" assign_temp_and_real id=#{plan.id} done? :#{plan.rate[:kakou]} :#{plan.plan_dry_to}") if plan.id==11667
    #正常終了の戻り値
    ret = true

    logger.info("ASSIGN #{plan.id} #{plan.lot_no}========================")
    #抄造 養 乾燥の時間を仮に確保。養生庫はもう決まっている
    #shozo,yojo,dry,wait = temp_assign_all_plan(plan,shozoDone)
    shozo,yojo,dry  = temp_assign_all_plan_check_biyond_holyday(plan,shozoDone)

    return nil if !shozo && !shozoDone
    return 0   if shozo == 0

    #loggerのために仮に設定した plan_shozo_from を削除する
    plan.plan_shozo_from=nil unless shozoDone

    #logger.debug("assign_temp_and_real PRO_IDS #{shozo[0][2]}") if shozo
    #時間が確保できたので、割り付ける
    msg="==== ASSIGN 製造割付 == #{plan.lot_no}(#{plan.id}) "
    assign_maint_plan_by_temp(plan,plan.shozo?,shozo) if shozo && !shozoDone
    msg += "抄造 #{plan.plan_shozo_from.mdHM}- #{plan.plan_shozo_to.mdHM} " if shozo && !shozoDone
    assign_maint_plan_by_temp(plan,:yojo,yojo) if yojo
    logger.debug(" id=#{plan.id} Yojo END") if plan.id==11435
    if ! plan.done? && dry #.missing?
      assign_maint_plan_by_temp(plan,plan.dry?,dry)  #  if ! plan.done? && !dry.missing?
      
      msg += "乾燥 #{plan.plan_dry_from.mdHM}- #{plan.plan_dry_to.mdHM} " #  if ! plan.done? && !dry.missing?
      if ! plan.done?# && !dry.missing?
        assign_kakou(plan) 
        msg += "加工 #{plan.plan_kakou_from.mdHM}- #{plan.plan_kakou_to.mdHM} "  if plan.plan_kakou_from
      end
    end
    msg += "\n=================================================="

    #養生庫を設定する。
    #乾燥が割り当て失敗してるときは、今月はこの養生庫はあかない
    #  一月くらい先までふさがってることにしておく
    plan.yojoKo.assign(plan, plan.plan_dry_end ? plan.plan_dry_end : time_to + 1.month)

    logger.info(msg)
    
    #正常終了
      @first_lot = false
    ret
  end

  #Ubeboard::Plan の集合を割り付ける
  #1. 養生庫を割り当てる。 Function::Ubeboard::SkdHelp#get_yojoko
  #2. 割り付ける assign_temp_and_real
  def assign_plans(plans,sum)
    @first_lot = true
    plans.each_with_index{|plan,idx|
      logger.info("==== #{plan.lot_no} #{plan.meigara}====")
      unless (msg=plan.ube_product_error?)==""
          errors.add(:nil,msg)
          logger.info("ERROR: #{Time.now.strftime('%Y/%m/%d-%H:%M')}:#{msg}")
        next
      end
      mod = 0.0
      logger.info("==== #{plan.lot_no} #{plan.meigara}====")
      #養生庫を割り当てる
      #養生庫の量が大きければ、残り生産量を作る。ただし MassMin より少なければ MassMin
      return unless yojoKo = get_yojoko(plan,mod)
      debug("割付開始時") if plan.lot_no == "1M0600"
      plan.yojoKo = yojoKo#.no
      plan.mass_calculate_by_yojoko_size_or_MassMin(sum)
      #1ロット割り付ける
      unless ret = assign_temp_and_real(plan)#,yojoKo)
        clear_jun_renumber_lot_when_passed(plans[idx..-1])
        return nil
      end
      plan.jun = (@junsave += 10)
      #plan.lot_no = (max_lot[plan.shozo?]=max_lot[plan.shozo?].succ)
      sum[plan.ube_product_id] =  
      sum[plan.ube_product_id] - plan.mass > 0 ? sum[plan.ube_product_id] - plan.mass  : 0

      if  ret.class == Fixnum
        rest = plans.size - idx
        msg = "Info: 休日前に[#{plan.proname}]のラウンドが抄造完了せず。"
        msg += "残り#{plans.size-idx}ロット、" if rest > 0
        msg += ret > 0 ? "｢#{plan.lot_no}｣で打ち切り。製造数量 #{plan.mass} ～#{plan.plan_shozo_to.mdHM rescue ''}" :
          "｢#{pre_condition[plan.shozo?].lot_no}｣で打ち切り。～#{pre_condition[plan.shozo?].plan_shozo_to.mdHM  rescue ''}"

        logger.info msg
        errors.add(:nil,msg)

        clear_jun_renumber_lot_when_passed(plans[(ret>0 ? idx+1 : idx)..-1])
        return nil
      end
    }
    return true
  end #of assign_plans

  def clear_jun_renumber_lot_when_passed(plans)
    first_lot_no = plans.first.lot_no
    lot_no = first_lot_no.dup
    logger.info("=== 休日飛ばしによるlot_no付けなおし\n"+
                "    飛ばされるplan　=> " + plans.map{|plan| " [#{plan.lot_no} #{plan.id}] "}.join
                )
    plans.each{|plan|       plan.jun=nil;       plan.lot_no = ""    }
    renum_plans = 
      grouped_plan_shz[plans.first.shozo?].flatten.
      select{|plan| plan.lot_no >= first_lot_no }.
      sort_by{|plan| plan.lot_no}
    logger.info("    詰められたplanの先頭=>"+
                renum_plans[0,3].map{|plan| " [#{plan.lot_no} #{plan.id}] "}.join
                )
    renum_plans.each{|plan| plan.lot_no = lot_no; lot_no = lot_no.succ}
  end

  def sum_of_product
    sum=Hash.new{|h,k| h[k] = 0}
    sorted_plan[2].each{|plan| sum[plan.ube_product_id] += plan.mass}
    return sum
end

  #アルゴリズム7
  # 考え方
  #  1 片方の抄造の優先順が高いとき、抄造も乾燥も空いていても
  #    養生がふさがってしまうときが有る。
  #　   優先順をあげれば良いのだがこれを自動化したい。
  #  
  #　 2 それを行うために、優先順は抄造毎とする。
  #  3 東と西と仮割り付けして、早く抄造できるラウンドを先に行う。
  #
  # 懸念
  #  　上記ルールでは西を先に抄造するが、乾燥は東の製品を先に、
  #    というケースがあるだろうか。有るとしたらそれに対応可能か？
  #    ↓
  #    あった。７のままでは救済は無いようだ
  #
  #
  # 手順
  #   ラウンド毎にまとめたplansを東西に振り分ける。
  #   東西から先頭のラウンド、ロットを選び抄造を仮押さえして
  #   東西どちらが先になるか調べ、早い方を採用する
  #
  #

  #アルゴリズム7改
  #　優先順モードと優先順尊重モードの二つを用意する
  #　優先順モードは優先順に割り付ける
  #  尊重モードは、抄造の早い方を先に割り付け、
  #  その順で優先順を書き直す。
  #  尊重モードを初期値とし、チェックボックスで状態を管理し
  #  変更状態を維持する。DBにも残すか？
  #  尊重モードは「乾燥待ちで抄造が待たされるときは、順を変える」
  #  も取り込むか？スイッチでやるか？
  #
  #




  def debug(msg="")
    #debug 出力　freeList,pre_condition,yojo
    logger.info("freeList #{msg}")
    [:shozow,:shozoe,:yojo,:dryo,:dryn,:kakou].each{|real_ope|
      logger.info("#{real_ope}\n"+freeList[real_ope].map{|f,t| "#{f.mdHM} - #{t.mdHM}" }.join("  ")
)
    }
    logger.info("freeList hozen #{msg}")
    [:shozow,:shozoe,:yojo,:dryo,:dryn,:kakou].each{|real_ope|
      logger.info("#{real_ope}\n"+freeList[real_ope].hozenFree.freeList.map{|f,t| "#{f.mdHM} - #{t.mdHM}" }.join("  ")
)
    }


    logger.info("pre_condition #{msg}: \n" +
                 "\t\t:shozow\t\t:shozoe\t\tyojo\t\t:dryo\t\t:dryn\t\t:kakou")
    logger.info("\tLotNo\t"+[:shozow,:shozoe,:yojo,:dryo,:dryn,:kakou].map{|real_ope|
                   pc = pre_condition[real_ope] ;
                   pc ? pc.lot_no : "      "
                 }.join("\t\t")
                 )
    logger.info("\t終了\t"+[:shozow,:shozoe,:yojo,:dryo,:dryn,:kakou].map{|real_ope|
                  pc = pre_condition[real_ope] 
                  time = pc[PlanTimes[real_ope][1]]
                  time ? time.mdHM : "../..-..:.."
                 }.join("\t")
                 )

  end
  def debug_yojo(msg)
    logger.debug("養生庫 #{msg}: \n" +"")
    (2..24).step(6).each{|i|  j = i>19 ? 24 : i+5
      logger.debug( "\t養生庫No\t"+(i..j).map{|k| k }.join("\t\t") +
                    "\n\tlot_no\t\t"+(i..j).map{|k| yojoko[k].plan.lot_no rescue "      " }.join("\t\t") +
                    "\n\tnext_start\t"+(i..j).map{|k| 
                      yojoko[k].next_start.mdHM rescue "../..-..:.."}.join("\t")
                    )
    }
  end

  #立案開始日を設定する。
  #
  #年がskd_fromと異なる場合はそれに合わせる
  def set_replan_from(date)
    if date.blank? ; self.replan_from = skd_from
    else
      self.replan_from = Time.parse(date)
      self.replan_from -= (replan_from.year - skd_from.year).year
      logger.debug("### set_replan_from = #{date} #{self.replan_from}")
    end
  end


  def set_yojoKo_object
    ube_plans.each{|plan| plan.yojoKo = yojoko[plan.yojoko] if yojoko[plan.yojoko] }
  end

  def temp_assign_all_plan_check_biyond_holyday(plan,shozoDone)
    shozo,yojo,dry,wait = temp_assign_all_plan(plan,shozoDone)
    return nil if !shozo && !shozoDone

    if wait && !@first_lot  # 前置き超過で抄造を遅らせるのは最初のロットに限る
      msg = "Info: #{plan.proname}]のラウンド #{pre_condition[plan.shozo?].lot_no}の次の順だった　ID#{plan.id}) が前置き時間超過になり抄造を遅らせる必要があるので"
      msg += "抄造をやめ、次のラウンドに移ります。ラウンド終了 #{pre_condition[plan.shozo?].plan_shozo_to.mdHM}"

      logger.info msg
      errors.add(:nil,msg)
      return  nil
    end
      # 抄造開始が前のロットのあと休日を挟んだかどうかみる
      # だったら休日前に作れる量だけにして時間取り直す
      # ただし 優先順の場合とラウンド最初のロットの場合はここはパス
    logger.debug("  temp_assign_all_plan_check_biyond_holyday: "+
                 "#{pre_condition[plan.shozo?].plan_shozo_to.mdHM}->#{shozo[1][0].mdHM}"+
                 ":@jun_only=#{@jun_only} @first_lot=#{@first_lot}"
                 )
    return [shozo,yojo,dry,wait] if @jun_only || @first_lot || 
      !(bh=biyond_holyday?(plan.shozo?,pre_condition[plan.shozo?].plan_shozo_to,shozo[1][0]))

    # 残り時間がない時は帰る
    return nil unless rest = freeList[plan.shozo?].rest_time(pre_condition[plan.shozo?].plan_shozo_to)

    restlength = ((rest[1] - rest[0] - (shozo[0][1]-shozo[0][0]))/Round).to_i*Round #休日前残り時間。
    new_mass = (restlength * plan.unit_time[:shozo]/1.hour).to_i

    logger.info("==INFO 休日前：最低 最小数量までの製造"+
                 "assign_temp_and_real:#{plan.lot_no} "+
                 "抄造前ロット終了 #{pre_condition[plan.shozo?].plan_shozo_to.mdHM} "+
                 "抄造割付開始時間 #{shozo[1][0].mdHM} 休日前残り時間 #{restlength/60}分"+
                 " 製造可能数量 #{new_mass}")
    case bh
    when 4
      shozo_maint,shozo_plan = shozo
      ope_length = shozo_plan[1]-shozo_plan[0]
      offset = shozo_maint[0] - pre_condition[plan.shozo?].plan_shozo_to
      shozo_maint[0] = pre_condition[plan.shozo?].plan_shozo_to
      shozo_maint[1] = shozo_plan[0] = shozo_maint[1] - offset
      shozo_plan[1]  = shozo_plan[0]+ope_length + (24.hour-unkyu(plan.shozo?))
      shozo = [ shozo_maint,shozo_plan]
      shozo,yojo,dry,wait = temp_assign_all_plan(plan,[[],shozo_plan])
      if dry
        logger.info("==INFO 運休を挟んで抄造する 抄造 #{shozo_maint[0]}-#{shozo_maint[1]}/#{shozo_plan[0]}-#{shozo_plan[1]} "+
                    "#{yojo[1][0]}-#{yojo[1][1]},#{dry[1][0]}-#{dry[1][1]}")
      else
        logger.info("==INFO 運休を挟んで抄造する 抄造 #{shozo_maint[0]}-#{shozo_maint[1]}/#{shozo_plan[0]}-#{shozo_plan[1]} "+
                    "#{yojo[1][0]}-#{yojo[1][1]},乾燥割り当て失敗")
      end
      return [[shozo_maint,shozo_plan],yojo,dry]

   else
    # 残り時間がある程度あれば作る、
    return 0 if new_mass < masslimit
    logger.debug("===================== biyond_holyday? #{bh}")
 
      plan.mass = mass = new_mass
      shozo,yojo,dry,wait = temp_assign_all_plan(plan,shozoDone)

      return nil if wait
      return [shozo,yojo,dry] #,mass]
    end
  end

  ##実績があり、計画がないものは計画にコピーする
  ##実績がないときは計画は消す
  ##結果、計画があったら割り付ける

  #保守、切り替え時間を削除する。ただし、実績が入っているものと
  #立案開始日より前のものは残す
  def delete_hozen_ubeplan_unless_resulted
    hozens_not_resulted = ube_plans.select{|plan|
      Reuslts.map{|sym| plan[sym] }.compact.size ==0 && plan.hozen?
    }
    hozens_planed_after_replan_from = hozens_not_resulted.select{|plan|
     (PlanStartSym.map{|sym| plan[sym] }.compact.max || skd_to )> replan_from 
    }
    ids = hozens_planed_after_replan_from.map(&:id)
    #関連の削除
    ube_plans.delete(hozens_planed_after_replan_from)

    # DBからの削除
    attribute = Hash[*PlanTimes.values.flatten.uniq.map{|sym| [sym,nil]}.flatten].
      merge(:ube_product_id => 0,:lot_no => "", :mass => 0)
    Ubeboard::Plan.update(ids,[attribute]*ids.size)

    ids
  end

  #実績があり、計画がないものは計画にコピーする
  #実績がなくかつ立案開始日より遅いときは計画は消す
  def copy_result_to_plan_or_eraze_plan
    ube_plans.each{|plan| 
      Ope.each{|ope| plan_f,plan_to,result_from ,result_to = PlanTimes[ope]
        [[plan_f,result_from],[plan_to,result_to]].each{|pln,rslt|
          case [!! plan[pln],!! plan[rslt]] 
          when [false,true] ; plan[pln] = plan[rslt] 
          when [true,false] ;                       
            logger.debug("####{plan.id} plan.plan_shozo_from = #{plan.plan_shozo_from} replan_from #{replan_from} ###")
            plan[pln] = nil if !plan.plan_shozo_from || 
              plan[pln] >= (self.replan_from || self.skd_from)
          end
        }          
      }
      logger.debug("copy_result_to_plan_or_eraze_plan:id=#{plan.id} #{plan.plan_kakou_from}") if plan.id == 11435
    }
  end
  def  set_status_done_if_done
      ube_plans.each{|plan| 
        if  plan[:result_kakou_to] && plan[:result_kakou_to]  ||
            plan[:result_dry_to]   && (plan.rate[:kakou]==0.0 || plan.rate[:kakou].blank?) ||
            plan[:result_yojo_to]  && plan.condition == "型板"            
          plan.current :done
        end
      }
  end


      #完了は、:done と 保守
      #完了の 順
      #one = ube_plans.select{|plan| 
      # plan.next_ope == :done || plan.mass == 1
      #.sort{|a,b| 
      #   (a.plan_shozo_from.nil? ? (b.plan_shozo_from.nil? ? 0 : 32) : (b.plan_shozo_from.nil? ? -32:0)) + 
      #   (a.plan_shozo_from.to_i   <=>  b.plan_shozo_from.to_i) * 16 +
      #   (a.plan_dry_from.to_i   <=>  b.plan_dry_from.to_i) * 4 +
      #   (a.plan_kakou_from.to_i   <=>  b.plan_kakou_from.to_i) * 1
      #
      #仕掛かりは、抄造の開始実績ありかつ完了ではないもの
      #tock = ube_plans.select{|plan| 
  #plan.result_shozo_from && plan.next_ope != :last_month
      # plan.result_shozo_from && !plan.result_done?
      #   
      #####新規 #####
      #抄造の開始実績がないなら新規
  def sort_by_status
    done = ube_plans.select{|plan| 
        plan.next_ope == :done || plan.mass == 1
      }.sort{|a,b| 
          (a.plan_shozo_from.nil? ? (b.plan_shozo_from.nil? ? 0 : 32) : (b.plan_shozo_from.nil? ? -32:0)) + 
          (a.plan_shozo_from.to_i   <=>  b.plan_shozo_from.to_i) * 16 +
          (a.plan_dry_from.to_i   <=>  b.plan_dry_from.to_i) * 4 +
          (a.plan_kakou_from.to_i   <=>  b.plan_kakou_from.to_i) * 1
      }
      stock = ube_plans.select{|plan| 
        plan.result_shozo_from && !plan.result_done?
      } - done 
      wait = (ube_plans.select{|plan| plan.current.nil? } - stock).sort{|a,b| 
        case [!!a.jun,!!b.jun]
        when [true,true] ; a.jun <=> b.jun
        when [true,false]; -1 
        when [false,true]; 1
        else ; a.id<=> b.id
        end
      }
    [done,stock,wait]
  end
end
class Time
  def mdHM ;  strftime("%m/%d-%H:%M") ;end
  def max(a,b) ; a > b ? a : b ; end
  def ube_date ;(self - 8.hour).day ; end
  #def inspect;strftime("%m/%d-%H:%M");end
end
class Float
  def marume(r) ;    (self.to_i.to_f/r).ceil*r;  end
  def hm;    h=self.to_i/3600; m= (self.to_i%3600)/60; "%02d"%h + ":%02d"%m;  end
end

class Fixnum
  def marume(r);    (self.to_f/r).ceil*r;  end
  def hm       ;    h=self/3600;    m= (self%3600)/60; "%02d"%h + ":%02d"%m ;  end
end

__END__
$Id: ube_skd.rb,v 2.76 2012-11-24 11:58:36 dezawa Exp $
