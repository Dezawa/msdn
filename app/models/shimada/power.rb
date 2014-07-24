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

  PolyFits = 
    {
#1 => {
#:ave => [ 0.000 ,0.000 ,0.000 ,0.000 ,0.000],
#:max => [ 0 ,0 ,0 ,0 ,0],
#:min => [ 0 ,0 ,0 ,0 ,0]
#},
#2 => {
#:ave => [ 501.557 ,-7.063 ,-1.178 ,0.006 ,-0.012],
#:max => [ 563.790 ,-5.930 ,1.116 ,0.025 ,-0.031],
#:min => [ 439.324 ,-8.196 ,-3.472 ,-0.014 ,0.008]
#},
#3 => {
#:ave => [ 546.889 ,-0.556 ,0.362 ,-0.048 ,-0.026],
#:max => [ 592.745 ,5.929 ,1.113 ,-0.051 ,-0.025],
#:min => [ 501.034 ,-7.041 ,-0.389 ,-0.045 ,-0.028]
#},
#4 => {
#
#:ave => [ 688.133 ,-6.394 ,0.639 ,-0.003 ,-0.038],
#:max => [ 772.303 ,-4.096 ,1.529 ,0.046 ,-0.043],
#:min => [ 603.962 ,-8.693 ,-0.251 ,-0.052 ,-0.032]
#    }
########  offset_of_hukurosu_vs_pw == 0 による##############
1 => {
:ave => [ 0.000 ,0.000 ,0.000 ,0.000 ,0.000],
:max => [ 0 ,0 ,0 ,0 ,0],
:min => [ 0 ,0 ,0 ,0 ,0]
},
2 => {
:ave => [ 501.557 ,-7.063 ,-1.178 ,0.006 ,-0.012],
:max => [ 563.790 ,-5.930 ,1.116 ,0.025 ,-0.031],
:min => [ 439.324 ,-8.196 ,-3.472 ,-0.014 ,0.008]
},
3 => {
:ave => [ 587.788 ,-1.792 ,0.651 ,-0.034 ,-0.030],
:max => [ 645.434 ,0.038 ,1.470 ,0.014 ,-0.028],
:min => [ 530.141 ,-3.623 ,-0.168 ,-0.082 ,-0.032]
},
4 => {
:ave => [ 688.133 ,-6.394 ,0.639 ,-0.003 ,-0.038],
:max => [ 772.303 ,-4.096 ,1.529 ,0.046 ,-0.043],
:min => [ 603.962 ,-8.693 ,-0.251 ,-0.052 ,-0.032]
    }
######### 2014の物による########
#1 => {
#:ave => [ 0.000 ,0.000 ,0.000 ,0.000 ,0.000],
#:max => [ 0 ,0 ,0 ,0 ,0],
#:min => [ 0 ,0 ,0 ,0 ,0]
#},
#2 => {
#:ave => [ 501.557 ,-7.063 ,-1.178 ,0.006 ,-0.012],
#:max => [ 563.790 ,-5.930 ,1.116 ,0.025 ,-0.031],
#:min => [ 439.324 ,-8.196 ,-3.472 ,-0.014 ,0.008]
#},
#3 => {
#:ave => [ 587.788 ,-1.792 ,0.651 ,-0.034 ,-0.030],
#:max => [ 645.434 ,0.038 ,1.470 ,0.014 ,-0.028],
#:min => [ 530.141 ,-3.623 ,-0.168 ,-0.082 ,-0.032]
#},
#4 => {
#:ave => [ 688.133 ,-6.394 ,0.639 ,-0.003 ,-0.038],
#:max => [ 772.303 ,-4.096 ,1.529 ,0.046 ,-0.043],
#:min => [ 603.962 ,-8.693 ,-0.251 ,-0.052 ,-0.032]
#    }
#### 稼働1,2,3,4をもとに
#    1 => {
#      :ave => [ 0.000 ,0.000 ,0.000 ,0.000 ,0.000],
#      :max => [ 0 ,0 ,0 ,0 ,0],
#      :min => [ 0 ,0 ,0 ,0 ,0]
#    },
#    2 => {
#      :ave => [ 497.014 ,-6.364 ,-0.947 ,0.011 ,-0.012],
#      :max => [ 556.435 ,-4.326 ,1.423 ,0.041 ,-0.029],
#      :min => [ 437.593 ,-8.402 ,-3.317 ,-0.020 ,0.006]
#    },
#    3 => {
#      :ave => [ 586.473 ,-1.185 ,0.716 ,-0.039 ,-0.028],
#      :max => [ 653.921 ,-0.215 ,1.207 ,-0.002 ,-0.024],
#      :min => [ 519.024 ,-2.155 ,0.224 ,-0.076 ,-0.032]
#    },
#    4 => {
#      :ave => [ 672.331 ,-4.778 ,0.805 ,-0.004 ,-0.035],
#      :max => [ 758.378 ,-4.122 ,1.285 ,0.057 ,-0.036],
#      :min => [ 586.284 ,-5.433 ,0.325 ,-0.065 ,-0.035]
#    }
#
  }
  BugsFit = { :y0 => 4400, :slop => 5.4,:offset => [1200,2400],:offset0 => [-10000,1200,2400,10000] }
  Hours = ("hour01".."hour24").to_a
  Revs = ("rev01".."rev24").to_a
  ByVapers = ("by_vaper01".."by_vaper24").to_a
  Vapers = ("vaper01".."vaper24").to_a
  Aves = ("ave01".."ave24").to_a
  DayOffset = [(3..23),(0..3)]
  TimeOffset = 2
  @@average_diff = nil

  Differences = ("difference00".."difference23").to_a
  Lines = [(0..280),(280..410),(410..540),(540..660),(660..800),(800..1000)]
  Header = "時刻"

  ReviceParms = { :threshold_temp => 10.0, :slope_lower => 3.0, :slope_higher => 9.0,
    :y0 => 660.0 , :power_0line => 200.0}

  VaperParms = { :threshold_vaper => 20.0, :slope_lower => 3.0, :slope_higher => 20.0,
    :y0 => 660.0 , :power_0line => 200.0}

  Differ = ("00".."23").map{ |h| "difference#{h}" }
  NA     = ("f4_na0".."f4_na4").to_a
  F3_SOLVE = %w(f3_x1 f3_x2 f3_x3)
  F2_SOLVE = %w(f2_x1 f2_x2)
  CashColumns = Differ + NA + F3_SOLVE + F2_SOLVE + ["line"]

  def self.power_all(conditions = ["", [] ])
    self.all(:conditions => ["month_id is not null and date < '2014-7-1'" +
conditions[0] ,
 *conditions[1] ] ) 
  end

  def self.by_patern(patern)
      line_shape = ( if   patern ; Paterns[patern]
                     else Un_sorted
                     end ).map{ |ls| ls.split("",2)}
      #months = Shimada::Month.all
      @power=power_all.
        select{ |power| line_shape.any?{ |line,shape| power.lines == line.to_i && power.shape_is == shape }}
  end

  def self.by_offset(offset)
    low,high = BugsFit[:offset0][offset.to_i,2]
    Shimada::Power.all(:conditions => "hukurosu is not null and date < '2014-7-1'").
      select{ |pw| pw.offset_of_hukurosu_vs_pw > low and  pw.offset_of_hukurosu_vs_pw<= high}
  end

  def self.reset_reevice_and_ave
    self.all.each{ |power|
      ( Revs +   Aves + Vapers).each{ |clm|  power[clm]=nil }
      power.save
    }
    reculc_all
  end

  def self.reculc_all
    self.all.each{ |pw|
      pw.shape_is =  pw.na = pw.f4_peaks = pw.f3_solve = pw.f2_solve =  pw.differences = nil
      CashColumns.each{ |sym| pw[sym] = nil}
      pw.save
    }
      reculc_shapes
    rm_gif
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
    #ave_power = Shimada::Power.power_all
    ave_power = create_average_diff #unless ave_power && ave_power.first.difference[0]
    @@average_diff = ave_power
  end

  def self.create_average_diff
    ave_power = Shimada::Power.find_or_create_by_date_and_line(nil,nil)
    all_powers = Shimada::Power.power_all
    diffs = all_powers.inject([0]*24){ |s,v|
logger.debug("CREATE_AVERAGE_DIFF: date=#{v.date}")
      v.difference.each_with_index{ |diff,idx| s[idx]+=( diff || 0 )} if v.difference
      s
    }
    diffs =  diffs.map{ |d| d/all_powers.size}
    ave_power.update_attributes(Hash[*Differences.zip(diffs).flatten])
    ave_power.difference
    ave_power
  end

  @@average_line = { }
  # rev => 平均 、difference => SDEV、powers => +2σ、ave => -2σ
  def self.average_line(line)
    return @@average_line[line] if @@average_line[line]
    return nil unless (1..4).include?(line)
    patern = "稼働#{line}"

    average_line = Shimada::Power.find_or_create_by_date_and_line(nil,line)
    
    powers = self.by_patern(patern).
      select{ |pw| pw.offset_of_hukurosu_vs_pw < 1200 && pw.line > 2 && pw.max_revs >= 605} 
         #pw.date > Date.new(2013,9)} # )power_all([" and line = ?", line])
    if  powers.size>2
      aves = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_temp[i]}.compact.average}
      sdev = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_temp[i]}.compact.standard_devitation}
      high = (0..23).map{ |i| aves[i]+2*sdev[i] }
      lows = (0..23).map{ |i| aves[i]-2*sdev[i] }

      average_line.update_attributes( Hash[*Revs.zip(aves).flatten].
                                      merge(Hash[*Differences.zip(sdev).flatten]).
                                      merge(Hash[*Hours.zip(high).flatten]).
                                      merge(Hash[*Aves.zip(lows).flatten]))
    end
    #ave_power.difference
    @@average_line[line] = average_line
  end


  def copy_revise
    std = self.class.average_line(self.line)
    Revs.each{ |sym|  self[sym] = std[sym] }
    self
  end

  def inv_revise(temperature)
    temperature.each_with_index{ |temp,idx|
      rev = self[Revs[idx]]
      self[Hours[idx]] = temp >  ReviceParms[:threshold_temp]  ?
      rev + ReviceParms[:slope_higher] * (temp - ReviceParms[:threshold_temp]) : 
      rev + ReviceParms[:slope_lower] * (temp - ReviceParms[:threshold_temp])
    }
    self
  end

  Keys = { :revise => Revs,:sdev => Differences,:max => Hours,:min => Aves}
  def copy_and_inv_revise(temperature,method = :revise)
    std = self.class.average_line(self.line)
    temperature.each_with_index{ |temp,idx|
      Keys[method].each{ |hour|  
        value  = std[hour]
        self[hour] = temp >  ReviceParms[:threshold_temp]  ?
        value + ReviceParms[:slope_higher] * (temp - ReviceParms[:threshold_temp]) : 
        value + ReviceParms[:slope_lower] * (temp - ReviceParms[:threshold_temp])
      }
    }
    self
  end


  def lines
    return @lines if @lines
    return 0 if revise_by_temp.size == 0
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
    return nil unless difference
    return nil unless ave_difference = self.class.average_diff.difference
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
  def aves   ; Aves.map{ |h|  self[h]} ; end

  def offset_3(method,last=23)
    return [] if ( values = send(method) ).size < TimeOffset
    if date 
      values[TimeOffset..last] + (( pw = self.class.find_by_date(date.tomorrow)) ? pw.send(method)[0..TimeOffset] : [])
    else
      values[TimeOffset..last] + values[0..TimeOffset]
    end
  end

  def powers_3 ;    offset_3(:powers) ;  end
  def revise_by_temp_3 ; offset_3(:revise_by_temp) ;  end
  def revise_by_vaper_3 ; offset_3(:revise_by_vaper) ;  end
  def difference_3 ; offset_3(:difference,22) ;  end
  def diffdiff_3 ; offset_3(:diffdiff,21) ;  end
  def aves_3     ; offset_3(:aves);end


  # Array a of \sum_{i=0}^{次元数}(a_i x^i)
  # 
  def a(n=PolyLevel)
     return @a if @a
    if revise_by_temp.compact.size > n
      polyfit(PolyFitHour.map{ |h| h-PolyFitX0},revise_by_temp[PolyFitHour],n)
    else
      []
    end
  end
  def a0 ; (a[0] || 0.0);end
  def a1 ; (a[1] || 0.0);end
  def a2 ; (a[2] || 0.0);end
  def a3 ; (a[3] || 0.0);end
  def a4 ; (a[4] || 0.0);end
  def a5 ; (a[5] || 0.0);end
  def a6 ; (a[6] || 0.0);end

  def a_low(n=PolyLevel)
    return [] unless aves.compact.size > n
    polyfit(PolyFitHour.map{ |h| h-PolyFitX0},aves[PolyFitHour],n)
  end

  def a_high(n=PolyLevel)
    return [] unless powers.compact.size > n
    polyfit(PolyFitHour.map{ |h| h-PolyFitX0},powers[PolyFitHour],n)
  end

  (0..5).each{ |i| define_method("a_low#{i}"){ a_low[i]}; define_method("a_high#{i}"){ a_high[i]}}

  def na(n=PolyLevel)
    return @na if @na
    if !self.f4_na0 && normalized_ave && normalized_ave.size > n
      self.f4_na0, self.f4_na1, self.f4_na2, self.f4_na3, self.f4_na4 = 
        polyfit(PolyFitHour.map{ |h| h-PolyFitX0},normalized_ave[PolyFitHour],n)
      save
    @na =   [ f4_na0, f4_na1, f4_na2, f4_na3, f4_na4 ]
    end
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
    return if revise_by_temp.size == 0
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
    return if revise_by_temp.size == 0
    if  f3x2 ; revise_by_temp_ave[ [8,f3x1+PolyFitX0].max .. [f3x3 + PolyFitX0,20].min ].min
    elsif x2 ; revise_by_temp_ave[x2+PolyFitX0] || revise_by_temp_ave.last
    end
  end

  def difference_peak_sholder
    return nil if revise_by_temp_ave.size ==0
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
    #logger.debug("WEATHER id=#{id} date=#{date} ")
    return @weather if @weather
    return @weather = db_weather if db_weather
    return nil unless date
    if db_weather = Weather.find_or_feach("maebashi", self.date)
      save
      @weather = db_weather
   
    end
  end

  def temps 
    return @temps if @temps
    return nil unless weather
    @temps = Hours.map{ |h| weather[h]}
    save
    @temps
  end

  def variance_revise(from = 8,to = 18)
    revises = revise_by_temp_ave[from..to].compact
    return nil if revises.size > 0
    ave = revises.inject(0.0){ |s,e| s += e}/revises.size
    sigma  = revises.inject(0.0){ |s,e| s += (e-ave)*(e-ave)}
  end

  # y = 9(x - 10) + 600 の傾きで補正する
  # 10℃  600kWh
  # 20    690kWhのときに傾き9、補正量90。Pw kWhだったら 90*(Pw-200)/(690-200) 
  # 30    780                                     9(T-10) * (Pw-200)/(9*(T-10)+600-200)
  #                                               9(T-10) * (Pw-200)/(9*(T-10)+400)
  def revise_by_temp
    return @revise_by_temp if @revise_by_temp
    unless self.rev01
      return [] unless weather
      revs = Hours.map{ |h|
        power = self[h]
        temp  = weather[h]
         if power && temp
           x0,y0,p0,sll,slh = [:threshold_temp,:y0,:power_0line, :slope_lower, :slope_higher ].
             map{ |sym|Shimada::Power::ReviceParms[sym]}
           slp = temp > ReviceParms[:threshold_temp]  ? slh : sll
           power -  slp*(temp-x0)*(power-p0)/(slp*(temp-x0)+y0-p0)
         else power ? power : 0
         end
      }
      Revs.each{ |r|  self[r] = revs.shift}
      save
    end
    @revise_by_temp = Revs.map{ |r| self[r]}
  end

  def revise_by_vaper
    return @revise_by_vaper if @revise_by_vaper
    unless self.by_vaper01
      return [] unless weather

      x0,y0,p0,sll,slh = [:threshold_vaper,:y0,:power_0line, :slope_lower, :slope_higher ].
        map{ |sym| VaperParms[sym]}

      vapers0 = (0..23).map{ |h|
        revise = revise_by_temp[h]
        vaper  = weather[Vapers[h]]
        logger.debug("Vapers #{vaper},#{Vapers[h]}")
         if revise && vaper
           slp = vaper > VaperParms[:threshold_vaper]  ? slh : sll
           revise -  slp*(vaper-x0)*(revise-p0)/(slp*(vaper-x0)+y0-p0)
         else revise ? revise : 0
         end
      }
      ByVapers.each{ |r|  self[r] = vapers0.shift}
      save
    end
    @revise_by_vaper = ByVapers.map{ |r| self[r]}
  end

  def revise_by_temp_sum
    revise_by_temp.inject(0.0){ |s,e| s += e if e; s}
  end

  # ΣPw = 4400 + 5.4 hukuro + offset
  # offset = ΣPw - 4400 - 5.4 hukuro
  def offset_of_hukurosu_vs_pw
    return 100 unless hukurosu
    revise_by_temp_sum - BugsFit[:y0] - hukurosu * BugsFit[:slop]
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
    #return [] unless revise_by_temp && revise_by_temp.first
    if difference00
      @differences = ("00".."23").map{ |h| self["difference#{h}"] }
    elsif date.nil? || revise_by_temp.compact.size < 24
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
    return [ ] if revise_by_temp.size == 0
    y0 = revise_by_temp_ave.first
    revise_by_temp_ave[1..-1].map{ |y| dif = y - y0; y0 = y ; dif} 
  end
  def difference_ave(num=3)
    return [] if difference.size ==0 
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
    return [] if revise_by_temp.size ==0 
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
    return [] if powers.compact.size < 24
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
    return [] if powers.compact.size < 24
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

  def min_revs
    Revs.map{ |h| self[h]}.sort.first
  end

  def max_revs
   Revs.map{ |h| self[h]}.sort.last
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

