# -*- coding: utf-8 -*-

module Ubeboard::Function

  #== 空き時間管理モジュール
  # Hash @FreeList,@freelist に各実工程の空き時間リストを配列でもつ
  # 基本的にはここですべての空き時間を管理する。
  #   すなわち
  #    立案期間の空き時間を用意し、休日と休転分を引いたのちに
  #    製造、切り替え、保守の時間を割り当てて行く。
  #
  # *休日は 保守、製造ともに行わない。この管理を @FreeList で行う
  # *休転は保守は行い製造は行わない。 この管理を @freelist で行う
  # *両方が重なったときは休転を優先する。すなわち保守は行う
  # すなわち、
  #  　　　　　　　　製造　　　　　保守
  #  空き時間検索　@FreeList　　 @freelist
  #  割付　　　　　@FreeList,@freelist両方
  #
  #
  #== 関連method
  #* freeList     各ラインの空き時間を返す。
  #* searchfree   空き時間を検索する
  #* assignFreeList 指定された日時で割り付けする。
  #* assign_maint   保守を割り当てる。
  #* holyday?       指定日時がそのラインの休日であるかどうか
  #* maintain       前後のロットの間に保守を入れる必要ありや
  #
  #===初期化
  #freeList が始めて呼ばれたときに @FreeList と @freelist を初期化する。
  #
  #===割付
  #        休日は assign_holydayを通して 割付とUbeboard::Plan作成を行う
  #          割付は @FreeListへ  
  #        終業始業は assignFreeListにて割り付ける
  #          割付は @FreeListへ  
  #        休転は assignFreeListにて割り付ける
  #          割付は @FreeList と @freelist へ  
  #      
  #    searchfree(real_ope,start,periad,condition=nil)
  #      空き時間を検索する
  #      抄造の保守は @freelist から探す
  #      それ以外は　 @FreeList から探す
  #        
  #      conditionは @freelist から探すかどうかのflag
  #        nil は @FreeList、trueは@freelist
  #        
  #      
  #    assignFreeList(ope,start,stop,condition=nil) 
  #      割り付けする。
  #      @FreeList を処理するが
  #      抄造の場合は @freelist も処理する。
  #        ただし、初期化時には休転のみ処理する
  #        
  #      conditionは @freelist も処理するかどうかのflag
  #        nil は 処理しない、trueは処理する
  #        
  #    assign_maint(real_ope,start,stop,array_hozen_code,option={})
  #      保守を割り当てる。
  #        そのとき 記名保守、休日は保守用Ubeboard::Planを作る
  #        割り当てはassignFreeListで行う 
  #          
  #      option[:jun]       記名の時の挿入順位置  
  #      option[:freelist]  true => @freelist　も
  #        
  #    holyday?(ope,date)
  #    maintain


