# -*- coding: utf-8 -*-
# Uploadされた在庫一覧から、本日の倉庫の得点を出す。
# 通路置き 数、総量
# 総在庫量(製品、原料、再処理、長期 に分けるか？）
# 穴数(大きさで分けるか？）
# 半分以上空き枠
# 
# 計算の度に求めて記録していくが、同じ日付だったら上書き
#    DBいるか？ date 総在庫量(製品、原料、再処理、長期) 通路置き 数、総量、穴数 半分以上空き枠
#    ここでDB作っちゃうならWakuこそDBかなぁ
class Ubr::Point

  @dir= File.dirname(__FILE__)
  if /www/ =~ @dir
    $LOAD_PATH << @dir
    MasterDir =  @dir
  else
    $LOAD_PATH << File.join(File.dirname(__FILE__),"../System") << "~/lib/ruby"
    MasterDir =  File.join(@dir,"../System/Master")
  end

  SoukoSort = [["全て",/./],
          ["1～3",/^[123][A-DF]/],
          ["4～5",/^[456]/],
          ["2F",/^[25][ELMN]/],
          ["総合",/^0[A-GJ]/]
         ]

  def initialize(waku_waku,date_of_file)
    today = Time.local(*(/(\d{4})(\d\d)(\d\d)/.match(date_of_file).to_a)[1,3])
    # [ 10以上、5以上、1以上(全数)]
    vacants_list = SoukoSort. #[/^[1-6][A-Y]|^0[A-GJ]/,/^[1-6][A-Y]/,/^0[A-GJ]/].
      map{ |idx_or_name|
      vacants = [0]+Ubr::Waku.empty_number_by_masusuu(idx_or_name[1],[10,5,1]) +[0]
      #  全量<-[2]-0, 10未満<- [2]-[0],5未満 <- [2]-[1]
      #  全量<-[3]-[0], 10未満<- [3]-[1],5未満 <- [3]-[2]  左に0を入れたから
      vacants_sum     = (0..2).map{ |i| vacants[3] - vacants[i]}#.reverse
      #vacants_between = (0..2).map{ |i| vacants[i+1]-vacants[i]}
      #[vacants_sum,vacants_between]
      vacants_sum
    }

    weights = SoukoSort. #[/^[1-6]/,/^0[A-FJ]/,/^[789]/,/^0[^A-FJ]/,/^[^0-9]/].
      map{ |souko_reg|
      "%.2f"%(Ubr::Waku.weight_of_aria(souko_reg[1])*0.000001)
    }
    #total_weight = weights.inject(0){ |s,v| s+v}

    tuuro  = SoukoSort.map{ |name_reg| Ubr::Waku.tuuro_weight_wakusuu(name_reg[1])}
    # 原料、再処理、長期 
    #       G123B028-----S--F7
    #       01234567890123
    weights_not_product = 
      [
       Ubr::LotList.lotlist.select{ |id,lot| /Z/ =~ lot.grade }.inject(0){ |s,l| s+l[1].weight},
       Ubr::LotList.lotlist.select{ |id,lot| lot.meigara_code[13,1] == "S" }.inject(0){ |s,l| s+l[1].weight},
       Ubr::LotList.lotlist.select{ |id,lot| today - lot.packed > 2.year}.inject(0){ |s,l| s+l[1].weight}
      ].map{ |w| (w*0.001).to_i}
    @point = [date_of_file] + #[date_of_file.sub(/^..../,"")] +
      vacants_list +                   # 穴数
      weights +                        # 総量
      tuuro +                          # 通路重量、枠数
      weights_not_product              # 製品以外 
    #Ubr::Waku.tuuro_weight_wakusuu + # 全通路 重量、枠数
    #vacants_list[0] + 
      #[total_weight]+ weights + 
      #weights_not_product +
      #vacants_list[1][1] + vacants_list[2][1] +
      #Ubr::Waku.tuuro_weight_wakusuu(/^[1-6]/)+
      #Ubr::Waku.tuuro_weight_wakusuu(/^0[A-GJ]/)
  end

  def save
    path = Ubr::Lot::SCMFILEBASE+".stat"
    lines = File.exist?(path) ? File.read(path).split(/[\n\r]+/).map{ |l| l.split} : []
    header = lines.shift if lines[0] && /201\d{5}/ !~ lines[0][0]
    if samedate = lines.index{ |l| l[0] == @point[0]}
      lines[samedate] = @point.flatten
    else
      lines = lines.push(@point).sort_by{ |l| l[0] }
    end

      label = "年月日"+
      " 穴" + SoukoSort.map{ |name_reg| "10桝以上穴数 5-9桝穴数 1-4桝穴数"}.join(" ") +
      " 重量"+ SoukoSort.map{ |name_reg| name_reg[0]}.join(" ") +
      " 通路" + SoukoSort.map{ |name_reg| %w(通路置き量 通路置き枠数)}.flatten.join(" ") +
      " 原料 再処理 長期"
              
    open(path,"w"){ |fp|
      #fp.puts "年月日 通路総量 通路置枠数 "+   # 1,2,3
      #"全穴数 10桝以下穴 4桝以下穴 10桝以上穴数 5-9桝穴数 1-4桝穴数 "+  # 4 - 9
      #"総量 1-6 0A-0F,J 789 0GH  その他 " +                             # 10 - 15, 16-18
      #"原料 再処理 長期 "+ # 1-6        0A-G,J                            1-6        0A-G,J
      #"10桝以上穴数 5-9桝穴数 1-4桝穴数 10桝以上穴数 5-9桝穴数 1-4桝穴数  通路総量 枠数  通路総量 枠数"
          # 19 -24                                                         25 - 28
      #fp.puts lines.map{ |l| l.join(" ")}.join("\n")

      fp.puts(label)
      fp.puts lines.map{ |l| l.join(" ")}.join("\n")
    }

    make_average(label,lines)
  end

