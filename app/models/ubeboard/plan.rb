# -*- coding: utf-8 -*-
require 'jcode'
# == 製造ロットの情報(UbePlan)
# UbeSkdに habm される。
#   完了しなかったロットや、完了していても各工程の最終製品である場合は
#   次月度の製造計画の UbeSkd に取り込まれる。
# UbeProduct をhas_one する
#
# jun  :: 製造順。これを変更して再立案することで最適化する
# lot_no  :: 
# mass  :: 製造枚数
# ube_product_id  :: 製造条件へのリンク
# meigara  :: 銘柄。通常同じ品種間での切り替えは５分だが、同じ品種でも銘柄が異なると切り替え時間が変わるものもある
# yojoko  :: 養生庫の番号
# plan_shozo_from  :: 抄造開始予定日時
# plan_shozo_to  :: 
# plan_yojo_from  :: 
# plan_yojo_to  :: 
# plan_dry_from  :: 
# plan_dry_out   :: 最初の1枚が乾燥機から出てくる時間　乾燥工程固有
# plan_dry_end   :: 最後の１枚を乾燥機に投入する時間　　乾燥工程固有
# plan_dry_to  :: 
# plan_kakou_from  :: 
# plan_kakou_to  :: 
# result_shozo_from  :: 抄造開始実績日時
# result_shozo_to  :: 
# result_yojo_from  :: 
# result_yojo_to  :: 
# result_dry_from  :: 
# result_dry_to  :: 
# result_kakou_from  :: 
# result_kakou_to  :: 
class UbePlan < ActiveRecord::Base
  extend Function::LipsToUbePlan
  extend Function::CsvIo

  belongs_to   :ube_product
  #belongs_to   :ube_skd
  has_and_belongs_to_many  :ube_skd


  #attr_accessible :jun               ,:lot_no            ,:ube_product_id    ,:mass
  #attr_accessible :plan_shozo_from   ,:plan_shozo_to     ,:plan_yojo_from    ,:plan_yojo_to     
  #attr_accessible :plan_dry_from     ,:plan_dry_to       ,:plan_dry_out      ,:plan_dry_end
  #attr_accessible :plan_kakou_from   ,:plan_kakou_to    
  #attr_accessible :result_shozo_from ,:result_shozo_to   ,:result_yojo_from  ,:result_yojo_to   
  #attr_accessible :result_dry_from   ,:result_dry_to     ,:result_kakou_from ,:result_kakou_to  
  #attr_accessible :meigara,:yojoko

  attr_reader     :yojoKo


  def after_find
    extend ThreeByTen if _3by10?
    extend ShozoW     if  shozo_w?
    lot_no = "" unless lot_no
  end
  def before_save
    lot_no = "" unless lot_no
  end
  def yojoKo=(yojoko_object)
    self.yojoko = yojoko_object.no
    @yojoKo =yojoko_object
  end

  def self.real2ope(real_ope)
    case real_ope
    when :shozow,:shozoe,:shozo ;:shozo
    when :dryo,:dryn,:dry; :dry
    else ; real_ope
    end
  end

  
  def self.make_plans_from_params(params)
    [params.map{|id,param|  UbePlan.new(param)  } ,[]]    
  end



  # 抄造から養生、養生から乾燥の時間が長すぎるとき、エラーをだす。
  def after_find2
    #if lot_no && /A\d{2}/ !~ lot_no && !!plan_dry_from && !! plan_shozo_to && 
    if  !hozen?              && !!plan_dry_from && !! plan_shozo_to && 
        plan_yojo_to && plan_yojo_from &&
        (plan_dry_from - plan_yojo_to > 24.hour || plan_yojo_from - plan_shozo_to > 72.hour)
      too_late_dry(true)
      errors.add(:plan_dry_from,self.lot_no)
    end
    mass ||= 1.0
    errors.add(:plan_shozo_from,self.lot_no) if lot_no != "" && !plan_shozo_from && !hozen?
  end


  #同一品種でも銘柄が異なると切り替え時間が長くなるものがある。その品種。
  $Meigara = %w(12F 12普及 12高級 15高級 16高級)

  # 製品名を返す
  def proname
    @proname ||= if ube_product_id ; self.ube_product.proname
                 else
                   ube_product_error? if ube_product_id
                   ""
                 end
  end

  def ope_condition_id
    @ope_condition_id ||= ube_product.ope_condition_id
  end
   # このロットの品種を返す
  def condition
    @ope_condition ||= ube_product.ope_condition rescue ""
  end

   # このロットの製造速度(を表すUbeOperation)を返す。
  def rate
    @rate ||= UbeOperation.find_by(ope_name: condition)
  end
  def lot_size;  @lot_size ||=  ube_product.lot_size ;end
  def copy; @copy ||= nil ; end
  def delete;@delete ||= nil ;end
  #抄造・加工の時産(枚/時)、乾燥の滞留

  # 製品が指定されていなかったり、製品の登録が無い場合にエラー
  def ube_product_error?
    if ! ube_product_id
      msg = "#{self.lot_no}の製品が未入力です"
    elsif ! ube_product
      msg = "ID=#{ube_product_id}の製品登録がありません"
    else
      msg =""
    end
    msg
  end

  # Nomalized mass 養生庫の大中小により 1.25, 1.00, 0.75を返す。
  def n_mass(v=nil)
      unless ube_product_id
        ube_product_error?
        @n_mass =1.0
      else
        n = (4.0 * mass / lot_size).round
        @n_mass = 0.25 * (n <3.0 ? 3.0 : (n > 5.0 ? 5.0 : n ))
      end
    @n_mass = v if v
    @n_mass     
  end

  #削除可能かどうかみる。実績が入力されていないこと。
  def deletable?
    !(result_shozo_from || result_yojo_from || result_dry_from || result_kakou_from)
  end

  # time_sym :  plan_to, plan_from
  def plans(real_ope,time_sym) 
    ope = UbePlan.real2ope(real_ope)
