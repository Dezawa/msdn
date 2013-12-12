# -*- coding: utf-8 -*-
module Ubeboard::Function::LipsToUbePlan
  # LiPSで指定された製造枚数が多く、ロット数が多くなったとき、
  # 連続製造できる 同一品種のロット数の最大
  LotMax = 5
  # 連続製造できる 同一品種のロット数の最小
  LotMin = (LotMax+1)/2

   # LiPSのデータを元に、Ubeboard::Planのインスタンスを作る。saveはしない。
  # 　LiPSの製品名とUbeboard::Product#pronameが一致していないとだめ。
  # 　　一致しない時は取り込まず、警告を表示する
  # 　　一応、全角→半角 の正規化は行っている
  # 　製造数量　：LiPSから渡された製造量に (1-不良率)を乗じた数量を製造計画する。
  # 　ロット分割：どの養生庫が使われるか未定なので、標準製造量で割り当てる。
  # 　　　　　　　半端ができたら 最低数量 MassMin のロットにするが、それは Ubeboard::Skd#male_plamn で
  # 　　　　　　　行うので、ここでは半端数をそのまま割り当てておく
  # 　連続lot数 ：同じ製品が連続製造数量が Ubeboard::Product#roundsizeを越えないように分割する
  # 　製造順　　：LiPSの順番。
  # 
  # <tt>lips</tt> :: LiPSのデータ。
  # <tt>String</tt> :: lips/member からのリンクで来た場合。
  # <tt>IO</tt> :: Uploadされたときは、IOになっている
  def make_plans_from_lips(lips)

    if lips.class == String
      infp = open(RAILS_ROOT+"/public"+lips) rescue infp = open(lips)
    elsif lips.class == ActionController::UploadedTempfile or
        lips.class == File or
        lips.class == ActionController::UploadedStringIO 
      infp = lips
    end

    I18n.locale = :default
    param =HashWithIndifferentAccess.new
    param[:promax]=100
    param[:opemax]=100
    lips = Lips.new(param)

    errors = [] #ActiveRecord::Errors.new(self)

    lips.csv_upload(infp)
    if lips.errors[:base].size>0
       errors << lips.errors[:base]
      return [[],errors]
    end
    logger.debug("LipsUpload lips.error=#{lips.errors}")

    pro = lips.proname.zip(lips.pro).map{|name,mass| [name,mass] if mass>0.0 }.compact
    logger.debug("LipsUpload pro=#{pro.join(',')}")
    #
    #subplan = {:dryo => Array.new(100/LotMax,[]) , :dryn => Array.new(100/LotMax,[])}
    subplan = Array.new(100/LotMax,[])
    pro.each{|proname,mass|
      # proname正規化
      proname.tr!("０-９（）Ａ-Ｚａ-ｚｱ-ﾝ","0-9()A-Za-zア-ン")
      product = Ubeboard::Product.find_by(proname: proname)
      if product.nil?
        errors << "製品 '#{proname}'は製造条件一覧にありません"
        next
      end
      # 製造総量を不良率で補正する
      defect_rate = product.defect_rate
      unless defect_rate
        errors << "製品 '#{proname}'の不良率が未定義です"
        defect_rate =  0.0 
      end

      unless product.lot_size && product.lot_size > 1
        errors << msg="製品 '#{proname}'の基準製造量が未定義です 2304 としておきます。"
        logger.info msg
        product.lot_size =  2304 
      end
      mass_correct = (mass.to_f * 100.0 / (100.0 - defect_rate)).ceil
      
      # lotに分割する
      lotNr =  (mass_correct.to_f/product.lot_size).ceil.to_f
      plns =lotNr.to_i.times.map{ 
        Ubeboard::Plan.new(:ube_product_id =>product.id,:mass =>product.lot_size,:lot_no =>"")  
      }
      # 最後のロットは、端数のはず
      plns[-1].mass = product.lot_size * lotNr - mass_correct
      
      #### 多量ロットの分割。LotMin 以上のとき、LotMin～LotMax に収まるように分割する
      #### 抄造乾燥時間比からLotMax、ラウンドサイズを決める
      # 多量ロットの分割。1ラウンドの製造数量を Ubeboard::Product#roundsize 以下にする。
      # 未定義の時は警告を出し1万枚にする
      plan = plns.first
      if (roundsize = plan.ube_product.roundsize).blank? || roundsize==0
        msg=" '#{proname}'はラウンド最大製造量が未定義なので1万枚とします"
        errors << msg
        logger.info msg
        roundsize = 10000
      end
      logger.info("#{proname} lotmax= #{roundsize}/#{product.lot_size}=>#{roundsize/product.lot_size}")
      #rate = (plan.ope_length[:shozo][0].to_f/plan.ope_length[:dry][0] rescue 1)
      lotmax = roundsize/product.lot_size # planLotMax - (rate < 1.2 ? 0 : (1.7 < rate ? 2 : 1 ))
      roundNr =  (lotNr / lotmax).ceil rescue 1
      ###roundSize = lotNr/roundNr  # 実数
      ###  lotNr = 1..8    <= Max    lotNr
      ###          9..16             lotNo/2   4/5,5/5,5/6,.... 8/8
      ###          17..24             8 + 9..16
      ###  Max 5 Min 3 だと   roundNr roundSize
      ###          1..5   5
      ###          6 7 8 9 10   2    6/2..10/2 1..3 4..6,1..3.5 3.5..7 1..2   6/1
      # ラウンドサイズのグループにまとめる
      lot=0 ###.001
      (0..roundNr-1).each{|i| subplan[i] += plns[lot..(lot+lotmax-1)]; lot += lotmax}
    }
    #
    # subplan[:dryo] = [
    plans = subplan.inject([]){|a,v| a += v}
    max_id = Ubeboard::Plan.find(:first,:order => "id DESC").id+1 rescue 1
    plans.each{|plan| plan.id = max_id ; max_id += 1}
    errors << "LiPS CSVファイルの様ですが、製造数がゼロです" if plans.size == 0
    jun = 3000
    plans.each{|plan| plan.jun = jun; jun += 10}
    [plans,errors.uniq]
  end
  
  def make_plans_from_params(params)
    [params.map{|id,param|  Ubeboard::Plan.new(param)  } ,[]]    
  end

end
