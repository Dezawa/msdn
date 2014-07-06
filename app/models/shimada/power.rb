# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  include Shimada::GnuplotDef
  include PolyFit

  attr_accessor :shape_is, :na, :f4_peaks, :f3_solve, :f2_solve, :differences


  PolyFitHour = (5 .. 23)  # 6時～23時
  PolyFitX0   = 14.0       # 15時
  PolyLevel   = 4
  Err         = 0.01

  set_table_name 'shimada_powers'
  belongs_to :month     ,:class_name => "Shimada::Month"
  belongs_to :db_weather,:class_name => "Weather"
  Hours = ("hour01".."hour24").to_a
  Revs = ("rev01".."rev24").to_a
  Aves = ("ave01".."ave24").to_a

  @@average_diff = nil

  Differences = ("difference00".."difference23").to_a
  Lines = [(0..300),(300..400),(400..560),(560..680),(680..800),(800..1000)]
  Shapes = self.all.map(&:shape).compact.uniq
  Header = "時刻"

  Paterns = {
    "S" => %w(0S 1S)        ,"4H" => %w(4H)    ,"4F" => %w(400 4F),"4D" => %w(4-- 4-+ 4-0 4d),
    "3F" => %w(3-- 30- 3F 300 3O),"3H" => %w(3H)    ,"3D" => %w(3d),
    "2F" => %w(2O),
    "OT" => %w(1他遅 2他遅 3他遅 4他遅 1他急変 2他急変 3他急変 4他急変)
   }
  AllPatern = %w(0 1 2 3 4 5).product(Shapes).map{ |l,s| l+s } 
  Un_sorted = AllPatern - Paterns.values.flatten

  Differ = ("00".."23").map{ |h| "difference#{h}" }
  NA     = ("f4_na0".."f4_na4").to_a
  F3_SOLVE = %w(f3_x1 f3_x2 f3_x3)
  F2_SOLVE = %w(f2_x1 f2_x2)
  CashColumns = Differ + NA + F3_SOLVE + F2_SOLVE + ["line"]

  def self.reset_reevice_and_ave
    self.all.each{ |power|
      ( Revs +   Aves ).each{ |clm|  power[clm]=nil }
      power.save
    }
  end

  def self.reculc_all
    self.all.each{ |pw|
      pw.shape_is =  pw.na = pw.f4_peaks = pw.f3_solve = pw.f2_solve =  pw.differences = nil
      CashColumns.each{ |sym| pw[sym] = nil}
      pw.save
    }
      reculc_shapes
  end

  def self.reculc_shapes
    #self.update(self.all.map(&:id), :shape => nil)
    self.update_all("shape = null")
    @shpe_is = nil
    File.delete(*Dir.glob(RAILS_ROOT+"/tmp/shimada/giffiles/*.gif"))
    self.all(:conditions => "date is not null").each{ |pw| pw.lines;pw.shape_is}
  end

  def self.average_diff
    return @@average_diff if @@average_diff
    ave_power = Shimada::Power.find_by_date(nil)
    ave_power = create_average_diff unless ave_power && ave_power.difference[0]
    @@average_diff = ave_power
  end

  def self.create_average_diff
    ave_power = Shimada::Power.find_or_create_by_date(nil)
    all_powers = Shimada::Power.all(:conditions => "date is  not null")
    diffs = all_powers.inject([0]*24){ |s,v|
logger.debug("CREATE_AVERAGE_DIFF: date=#{v.date}")
      v.difference.each_with_index{ |diff,idx| s[idx]+=( diff || 0 )};s
    }
    diffs =  diffs.map{ |d| d/all_powers.size}
    ave_power.update_attributes(Hash[*Differences.zip(diffs).flatten])
    ave_power.difference
    ave_power
  end

  def lines
    return @lines if @lines
    unless line
      update_attribute(:line , Lines.index{ |l| l.include?(revise_by_temp_ave[7..-1].max) })
    end
    @lines = line
  end

  def shape_is
    return @shape_is if @shape_is
    update_attribute(:shape , shape_calc) unless shape
    @shape_is = shape
  end

    # F Flat          ほぼ平ら。稼働ライン数が一定なのだろう
    # U step Up       階段状に増える。稼働ラインが途中から増えたのだろう
    # D step Down     階段状に減る。　稼働ラインが途中で減ったのだろう
    # I Increace      ズルズル増える  稼働ラインの変化ではなく、なんかある？
    # R Reduce        ズルズル減る。  稼働ラインの変化ではなく、なんかある？
    # C Cup           途中で稼働ライン一時的に止めた
    # H Hat           途中で一時的に増えている。なんかある？
    # S Sleep         稼働なし
  Shapes = %w(- 0 +).product(%w(- 0 +)).map{ |a,b| a+b }+%w(F O S H)
  def shape_calc
    return nil unless lines
    if lines < 2  ; "S"
    elsif max_diff_from_average_difference > 200 ; "他急変1"
    elsif [diffdiff(3..20).max,-diffdiff(3..20).min].max >  190 ; "他急変2"
    elsif discriminant.abs < 0.000002       ;"00"
    elsif revise_by_temp[6] < 400           ;     "他遅"
    elsif na[4] > 0