__END__
>> ave3.a
=> [585.344448512587, -2.8946985333208, 0.543465592966868, -0.0273597742127158, -0.0271368587272631]
>> ave4.a
=> [671.311419302734, -11.046155811208, 0.424149932237185, 0.0538818174000054, -0.0320642544879384]
>> ave2.a
=> [390.506310135954, -4.09290092097442, 0.800845654009422, -0.118680606373331, -0.0413615377084879]
>> 

>> ave3.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave3.revise_by_temp[PolyFitHour],n)
=> [585.344448512587, -2.8946985333208, 0.543465592966868, -0.0273597742127158, -0.0271368587272631]
>> ave3.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave3.powers[PolyFitHour],n)
=> [681.880767263428, -2.16091644385028, 1.00939574410472, 0.0151249061825689, -0.0245542670105259]
>> ave3.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave3.aves[PolyFitHour],n)
=> [488.807671961234, -3.62848992635336, 0.0775723702054876, -0.0698439229758882, -0.0297197879828015]
>> 

>> ave.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave.revise_by_temp[PolyFitHour],n)
=> [671.311419302734, -11.046155811208, 0.424149932237185, 0.0538818174000054, -0.0320642544879384]
>> ave.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave.powers[PolyFitHour],n)
=> [775.743610849375, -1.00351300544133, 0.763666749521605, -0.0184740946617896, -0.033552131134333]
>> ave.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave.aves[PolyFitHour],n)
=> [566.879582177953, -21.0886685977422, 0.0846391388986092, 0.126236193201364, -0.0305765463560064]

>> ave.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave.revise_by_temp[PolyFitHour],n)
=> [390.506310135954, -4.09290092097442, 0.800845654009422, -0.118680606373331, -0.0413615377084879]
>> ave.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave.powers[PolyFitHour],n)
=> [610.610527123437, -1.38989022969643, -0.44405480799054, -0.007231545329454, -0.0114488937191251]
>> ave.polyfit(PolyFitHour.map{ |h| h-PolyFitX0},ave.aves[PolyFitHour],n)
=> [500.55827931081, -2.74142026691058, 0.178407164847272, -0.0629558940801201, -0.0264053476445685]
>> 
