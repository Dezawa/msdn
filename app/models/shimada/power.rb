# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  include Shimada::GnuplotDef
  set_table_name 'shimada_powers'
  belongs_to :month     ,:class_name => "Shimada::Month"
  belongs_to :db_weather,:class_name => "Weather"
  Hours = ("hour01".."hour24").to_a
  Revs = ("rev01".."rev24").to_a
  Aves = ("ave01".."ave24").to_a
  Lines = [(0..300),(300..350),(350..400),(400..550),(550..700),(700..800)]

  Header = "時刻"


  def self.reset_reevice_and_ave
    self.all.each{ |power|
      ( Revs +   Aves ).each{ |clm|  power[clm]=nil }
      power.save
    }
  end

  def self.output_plot_data(powers,method,opt = { },&block)
    path = []
    ary_powres = if by_month = opt[:by_month]
                   powers.group_by{ |p| p.date.strftime("%Y/%m")} 
                 else
                   [[powers.first.date.strftime("%Y/%m"),powers]]
                 end
    ary_powres.each_with_index{ |month_powers,idx|
      path << "/tmp/shimada/shimada_power_temp%d"%idx
      open(path.last,"w"){ |f|
        f.puts "時刻 #{month_powers.first}"
        month_powers.last.each{ |power|
          yield f,power #power.send(method).each_with_index{ |h,idx| f.printf "%d %.3f\n",idx+1,h }
          f.puts
        }
      }
    }
    path
  end

  def self.gnuplot(powers,method,opt={ })
    path = output_plot_data(powers,method,opt){ |f,power| 
      power.send(method).each_with_index{ |h,idx| f.printf "%d %.3f\n",idx+1,h }
    }
    def_file = "/tmp/shimada/power.def"

    by_month = opt[:by_month] ? "set key outside autotitle columnheader" : "unset key"
    preunble = ( case method
                 when :normalized ;  Nomalized_def
                 when :difference, :difference_ave ,:diffdiff;  Differ_def 
                 else             ; Power_def 
                 end)% by_month

    open(def_file,"w"){ |f|
      f.puts preunble
      f.puts "plot " + path.map{ |p| "'#{p}' using 1:2  with line"}.join(" , ")
    }
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
  end

  def self.gnuplot_by_temp(powers,opt={ })
    path = output_plot_data(powers,:powers,opt){ |f,power| 
      temperatures = Weather.find_or_feach("maebashi", power.date).temperatures
      power.powers.each_with_index{ |h,idx| f.printf "%.1f %.1f\n",temperatures[idx],h }
    }
#    path = gnuplot_data_by_temp(powers,opt)
    def_file = "/tmp/shimada/power_temp.def"
    open(def_file,"w"){ |f|
      f.puts Temp_power_def
      f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ") +
      if opt[:with_Approximation]
        ", 780+9*(x-20) ,670+3*(x-20), 0.440*(x-5)**1.8+750"
      else
        ""
      end
    }
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
  end

  def lines
    Lines.index{ |line| line.include?(revise_by_temp_ave[3..-1].max) }
  end

  def powers ; Hours.map{ |h| self[h]} ; end

  def weather
    return db_weather if db_weather
    db_weather = Weather.find_or_feach("maebashi", date)
  end

  def temps 
    return @temps if @temps
    @temps = Hours.map{ |h| weather[h]}
    save
    @temps
  end

  def revise_by_temp
    return @revise_by_temp if @revise_by_temp
    unless self.rev01
      revs = Hours.map{ |h|
        power = self[h]
        temp  = weather[h]
        temp > 15.0 ? power - 9 * (temp - 20) : power - 3 * (temp - 20)
      }
      Revs.each{ |r|  self[r] = revs.shift}
      save
    end
    @revise_by_temp = Revs.map{ |r| self[r]}
  end

  def diffdiff(num=5)
    n = num/2
    y0 = difference_ave.first
    diff =difference_ave[1..-1].map{ |y| dif = y - y0; y0 = y ; dif*4}
    aves = (0..diff.size-1).map{ |h| ary = diff[[0,h-n].max..[h+n,diff.size-1].min]
      ary.inject(0){ |s,e| s+e}/ary.size
    } 
  end

  def difference
    y0 = revise_by_temp_ave.first
    revise_by_temp_ave[1..-1].map{ |y| dif = y - y0; y0 = y ; dif} 
  end

  def difference_ave(num=5)
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
        ary.inject(0){ |s,e| s+e}/ary.size
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

  def normalized(num=5)
    ave = max_ave(num)
    move_ave(num)
    #Hours.map{ |h| self[h]/ave}
    move_ave(num).map{ |h| h/ave}
  end

  def max_powers(num=3)
    Hours.map{ |h| self[h]}.sort.last(num)
  end

  def max_ave(num=3)
    move_ave(num).sort.last(num).inject(0){ |s,e| s+=e}/num
  end
# 629.36, [624.6, 629.6, 630.6, 630.8, 631.2]
end