module SkdFreelist
  StartFrom = Ubeboard::Holyday::StartFrom
  #各実工程の空き時間のリスト
  #* 戻り値
  #  空き時間の配列の配列のHash
  #  { real_ope => [ [from,to],[from,to],,,,] }
  #
  #  休日は製造、保守ともに行わない。
  #  休転は保守は行う
  #   @FreeList は休日、休転共に削除し
  #   @freelist は休日を削除して、休転時間を追加する
  # 
  #最初に呼ばれたときは初期化を行う。
  # 初期化は、
  #1. まず立案期間全体を空き時間として準備し
  #2. 休日分を削除し(assign_holydayを通し削除と表示用のUbeboard::Plan作成を行う)
  #3. 休転分を削除し(assign_kyuutenを通し削除と表示用のUbeboard::Plan作成を行う)
  #4. @freelistについて add_kyuuten にて休転分を追加する
  def freeList
    unless @FreeList
      ###割り当て開始に当たって、各工程の割り当てを初期化する。
      # 立案期間をまず与えて
      @FreeList = Hash.new
      [:dryo,:dryn,:shozow,:shozoe,:yojo,:kakou].each{|ope|
        case ope
        when :dryo,:dryn,:kakou
          @FreeList[ope] = 
            Ubeboard::Function::FreeList.new(ope,[time_from,time_to],self) #holydays.dup,maintain)
        when :shozow,:shozoe
          @FreeList[ope] = 
            Ubeboard::Function::FreeListShozo.new(ope,[time_from,time_to],self) #,holydays.dup,maintain)
        when :yojo
          @FreeList[ope] = 
            Ubeboard::Function::FreeListYojo.new(ope,[time_from,time_to],self) #,holydays.dup,maintain)
        end
      }
    end
    @FreeList
  end

  #保守、切り替えを割り付ける
  #*   保守、切替の時間を freeListから削除し、
  #*   保守、記名切替のためにUbeboard::Planを作成する。
  #*   時間、曜日による保守を行ったときは、hozen_day を更新し、
  #    同じ日に二度行うのを防止する。
  #
  #<tt>array_hozen_code</tt> :: nil かもしくは [hozen_code,hozen_code,,,]
  #<tt>hozen_code</tt>  :: [ube_product_id,製造番号] 例：[28, "A02"] 
  #       無記名切り替えのときは、nil
  #<tt>jun</tt> :: Ubeboard::Plan上の優先順
  def assign_maint(real_ope,start,stop,array_hozen_code,option={})
    logger.debug("\n#{real_ope} remove_skd_from_freelist #{start}-#{stop}\n")

    freeList[real_ope].assignFreeList(start,stop) 

    jun = option[:jun]

    # 保守分も累計し、最後に changetime にて保守分を引く
    sum_change_time[real_ope] += stop - start 

    return unless array_hozen_code && array_hozen_code[0]

    #from_to = Ubeboard::Skd::PlanTimes[real_ope]
    #opt = from_to ? { from_to[0] => start,from_to[1]   => stop} : {} 

    if @maintlog && @maintlog.size>0
      logger.info("Maintain: #{start.mdHM} "+@maintlog.join("\n"))
      @maintlog = []
    end
    array_hozen_code.each{|pro_id|
      lot_no = pro_id_2_lot_no(pro_id)
      plan = create_hozen_plan(real_ope,start,stop,pro_id,jun)  if lot_no
      
      # 酸洗したら 実施日を登録する。
      # 長い抄造の保守・切り替えの時も酸洗を行っているであろうから、登録する。
      hozen_date[real_ope] = (stop-8.hour).day if %w(A02 A03 A06 A08 A09 A10 A11 A12).include?(lot_no)
      # WF、PF、刃物替えをおこなったら、累積をリセットする
      reset_runtime(real_ope,pro_id,lot_no) if %w(A08 A11 A13).include?(lot_no)
      jun -= 0.1 if jun
    }
  end

  #保守、記名切り替えを表示するために Ubeboard::Plan を作成し、関連付ける
  #real_ope :: 対象となる実工程
  #start    :: 割り当て開始日時
  #stop     :: 割り当て終了日時
  #pro_id   :: 割り当てる保守・記名切り替えの Ubeboard::Product#id
  #jun      :: 順番
  def ddcreate_hozen_plan(real_ope,start,stop,pro_id,jun=nil)
    from_to = Skd::PlanTimes[real_ope]
    opt = from_to ? { from_to[0] => start,from_to[1]   => stop} : {} 
    lot_no = pro_id_2_lot_no(pro_id)
    plan = Plan.find_or_create_by_ube_product_id(0)
    plan.update_attributes( opt.merge(:skd_id     => id,
                                       :product_id => pro_id,
                                       :lot_no         => lot_no,
                                       :mass => 1.0,
                                       :jun => jun
                                       )
                             ) 
    ube_plans << plan
  end


  ######################################################################
  # 前のロットとの間に休日が入ったかどうか判断する
  def biyond_holyday?(real_ope,last_end,start)
    #start - last_end > beyond_holyday
    holy_types = holydays[real_ope].select{|holyday| last_end < holyday[0] && holyday[1] < start}.
      map{|holyday| holyday[2]}.sort.uniq
    case holy_types
    when []       ; nil
    when [1],[1,4]; 1
    when [4]      ; 4
    else rase
    end
  end

  # 次の抄造製造との空き時間が、休日を挟んでいるかどうか判定するための値
  def beyond_holyday
    @BeyondHolyday ||= (Ubeboard::Skd::BeyondHolyday + 8).hour #starting + ending
  end

  ################################################
  def unkyu(real_ope)
    unless @unkyu
      @unkyu = Hash.new{|h,k| h[k] = Ubeboard::Skd::HolydayUnkyu}

      ucs = Ubeboard::Constant.where('keyword like "%unkyu_start"')
      ucs.each{|uc|
        realope,dmy,dmy1 = uc.keyword.split("_")
        @unkyu[realope.to_sym] = (uc.value-8).hour
      }
    end
    @unkyu[real_ope]
  end

  # 抄造工程の終業作業時間
  def ending(real_ope,holy_type)
    unless @ending 
      @ending = { 
        [:shozow,1] => 5.hour, [:shozoe,1] => 5.hour,
        [:shozow,4] => 1.hour, [:shozoe,4] => 1.hour
      }
      ucs = Constant.all(:conditions => 'keyword like "%ending"')
      # "shozow_holyday_ending"
      ucs.each{|uc|
        realope,holyday_type,s = uc.keyword.split("_")
        ht = case holyday_type
             when "holyday"  ; 1
             when "unkyu"    ; 4
             else ; raise 
             end
        @ending[[realope.to_sym,ht]] = uc.value.minute
      }
    end
    @ending[[real_ope,holy_type]]
  end

  # 抄造工程の始業作業時間
  def starting(real_ope,holy_type)
    unless @starting 
      @starting = { 
        [:shozow,1] => 3.hour, [:shozoe,1] => 3.hour,
        [:shozow,4] => 1.hour, [:shozoe,4] => 1.hour
      }
      ucs = onstant.all(:conditions => 'keyword like "%starting"')
      # "shozow_holyday_starting"
      ucs.each{|uc|
        realope,holyday_type,s = uc.keyword.split("_")
        ht = case holyday_type
             when "holyday"  ; 1
             when "unkyu"    ; 4
             else ; raise 
             end
        @starting[[realope.to_sym,ht]] = uc.value.minute
      }
    end
    @starting[[real_ope,holy_type]]
  end

  #####################################################################3
  #この立案期間内の休日のlistを返す
  #  {:shozo => [[s,e],[s,e],,,,]],:yojo=>.....}
  #s :: 休日の午前8時
  #e :: 休日の翌日午前8時
  #
  #始めて呼ばれたときに Ubeboard::Holyday を読んで初期化する
  def holydays
    unless @holydays
      @holydays = Hash.new{|h,k| h[k] = [] } 
      
      # 開始日、日数
      @day_from = skd_from.day - 1  # 1日は休日配列の  0
      @days     = (skd_to - skd_from)/1.day
      # 各工程のこの期間の休日予定を得る
      Ubeboard::Holyday.where(["month >= ? and month <= ?",str_from,str_to]).
        each{|holyday|
        day0 = Time.parse(holyday.month+"/1 08:00")
       [:shozow,:shozoe,:dryo,:dryn,:kakou].each{|real_ope|
          holyday[real_ope].each_with_index{|holyday_code,d|
            day1 = day0+d.day
            case holyday_code
            when "1","2","3" # 休日,休出,過労働
              @holydays[real_ope] << [day1+StartFrom[holyday_code],day1+1.day,holyday_code.to_i,real_ope]
            when "4"         # 運休
              @holydays[real_ope] << [day1+unkyu(real_ope)        ,day1+1.day,holyday_code.to_i,real_ope]
            end
          }
        }
      }
    
    end
    @holydays
  end

  #指定された実工程の指定された日時が休日かどうか調べる
  #ope :: 実工程
  #date :: 日時
  def holyday?(ope,date)
    holydays[ope].select{|s,e| s <= date && date < e }.size > 0
  end

  #この期間の休転の一覧を返す
  # { "西抄造" => [[plan_from,plan_end,result_f,result_end],[],,,,] }
  #plan_from :: 休転の開始日時 
  #plan_end :: 休転の終了日時
  #
  #初めて呼ばれたとき、Ubeboard::Maintain を読んで初期化する
  def maintain
    unless @maintain
      @maintain = Hash.new{|h,k| h[k]= []}
      conditions = "plan_time_start <= ? and plan_time_end >= ? "
      maint = Ubeboard::Maintain.find(:all,:conditions=>[conditions ,time_to,time_from])
      #%w(西抄造 東抄造 養生 原乾燥 新乾燥 加工).zip(RealOpe).each{|ope_name,ope|
      maint.each{|m| 
        @maintain[Ubeboard::Skd::RealName2Id[m.ope_name]] << 
        [m.plan_time_start,m.plan_time_end,m.maintain]
      }
      #@maintain.each{|ope_name,v| @maintain[Ubeboard::Skd::RealName2Id[ope_name]] = v }
    end
    @maintain
  end


end # of Ubeboard::SkdFreelist
end # of Function
__END__
$Id: ube_skd_freelist.rb,v 2.31 2012-11-01 08:35:29 dezawa Exp $
