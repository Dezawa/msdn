# -*- coding: utf-8 -*-
=begin
パターン分類試行の記録
SHIMADA_PATERNING1 2014/7/6 14:13
  稼働無、2F 3→2 3一時低下まぁよい
  3F,4F  気になる落ち込みあり
        3O,3F,300,3-- ４ついずれにも 
        4F,400 いずれにも
  4→3、  4dに 3→4らしき動き見える
  4一時低下  4→3と微妙なのあり

  ＃ その他を 他 でなく、 遅、急変、にとりあえず分ける
  急変1は良さそう。
  急変2は、line2はよさそうだがline3はFが、line4はDが混じっていそう。詳細見る
      3急変2は朝の立ち上がりの不安定さ、
      4急変2は朝や日中の不安定さ。
    とりあえずこのままにする。
  3O
    14/2/5 落ち込みあるも、dif、difdifいずれにもかからず。

###
   稼働無 の分類はよい
   稼働2  2O             まぁよいが、急変2を含んでいる
   稼働3   -- 0- F 00 O  立ち上がり不安定、出遅れ、急変1,2、後引きを含む
   稼働4  00 F 立ち上がり不安定、出遅れ、急変２、後引きを含む
   -0 は概ねD
   -- は概ねDだが、いくつか異なる
   +-,0- はない。ありえないな。下に凸のみの形になるから
   ++,+0 は、理論的にはあるが、データにはなかった
   0+ はみなH
   00 は概ねFだが急変、立ち上がり変動あり
   F (二次微分に解なし）はほぼみな F だが遅れ、急変2を含む

   -+ は D、H、U、D+急変など多彩
   O   は概ね FないしR だが 、いくつか異なる

   -- -+,O についてもう少し見る

   --
      426 F  621急変2含む
      f4(f3_x1)(左のピーク)と f4(x2)(右の肩)の差が大きければ D そうでなければ F とする
      とりあえず100としたが、ちょっと大きすぎるかも
        --F は 稼働2,3,4 に含める
   -+
     3line  1/7 3/4 5/1 は F に近い。概ねD
     4line  9/11 Hに近い 9/27 Fかつ後引き 数字的には7/20,9/27 が特徴的だが、それでは読めない
以上 tag LAST_NOMAL
  正規化データでの近似式の値を使って分類していたが、予想・期待と異なり
  正規化データと補正後電力ではf2,f3の解の値がまるで異なることがわかった。
  なので、正規化データでの分類は止める。
以降、補正後電力での近似式の値を使って分類 やりなおし
  S  稼働無 OK
  F  F。立ち遅れなどはあり
      line2 は -+ と O があり、これはOK 

  -- FとDが混じる
  -0,00,0+,+0 は、理論的にはあるが、データにはなかった
  +-,0- はない。ありえないな。下に凸のみの形になるから
  -+ FH他入り混じってる
  O  概ねFか？ 要詳細分類
  ++ ほぼF

  --,-+,O について詳細詰める
  -+ 凹、右上がり、右下がり、stepUp、stepDownのいずれもがありえる
     凹(H)は f3x1,f3x3 におけるf4の差が少なく、f3x2のf4の落ち込みが大
       落ち込みをいくつにするか？ 150だと13/2/6 の111が、,,, 100 にしておく
  -- 肩の落ち具合で、FとDに分けた
  O  13/4/17,30 13/5/23,6/10,25,7/,8/全般,11/10、14/2/5
     14/3/1,3,10,12 Uか？  4/2
     Uか？と想われるものあるが、概ねF(一部R?)。異常含みが多い

 はて！！
    rev と nom で近似線の正負まで違うケースが
  一旦標準化はやめるか？

 急変１、２、出遅れ を定義した。


 蒸気補正を間違えていた。
   温度補正した値と蒸気量の関係を見るべき所、未補正電力と比べてしまっていた。

   修正すべきデータ
     蒸気補正後電力量
     季節変動
     これらのグラフ
     運転パターンの 蒸気、月間
     予測
     袋数と電力消費

   ついでに、
     岐阜の 年間 温度-水蒸気圧 グラフ
     岐阜と前橋の 15時での年間 温度-水蒸気圧 グラフ
###########################
3ライン稼働から見た年間変動
月      +α
 1 620  50
 2 615  45
 3 600  30
 4 570   0
 5 570   0
 6 570   0
 7 570   0
 8 570   0
 9 570   0
10 610  40
11 610  40
12 615  45
###

  3ライン稼働と思われる日を抜き出す
    全部     1302, 
    一部違う 1301, 1303 ,1304, 1305, 1306, 1309,1310, 1311, 1404, 1405
    違う日
id=68
puts "13-01 1,5,19,24
13-02 6 9
13-03 6,10,16,19,20,21
13-04 4, 8, 13,17, 20,27,30
13-05 2, 9, 11, 19, 20, 23, 25,30
13-06 1, 3, 8, 10, 12, 13,20, 21, 24, 30
13-07 
13-09 7, 11,16,  21, 22, 24, 28, 
13-10 1, 7, 12, 26 27,
13-11 6, 9, 10, 16,
14-01 1, 8, 15, 16, 17, 18, 21, 27
14-02 1, 5,  6, 15, 16, 7,10 12 13 14 17 18 19 20 21 22 23 24 25 26 27
14-03 8, 18, 25, 30, 4, 5, 13 14 16 20 2 
14-04 1, 5, 12, 14, 19, 26
14-05 2, 7, 10, 16, 19, 24, 30
14-06 22 25 2 3 4 17".split(/\n/).
map{|line| days=line.split(/[\s,]+/)
id += 1
  month = days.shift
  month="20#{month}"
  "month_id = '#{id}' and date not in (" +
   days.map{|d| "'#{month}-#{d}'"}.join(",")+")" 
   }.join(" or \n")

power = Shimada::Power.all(
  :conditions => "month_id = '69' and date not in ('2013-01-1','2013-01-5','2013-01-19','2013-01-24') or 
month_id = '70' and date not in ('2013-02-6','2013-02-9') or 
month_id = '71' and date not in ('2013-03-6','2013-03-10','2013-03-16','2013-03-19','2013-03-20','2013-03-21') or 
month_id = '72' and date not in ('2013-04-4','2013-04-8','2013-04-13','2013-04-17','2013-04-20','2013-04-27','2013-04-30') or 
month_id = '73' and date not in ('2013-05-2','2013-05-9','2013-05-11','2013-05-19','2013-05-20','2013-05-23','2013-05-25','2013-05-30') or 
month_id = '74' and date not in ('2013-06-1','2013-06-3','2013-06-8','2013-06-10','2013-06-12','2013-06-13','2013-06-20','2013-06-21','2013-06-24','2013-06-30') or 
month_id = '77' and date not in ('2013-09-7','2013-09-11','2013-09-16','2013-09-21','2013-09-22','2013-09-24','2013-09-28') or 
month_id = '78' and date not in ('2013-10-1','2013-10-7','2013-10-12','2013-10-26','2013-10-27') or 
month_id = '79' and date not in ('2013-11-6','2013-11-9','2013-11-10','2013-11-16') or 
month_id = '81' and date not in ('2014-01-1','2014-01-8','2014-01-15','2014-01-16','2014-01-17','2014-01-18','2014-01-21','2014-01-27') or 
month_id = '82' and date not in ('2014-02-1','2014-02-5','2014-02-6','2014-02-15','2014-02-16','2014-02-7','2014-02-10','2014-02-12','2014-02-13','2014-02-14','2014-02-17','2014-02-18','2014-02-19','2014-02-20','2014-02-21','2014-02-22','2014-02-23','2014-02-24','2014-02-25','2014-02-26','2014-02-27') or 
month_id = '83' and date not in ('2014-03-8','2014-03-18','2014-03-25','2014-03-30','2014-03-4','2014-03-5','2014-03-13','2014-03-14','2014-03-16','2014-03-20','2014-03-2') or 
month_id = '84' and date not in ('2014-04-1','2014-04-5','2014-04-12','2014-04-14','2014-04-19','2014-04-26') or 
month_id = '85' and date not in ('2014-05-2','2014-05-7','2014-05-10','2014-05-16','2014-05-19','2014-05-24','2014-05-30') or 
month_id = '86' and date not in ('2014-06-22','2014-06-25','2014-06-2','2014-06-3','2014-06-4','2014-06-17')
)
pp Shimada::Power.maybe3lines.group_by{|pw| pw.month_id}.
map{|id,pws| pws.map{|pw| pw.revise_by_vaper[14]}.average.round(0)}
pp Shimada::Power.maybe3lines.group_by{|pw| pw.month_id}.
map{|id,pws| pws.map{|pw| pw.revise_by_vaper[14]}.standard_devitation.round(1)}

これらの 15時のpowerの平均,σは
  1     2    3    4    5    6    9   10   11    1    2    3    4    5   6
[635, 617, 578, 574, 592, 577, 577, 599, 609, 608, 611, 625, 565, 552, 552]
[28.2,21.6,31.2,20.6,23.3,26.3,41.5,15.7,22.0,29.5,37.0,59.8,26.5,17.6,33.9]


=end
           


class Shimada::Month < ActiveRecord::Base
  extend ExcelToCsv
  require 'shimada/factory_module.rb'
  #ShimadaMoonth = { "GMC" => Shimada::Month , "中部シマダヤ" => Shimada::Chubu::Month}
  
  #self.table_name= 'shimada_months'
  has_many :shimada_powers ,:class_name =>  "Shimada::Power" ,:dependent => :delete_all
  belongs_to :shimada_factory     ,:class_name => "Shimada::Factory"

  def powers
    @powers ||= shimada_powers.sort_by{ |p| p.date }
  end

  class << self
    
    def csv_upload(file,factory)
      factory = Shimada::Factory.find(factory) if factory.class == Integer
      return Shimada::Chubu::Month.csv_upload(file,factory) if factory.name == "中部シマダヤ"
      csv_files(file).each{ |csvfile|  create_month_by(csvfile) }
      Shimada::Power.delete_all("hour01 = '0.0'")
    end

    def  create_month_by(csvfile)
      lines = File.read(csvfile).split(/[\r\n]+/)
      while create_one_month_by(lines);end
    end

    def  create_one_month_by(lines)
      year = search_year(lines)
      return nil unless year

      data_clm,days =search_monthdate(lines)
      
      lastday = Date.new(year,*days.first.split("/").map(&:to_i)).end_of_month.day
      days = days[0,lastday].map{ |d| Date.new(year,*d.split("/").map(&:to_i))}
      skip_untile_first_data_line(lines)
      
      month = self.find_or_create_by(month: days.first)
      powers = days.map{ |day| Shimada::Power.find_or_create_by(date:  day) }
      set_power(powers,lines)
      month.shimada_powers = powers
    end

    def search_year(lines)
      line=lines.shift
      until /^,?(201\d)/ =~ line
        line=lines.shift 
        return nil unless line
      end
      $1.to_i
    end

    def search_monthdate(lines)
      line=lines.shift
      until /月日/ =~ line; line=lines.shift ;end
      clms = line.split(",")
      hour_clm = clms.index("月日")
      [hour_clm,clms[hour_clm+1..-1]]
    end

    def skip_untile_first_data_line(lines)
      line=lines.shift
      until /時間/ =~ line; line=lines.shift ;end
    end


    def set_power(powers,lines)
      Shimada::Power::Hours.each_with_index{ |hour,idx|
        clms = (line = lines.shift).split(",")
        raise RuntimeError,"時刻が合わない: #{line}" if idx+1 != clms.shift.to_i
        powers.each{ |power| power[hour] = clms.shift.to_f }
      }
         line=lines.shift until /袋数/ =~ line
logger.debug("SET_POWER:#{line}")
      clms = line.split(",")
      clms.shift
      powers.each{ |power| power[:hukurosu] = clms.shift.to_f ;power.save}
    end



end
end
