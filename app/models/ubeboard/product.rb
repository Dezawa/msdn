# -*- coding: utf-8 -*-
# 製品もしくは保守・記名切り替えを登録する。
# proname  :: 製品名、または保守、切り替え名
# shozo  :: 抄造を東西どちらで行うか。値は 西抄造、東抄造
# dry  :: 乾燥を原新どちらで行うか。値は 原乾燥、新乾燥
# lot_size  :: 標準製造量。養生庫により実際の製造数は異なり、x0.75、x1.00,  x1.25 となる
# defect_rate  :: 総合不良率。単位は %
# ope_condition  :: 品種名。保守・記名切り替えの場合は　"A??"番号。
# color  :: 作業指示書に出力する時の色。16進6桁の RGB で定義する。無定義の時は、、
# roundsize :: ラウンドでの最大製造数量の標準
class Ubeboard::Product < ActiveRecord::Base
 # extend ApplicationHelper
  extend CsvIo
  self.table_name = 'ube_products'
require 'nkf'
require 'csv'
  #validates_presence_of :proname ,:shozo ,:dry,:lot_size,:ope_condition,:defect_rate
  #validates_inclusion_of :lot_size, :in =>(500..3000), :message=>"lot sizeが範囲外です"
  #attr_accessible :id,:proname ,:shozo ,:dryer,:lot_size,:defect_rate,:ope_condition,:color,:hozen
  #attr_accessible :roundsize
  CSVlabels =  ["ID","製品名","抄造機","乾燥機","lot size","ラウンド最大製造数","不良率","製造条件","表示色","保全"]
  CSVatrs   = [:id,:proname ,:shozo ,:dryer,:lot_size,:roundsize,:defect_rate,:ope_condition,:color,:hozen]

  has_many      :ube_plans

  @@holycode = {}
  # selectのときのchoiseに使う配列を返す。
  # DBの変更にダイナミックに追随するために、Ubeboard::ProductControllerのcreate、update, csv_upload
  # のときに再読み込みされる
  def self.products(read=nil)
    if !@pronames || read
      @pronames ||= self.all(:conditions => "hozen = false or hozen is null",
                                 :select => "proname,id"
                                 ).map{ |p| [p.proname,p.id]}
    end
    @pronames 
  end

  # 製品登録情報の一貫性を調べる。全製品に対して ope_condition_valid? でチェックする
  def self.error_check
    error = []
    count = Hash.new{|h,k| h[k]=[]}
    products = self.all(:conditions => "ope_condition not like 'A%'").each{|ube_pro|
      error += ube_pro.ope_condition_valid?
      count[ube_pro.proname] << ube_pro
    }
    count.map{|k,v| v if v.size>1}.compact.each{|v|
      error << "製品:「#{v[0].proname}」が重複しています。ID=[#{v.map(&:id).join(',')}]"
    }
    error.uniq
  end
  
  def self.hozen_code(hozen,real_ope=nil)
    @hozen_code ||= Hash.new
    unless @hozen_code[[hozen,real_ope]]
      case hozen
      when "酸洗"
        up = self.find_by(ope_condition: real_ope==:shozow ? "A02":"A03")
        #when :yobouhozen,"予防保全"
      else
        if [:shozow,:shozoe].include?(real_ope)
          up = self.find_by(proname: hozen,
                                  shozo: Ubeboard::Skd::Id2RealName[real_ope])
        elsif [:dryo,:dryn].include?(real_ope)
          up = self.find_by(proname: hozen,
                                  dryer: Ubeboard::Skd::Id2RealName[real_ope])
        end
        
        if up.nil? # || up.size==0
          up = self.find_by(proname: hozen)
        end
      end
      @hozen_code[[hozen,real_ope]] =  up ? [up.id,up.ope_condition,real_ope] : nil
    end
    @hozen_code[[hozen,real_ope]] 
  end

  def self.holydaycode(ope_condition,ope ,real_ope,real_ope_name)
    pro = ope == :kakou ?
    self.all(:conditions => "ope_condition ='#{ope_condition}' and shozo is null and dryer is null") :
      self.all(:conditions => "ope_condition='#{ope_condition}'and #{ope}='#{real_ope_name}'")
      if pro.size>0
        [ pro.first.id, ope_condition ,real_ope ]
      else
        [nil,ope_condition,real_ope]
      end
  end

  def self.holyday_code
    unless @@holycode.size>0
      @@holycode=Hash.new
      [[1,"A01"],[4,"A01-1"],["A15","A15"]].each{|type,ope_condition|
        [[:shozow,"西抄造",:shozo],[:shozoe,"東抄造",:shozo],
         [:dryo,  "原乾燥",:dryer],[:dryn  ,"新乾燥",:dryer]
        ].each{|real_ope,real_ope_name,ope|
          @@holycode[[type,real_ope]] = holydaycode(ope_condition,ope ,real_ope,real_ope_name)
        }
        @@holycode[[type,:kakou]] = holydaycode(ope_condition ,:kakou,:kakou,nil)
      }
    end
    @@holycode  #type,real_ope
  end
  
  def after_find
    #check_ope
  end

  # 抄造、乾燥機が指定されているか、
  # 品種が指定されているか, 登録されて居る品種か
  # 品種の情報には、使う抄造、乾燥の速度が入っているか
  # 切り替え時間は入っているか。
  # 
  # Ubeboard::Operation.error_cneck での切り替え時間チェックと異なるのは、
  #  Ubeboard::Operation :: 登録されている全品種について調べる
  #  Ubeboard::Product   :: どの製品にも使われていない品種については調べない
  def ope_condition_valid?
    error = []
    # 対応する品種は登録されて居るか
    kind = Ubeboard::Operation.all(:conditions => "ope_name = '#{ope_condition}'")[0]
    unless kind
      error << "製造条件：#{self.proname}の品種が入力されていません。もしくは未登録の品種です"
    end

    # 抄造、乾燥機が指定されているか
    unless idx_shozo= %w(西抄造 東抄造).index(shozo) 
      error << ("製造条件：#{self.proname}の抄造機が入力されていません")
    else
      shozoki =  idx_shozo ? %w(西抄造 東抄造)[idx_shozo] : nil
    end

    unless idx_dryer=%w(原乾燥 新乾燥).index(dryer)
      error<<("製造条件：#{self.proname}の乾燥機が入力されていません") unless proname == "型板"
    else
      dry_no  =  idx_dryer ? %w(原乾燥 新乾燥)[idx_dryer] : nil
    end

    # 対応する品種は抄造、乾燥条件が指定されているか
    return error unless kind

    if idx_shozo 
      kind[[:west,:east][idx_shozo]] || 
        error << ("工程速度：#{kind.ope_name}、#{shozoki}の抄造時産が入力されていません")
      error += check_change shozoki
    end
    if idx_dryer
      kind[[:old,:new][idx_dryer]] ||
        error << ("工程速度：#{kind.ope_name}、#{dry_no}の乾燥炉滞留時間が入力されていません")
      error += check_change dry_no
    end
    error
  end

  # 切り替え時間が定義されて居るか 
  def check_change(line)
    error = []
      # 切り替え時間が定義されて居るか 
      #   該当するラインの切り替え時間を全部取ってきて
      ch_times = Ubeboard::ChangeTime.all(:conditions => "ope_name='#{line}' and change_time is not null")
      #   前後の全品種を得る
      kinds = ch_times.map{|ch| [ch.ope_from,ch.ope_to]}
      kind_names = kinds.flatten.uniq
      # 
      unless kind_names.include?(ope_condition)
        error << ("切替時間：#{line}、#{ope_condition}の切替時間が入力されていません")
      else
        # 
        post_kinds = kinds.select{|k| k[0]==ope_condition}.map{|o| o[1]}
        pre_kinds  = kinds.select{|k| k[1]==ope_condition}.map{|o| o[0]}
        (nasi = kind_names - post_kinds).size == 0 ||
          error << ("切替時間：#{line}:#{ope_condition}→ 「#{nasi.join(',')}」の切替時間が入力されていません")
        (nasi = kind_names - pre_kinds).size == 0 ||
          error << ("切替時間：#{line}:「#{nasi.join(',')}」→#{ope_condition}の切替時間が入力されていません")
      end
    error
  end

  def ope_condition_id
    Ubeboard::Operation.find_by(ope_name: ope_condition).id
  end
end
