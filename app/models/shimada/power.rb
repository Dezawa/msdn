# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  set_table_name 'shimada_powers'
  belongs_to :month     ,:class_name => "Shimada::Month"
  belongs_to :db_weather,:class_name => "Weather" 
  belongs_to :shimada_factory     ,:class_name => "Shimada::Factory"

  include Shimada::GnuplotDef
  include Statistics
  include Shimada::Patern

  attr_accessor :shape_is, :na, :f4_peaks, :f3_solve, :f2_solve, :differences


  PolyFitHour = (5 .. 23)  # 6時～23時
  PolyFitX0   = 14.0       # 15時
  PolyLevel   = 4


  PolyFits = 
{ 
#########   by_month
1 => {
:ave => [ 0.000 ,0.000 ,0.000 ,0.000 ,0.000],
:max => [ 0 ,0 ,0 ,0 ,0],
:min => [ 0 ,0 ,0 ,0 ,0]
},
2 => {
:ave => [ 490.649 ,-3.242 ,-0.586 ,0.006 ,-0.012],
:max => [ 550.071 ,-0.535 ,1.543 ,0.029 ,-0.024],
:min => [ 431.227 ,-5.949 ,-2.715 ,-0.017 ,-0.000]
},
3 => {
:ave => [ 560.434 ,-1.307 ,0.560 ,-0.033 ,-0.025],
:max => [ 616.362 ,1.126 ,0.883 ,-0.013 ,-0.020],
:min => [ 504.506 ,-3.739 ,0.236 ,-0.054 ,-0.031]
},
4 => {
:ave => [ 623.029 ,-4.620 ,0.612 ,-0.002 ,-0.032],
:max => [ 699.186 ,-3.927 ,1.134 ,0.051 ,-0.033],
:min => [ 546.873 ,-5.313 ,0.089 ,-0.055 ,-0.030]
} 
#1 => {
#:ave => [ 0.000 ,0.000 ,0.000 ,0.000 ,0.000],
#:max => [ 0 ,0 ,0 ,0 ,0],
#:min => [ 0 ,0 ,0 ,0 ,0]
#},
#2 => {
#:ave => [ 492.648 ,-5.180 ,-0.645 ,0.064 ,-0.007],
#:max => [ 560.767 ,-3.042 ,0.951 ,0.062 ,-0.015],
#:min => [ 424.529 ,-7.318 ,-2.240 ,0.067 ,0.002]
#},
#3 => {
#:ave => [ 571.127 ,-0.858 ,0.517 ,-0.036 ,-0.025],
#:max => [ 634.462 ,0.710 ,0.794 ,-0.008 ,-0.019],
#:min => [ 507.792 ,-2.425 ,0.240 ,-0.064 ,-0.032]
#},
#4 => {
#:ave => [ 628.317 ,-2.178 ,0.791 ,-0.035 ,-0.032],
#:max => [ 698.077 ,-0.596 ,1.123 ,0.014 ,-0.027],
#:min => [ 558.557 ,-3.760 ,0.459 ,-0.085 ,-0.037]
#    }
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
#########  offset_of_hukurosu_vs_pw == 0 による##############
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
########## 2014の物による########
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
  MonthOffset = [570,50,45,30,0,0,0,0,0,0,30,40,45]
  BugsFit = { 
    "revise_by_temp" =>
    { :y0 => [4400,4400,4400], :slop => [5.4,5.4,5.4],:offset => [0,1200,2400],
      :offset0 => [-10000,1200,2400,10000] },
    "revise_by_month" => 
    # 実際のライン数 + 1 を定義しておく
    { :y0 => [4400,4400,4400,4400], :slop => [4.4,5.7,7.0,10.0],:offset => [0,0,0,0],
      :offset0 => [0,5.7,7.0,10.0] }
  }
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
  LinesVaper = [(0..280),(280..410),(410..540),(540..660),(660..800),(800..1000)]
  Header = "時刻"

  ReviceParams = { :threshold => 10.0, :slope_lower => 0.0, :slope_higher => 9.0,
    :y0 => 660.0 , :power_0line => 200.0}

  VaperParams = { :threshold => 20.0, :slope_lower => 0.0, :slope_higher => 6.0,
    :y0 => 620.0 , :power_0line => 200.0}

  VaperParamsRaw = { :threshold => 20.0, :slope_lower => 0.0, :slope_higher => 20.0,
    :y0 => 660.0 , :power_0line => 200.0}

  Differ = ("00".."23").map{ |h| "difference#{h}" }
  NA     = ("f4_na0".."f4_na4").to_a
  F3_SOLVE = %w(f3_x1 f3_x2 f3_x3)
  F2_SOLVE = %w(f2_x1 f2_x2)
  CashColumns = Differ + NA + F3_SOLVE + F2_SOLVE + ["line"]

  def self.power_all(factory_id,conditions = ["", [] ])
    self.all(:conditions => ["month_id is not null and date < '2014-7-1' and shimada_factory_id = #{factory_id} " +conditions[0] , *conditions[1] ] ) 
  end

  def self.by_patern(factory_id,patern)
      line_shape = ( if   patern ; Paterns[patern]
                     else Un_sorted
                     end ).map{ |ls| ls.split("",2)}
      #months = Shimada::Month.all
      @power=power_all(factory_id).
        select{ |power| line_shape.any?{ |line,shape| power.lines == line.to_i && power.shape_is == shape }}
  end
  def self.bugs_fit(method)
    Shimada::Power::BugsFit[
                            case method.to_s
                            when /revise_by_temp/ ; "revise_by_temp"
                            when /revise_by_month/: "revise_by_month"
                            end
                           ]
  end

  def self.by_offset(offset,by = :by_vaper)
    offset = offset.to_i
    case by.to_s
    when /_by_temp/    
      low,high = bugs_fit(by)[:offset0][offset.to_i,2]
      Shimada::Power.all(:conditions => "hukurosu is not null and date < '2014-7-1'").
        select{ |pw| pw.offset_of_hukurosu_vs_pw(by) > low and  pw.offset_of_hukurosu_vs_pw(by)<= high}
    when /_by_month/
      Shimada::Power.all(:conditions => "hukurosu is not null and date < '2014-7-1'").
        select{ |pw| pw.offset_from_hukurosu_vs_pw(by) == offset }
    end
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

  def self.average_diff(factory_id)
    return @@average_diff if @@average_diff
    #ave_power = Shimada::Power.power_all
    ave_power = create_average_diff(factory_id) #unless ave_power && ave_power.first.difference[0]
    @@average_diff = ave_power
  end

  def self.create_average_diff(factory_id)
    ave_power = Shimada::Power.find_or_create_by_date_and_line(nil,nil)
    all_powers = Shimada::Power.power_all(factory_id)
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
  def self.average_line(factory_id,line)
    return @@average_line[line] if @@average_line[line]
    return nil unless (1..4).include?(line)
    patern = "稼働#{line}"

    average_line = Shimada::Power.find_or_create_by_date_and_line(nil,line)
    
    powers = self.by_patern(factory_id,patern).
      select{ |pw| 
      #pw.offset_of_hukurosu_vs_pw < 1200 && pw.line > 2 && pw.max_revs >= 605} 
         #pw.date > Date.new(2013,9)} # )
      power_all(factory_id,[" and line = ?", line])
    }
    if  powers.size>2
      aves     = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_month[i]}.compact.average}
      aves_rev = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_month[i]}.compact.average}
      sdev     = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_month[i]}.compact.standard_devitation}
      high = (0..23).map{ |i| aves[i]+2*sdev[i] }
      lows = (0..23).map{ |i| aves[i]-2*sdev[i] }
      average_line.update_attributes( Hash[*Revs.zip(aves_rev).flatten].
                                      merge(Hash[*ByVapers.zip(aves).flatten]).
                                      merge(Hash[*Differences.zip(sdev).flatten]).
                                      merge(Hash[*Hours.zip(high).flatten]).
                                      merge(Hash[*Aves.zip(lows).flatten])
                                      )
    end
    #ave_power.difference
    @@average_line[line] = average_line
  end

  # rev => 平均 、difference => SDEV、powers => +2σ、ave => -2σ
  def self.average_line_temp(factory_id,line)
    return @@average_line[line] if @@average_line[line]
    return nil unless (1..4).include?(line)
    patern = "稼働#{line}"

    average_line = Shimada::Power.find_or_create_by_date_and_line(nil,line)
    
    powers = self.by_patern(factory_id,patern).
      select{ |pw| 
      #pw.offset_of_hukurosu_vs_pw < 1200 && pw.line > 2 && pw.max_revs >= 605} 
         #pw.date > Date.new(2013,9)} # )
      power_all(factory_id,[" and line = ?", line])
    }
    if  powers.size>2
      aves = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_temp[i]}.compact.average}
      sdev = (0..23).map{ |i| powers.map{ |pw| pw.revise_by_temp[i]}.compact.standard_devitation}
      high = (0..23).map{ |i| aves[i]+2*sdev[i] }
      lows = (0..23).map{ |i| aves[i]-2*sdev[i] }
      average_line.revise_by_vaper
      average_line.save
      average_line.update_attributes( Hash[*Revs.zip(aves).flatten].
                                      merge(Hash[*Differences.zip(sdev).flatten]).
                                      merge(Hash[*Hours.zip(high).flatten]).
                                      merge(Hash[*Aves.zip(lows).flatten])
                                      )
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
      self[Hours[idx]] = temp >  ReviceParams[:threshold]  ?
      rev + ReviceParams[:slope_higher] * (temp - ReviceParams[:threshold]) : 
      rev + ReviceParams[:slope_lower] * (temp - ReviceParams[:threshold])
    }
    self
  end

  Keys = { :revise => Revs,:sdev => Differences,:max => Hours,:min => Aves}
  def copy_and_inv_revise(temperature,method = :revise)
    std = self.class.average_line(self.line)
    temperature.each_with_index{ |temp,idx|
      Keys[method].each{ |hour|  
        value  = std[hour]
        self[hour] = temp >  ReviceParams[:threshold]  ?
        value + ReviceParams[:slope_higher] * (temp - ReviceParams[:threshold]) : 
        value + ReviceParams[:slope_lower] * (temp - ReviceParams[:threshold])
      }
    }
    self
  end


  def lines_rev
    return @lines if @lines
    return 0 if revise_by_temp.size == 0
    unless line
      update_attribute(:line , Lines.index{ |l| l.include?(revise_by_temp_ave[7..-1].max) })
    end
    @lines = line
  end
  def lines
    return @lines if @lines
    return 0 if revise_by_vaper.size == 0
    unless line
      update_attribute(:line , Lines.index{ |l| l.include?(revise_by_vaper_ave[7..-1].max) })
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
    return nil unless ave_difference = self.class.average_diff(shimada_factory_id).difference
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
  def revise_by_month_3 ; offset_3(:revise_by_month) ;  end
  def difference_3 ; offset_3(:difference,22) ;  end
  def diffdiff_3 ; offset_3(:diffdiff,21) ;  end
  def aves_3     ; offset_3(:aves);end


  # Array a of \sum_{i=0}^{次元数}(a_i x^i)
  # 
  def a_rev(n=PolyLevel)
     return @a if @a
    if revise_by_temp.compact.size > n
      polyfit(PolyFitHour.map{ |h| h-PolyFitX0},revise_by_temp[PolyFitHour],n)
    else
      []
    end
  end
  def a(n=PolyLevel)
     return @a if @a
    if revise_by_temp.compact.size > n
      polyfit(PolyFitHour.map{ |h| h-PolyFitX0},revise_by_vaper[PolyFitHour],n)
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

  def vapers 
    return @vapers if @vapers
    return nil unless weather
    @vapers = Vapers.map{ |h| weather[h]}
    save
    @vapers
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
           x0,y0,p0,sll,slh = [:threshold,:y0,:power_0line, :slope_lower, :slope_higher ].
             map{ |sym|Shimada::Power::ReviceParams[sym]}
           slp = temp > ReviceParams[:threshold]  ? slh : sll
           power -  slp*(temp-x0)*(power-p0)/(slp*(temp-x0)+y0-p0)
         else power ? power : 0
         end
      }
      Revs.each{ |r|  self[r] = revs.shift}
      save
    end
    @revise_by_temp = Revs.map{ |r| self[r]}
  end

  def revise_by_month
    return unless self.date
    base = MonthOffset[0]+ MonthOffset[self.date.month]-200
    revise_by_vaper.map{ |rev| rev  - (rev-200)/base * MonthOffset[self.date.month]}
  end

  def revise_by_vaper
    return @revise_by_vaper if @revise_by_vaper
    unless self.by_vaper01
      return [] unless weather

      x0,y0,p0,sll,slh = [:threshold,:y0,:power_0line, :slope_lower, :slope_higher ].
        map{ |sym| VaperParams[sym]}

      vapers0 = (0..23).map{ |h|
        revise = revise_by_temp[h]
        vaper  = weather[Vapers[h]]
        logger.debug("Vapers #{vaper},#{Vapers[h]}")
         if revise && vaper
           slp = vaper > VaperParams[:threshold]  ? slh : sll
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

  def revise_by_month_sum
    revise_by_month.inject(0.0){ |s,e| s += e if e; s}
  end

  # ΣPw = 4400 + 5.4 hukuro + offset
  # offset = ΣPw - 4400 - 5.4 hukuro
  def offset_of_hukurosu_vs_pw(method = :revise_by_temp)
    return 100 unless hukurosu
    bugs_fit = self.class.bugs_fit(method)
    revise_by_temp_sum - bugs_fit[:y0][0] - hukurosu * bugs_fit[:slop][0]
  end

  def offset_from_hukurosu_vs_pw(method)
    return 100 unless hukurosu
    bugs_fit = self.class.bugs_fit(method)
    method = "#{method.to_s.sub(/_sum/,"")}_sum".to_sym
    threshold = (1..bugs_fit[:y0].size-1).
      find_index{ |idx| send(method) < ( bugs_fit[:y0][idx] + hukurosu * bugs_fit[:slop][idx])
    }
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

  def revise_by_vaper_ave(num=3)
    return [] if revise_by_vaper.size ==0 
    return @revise_by_temp_ave if @revise_by_temp_ave
    unless self.ave01
      n = num/2

      aves = (0..powers.size-1).map{ |h| ary = revise_by_vaper[[0,h-n].max..[h+n,revise_by_vaper.size-1].min]
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

  def self.simulate_a_hour(line,hr,temp,vaper)
     polyfits = Shimada::Power::PolyFits[ line]
     [inv_revice(f4(hr,polyfits[:ave]),temp,vaper),
      inv_revice(f4(hr,polyfits[:min]),temp,vaper),
      inv_revice(f4(hr,polyfits[:max]),temp,vaper)
     ]
  end 

  def self.inv_revice(pw,temp,vaper) 
    pw =   inv_vaper(pw,vaper) 
    inv_temp(pw,temp)
  end

  def self.inv_temp(pw,temp)
    params = ReviceParams
    temp >  params[:threshold]  ? pw + params[:slope_higher] * (temp - params[:threshold]) : 
      pw + params[:slope_lower] * (temp - params[:threshold])
  end

  def self.inv_vaper(pw,vaper)
    params = VaperParams
    vaper >  params[:threshold]  ?
    pw + params[:slope_higher] * (vaper - params[:threshold]) : 
      pw + params[:slope_lower] * (vaper - params[:threshold])
  end

  def self.f4(h,a)
    x = h - PolyFitX0
    (((a[4] * x + a[3])*x + a[2])*x + a[1])*x+a[0] 
  end

  # [ [month,average_power],[  ], [  ] ]
  def self.average_group_by_month_maybe3line
    average_group_by_month(maybe3lines).sort
  end

  def self.simulation(factory_id,from,to)
    from ||= Time.now.beginning_of_year.to_date
    to   ||= Time.now.to_date
    #powers = self.
  end

  def self.average_group_by_month(powers)
    powers.group_by{ |p| p.month_id }.
      map{ |month_id,pwrs| 
      [Shimada::Month.find(month_id).month,pwrs.map{ |p| p.revise_by_vaper[14]}.average]}
  end

  def self.maybe3lines
    ids =  Shimada::Month.all.sort_by{|m| m.month}.map(&:id)

    powers = Shimada::Power.all(
  :conditions => "month_id = #{ids[0]} and date not in ('2013-01-1','2013-01-5','2013-01-19','2013-01-24') or 
month_id =  #{ids[1]} and date not in ('2013-02-6','2013-02-9') or 
month_id = #{ids[2]} and date not in ('2013-03-6','2013-03-10','2013-03-16','2013-03-19','2013-03-20','2013-03-21') or 
month_id =  #{ids[3]} and date not in ('2013-04-4','2013-04-8','2013-04-13','2013-04-17','2013-04-20','2013-04-27','2013-04-30') or 
month_id =  #{ids[4]} and date not in ('2013-05-2','2013-05-9','2013-05-11','2013-05-19','2013-05-20','2013-05-23','2013-05-25','2013-05-30') or 
month_id =  #{ids[5]} and date not in ('2013-06-1','2013-06-3','2013-06-8','2013-06-10','2013-06-12','2013-06-13','2013-06-20','2013-06-21','2013-06-24','2013-06-30') or 
month_id =  #{ids[8]} and date not in ('2013-09-7','2013-09-11','2013-09-16','2013-09-21','2013-09-22','2013-09-24','2013-09-28') or 
month_id =  #{ids[9]} and date not in ('2013-10-1','2013-10-7','2013-10-12','2013-10-26','2013-10-27') or 
month_id = #{ids[10]} and date not in ('2013-11-6','2013-11-9','2013-11-10','2013-11-16') or 
month_id =  #{ids[12]} and date not in ('2014-01-1','2014-01-8','2014-01-15','2014-01-16','2014-01-17','2014-01-18','2014-01-21','2014-01-27') or 
month_id =  #{ids[13]} and date not in ('2014-02-1','2014-02-5','2014-02-6','2014-02-15','2014-02-16','2014-02-7','2014-02-10','2014-02-12','2014-02-13','2014-02-14','2014-02-17','2014-02-18','2014-02-19','2014-02-20','2014-02-21','2014-02-22','2014-02-23','2014-02-24','2014-02-25','2014-02-26','2014-02-27') or 
month_id =  #{ids[14]} and date not in ('2014-03-8','2014-03-18','2014-03-25','2014-03-30','2014-03-4','2014-03-5','2014-03-13','2014-03-14','2014-03-16','2014-03-20','2014-03-2') or 
month_id =  #{ids[15]} and date not in ('2014-04-1','2014-04-5','2014-04-12','2014-04-14','2014-04-19','2014-04-26') or 
month_id =  #{ids[16]} and date not in ('2014-05-2','2014-05-7','2014-05-10','2014-05-16','2014-05-19','2014-05-24','2014-05-30') or 
month_id =  #{ids[17]} and date not in ('2014-06-22','2014-06-25','2014-06-2','2014-06-3','2014-06-4','2014-06-17')"
)
    logger.info("MAYBE3LINES: powers.size = #{powers.size}")
powers
  end 

# 629.36, [624.6, 629.6, 630.6, 630.8, 631.2]
end

__END__
[2013,2014].each{ |y|
open("tmp/shimada/time_vs_revise_by_vaper_#{y}","w"){ |f|
  pw = Shimada::Power.power_all(1).select{ |p| p.date.year == y };1
  pw.each{|p| d=p.date.yday ;(0..23).each{|h| 
        f.printf "%s ",( p.date.day == 1 && h==0 ? p.date.month.to_s :  " \"\"")
        #f.printf("%.1f\n",p.powers[h])}};1
        f.printf("%.1f\n",p.revise_by_vaper[h])}};1
  }
}

open("tmp/shimada/vaper_vs_power_#{y}","w"){ |f|
  pw = Shimada::Power.power_all(1).select{ |p| p.date.year == y };1
  pw.each{|p| d=p.date.yday ;(0..23).each{|h| 
        f.printf "%s ",( p.date.day == 1 && h==0 ? p.date.month.to_s :  " \"\"")
        #f.printf("%.1f\n",p.powers[h])}};1
        f.printf("%.1f\n",p.revise_by_vaper[h])}};1
  }
}
