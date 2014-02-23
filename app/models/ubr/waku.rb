#!/usr/local/bin/ruby
# -*- coding: utf-8 -
require 'pp'
require 'csv'
#require 'postscript'
#require 'ubr/const'
module Ubr
class Waku < ActiveRecord::Base
  extend Function::CsvIo
  case RAILS_GEM_VERSION
  when /^2/ ;set_table_name 'ubr_wakus'
  when /^[34]/ ; self.tabele_name =  'ubr_wakus'
  end
  delegate :logger, :to=>"ActiveRecord::Base"

  Direction = { "↑"=>Pos[0,-1],"↓" =>Pos[0,1], "→" => Pos[1,0],"←" => Pos[-1,0]}
  Aria = %w(1号倉庫 2号倉庫 3号倉庫 4号倉庫 5号倉庫 6号倉庫 2号2階 5号2階 総合倉庫 AP跡 野積 番兵).
    #SPE倉庫 7号残 0H 番兵).
    zip([ /^[1]/,/^2[CD]/,/^3/,/^4/,/^5[I-K]/,/^6/,/^2E/,/^5[LMN]/,/^0[A-H]/,/^0[J-L]/,/^7/,/./])
  AriaEx = %w(SPE倉庫 7号残 0H 番兵).zip([/^7[^A-E]/,/^0H/,/./])
  Place=Aria
  Kata      = { 
    ["↑","N"] => :UN, ["↓","N"] => :DN, 
    ["→","N"] => :RN, ["←","N"] => :LN, 
    ["↑","14"] => :U14, ["↓","14"] => :D14, 
    ["→","14"] => :R14, ["←","14"] => :L14, 
    ["↑","11"] => :U11, ["↓","11"] => :D11, 
    ["→","11"] => :R11, ["←","11"] => :L11, 
    #"↑","N"] => :HN, ["↓","N"] => :HN, 
    #"→","N"] => :VN, ["←","N"] => :VN, 
    ["↑","S"] => :HS, ["↓","S"] => :HS, 
    ["→","S"] => :VS, ["←","S"] => :VS
  }

  attr_accessor  :enable,:kawa_suu,:direction,:aria
  
  attr_writer :lot_list,:pos_xy

  def after_find
    @lot_list = []
  end

  def self.waku(reload=false)
    if !$Waku || reload
      $Waku = { }
    end
    return $Waku if $Waku.size>0
    $Waku = Hash[*self.all.map{ |waku| [waku.name,waku]}.flatten]
  end  

 def self.by_name(name) ; waku[name]; end
  def self.idx_or_name2name(idx_or_name)
    case idx_or_name
    when Integer ; Aria[idx_or_name].first
    when /^\d+$/ ; Aria[idx_or_name.to_i].first
      
    else         ; idx_or_name
    end
  end

  def self.tuuro(idx_or_name=nil)
    case idx_or_name
    when nil
      waku.values.select{ |w| /Z$/ =~ w.name } 
    when      Integer ; aria = Aria[idx_or_name].first
      waku.values.select{ |w| w.aria ==  aria && /Z$/ =~ w.name } 
    when String       ;
      waku.values.select{ |w| w.aria ==  idx_or_name && /Z$/ =~ w.name } 
    when Regexp
      waku.values.select{ |w| idx_or_name =~ w.name && /Z$/ =~ w.name } 
    end    
  end
  def self.aria(idx_or_name,active = true)
    ret = 
      case idx_or_name
       when Regexp
         waku.select{ |name,wk| idx_or_name =~ name }.map{ |name,wk| wk}
       else 
         aria = idx_or_name2name(idx_or_name)
        waku.values.select{ |w| w.aria ==  aria }
       end
    active ? ret.select{ |wk| wk.direction} : ret
  end

  def direction ; Direction[direct_to] ;end
  def aria      ; Aria[Aria.index{|p| p[1] =~ name}][0]; end
  def kata      ;     Kata[[direct_to||"↑",palette || "N"]] ;  end
  def kawa_suu  ; @kawa_suu ||= (dan1||0) +(dan2||0)  +(dan3||0)   ;end
  def volum3    ; @volum3   ||= (dan1||0) +(dan2||0)*2+(dan3||0)*3 ;end
  def tuuro?    ; !!(/Z$/ =~ name) ; end
  def to_s      ; self.name ; end
  def pos_xy    ; @pos_xy ||= Pos[pos_x,pos_y]  ;end



  def self.load(file = "Master/Waku.csv") # 名前 川数
    CSV.foreach(file) do |row|
      next unless row[0] #&& row[1]
      $Waku[row[0]] = 
        Waku.new(:name => row[0],:kawa_suu => row[1].to_i
                 )
    end
    $Waku
  end
  
  def self.load_from_master(file = nil)
    file ||= File.join(Const::MasterDir,"SoukoMaster.csv")
    # 倉庫ブロック,枠,   ,容量/kg
    # 0A,01,00:通常,30000
    $Waku = {} 

    CSV.foreach(file) do |row|
      next unless /^[\dKORTZ][a-dA-Z\d]/ =~ row[0] #&& row[1]
      
      $Waku[row[0]+row[1]] = 
        Waku.new(:name => row[0]+row[1],
                 :dan3 => row[4].to_i,
                 :dan2 => row[5].to_i,
                 :dan1 => row[6].to_i,
                 :kawa_suu => row[4].to_i+row[5].to_i+row[6].to_i,
                 :pos_x => row[8].to_f,
                 :pos_y => row[9].to_f,
                 :retusu    => (row[12] || 1 ).to_i,
                 :direction => Direction[row[10]],
                 :kata => Kata[[row[10]||"↑",row[11]|| "N"]],
                 :volum3 => (row[4].to_i * 3 + row[5].to_i * 2 + row[6].to_i)#*1000
                 )
    end

    $Waku
  end

  def self.load_by_define(file = "Master/WakuBase.csv")
    $Waku rescue  $Waku = {} 
    block = colmname = nil
    CSV.foreach(file,:headers => true){ | row|
      next unless (kawa=row[2]) && (retu = row[3])
      case row[1]
      when String
        block = row[1] 
        colmname  = row[4]
        unless colmname ;  puts row; raise "列の名前がない"; end
      else
        colmname  = row[4] if row[4]
      end

      #pp [row[1],block,retu,row]
      (1..retu.to_i).each{|r| 
        waku = new(:name => (block + colmname),
                        :volum2 => kawa.to_i*2,
                        :volum3 => (kawa.to_i*3 - (row[5] || "0").to_i)
                        ) 
        $Waku[block + colmname] = waku
        colmname.succ!
      }
    }
  end

  ######## Ube::Lotとの関連
  def lot_list(without_pull = false)
    return @lot_list unless without_pull
    @lot_list.select{|seg| !seg.pull? }
  end

  def paret_su(without_pull = false)
    lot_list(without_pull).inject(0){|sum,seg| sum + seg.paret_su}
  end

  def empty?(without_pull = false) ; 
    without_pull ? lot_list.select{ |seg| !seg.pull? && /Z$/ !~ name }.size == 0 :
      lot_list.select{ |seg| /Z$/ !~ name }.size == 0
  end
  def add(lot_segment);    @lot_list << lot_segment
  end
  def remove(lot_segment);    @lot_list.delete(lot_segment) ;  end

  def weight(without_pull = false)
    lot_list(without_pull).inject(0){|wt,segment| wt + segment.weight }
  end

  def drift_by_mult_retu
    [(direction[0] == 0 ? 1 : 0),(direction[1] == 0 ? 1 : 0)]
  end


  #def tuuro? ; /Z$/ =~ name ;end

  #  [空き,引き合い,引き合い無,過剰]
  def used_map
    without = occupied(WithoutPull)  # 引き合い含まず
    within  = occupied(WithPull) # 引き合い込み
    if tuuro? # 通路のときはmasu数は無限なので、占有数だけあることにする
      masu     = within #.to_f/retusu).ceil 
    else
      masu     = kawa_suu * retusu
    end
    vacunt = [ masu - within,0].max
    ary = [ vacunt,                                              # 空枠
            [masu - vacunt - without,0].max,                    # 引き合い
            without <= masu+1 ? [masu, without].min : 0,       # 埋まり
            without >  masu+1 ? [without-1-masu,masu].min : 0] # 超過
    ary[2] = masu - ary[3] if ary[3]>0                           # 埋まり
    destribute_ary(ary,masu)
  end

  # ary（空き、埋まり、引き合い、溢れ） をretusu列に分ける
  def destribute_ary(arg_ary,masu=nil)
    masu ||= kawa_suu * retusu
    ary = arg_ary.dup
    k_suu = Array.new(retusu){ |a| a=masu/retusu} #kawa_suu}
    aary = Array.new(retusu){ |a| a=[0,0,0,0]}
    if tuuro? # 通路のときは複数列均等に分ける
      if retusu == 1
        aary[0] = ary
      else
        (1..2).each{ |s|
          (0..retusu-2).each{ |r| 
            aary[r][s] = [k_suu[r],ary[s]/retusu].min
            ary[s]   -=  aary[r][s]
            k_suu[r] -=   aary[r][s]
          }
          aary[retusu-1][s] = ary[s]
        }
      end
    else # 通常枠は複数列端から振り分ける
      (0..3).each{ |s| 
        (0..retusu-1).each{ |r| 
          aary[r][s] = [k_suu[r],ary[s]].min
          ary[s]   -=  aary[r][s]
          k_suu[r] -=   aary[r][s]
        }
      }
    end
    aary
  end

  # 何桝使われているか求める
  # 3段積みフレコンと40袋積んだ紙袋パレットは、規程の段数積まれる
  # 11型パレットとY14は2段積み.
  # 包装日の順に奥から詰める。
  # ロットが異なる場合は重ねない。但し1トン以下の紙袋の場合は重ねる
  # 40袋に満たない紙袋パレットは積み過ぎると危ないので24面を上限にする
  #   面とは、5俵8段で1パレットだが、段が多義なので5俵8面と表現する
  #   これにパレットの 1面を加え、1tonパレット3段だと3x9=27面となる。
  #   8面積みパレットが1or2段ある上に乗せる場合も合わせて24面を上限とする。
  #   計算は「24で除して繰り上げ」で済ませる。
  def occupied(without_pull = false)
    # 1段～3段積み桝でまだ残っている数
    remain = [ 0,dan1,dan2,dan3] 

    # ロットを包装日の順に並べ、 1トン以下の紙袋とそれ以外に分ける
    lot_main_part , lot_paper_le_1ton = lot_sort_by_packed(without_pull)

    # 包装日の順に奥から詰める。
    masu_need = lot_main_part.
      inject(0){ |need,seg| f= stack_palet(seg,remain);need + f} # stack_palet(seg,remain) }

    # 1トン以下の紙袋を詰める
    masu_need += stack_paper_palet(lot_paper_le_1ton,remain)
    masu_need
  end

  def lot_sort_by_packed(without_pull=false)
    sort_by_packed = lot_list(without_pull).sort_by{ |seg| seg.lot.packed_date}
    lot_paper_le_1ton  = 
      sort_by_packed.select{ |seg| seg.count <= 40 &&  /^N/ =~ seg.lot.keitai }
    lot_main_part      =
      sort_by_packed.select{ |seg| seg.count >  40 ||  /^N/ !~ seg.lot.keitai }
    [lot_main_part,lot_paper_le_1ton ]
  end

  def stack_palet(seg,remain)
    case stack_limit=seg.lot.stack_limit
    when 3 ;   stack_3dan(seg.paret_su,remain)
    when 2 ;   stack_2dan(seg.paret_su,remain)
    else   ;   stack_1dan(seg.paret_su,remain)
    end
  end
  
  def stack_3dan(parets,remain)
    if parets <= 3*remain[3] 
      y = (parets/3.0).ceil
      remain[3] -= y
      y
    elsif parets <= 3*remain[3] + 2*remain[2] 
      yy = parets  - remain[3]
      y = (yy*0.5).ceil
      remain[2] -= (y - remain[3])
      remain[3] = 0 
      y
    elsif parets <= 3*remain[3] + 2*remain[2] + remain[1]
      y = parets  - 2*remain[3]-remain[2]
      remain[1] -= (y - remain[3] - remain[2])
      remain[3] = remain[2] = 0
      y      
    else # 容量オーバーの時は、3段積みで枠外に、とする
      yy = parets - 3*remain[3]-2*remain[2]-remain[1]
      y = (yy/3.0).ceil + remain[3] + remain[2] + remain[1]
      remain[3] = remain[2] = remain[1] =0
      y
    end
  end

  def stack_2dan(parets,remain)
    if parets <= 2*remain[3]
      yy = parets
      y = (yy*0.5).ceil
      remain[3] = remain[3]-y
    elsif parets <= 2*(remain[2]+remain[3])
      yy = parets 
      y = (yy*0.5).ceil
      remain[2] -= y-remain[3]

      remain[3] =  0 
    elsif parets <= 2*(remain[2]+remain[3]) + remain[1]
      y = parets - remain[2]-remain[3] # d1 = p - 2(d2+d3), d1+d2+d3 = p-d2-d3
      remain[1] -= (y - remain[3] - remain[2])
      remain[3] = remain[2] = 0
      y
    else     
      y = (remain[2]+remain[3]+ remain[1])+ #空き枠に収まった分
        ((parets - 2*(remain[2]+remain[3]) - remain[1])*0.5).ceil # 足りない分
      remain[3] = remain[2] = remain[1] = 0
      y
    end
      y
  end


  def stack_1dan(parets,remain)
    if parets <= remain[3]
      y = parets
      remain[3] = remain[3]-y
    elsif parets <= remain[2]+remain[3]
      y = parets
      remain[2] -= y-remain[3]
      remain[3] =  0 
    elsif parets <= remain[2]+remain[3] + remain[1]
      y = parets
      remain[1] -= (y - remain[3] - remain[2])
      remain[3] = remain[2] = 0
    else     
      y = parets
      remain[3] = remain[2] = remain[1] = 0
    end
    y
  end

  #とりあえず、全量を一枡3トンで積むことにして計算する
  def stack_paper_palet(lot_paper_le_1ton,remain)
    (lot_paper_le_1ton.inject(0){ |count,seg| count + seg.count}/40.0).ceil
  end

  # 空の桝が 3段桝 n3, 2段桝 n2, 1段桝 n1個あり、
  # 一杯でない桝の積み余裕が  3段桝 m3, 2段桝 m2 ある時
  # パレット p個は桝をいくつ使うか、一杯でない桝を残すか
  # 
  # 3段積みパレットの時
  #   桝x個で yパレットを積むと
  #     x <= n3             : y = 3 * x + Σm
  #     n3 < x <= n3+n2     : y = 2*(x-n3) + 3 * n3 + Σm
  #     n3+n2 < x           : y = x -(n3+n2) + 3*n3+2*n2  + Σm
  # 
  #  すなわち
  #    a) y <= 3 * n3 + Σm                     : x = 1/3 * ( y - Σm )  切り上げ
  #    b) 3 * n3 + Σm < y <= 3*n3 + 2*n2 + Σm : x = 1/2 * ( y - Σm - 3*n3 + 2*n3) 切り上げ
  #                                                                   - n3
  #    c)  3*n3 + 2*n2 + Σm < y                : x = y - Σm - 3*n3 - 2*n2 + (n3+n2)
  #                                                           -2*n3 - n2
  #  3や2で除したときの余りが、最後の枠の埋まり具合
  #  つまり最後の桝の余裕は
  #  余り 0 -> 0
  #  余り 1 ->   a) -> 3-1, b) -> 2-1
  #  余り 2 ->   a) -> 3-2
  # 
  # 2段積みパレットの時
  #   桝x個で yパレットを積むと
  #     x <= n3+n2          : y = 2 * x + Σm
  #     n3+n2 < x           : y = x -(n3+n2) + 2*n3+2*n2  + Σm
  # 
  #  すなわち
  #    a) y <= 2 * + Σm                        : x = 1/2 * ( y - Σm )  切り上げ
  #    b) 2 * + Σm < y <= 2 * (n3+n2) + Σm    : x = 1/2 * ( y - Σm )  切り上げ
  #    c) 2*(n3+n2) + Σm < y       : x = y - Σm - 2*n3 - 2*n2 + (n3+n2)
  #                                               -(n2+n3) 
  #  3や2で除したときの余りが、最後の枠の埋まり具合
  #  つまり最後の桝の余裕は
  #  余り 0 -> 0
  #  余り 1 -> 2-1
  #  
  #  stack_limit :: この銘柄の最大段数
  #  parets      :: 積むべきパレット数
  #  remain      :: 0,1,2,3段桝の数
  #  last_waku   :: 0,1,2,3段桝の一杯でない桝に残された余裕段数
  #  
  # 戻り値 
  #   使った桝数
  # 副作用
  #   remain、last_waku が更新される
  def masu_used(stack_limit,parets,remain,last_masu)
    case stack_limit
    when 3;    masu_used_3stack(parets,remain,last_masu) 
    when 2;    masu_used_2stack(parets,remain,last_masu)
    end
  end

  #  すなわち
  #    a) y <= 3 * n3 + Σm                     : x = 1/3 * ( y - Σm )  切り上げ
  #    b) 3 * n3 + Σm < y <= 3*n3 + 2*n2 + Σm : x = 1/2 * ( y - Σm - 3*n3 + 2*n3) 切り上げ
  #                                                                   - n3
  #    c)  3*n3 + 2*n2 + Σm < y                : x = y - Σm - 3*n3 - 2*n2 + (n3+n2)
  #                                                           -2*n3 - n2
  def masu_used_3stack(parets,remain,last_masu)
    sigma = last_masu.inject(0){ |sum,masu| sum + masu}

    (0..3).each{ |i| last_masu[i] = 0 }
    if parets <= 3*remain[3] + sigma
      yy = parets - sigma
      last_masu[3] = case yy % 3
                     when 0 ; 0
                     when 1 ; 2
                     when 2 ; 1
                     end
      y = (yy/3.0).ceil
      remain[3] -= y
      y
    elsif parets <= 3*remain[3] + 2*remain[2] + sigma
      yy = parets - sigma - remain[3]
      last_masu[2] = yy  % 2
      y = (yy*0.5).ceil
       remain[2] -= (y - remain[3]);remain[3] = 0 
      y
    elsif parets <= 3*remain[3] + 2*remain[2] + remain[1] +sigma
      y = parets - sigma - 2*remain[3]-remain[2]
      remain[1] -= (y - remain[3] - remain[2])
      remain[3] = remain[2] = 0
      y      
    else # 容量オーバーの時は、3段積みで枠外に、とする
      yy = parets - sigma - 3*remain[3]-2*remain[2]-remain[1]
      last_masu[3] = case yy % 3
                     when 0 ; 0
                     when 1 ; 2
                     when 2 ; 1
                     end
      y = (yy/3.0).ceil + remain[3] + remain[2] + remain[1]
      remain[3] = remain[2] = remain[1] =0
      y
    end
  end

  #  すなわち
  #    a) y <= 2 * + Σm                        : x = 1/2 * ( y - Σm )  切り上げ
  #    b) 2 * + Σm < y <= 2 * (n3+n2) + Σm    : x = 1/2 * ( y - Σm )  切り上げ
  #    c) 2*(n3+n2) + Σm < y       : x = y - Σm - 2*n3 - 2*n2 + (n3+n2)
  #                                               -(n2+n3) 
  def masu_used_2stack(parets,remain,last_masu) 
    sigma = last_masu.inject(0){ |sum,masu| sum + [1,masu].min}
    (0..3).each{ |i| last_masu[i] = 0 }
    if parets <= 2*remain[3] + sigma
      yy = parets - sigma
      last_masu[3] = yy  % 2
      y = (yy*0.5).ceil
      remain[3] = remain[3]-y
    elsif parets <= 2*(remain[2]+remain[3]) + sigma
      yy = parets - sigma
      last_masu[2] = yy  % 2
      y = (yy*0.5).ceil
      remain[2] -= y-remain[3]

      remain[3] =  0 
    elsif parets <= 2*(remain[2]+remain[3]) + remain[1] + sigma
      y = parets - sigma - 2*(remain[2]-remain[3])
      remain[1] -= (y - remain[3] - remain[2])
      remain[3] = remain[2] = 0
      y
    else
      
      y = ((parets - sigma - 2*(remain[2]-remain[3]) - remain[1])/3.0).ceil
      remain[3] = remain[2] = remain[1] = 0
      y
    end
      y
  end

  #  紙は一ロットずつ積んでいく
  #                        2段桝           n3段桝
  #  正規面数              18面まで        24面まで
  #  端数パレット          18面まで        24面まで
  #                         6面の下駄      
  #              すると、1段桝は 24-9=15面の下駄
  #   
  #  
  #  
  #  
  #  
  # ちと厄介。詳細判るまでは 40俵を積み、端数を積むことにする 
  def masu_used_paper(segments,remain,last_masu)
    used=0
    # 40俵を積む
    #segments.each{ |segment|
    #  used += masu_used_3stack((segment.count/40).to_i,remain,last_masu)
    #}
    used = stack_40hyou(segments,remain,last_masu)
    last_masu_men = [0,0,(last_masu[2]>0 ? 9 : 0),[24-(3-last_masu[3])*9,0].max]
    men_list = segments.map{ |segment| 
      ((segment.count % 40)/5.0).ceil + 1 if (segment.count % 40) > 0
    }.compact
