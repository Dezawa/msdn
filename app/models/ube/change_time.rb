# -*- coding: utf-8 -*-
require 'csv'
#require 'jcode'
require 'pp'
require 'nkf'
# 同一品種でのロット切り替え時間、異なる品種での切り替え時間を定義します。
## 同じ品種であっても銘柄が異なると切り替え時間が長くなるものが有ります。
## その場合は長い方の時間を登録します。
### この場合、同一銘柄の場合の切り替え時間はプログラム内でハードコードされています。
### Ube::SkdHelp.change_time。
# ope_name  :: 工程の実名称 東西抄造、原新乾燥、加工
# ope_type  :: 使ってない。
# change_time  :: 所要時間 分
# ope_from  :: その工程の前の品種
# ope_to  ::  その工程の後の品種
#
# １組ごとのオカレンスとなるので、一覧性の良いCSVではそのままでは入力できない。
# 専用に入力の仕組みを用意している。Ube::ChangeTime.csv_upload
class Ube::ChangeTime < ActiveRecord::Base
  extend CsvIo
  #:w
:n
#self.table_name = 'ube_change_times'
  # ==CSVからのデータ置き換え
  # 追加、修正はできない。全置き換えとなる。
  #
  # 一覧表で入力するのがやりやすいが、通常のTableでのCSV表現とことなり、１オカレンス１行ではなく
  # １オカレンス１cellなので、通常のIOではだめ。さらに５工程分の表となる。
  # ので、特別な入力処理を行うことにした。
  #
  # CSV書式
  # column 1   ライン名 東西抄造、原新乾燥、加工：表の切り替え
  #           「製品名」 column 2～  切り替え後の品種名
  #            前品種名　column 2～  切り替え時間
  #              ""   無視する行
  #  
  #  ┌─────┬─────────────────<br>
  #  │西抄造　│				
  #  ├────┼───┼────┼───┼───┼
  #  │製品名　│12F　 │12普3×6│12普及│16F　 │
  #  ├────┼───┼────┼───┼───┼
  #  │12F 　  │ 5　　│40　　　│480 　│	5	
  #  ├────┼───┼────┼───┼───┼
  #  │12普3×6│480　 │5 　　　│480 　│480 　│
  #  ├────┼───┼────┼───┼───┼
  # 
  def self.csv_upload(csvfile)
    case csvfile
    when String
      #lins = File.read(csvfile)
      rows = CSV.parse(NKF.nkf("-w",File.read(csvfile))) #read(csvfile)
    else
      rows = CSV.parse(NKF.nkf("-w",csvfile.read))
      #rows 
    end
    while row = rows.shift
      logger.debug("Ube::ChangeTime  #{row.join(',')}")
      
      case row[0]
      when "東抄造","西抄造","原乾燥","新乾燥","加工"
        opename = row[0] #$&
      when "製品名"
        logger.debug("Ube::ChangeTime 製品名 #{row.join(',')}")
        pro_names = row[1..-1].compact
      when "",nil ; next
      else
        ope_from    = row[0]
        pro_names.each_with_index{|ope_to,idx|
          Ube::ChangeTime.
          find_or_create_by(ope_name: opename,ope_from: ope_from ,ope_to: ope_to).
          update_attribute(:change_time , row[idx+1] )
        }

      end

    end
  end

  def self.csv_out
    (UbeSkd::RealOpe - [:yojo]).map{|real_ope| ope_name = UbeSkd::Id2RealName[real_ope]
      change_times = self.all(:conditions => ["ope_name = ?",ope_name])
      froms = change_times.map(&:ope_from).uniq.sort
      head = ope_name + "\n製品名," + froms.join(",")
      rows=froms.map{|ope_from| 
        row = ope_from+"," +
        change_times.select{|ct| ct.ope_from == ope_from }.sort_by{|ct| ct.ope_to
        }.map{|ct| ct.change_time}.join(",")
      }.join("\n")
      head + "\n" + rows
    }.join("\n\n")
   
  end

  # 未入力の切り替え時間がないか調べる。Ube::Operation.error_chec から呼ばれる
  # 与えられた品種名のリストを前後品種に持つデータの存在を調べる
  # line_name :: String 東西抄造、原新乾燥、加工 
  # kind_list :: Array  前後にあるべき品種名のリスト
  def self.check(line_name,kind_list)
    changes = self.where(["ope_name = ? and change_time  > 0",line_name])
    from_to   = changes.map{|ch| [ch.ope_from,ch.ope_to]}
    not_defined = kind_list.product(kind_list) - from_to
    if not_defined.size > 0
      not_defined.map{|from,to| "切替：#{line_name}の #{from} → #{to} が未登録かゼロ分です"}
    else
      []
    end
  end
end
__END__
$Id: ube_change_time.rb,v 2.6 2012-10-16 08:49:11 dezawa Exp $
$Log: ube_change_time.rb,v $
Revision 2.6  2012-10-16 08:49:11  dezawa
ruby9仕様のために、codingを1行目に入れた

Revision 2.5  2012-03-29 11:02:02  dezawa
RDocに対応するための修正

Revision 2.4  2012-03-24 11:45:25  dezawa
前回割り当てた養生庫を使うようにして、立案結果の安定性を増した

Revision 2.3  2012-03-20 08:22:28  dezawa
Rdoc0_1

Revision 2.2.2.1  2012-03-18 08:05:02  dezawa
*** empty log message ***

Revision 2.2  2012-03-08 03:27:11  dezawa
エラーチェック改善：工程速度にあるが製品に使われていない品種の切り替えもチェックする

Revision 2.1  2012-03-06 12:08:57  dezawa
Id2ope を Id2RealNmae に変更

Revision 2.0  2012-01-29 23:31:36  dezawa
リリース版：最適化一旦ここまで。
BUG出しに移る

Revision 1.7  2012-01-01 08:55:31  dezawa
CSVでのIOに問題あった

Revision 1.6  2011-12-21 10:33:46  dezawa
*** empty log message ***

