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
  SoukoSort = [["全て",/^[1-6]|^7[A-D]|^0[A-GJ-L]/],
               ["1～3",/^[123][A-DF]/],
               ["4～6",/^[456][G-KO]/],
               ["2F",/^[25][ELMN]/],
               ["総合",/^0[A-G]/],
               ["野積",/^7[A-D]/],
               ["AC跡",/^0[JKL]/],
               ["LD倉庫",/^[1-6]/]
         ]
  GradeSort = [["製品","1","brue",18600],["OG","2","green",500],
               ["原料","Z","red",1000],["再処理","R","purple",500],["長期","","brown",500]]

  #Extension = [:tuuro ,:products ,:not_products]
  Extension = [:tuuro ,:products ,:target_weight]
  Label = { 
    :tuuro        => "年月日 "+ 
                      SoukoSort.map{ |name,reg| "10桝以上穴数 5-9桝穴数 1-4桝穴数 通路置き量 通路置き枠数"
                     }.join(" ") ,
    :products     => "年月日"+  " 重量"+ SoukoSort.map{ |name_reg| name_reg[0]}.join(" ") ,
    :not_products => "年月日  原料 SCP スネーク 再処理 長期" ,
    :target_weight => "年月日 "+ GradeSort.map{ |lbl,dmy| lbl }.join(" ")
  }
  label = 
    "年月日"+  " 穴" + SoukoSort.map{ |name_reg| "10桝以上穴数 5-9桝穴数 1-4桝穴数"}.join(" ") +
    #1
      " 穴" + SoukoSort.map{ |name_reg| "10桝以上穴数 5-9桝穴数 1-4桝穴数"}.join(" ") + # 2～,5～ ,8～,11～,14～16
      " 重量"+ SoukoSort.map{ |name_reg| name_reg[0]}.join(" ") +               # 17,18,19,20,21
      " 通路" + SoukoSort.map{ |name_reg| %w(通路置き量 通路置き枠数)}.flatten.join(" ") + # 23,25,27,29,31
      " 原料 SCP スネーク 再処理 長期"  # 32 33 34 35 36
              

  def initialize(waku_waku,date_of_file)
    @today = Time.local(*(/(\d{4})(\d\d)(\d\d)/.match(date_of_file).to_a)[1,3])
    @point = { 
      :tuuro        =>  [date_of_file] + (vacants_list.zip(tuuro)).flatten ,# 穴数# 通路重量、枠数
      :products     =>  [date_of_file] + weights.flatten ,             # 総量
      :not_products =>  [date_of_file] + weights_not_product.flatten ,  # 製品以外 
      :target_weight => [date_of_file] + target_weight.flatten   
    }
  end

  def  tuuro
    SoukoSort.map{ |name_reg| Ubr::Waku.tuuro_weight_wakusuu(name_reg[1],WithoutPull)}
  end


  # 製品 OG 原料 再処理 長期 
  #       G123B028-----S--F7
  #       01234567890123
  def target_weight
    grade_sort = GradeSort.map{ |lbl,grade,color,limit|
      Ubr::LotList.lotlist.select{ |id,lot| lot.grade == grade }.inject(0){ |s,l| s+l[1].weight}
    }
    
    scp     = Ubr::LotList.lotlist.select{|id,l| /^G123SCP/ =~ l.meigara_code  }.
      inject(0){ |s,l| s+l[1].weight}
    grade_sort[2] -= scp

    grade_sort[4] = Ubr::LotList.lotlist.select{ |id,lot| @today - lot.packed > 2.year}.
      inject(0){ |s,l| s+l[1].weight}
   
    grade_sort.map{ |w| (w*0.000001)}
  end

  # 原料 SCP スネーク、再処理、長期 
  #       G123B028-----S--F7
  #       01234567890123
  def weights_not_product
    genryou_lot = Ubr::LotList.lotlist.
      select{ |id,lot| /Z/ =~ lot.grade && /^G123(ZM085|J3519|Z670|SCP)/ !~ lot.meigara_code }
    genryou = genryou_lot.inject(0){ |s,l| s+l[1].weight}
    scp     = Ubr::LotList.lotlist.select{|id,l| /^G123SCP/ =~ l.meigara_code  }.inject(0){ |s,l| s+l[1].weight}
    snake   =  Ubr::LotList.lotlist.select{|id,l| /^G123(ZM085|J3519|Z670)/ =~ l.meigara_code  }.
      inject(0){ |s,l| s+l[1].weight}
    saishori = 
     Ubr::LotList.lotlist.select{ |id,lot| lot.meigara_code[13,1] == "S" }.inject(0){ |s,l| s+l[1].weight}
    tyouki = 
     Ubr::LotList.lotlist.select{ |id,lot| @today - lot.packed > 2.year}.inject(0){ |s,l| s+l[1].weight}

    [ genryou,scp,snake,saishori,tyouki ].map{ |w| (w*0.001).to_i}
  end

  # [ 10以上、5以上、1以上(全数)]
  def vacants_list
    SoukoSort. #[/^[1-6][A-Y]|^0[A-GJ]/,/^[1-6][A-Y]/,/^0[A-GJ]/].
      map{ |idx_or_name|
      vacants = [0]+Ubr::Waku.empty_number_by_masusuu(idx_or_name[1],[10,5,1]) +[0]
      #  全量<-[2]-0, 10未満<- [2]-[0],5未満 <- [2]-[1]
      #  全量<-[3]-[0], 10未満<- [3]-[1],5未満 <- [3]-[2]  左に0を入れたから
      vacants_sum     = (0..2).map{ |i| vacants[3] - vacants[i]}
    }
  end

  def weights
    SoukoSort.map{ |souko_reg|
      "%.2f"%(Ubr::Waku.weight_of_aria(souko_reg[1])*0.000001)
    }
  end

  def save
    save_self
    self.class.make_average_all
  end

  def save_self
    Extension.each{ |extension|
      path = Ubr::Const::SCM_stock_stat_FILEBASE+"_#{extension}.stat"
      lines = File.exist?(path) ? File.read(path).split(/[\n\r]+/).map{ |l| l.split} : []

      header = lines.shift if lines[0] && /201\d{5}/ !~ lines[0][0]
      if samedate = lines.index{ |l| l[0] == @point[extension][0]}
        lines[samedate] = @point[extension].flatten
      else
        lines = lines.push(@point[extension]).sort_by{ |l| l[0] }
      end

      label = Label[extension]
              
      open(path,"w"){ |fp|
        fp.puts(label)
        fp.puts lines.map{ |l| l.join(" ")}.join("\n")
      }

     # make_average(extension,label,lines)
    }
  end

  def self.make_average_all
    Extension.each{ |extension|
      path = Ubr::Const::SCM_stock_stat_FILEBASE+"_#{extension}.stat"
      lines = File.exist?(path) ? File.read(path).split(/[\n\r]+/).map{ |l| l.split} : []
      label = Label[extension]
      make_average(extension,label,lines)
    }
  end

  def self.average(row,orig,firstday,lastday) 
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

  #                              2014/5/23 のとき
  # 毎日    先週以降                5/12～5/23
  # 毎週    先月頭                    4/
  # 毎月    先々々四半期         2013/10～
  # 四半期  先年度               2013/4 ～
  # 年度    先々年度以前
  def self.make_average(extension,label,orig)
    orig.each{ |row| row[0] = Time.parse(row[0]).to_date}
    @today     = orig[-1][0]

    path = Ubr::Const::SCM_stock_stat_FILEBASE+"_#{extension}.ave"
    open(path,"w"){ |fp|
      fp.puts label
      rowsize =  orig[0].size
      
      while row = orig.shift
        from,to,fmt = from_to(@today,row[0])
        if from
          ave = average(row,orig,from,to)
          fp.puts ave[0].strftime(fmt) + ave[1..-1].join
        else
          fp.puts row[0].strftime("%m%d ")+row[1..-1].join(" ")
        end
      end
    }
  end

  def from_to(today,date)
    wday0      = today.beginning_of_week
    wday1      = wday0 -  1.week    #   この日までは毎日
    wday9      = wday0 -  9.week    #   
    month0     = wday0.beginning_of_month
    month1     = month0.last_month  #.last_month
             
    this_quarter = today.beginning_of_quarter
    quarter2     = this_quarter - 6.month
    this_year  = today.beginning_of_year
    this_annual= this_year + 3.month
    this_annual= this_annual.last_year if today.month<4
    last_annual= this_annual - 1.year

    if date  >= wday1        #   この日までは毎日
      return false

      # 週平均
    elsif date >= wday9 && date >= month1        #   この日までは週平均
      [date.beginning_of_week,date.beginning_of_week+7.day,"%m%d- "]
    elsif date >= quarter2   #   この日までは月平均              
      [date.beginning_of_month,date.beginning_of_month+1.month,"%y年%m "]
    elsif date >= last_annual   #  四半期平均
      [date.beginning_of_quarter,date.beginning_of_quarter+3.month,"%y年%m- "]
    else                       #   年度平均
      [date.beginning_of_annual,date.beginning_of_annual+1.year,"%y年度 "]
    end
  end

  def self.remake
    File.rename(Ubr::Lot::SCMFILE,Ubr::Lot::SCMFILE+"save")
    Dir.glob(File.join(RAILS_ROOT,"tmp","ubr","save","*.csv")).sort.each{ |csvpath|
      puts csvpath
      open(Ubr::Lot::SCMFILE,"w"){ |fp| fp.write(File.read(csvpath))}
      @waku_waku     = Ubr::Waku.waku(true) #load_from_master
      Ubr::LotList.lotlist(true)
      self.new(@waku_waku,(/201\d{5}/.match(csvpath)[0])).save_self if /201\d{5}/.match(csvpath)[0]
    }
    self.make_average_all
    File.rename(Ubr::Lot::SCMFILE+"save",Ubr::Lot::SCMFILE)
  end

end
class Time
  def beginning_of_annual
    this_year  = self.beginning_of_year
    this_annual= this_year + 3.month
    this_annual= this_annual.last_year if self.month<4
    this_annual
  end
end
class Date
  def beginning_of_annual
    this_year  = self.beginning_of_year
    this_annual= this_year + 3.month
    this_annual= this_annual.last_year if self.month<4
    this_annual
  end
end