logger.debug("PW_PEAKS: date=#{date} pw_peaks.join(',')")
      if f3x3 < 9 && pw_peaks[1]-pw_peaks[2] > 120  ; "d" 
      elsif f3x1 >-12 && pw_peaks[1]-pw_peaks[0] > 120  ; "d" 
      else      ; "O"
      end
    elsif discriminant < 0.0                ; "F"
    elsif y1     >  Err && y2.abs <   Err   ;  "+0"
    elsif y1     >  Err && y2     >   Err   ;  "++"
    elsif y1     >  Err && y2     <  -Err   
      max_powers[0] - min_powers[0]  > 120 ? "H" :  "+-"
    elsif y1     < -Err && y2.abs <   Err   ;  "-0"
    elsif y1     < -Err && y2     <  -Err   ;  "--"
    elsif y1     < -Err && y2     >   Err   # -+
      pw_values = pw_peaks
      unless f3_solve.all?{ |x| PolyFitHour.include?(x+PolyFitX0)}
         "-+"
      else
      #logger.debug("===== pw_values = #{pw_values.join(',')} f3_solve=#{f3_solve.join(',')}")
      logger.debug("===== ID=#{id} #{date} difference_peak_vary = #{difference_peak_vary} difference_peaks=#{difference_peaks}")
      difference_peak_vary > 99 && difference_peaks < 100  ? "H" : "-+" # H
      end
    elsif y1.abs <  Err && y2.abs <   Err   ;  "00" #
    elsif y1.abs <  Err && y2     >   Err    
      x0 = f3_solve((x1+x2)*0.5)
      max_powers[0] - min_powers[0] > 150 ? "H" :  "0+"
    elsif y1.abs <  Err && y2     <  -Err   ;  "0-"
    else      ;   "他"
    end
  end

  def max_diff_from_average_difference
