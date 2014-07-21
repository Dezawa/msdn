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
=end


class Shimada::Month < ActiveRecord::Base
  extend ExcelToCsv
  
  set_table_name 'shimada_months'
  has_many :shimada_powers ,:class_name =>  "Shimada::Power" ,:dependent => :delete_all

  def powers
    @powers ||= shimada_powers.sort_by{ |p| p.date }
  end

  class << self

    def csv_upload(file)
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
      
      month = self.find_or_create_by_month(days.first)
      powers = days.map{ |day| Shimada::Power.find_or_create_by_date( day) }
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
        powers.each{ |power| power[:hukurosu] = clms.shift.to_f ;power.save}
    end



end
end