#pp ["men_list:",men_list,"  last_masu_men",last_masu_men]
    used += men_list.inject(0){ |sum,men| sum+masu_used_paper_hasu(men,remain,last_masu_men) }
    (0..3).each{ |s| last_masu[s] = last_masu_men[s] }
    used
  end


  ## stat
  def self.tuuro_used(idx_or_name=nil)
    tuuro(idx_or_name).select{ |waku| waku.weight > 0}
  end

  def self.tuuro_weight_wakusuu(idx_or_name=nil)
    [(tuuro_used(idx_or_name).inject(0){ |w,waku| w += waku.weight}*0.001).to_i,
     tuuro_used(idx_or_name).count]
  end

 
  def self.weight_of_aria(idx_or_name,without_pull = false)
    #                  ↓ inactiveな枠でも集計
    aria(idx_or_name,false).inject(0){ |weight,waku| weight + waku.weight(without_pull)}
  end

  def self.empty(idx_or_name,without_pull = false)
    waku_list = 
      #(case idx_or_name
      # when Regexp
      #   waku.select{ |name,wk| idx_or_name =~ name }
      # else 
         aria(idx_or_name).select{ |waku| waku.empty?(without_pull) && /Z$/ !~ waku.name}
       #end
       #).select{ |waku| waku.empty?(without_pull) && /Z$/ !~ waku.name}
  end

  def self.empty_by_masusuu(idx_or_name,masusuu,without_pull = false)
    emptys = empty(idx_or_name,without_pull)
    masusuu.map{ |masu| emptys.select{ |wk| wk.kawa_suu >= masu } }
  end

  def self.empty_number_by_masusuu(idx_or_name,masusuu,without_pull = false)
    self.empty_by_masusuu(idx_or_name,masusuu,without_pull).map{ |lst| lst.size}
  end

  def self.by_occupied(idx_or_name,without_pull = false)
    waku_list = aria(idx_or_name).
      group_by{ |waku| waku.occupied(without_pull) }
  end

  def self.by_volume_occupied(idx_or_name,without_pull = false)
    by_tuuro_or_not = aria(idx_or_name).group_by{ |waku| waku.tuuro? }
    
    pack_by_volum = by_tuuro_or_not[false].
      group_by{ |waku| [ waku.volum3,waku.dan3,waku.dan2,waku.dan1] }
    pack_by_volum[[999,0,0,0]] = by_tuuro_or_not[true] if by_tuuro_or_not[true].size > 0

    list = { }
    pack_by_volum.keys.each{|volum| 
      list[volum] =
      pack_by_volum[volum].group_by{|waku| waku.occupied(without_pull)}
    }

    list
  end

  def self.by_volume_occupied_org(idx_or_name,without_pull = false)
    pack_by_volum = aria(idx_or_name).
      group_by{ |waku| [ waku.volum3,waku.dan3,waku.dan2,waku.dan1] }
    list = { }
    pack_by_volum.keys.each{|volum| 
      list[volum] =
      pack_by_volum[volum].group_by{|waku| waku.occupied(without_pull)}
     }
    list
   end
 
end
end