#pp PTime[[ope,time_sym]]
    self[PTime[[ope,time_sym]]]
  end

  Times = {:shozo=>[:plan_shozo_from,:plan_shozo_to],
    :shozow=>[:plan_shozo_from,:plan_shozo_to],
    :shozoe=>[:plan_shozo_from,:plan_shozo_to],
    :yojo=>[:plan_yojo_from,:plan_yojo_to],
    :dry=>[:plan_dry_from,:plan_dry_to,:plan_dry_out,:plan_dry_end],
    :dryo=>[:plan_dry_from,:plan_dry_to,:plan_dry_out,:plan_dry_end],
    :dryn=>[:plan_dry_from,:plan_dry_to,:plan_dry_out,:plan_dry_end],
    :kakou=>[:plan_kakou_from,:plan_kakou_to]
  }

  
  tt=Hash.new
  # { [:shozo,:plan_from] => :plan_shozo_from }
  UbeSkd::Ope.each{|ope| %w(plan result).each{|p_r| %w(from to out end).each{|t|
          tt[[ope,"#{p_r}_#{t}".to_sym]] = "#{p_r}_#{ope}_#{t}".to_sym
      }}}
  # 
  PTime = tt

  # PDFに使う値を計算しておく
  def pdf_value(ope = nil)
    unless @pdf_value
      @pdf_value = Hash.new{|h,k| h[k]=self[k] rescue ""}
      @pdf_value[:lot_no]=  lot_no
      @pdf_value[:name]  = meigara.blank? ? proname : meigara
      @pdf_value[:maeoki]= "%4.1f" % ((plan_yojo_from - plan_shozo_to - (shozo_w? ? 60 : 30).minute)/60.minute) rescue ""
      @pdf_value[:atooki]= "%4.1f" % ((plan_dry_from - plan_yojo_to)/60.minute) rescue ""
      @pdf_value[:mass]=mass
      @pdf_value[:yojoko]=yojoko
      #@pdf_value[:date]  = (self[plan_to]-8.hour).day
      #@pdf_value[:space] = sprintf( "%5.0f",(self[plan_from]-last_to)/60) rescue " ----"
      UbeSkd::PlanTimesSym.each{|sym| @pdf_value[sym]=(self[sym].strftime("%H:%M") rescue " ----")}
      [:plan_yojo_from,:plan_yojo_to].each{|sym| @pdf_value[sym]=(self[sym].strftime("%d %H:%M") rescue " ----")}
    end
    @pdf_value
  end

  def date(time=nil)
    @date = (time - 8.hour).day if time
    @date
  end

  # 予定から実績にコピーする
  #  ただし次の場合はコピーしない
  #    抄造の開始実績が入っている場合は全ての実績
  #    抄造の実績が無くても、開始実績が既に入っている工程以降
  #    開始実績が無くても、終了実績が入っているところ
  # 没
  #  ただし、既に入力された実績があったら、それ以降の工程はコピーしない
  def copy_results
    return if result_shozo_from
    %w(shozo yojo dry kakou).each{|ope| 
      %w(from to).each{|ft|  return self if self["result_#{ope}_#{ft}"]
        self["result_#{ope}_#{ft}"] = self["plan_#{ope}_#{ft}"]
      }
    }
    self
  end

  #指定された工程の開始予定、終了予定を設定し、「現工程」を設定する。
  #<tt>ope</tt> :: 工程もしくは実工程
  #<tt>times</tt> :: 計画の [開始、終了、乾燥のout、乾燥の end]
   def set_plan(real_ope,times)
     ope = UbePlan.real2ope(real_ope)
     self[PTime[[ope,:plan_from]]]= times[0] ;    self[PTime[[ope,:plan_to]]] = times[1]
     if  ope == :dry #times.size>2        period,stay,err = ope_length(real_ope)
       period,stay,err = ope_length(real_ope)
       self[PTime[[ope,:plan_out]]] =  plan_dry_out || times[0] + stay ;    
       self[PTime[[ope,:plan_end]]] =  plan_dry_end || times[1] - stay
     else
       self[PTime[[ope,:plan_out]]] = times[0]    
       self[PTime[[ope,:plan_end]]] = times[1]
     end
     # 型板の養生の場合は、養生終了が養生庫の空きだから、その計算のために 
     #  養生終了時間を乾燥搬入終了時間に入れる
     if condition == "型板" && ope == :yojo
       plan_dry_end = times[1]
     end
     logger.debug("set_plan: #{lot_no} #{ope} #{times.map(&:mdHM).join('|')}")
     #logger.debug("set_plan: #{lot_no}  #{plan_shozo_from.mdHM} #{plan_shozo_to.mdHM}") #if UbeSkd::Lot.include?(lot_no)

    current ope
   end

   def mass_calculate_by_yojoko_size_or_MassMin(sum)
      real_mass = @lot_size * yojoKo.size
      if real_mass <= sum[ube_product_id]
        mass = real_mass
        #sum[plan.ube_product_id] -= real_mass
      else
        mass =  sum[ube_product_id] >= UbeSkd::MassMin ? sum[ube_product_id] : UbeSkd::MassMin
        #sum[plan.ube_product_id] = 0
      end

   end

   #現工程（つまり今割り付けている工程の一つ前）の終了時間
   # 戻り値
   #   製造開始前は nil
   def current_to
     times= Times[self.current]
     logger.info("UbePlan#current_to:: #{lot_no} current='#{current}' #{disptime}")
     plans(current,:plan_to)
   end


   # この real_ope はself(このロット)が使う実工程か否か
   def real_ope?(real_ope)
     case real_ope
     when :shozow  ; shozo_w?
     when :shozoe  ; shozo_e? ; 
     when :dryo  ; dry_o?  
     when :dryn  ; dry_n?
     else ;true
     end
   end

   # このロットは製品なのか、表示用に用いる偽製品(保全・切り替え)なのか。



  # この製品が 東西抄造、原新乾燥か を返す。加工はその判断を行う必要はないが、
  # UbeSkd#make_plan の中で加工を特別扱いしないために、kakou? も定義する

  #この製品の抄造が東西どちらのラインかを返す
  def shozo?   ;    shozo_w? ? :shozow : :shozoe ;end

  #この製品の乾燥が、原新どちらのラインかを返す
  def dry?   ;    dry_o?   ? :dryo : :dryn ;end

  #この製品の加工ラインを返す。
  #加工では必要はないが、
  # UbeSkd#make_plan の中で加工を特別扱いしないために、加工も定義する
  def kakou?   ; :kakou ;end
  def yojo?    ; :yojo  ; end
  def shozo_w? ;  @shozo_w ||= ube_product &&  self.ube_product.shozo == "西抄造" ;end
  def shozo_e? ;  @shozo_e ||= ube_product &&  self.ube_product.shozo == "東抄造" ;end
  def dry_o?   ;  @dry_o   ||= ube_product &&  self.ube_product.dryer  == "原乾燥" ;end
  def dry_n?   ;  @dry_n   ||= ube_product &&  self.ube_product.dryer  == "新乾燥" ;end

  #現工程：r割り付けが終了した工程
  def current? ;    real_ope(current) ; end

  #次工程。割り付けが終了した工程の次の工程
  def next? ;    real_ope(self.next_ope) ; end

  
  #全工程を終了したかどうか
  def done?
      (condition == "型板" && !!plan_yojo_to) || 
      (rate[:kakou] == 0.0 || rate[:kakou].blank? ?  !!plan_dry_to : !!plan_kakou_to) #rescue false) ; 
  end
  
  def done_before(time)
    (hozen? || done?) &&
      [plan_kakou_to,plan_dry_to,plan_yojo_to].compact.max <= time
  end

  #全工程の実績が入力されているか
  def result_done? ; 
      (condition == "型板" && result_yojo_to) || 
      ((rate[:kakou] == 0.0 || rate[:kakou].blank? ?  !!result_dry_to : !!result_kakou_to) rescue false)
  end

  # 先月度に完了しているか
  def lastmonth?(time_from)
      ((condition == "型板" && result_yojo_to ? result_yojo_to : nil) || 
       (rate[:kakou] == 0.0 || rate[:kakou].blank? ?  result_dry_to : result_kakou_to)
       ) <= time_from rescue false
   

  end

  def too_late_dry(val=nil)
    @result = val if val
    @result ||= nil
  end 

  def real_ope(ope)
    case ope
    when :shozo ; shozo?
    when :dry ; dry?
    else        ; ope
    end
  end



  # どの工程の割付まで終わっているか。
  # 完了 :done の判断はここではできないな、、、
  def current(sym=nil)
    @current ||= if    plans(:kakou,:plan_from) ;:kakou
                 elsif plans(:dry,:plan_from) ;:dry
                 elsif plans(:yojo,:plan_from) ;:yojo
                 elsif plans(:shozo,:plan_from) ;:shozo
                 else                  ;nil
                 end
    if sym
      @current= UbePlan.real2ope(sym) 
      @done = (condition == "型板" && plan_yojo_to) || 
        ((rate[:kakou] == 0.0 || rate[:kakou].blank? ?  plan_dry_to : plan_kakou_to) rescue false) ; 
    end
    @current
  end

  #現工程(終了した工程)の次の工程を求めるためのテーブル
  Next = {
    :nil=>:shozo ,nil=>:shozo  , :shozo =>:yojo,:shozoe =>:yojo, :shozow =>:yojo,
    :yojo =>:dry ,:dry =>:kakou,:dryo =>:kakou ,:dryn =>:kakou, :kakou =>:done  ,:done =>:done}
  Pre  = {
    :nil=>:nil,nil=>:nil,:shozo =>:nil,:shozoe =>:nil,:shozow =>:nil, :yojo =>:shozo ,
    :dry =>:yojo,:dryn =>:yojo,:dryo =>:yojo,:kakou =>:dry}
  TimeTo= {:shozo =>:plan_shozo_to , :yojo =>:plan_yojo_to ,:dry =>:plan_dry_to,
    :kakou=>:plan_kakou_to}
  def next_ope
    @next = Next[current]
    @next = :done if @next == :kakou && (rate[:kakou]==0.0 || rate[:kakou].blank?)
    @next = :done if @next == :dry   && condition == "型板"
    @next
  end

 #次工程。割り付けが終了した工程の前の工程
  def pre(now=nil)# ;  real_ope(self.pre) ;
    return Pre[now] if now
    Pre[current]
  end

  #指定期間内の工程があるかどうか判定する。
  #  実績がある工程は実績で判断する。無い工程は予定で判断する
  #  内 true、外 false 、時刻空 nil
  def included(from,to)
    #times = UbeSkd::Ope.map{|ope| 
      #UbeSkd::PlanTimes[ope].map{|p_f,p_t,r_f,r_t| [self[r_f]||self[p_f] , self[r_t]||self[p_t]]}
    #}.flatten.compact.sort
    #times= plans.each{|sym,ts| p_f,p_t,r_f,r_t=ts; [r_f ||p_f, r_t || p_t] }.flatten.compact.sort
    times= UbeSkd::Ope.map{|sym| [ plans(sym,:result_from) || plans(sym,:plan_from),
                                   plans(sym,:result_to)   || plans(sym,:plan_to)] }.flatten.compact.sort
    return nil   if times.size == 0
    return false if ( times[-1]<=from ||  to <= times[0] )
    return true
  end

  def sym_holyday(sym)
    case sym
    when nil,:yojo,:kakou,:done ; sym
    when :shozo ; shozo_w? ? :shozow : :shozoe
    when :dry ; dry_o?   ? :dryo : :dryn
    end
  end
  
  def current_time_to ; plans(current,:plan_to) ;  end

  OpeTable={:shozow =>"西抄造",:shozoe => "東抄造",:yojo => "養生",
    :dryo =>"原乾燥",:dryn =>"新乾燥",:kakou =>"加工"}

  #移動時間の制約からくる、次工程開始可能時間
  #* 前工程終了時間に transfer が返す所要時間を加え、次工程開始可能時刻を返す
  def transfer_time(ube_skd,real_ope=nil,param_current_to=nil) 
    current = real_ope   || next_ope
    pre_ope = pre current
    pre_to  = param_current_to || (real_ope ? self.plans(pre_ope,:plan_to) : current_to) || ube_skd.time_from
    pre_to + transfer[current]
  end

  
  
  # 指定工程の切り替え時間。
  # <tt>before</tt> :: この工程の、直前に終了した品種(の工程条件名)
  def change_time(ope,pre_plan)
    before=pre_plan.condition
    @change_time ||= Hash.new
    unless @change_time[[ope,before]]
      ub_change = 
      UbeChangeTime.find_by(ope_name: OpeTable[ope],from: before,ope_to: self.condition)
      @change_time[[ope,before]] = 
        if ub_change && ub_change[:change_time]
          ub_change[:change_time].minute 
        else
          unless before.blank?
            err = "UbeChange: #{OpeTable[ope]},#{before}→#{self.condition} の切替時間が未定義です。ゼロ分とします"
            logger.info(err)
          end
          0
        end
    end
    [@change_time[[ope,before]] ,err]
  end


  #1. UbeChangeTime を参照して切り替え時間を得る。
  #2. UbeSkdの$Meigara に名前があるときは、銘柄違いの補正をする。
  #3. UbeSkd::ChangeTimeLimit を越える場合は記名切り替え。このときは
  #4. named_change_pro_ids にて UbeNamedChange を参照し、UbeProduct#id の配列を得る。
  #5. 後処理と前処理の両方が記名の時に発生する。どちらを記載するかは UbeNamedChangeによる
  #戻り値は [ 切り替え時間, [ UbeProduct#id,UbeProduct#id,UbeProduct#id,,,,]
  #
  #複数の記名切り替えがある時は、長い方の時間で返し、メンテナンスコードは複数返す。
  def change_time_concider_meigara(real_ope,pre_plan,skd)
    return Function::Maintain.new([0,[nil]]) if real_ope == :yojo || !pre_plan
    if pre_plan.condition == condition and pre_plan.meigara == meigara
      Function::Maintain.new([UbeSkd::Round,[]])
    else
      change,err = change_time(real_ope,pre_plan)
      if err
        skd.errors.add(:nil,err)
        logger.info(err)
      end
      pro_ids = if change > UbeSkd::ChangeTimeLimit
                  skd.named_change_pro_id(real_ope,pre_plan.ope_condition_id ,ope_condition_id) 
                else
                   []
                end

        logger.info("NAMEDCHANGE 名前付き切り替えか? #{lot_no} PRO_IDS #{ pro_ids.join(',')}")
      Function::Maintain.new([change,pro_ids]) #maintain_code]
    end
  end
  
  # いわゆる unit_time ではない。行きがかり上この名前。
  # 抄造、乾燥での時産(枚/時)、乾燥での滞留時間(分/枚)
  def unit_time
    unless @unit_time
      @unit_time = Hash.new
      uo = UbeOperation.find_by(ope_name: condition)

      if uo
        @unit_time[:shozo] = shozo_w? ? uo[:west] : uo[:east]
        @unit_time[:dry]   = dry_o?   ? uo[:old]  : uo[:new]
        @unit_time[:kakou] = uo[:kakou]
      end
    end
    @unit_time
  end

  # 指定工程の 所要時間
  #   乾燥の工程時間は次の様に求める
  #     全所要時間：リードタイム + 滞留時間 x (枚数/1000 + 1 ) + 15分
  #     　　リードタイム：UbeSkd::DryLead
  #         15分　　　　：UbeSkd::DryTrail
  #         滞留時間    ：@ope_length[:dry?] （UbeOperation.find_by_ope_name(ube_product.ope_condition)[:dry?])
  #              単位は分だから、換算すること
  #  抄造、加工は単位は 枚/時間 だから　これを 秒/枚 に直す。(1/@ope_length).hour
  # { real_ope => [length,stay,error] }
  def ope_length(sym)
     @ope_length = nil unless mass == @massave
    unless @ope_length 
      logger.debug(" **** MASS=#{mass} lot #{lot_no}") if lot_no == "2W0327"
      @massave=mass
      err=nil
      @ope_length = {:yojo => [40.hour,0,nil]}
      unless ube_product
        return [0,0,ube_product_error?]
      end
      err = " #{proname}の抄造条件が定義されて居ません" unless unit_time[:shozo] 
      @ope_length[:shozow] =@ope_length[:shozoe] = @ope_length[:shozo] = 
        [unit_time[:shozo] ? (mass.to_f/unit_time[:shozo]).hour.marume(UbeSkd::Round) : 0 ,0,err]
      err=nil
      err = " #{proname}の乾燥条件が定義されて居ません" if !unit_time[:dry] && condition != "型板"
      logger.info(err) if err
      #length = UbeSkd::DryLead+(stay*(mass/1000.0+1.0)).marume(UbeSkd::Round)+UbeSkd::DryTrail
      if unit_time[:dry]
        # 1000枚投入するといっぱいになって最初の1枚が出る。滞在時間は 1000枚分の時産
        stay   =  (1000 / unit_time[:dry]).hour.marume(1.minute)
        
        # 乾燥の時産とは投入/排出に要する時間で求める。これと滞在時間の合計が全処理時間
        length = ((mass.to_f/unit_time[:dry]).hour + stay).marume(UbeSkd::Round)
        
      else
        length = stay = 0
      end
      @ope_length[:dryo] = @ope_length[:dryn] = @ope_length[:dry] = [length,stay,err] 

      @ope_length[:kakou] = 
        [unit_time[:kakou] ? (mass.to_f/unit_time[:kakou]).hour.marume(UbeSkd::Round) : 0,0,nil]
    end
    @ope_length[sym]
  end

  # debug用出力。
  ## 各工程の予定開始、終了時刻を mdHM formatで表示する 
  def disptime
    UbeSkd::Ope.map{|ope| "#{ope}:"+UbeSkd::PlanTimes[ope].map{|t| self[t].mdHM rescue "../..-..:.."}.join("～")}.join("|")
  end

  def start_times
    UbeSkd::Ope.map{|ope| self[UbeSkd::PlanTimes[ope][0]].mdHM  rescue "../..-..:.."}.join("  ");
  end
  def if_error(err)
    return unless err
    errors.add(:nil,err)
    logger.info(err)
  end

  ## 品種による違いの有るもの

  #この工程への移動時間
  #養生、加工は場合分けが有るので、Module化した
  Transfer = {
     :nil => 0, :shozo => 0, :shozoe => 0,:shozow => 0,:yojo  => 30.minute ,
    :dryo => 10.minute,:dryn => 10.minute,:dry => 10.minute, :kakou => 24.hour+10.minute 
  }

  #次工程に移動するのに要する時間
  #* 今時間を割り当てようとしている real_ope へ、前の工程から移動するのに要する時間。
  #* 定数 Transfer から求める
  #* 加工へ移動する場合、乾燥後の後養生1日を含めた時間にしている。
  #   3x10品種は後養生が要らないので、その例外処理もここで行う
  #<tt>real_ope</tt> :: 指定ない場合は、「次の工程」が使われる。
  #                 　　仮時間確保の処理で呼ばれるとき、次の工程 以外に対しての評価が必要になる。
  #                     その時は指定する
  #<tt>current_to</tt> :: 指定ない場合は前の工程の終了時間が使われる。
  #                   　　仮時間確保の処理で呼ばれるとき、前の工程の終了時間はまだ代入されていない。
  #                       その場合指定する。
  #　　抄造　→　養生庫　→　乾燥　→　乾燥後置場　→　加工　→　加工後置場
  #        東：30分　　原：10分　原：5分　　　　　5分　　　　5分
  #        西：60分　　新：10分　新：5分	
  #後養生の時間も移動時間に含めることで、後養生を考慮しなくて済ませる
  def transfer
    @Transfer ||= Transfer.dup
  end


   #<tt>3x6</tt>, <tt>3x10</tt> と呼ばれる製品か否か。
   #
   # これらは乾燥後の後養生が不要である
   def _3by10?
     %w(F3×10 普3×10 12普3×6 野地板 野地2M ショップ 大壁).include?(condition)
   end
   def hozen?
     @hozen ||= begin
                  self.ube_product.hozen 
                rescue 
                  errors.add(:nil,"${id}:#{lot_no} の製品データがおかしい")
                  logger.info("UbePlan:No ube_product error:#{id}:#{lot_no} の製品データがおかしい")
                  true
                end
   end
end
module ShozoW
  def transfer#time
    unless @Transfer_ShozoW
      super
      @Transfer_ShozoW = true
      @Transfer[:yojo] = 60.minute
    end
    @Transfer
  end
  #UbePlan::Transfer[:yojo] = 60.minute
end
module ThreeByTen
  def transfer#time
    unless @Transfer_3x10
      super
      @Transfer_3x10=true
      @Transfer[:kakou] = 10.minute
    end
    @Transfer
  end
end

__END__
$Id: ube_plan.rb,v 2.40 2012-10-29 02:04:02 dezawa Exp $