logger.debug("MAX_DIFF_FROM_AVERAGE_DIFFERENCE id=#{id} date=#{date}")
    ave_difference = self.class.average_diff.difference
    difference.zip(ave_difference).map{ |a,b| (a-b).abs if a&&b}.compact.max
  end

  Sdev = [0,6000,90000]
  def shape_by_sdev
    case variance_revise
    when (Sdev[0]..Sdev[1])   ; "Flat"
    when (Sdev[1]..Sdev[2]) ; "Reduce"
    else           ; "Other"
    end
  end

  def shape_by_difdif
    case diffdiff[8..18].max
    when (-10..15)   ; "Flat"
    when (15..100) ; "Reduce"
    else           ; "Other"
    end
  end

  def shape_by_diff
    case difference_ave[8..18].min
    when (-15..10)   ; "Flat"
    when (-100..-15) ; "Down"
    else            ; "Other"
    end
  end

  def powers ; Hours.map{ |h| self[h]} ; end

  # Array a of \sum_{i=0}^{次元数}(a_i x^i)
  # 
  def a(n=PolyLevel)
    @a ||= polyfit(PolyFitHour.map{ |h| h-PolyFitX0},revise_by_temp[PolyFitHour],n)
  end
  def a0 ; (a[0] || 0.0);end
  def a1 ; (a[1] || 0.0)*10;end
  def a2 ; (a[2] || 0.0)*100;end
  def a3 ; (a[3] || 0.0)*1000;end
  def a4 ; (a[4] || 0.0)*10000;end
  def a5 ; (a[5] || 0.0)*100000;end
  def a6 ; (a[6] || 0.0)*1000000;end


  def na(n=PolyLevel)
    return @na if @na
    unless self.f4_na0 
            self.f4_na0, self.f4_na1, self.f4_na2, self.f4_na3, self.f4_na4 = 
              polyfit(PolyFitHour.map{ |h| h-PolyFitX0},normalized_ave[PolyFitHour],n)
      save
    end
    @na =   [ f4_na0, f4_na1, f4_na2, f4_na3, f4_na4 ]

  end
  def na0 ; (na[0] || 0.0);end
  def na1 ; (na[1] || 0.0)*10;end
  def na2 ; (na[2] || 0.0)*100;end
  def na3 ; (na[3] || 0.0)*1000;end
  def na4 ; (na[4] || 0.0)*10000;end
  def na5 ; (na[5] || 0.0)*100000;end
  def na6 ; (na[6] || 0.0)*1000000;end

  def f4(x) ;    (((na[4] * x + na[3])*x + na[2])*x + na[1])*x+na[0] ;  end
  def f4_peaks ;@f4_peaks ||= f3_solve.map{ |x| f4(x)} ;end
  def pw_peaks ;f3_solve.map{ |x| powers[x+PolyFitX0] || 0 };end

  def difference_peak_vary
    (powers[f3x1+PolyFitX0,3] + powers[f3x3+PolyFitX0,3]).max -
      powers[f3x2+PolyFitX0,3].min
  end

  def difference_peaks
    (powers[f3x1+PolyFitX0,3].max - powers[f3x3+PolyFitX0,3].max ).abs
  end

  def f3(x) ;    ((na[4] * 4 * x + na[3]*3)*x + na[2]*2)*x + na[1] ;  end
  def f3_solve(initial_x=nil)
    return @f3_solve if @f3_solve
    if  discriminant && discriminant >= 0
      unless self.f3_x1
        x12 = (x1+x2)*0.5
        self.f3_x1 = (0..4).inject(x1-(x2-x1)*0.5){ |x0,i| x0 - f3(x0)/f2(x0) }
        self.f3_x2 = (0..4).inject((x1+x2)*0.5){ |x0,i| x0 - f3(x0)/f2(x0) }
        self.f3_x3 = (0..4).inject(x2+(x2-x1)*0.5){ |x0,i| x0 - f3(x0)/f2(x0) }
        save
      end
      @f3_solve  = [self.f3_x1, self.f3_x2 , self.f3_x3]
    else
      @f3_solve  =  []
    end
  end

  def f3x1 ;f3_solve[0];end
  def f3x2 ;f3_solve[1];end
  def f3x3 ;f3_solve[2];end

  # 12x^2 + 6x + 2a1
  def f2(x) ;    (na[4] * 12 * x + na[3]*6)*x + na[2]*2 ;  end

  def discriminant ; 36*na[3]*na[3] - 96*na[2]*na[4]   ;  end
  def f2_solve
    @f2_solve ||=
      if  self.f2_x1  ; [self.f2_x1,self.f2_x2]
      elsif discriminant && discriminant >= 0
        #logger.debug("Math.sqrt  #{discriminant},#{na[3]} #{36*na[3]*na[3] - discriminant}")
        sqrt = Math.sqrt(discriminant)
        self.f2_x1,self.f2_x2 = [(-na[3]*6 + sqrt)/(24*na[4]), (-na[3]*6 - sqrt)/(24*na[4])].sort
        save 
        [self.f2_x1,self.f2_x2]
      else
        []
      end
  end
  def x1       ; f2_solve.first ;end
  def x2       ; f2_solve.last ;end

  def y1       ; x1 ? f3(x1) : nil ;end
  def y2       ; x2 ? f3(x2) : nil ;end

  def weather
