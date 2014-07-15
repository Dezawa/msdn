# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  set_table_name 'shimada_powers'
  belongs_to :month     ,:class_name => "Shimada::Month"
  belongs_to :db_weather,:class_name => "Weather" 

  include Shimada::GnuplotDef
  include Statistics
  include Shimada::Patern

  attr_accessor :shape_is, :na, :f4_peaks, :f3_solve, :f2_solve, :differences


  PolyFitHour = (5 .. 23)  # 6時～23時
  PolyFitX0   = 14.0       # 15時
  PolyLevel   = 4

  Hours = ("hour01".."hour24").to_a
  Revs = ("rev01".."rev24").to_a
  Aves = ("ave01".."ave24").to_a
  DayOffset = [(3..23),(0..3)]
  TimeOffset = 2
  @@average_diff = nil

  Differences = ("difference00".."difference23").to_a
  Lines = [(0..300),(300..430),(430..560),(560..680),(680..800),(800..1000)]
  Header = "時刻"

  ReviceParms = { :threshold_temp => 10.0, :slope_lower => 3.0, :slope_higher => 9.0,:y0 => 600}

  Differ = ("00".."23").map{ |h| "difference#{h}" }
  NA     = ("f4_na0".."f4_na4").to_a
  F3_SOLVE = %w(f3_x1 f3_x2 f3_x3)
  F2_SOLVE = %w(f2_x1 f2_x2)
  CashColumns = Differ + NA + F3_SOLVE + F2_SOLVE + ["line"]

  def self.power_all(conditions = ["", [] ])
    self.all(:conditions => ["date is not null" +
conditions[0] ,
 *conditions[1] ] ) 
  end

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
    self.update_all("deform = null")
    @shpe_is = nil
    rm_gif
    self.all(:conditions => "date is not null").each{ |pw| pw.lines;pw.shape_is}
  end

  def self.rm_gif ;    File.delete(*Dir.glob(RAILS_ROOT+"/tmp/shimada/giffiles/*.gif")) ;end

  def self.average_diff
    return @@average_diff if @@average_diff
    ave_power = Shimada::Power.find_by_date(nil)
    ave_power = create_average_diff unless ave_power && ave_power.difference[0]
    @@average_diff = ave_power
  end

  def self.create_average_diff
    ave_power = Shimada::Power.find_or_create_by_date_and_line(nil,nil)
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

  def line_shape ; "#{lines}#{shape}" ;end

  def shape_is
    return @shape_is if @shape_is
    update_attributes(:shape => shape_calc,:deform => self.deform) unless shape
    @shape_is = shape
  end

  def max_diff_from_average_difference
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

  def offset_3(method,last=23)
    if date 
      send(method)[TimeOffset..last] + (( pw = self.class.find_by_date(date.tomorrow)) ? pw.send(method)[0..TimeOffset] : [])
    else
      send(method)[TimeOffset..last] + send(method)[0..TimeOffset]
    end
  end

  def powers_3 ;    offset_3(:powers) ;  end
  def revise_by_temp_3 ; offset_3(:revise_by_temp) ;  end
  def difference_3 ; offset_3(:difference,22) ;  end
  def diffdiff_3 ; offset_3(:diffdiff,21) ;  end

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

  def f4(x) ;    (((a[4] * x + a[3])*x + a[2])*x + a[1])*x+a[0] ;  end
  def f4_peaks ;@f4_peaks ||= f3_solve.map{ |x| f4(x)} ;end
  def nf4(x) ;    (((na[4] * x + na[3])*x + na[2])*x + na[1])*x+na[0] ;  end
  def nf4_peaks ;@nf4_peaks ||= nf3_solve.map{ |x| nf4(x)} ;end
  def pw_peaks 
    logger.debug("PW_PEAKS:#{date} f3_solve=#{f3_solve.join(',')}")
    if f3x2 
      [ revise_by_temp_ave[0..[f3x2+PolyFitX0,1].max].max, 
        revise_by_temp_ave[[f3x2+PolyFitX0,22].min..23].max]
    else
      [revise_by_temp_ave.max]
    end
  end
  def pw_peak1 ;pw_peaks[0] ;end
  def pw_peak2 ;pw_peaks[1] ;end


  def pw_vary
    if  f3x2 ; revise_by_temp_ave[ [8,f3x1+PolyFitX0].max .. [f3x3 + PolyFitX0,20].min ].min
    elsif x2 ; revise_by_temp_ave[x2+PolyFitX0] || revise_by_temp_ave.last
    end
  end

  def difference_peak_sholder
    pw_peaks[0] - 
      ( revise_by_temp_ave[x2+PolyFitX0] || revise_by_temp_ave.last)
  end

  def difference_peak_vary
    pw_peaks.max - pw_vary if pw_vary
  end

  def difference_peaks ;  ( pw_peaks.first - pw_peaks.last ).abs ;  end

  def f3(x) ;    ((a[4] * 4 * x + a[3]*3)*x + a[2]*2)*x + a[1] ;  end
  def nf3(x) ;    ((na[4] * 4 * x + na[3]*3)*x + na[2]*2)*x + na[1] ;  end
  def f3_solve(initial_x=nil)
    return @f3_solve if @f3_solve
    if  discriminant && discriminant >= 0
      unless self.f3_x1
        x12 = (x1+x2)*0.5
        self.f3_x1 = (0..4).inject(x1-(x2-x1)*0.5){ |x0,i| x0 - f3(x0)/f2(x0) }
        if y1 * y2 < 0
          self.f3_x2 = (0..4).inject((x1+x2)*0.5){    |x0,i| x0 - f3(x0)/f2(x0) }
          self.f3_x3 = (0..4).inject(x2+(x2-x1)*0.5){ |x0,i| x0 - f3(x0)/f2(x0) }
        end 
        save
      end
      @f3_solve  = [self.f3_x1, self.f3_x2 , self.f3_x3]
    else
      self.f3_x1 = (0..4).inject(-0.5*a[1]/a[2]){ |x0,i| x0 - f3(x0)/f2(x0) }
      @f3_solve  =  [self.f3_x1]
    end
  end
  def nf3_solve(initial_x=nil)
    return @nf3_solve if @nf3_solve
    if  ndiscriminant && ndiscriminant >= 0
      unless self.nf3_x1
        nx12 = (nx1+nx2)*0.5
        self.nf3_x1 = (0..4).inject(nx1-(nx2-nx1)*0.5){ |nx0,i| x0 - nf3(x0)/nf2(x0) }
        if ny1 * ny2 < 0
          self.nf3_x2 = (0..4).inject((nx1+nx2)*0.5){ |x0,i| x0 - nf3(x0)/nf2(x0) }
          self.nf3_x3 = (0..4).inject(nx2+(nx2-nx1)*0.5){ |x0,i| x0 - nf3(x0)/nf2(x0) }
        end 
        save
      end
      @nf3_solve  = [nf3x1, nf3x2 , nf3x3]
    else
      @nf3_solve  =  []
    end
  end

  def f3x1 ;f3_solve[0];end
  def f3x2 ;f3_solve[1];end
  def f3x3 ;f3_solve[2];end

  def nf3x1 ;nf3_solve[0];end
  def nf3x2 ;nf3_solve[1];end
  def nf3x3 ;nf3_solve[2];end
  # 12x^2 + 6x + 2a1
  def f2(x) ;    (a[4] * 12 * x + a[3]*6)*x + a[2]*2 ;  end
  def nf2(x) ;    (na[4] * 12 * x + na[3]*6)*x + na[2]*2 ;  end

  def ndiscriminant ; 36*na[3]*na[3] - 96*na[2]*na[4]   ;  end
  def discriminant ; 36*a[3]*a[3] - 96*a[2]*a[4]   ;  end
  def f2_solve
    @f2_solve ||=
      if  self.f2_x1  ; [self.f2_x1,self.f2_x2]
      elsif discriminant && discriminant >= 0
        #logger.debug("Math.sqrt  #{discriminant},#{a[3]} #{36*a[3]*a[3] - discriminant}")
        sqrt = Math.sqrt(discriminant)
        self.f2_x1,self.f2_x2 = [(-a[3]*6 + sqrt)/(24*a[4]), (-a[3]*6 - sqrt)/(24*a[4])].sort
        save 
        [self.f2_x1,self.f2_x2]
      else
        []
      end
  end
   def nf2_solve
    @nf2_solve ||=
      if  nf2x1  ; [nf2x1,nf2x2]
      elsif discriminant && discriminant >= 0
        #logger.debug("Math.sqrt  #{discriminant},#{na[3]} #{36*na[3]*na[3] -ndiscriminant}")
        sqrt = Math.sqrt(discriminant)
        f2x1,f2x2 = [(-na[3]*6 + sqrt)/(24*na[4]), (-na[3]*6 - sqrt)/(24*na[4])].sort
        [f2x1,f2x2]
      else
        []
      end
  end
  def x1       ; f2_solve.first ;end
  def x2       ; f2_solve.last ;end

  def y1       ; x1 ? f3(x1) : nil ;end
  def y2       ; x2 ? f3(x2) : nil ;end

  def nx1       ; nf2_solve.first ;end
  def nx2       ; nf2_solve.last ;end

  def ny1       ; x1 ? nf3(nx1) : nil ;end
  def ny2       ; x2 ? nf3(nx2) : nil ;end

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
         if power && temp
          temp > ReviceParms[:threshold_temp]  ? 
           power -  ReviceParms[:slope_higher] * (temp - ReviceParms[:threshold_temp]) : 
             power - ReviceParms[:slope_lower] * (temp - ReviceParms[:threshold_temp])
         else power ? power : 0
         end
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
    @difference_ave ||= 
      (
       n = num/2
       aves = (0..difference.size-1).map{ |h| 
         ary = difference[[0,h-n].max..[h+n,difference.size-1].min]
         ary.inject(0){ |s,e| s+(e||0)}/ary.size
       }
       )
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

  def deviation_of_difference(range = 8..20 )
    #difference.zip(self.class.average_diff.difference)[range].map{ |d,a| d-a }.standard_devitation
    difference[range].standard_devitation
  end

  def deviation_of_revice(range = 8..20 )
    revise_by_temp.zip(revise_by_temp_ave)[range].map{ |d,a| d-a }.standard_devitation
  end


# 629.36, [624.6, 629.6, 630.6, 630.8, 631.2]
end