def average(row,orig,firstday,lastday)
  sum = row[0,1] + row[1..-1].map{ |s| s.to_f}
  count = 1
  while row0=orig.shift
    break if row0[0]>=lastday
    (1..sum.size-1).each{ |i| sum[i] += row0[i].to_f}
    count += 1
  end
  orig.unshift(row0) if row0
  (1..sum.size-1).each{ |i| sum[i] = "%.1f "%(sum[i]/count)}
  
  sum[0] = firstday#.strftime("%Y%m%d")
  sum
end

def make_average(label,orig)
  orig.each{ |row| row[0] = Time.parse(row[0]).to_date}
  today = orig[-1][0]
  wday0  = today.beginning_of_week
  wday1  = wday0 -  1.week  #   この日までは毎日生
  wday9  = wday0 -  9.week  #   
  month0 = wday0.beginning_of_month
  month1 = month0.last_month#.last_month

  open(Ubr::Lot::SCMFILEBASE+".ave","w"){ |fp|
    fp.puts label
    rowsize =  orig[0].size

    while row = orig.shift
      if row[0] >= wday1
        fp.puts row[0].strftime("%Y%m%d ")+row[1..-1].join(" ")

        # 週平均
      elsif row[0] >= wday9 && row[0] >= month1
        ave = average(row,orig,row[0].beginning_of_week,row[0].beginning_of_week+1.week)
        fp.puts ave[0].strftime("%Y%m%d- ") + ave[1..-1].join
      else
        ave = average(row,orig,row[0].beginning_of_month,row[0].beginning_of_month+1.month)
        fp.puts ave[0].strftime("%Y/%m ") + ave[1..-1].join
      end
    end
  }
  end

  def self.remake
    File.rename(Ubr::Lot::SCMFILE,Ubr::Lot::SCMFILE+"save")
    Dir.glob(File.join(RAILS_ROOT,"tmp","ubr","save","*.csv")).sort.each{ |csvpath|
      open(Ubr::Lot::SCMFILE,"w"){ |fp| fp.write(File.read(csvpath))}
      @waku_waku     = Ubr::Waku.waku(true) #load_from_master
      Ubr::LotList.lotlist(true)
      self.new(@waku_waku,(/201\d{5}/.match(csvpath)[0])).save
    }
    File.rename(Ubr::Lot::SCMFILE+"save",Ubr::Lot::SCMFILE)
  end



  
end