logger.debug("WEATHER id=#{id} date=#{date}")
    return db_weather if db_weather
    db_weather = Weather.find_or_feach("maebashi", date)
    save
    db_weather
  end

  def temps 
    return @temps if @temps
    @temps = Hours.map{ |h| weather[h]}
    save
    @temps
  end

  def variance_revise(from = 8,to = 18)
    ave = revise_by_temp_ave[from..to].inject(0.0){ |s,e| s += e}/(to-from+1)
    sigma  = revise_by_temp_ave[from..to].inject(0.0){ |s,e| s += (e-ave)*(e-ave)}
  end

  def revise_by_temp
    return @revise_by_temp if @revise_by_temp
    unless self.rev01
      #return unless weather
      revs = Hours.map{ |h|
        power = self[h]
        temp  = weather[h]
          temp > 15.0 ? power - 9 * (temp - 20) : power - 3 * (temp - 20) if power && temp
      }
      Revs.each{ |r|  self[r] = revs.shift}
      save
    end
    @revise_by_temp = Revs.map{ |r| self[r]}
  end

  def diffdiff(range=(1..22))
    logger.debug("DIFFDIFF: id=#{id} date=#{date} #{difference.join(',')}")
    @diffdiff ||= (1..difference.size).
      map{ |i| difference[i] -  difference[i-1] if  difference[i] &&  difference[i-1]
    }.compact
    @diffdiff[range]
  end

  def difference
    return @differences if @differences
    if difference00
      @differences = ("00".."23").map{ |h| self["difference#{h}"] }
    elsif date.nil?
      @differences=[]
    else
      y0 = revise_by_temp.first
      diff = { }
      @differences = revise_by_temp[1..-1].map{ |y| dif = y - y0; y0 = y ;  dif}.compact
      update_attributes(Hash[*Differences.zip(@differences).flatten])
    end
    @differences.compact
    @differences
  end

  def difference_revise_by_temp
    y0 = revise_by_temp_ave.first
    revise_by_temp_ave[1..-1].map{ |y| dif = y - y0; y0 = y ; dif} 
  end
  def difference_ave(num=3)
    n = num/2
    
    aves = (0..difference.size-1).map{ |h| ary = difference[[0,h-n].max..[h+n,difference.size-1].min]
      ary.inject(0){ |s,e| s+e}/ary.size
    }
  end

  def revise_by_temp_ave(num=3)
    return @revise_by_temp_ave if @revise_by_temp_ave
    unless self.ave01
      n = num/2

      aves = (0..powers.size-1).map{ |h| ary = revise_by_temp[[0,h-n].max..[h+n,revise_by_temp.size-1].min]
        ary.inject(0){ |s,e| s+(e ? e : 0 ) }/ary.size
      }
      Aves.each{ |r|  self[r] = aves.shift}
      save
    end
    @revise_by_temp_ave = Aves.map{ |r| self[r]}
  end

  def move_ave(num=5)
    @move_ave ||= []
    return @move_ave[num] if @move_ave[num]
    n = num/2
    @move_ave[num] = (0..powers.size-1).
      map{ |h| ary = powers[[0,h-n].max..[h+n,powers.size-1].min]
      ary.inject(0){ |s,e| s+e}/ary.size
    }
  end

  def normalized_ave(num=5)
    @normalized_ave ||= []
    return @normalized_ave[num] if @normalized_ave[num]
    n = num/2
    @normalized_ave[num] = (0..normalized.size-1).
      map{ |h| ary = normalized[[0,h-n].max..[h+n,normalized.size-1].min]
      ary.inject(0){ |s,e| s+e}/ary.size
    }
  end

  def normalized(num=5)
    ave = max_ave(num)
    #move_ave(num)
    #Hours.map{ |h| self[h]/ave}
    powers.map{ |h| h/ave}
  end

  def min_powers(num=3)
    Hours.map{ |h| self[h]}.sort.first(num)
  end

  def max_powers(num=3)
    Hours.map{ |h| self[h]}.sort.last(num)
  end

  def max_ave(num=3)
    move_ave(num).sort.last(num).inject(0){ |s,e| s+=e}/num
  end
# 629.36, [624.6, 629.6, 630.6, 630.8, 631.2]
end


