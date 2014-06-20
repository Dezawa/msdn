# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  set_table_name 'shimada_powers'
  belongs_to :month,:class_name => "Shimada::Month"
  Hours = ("hour01".."hour24")

  Temp_power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/power.gif'

set title "温度-消費電力 " 
set key outside autotitle columnheader
set yrange [0:1000]
set xrange [-10:40]
set xtics -10,5
!

  Header = "時刻"

  def self.gnuplot_data_by_temp(powers,opt = { })
    path = []
    if by_month = opt[:by_month]
      ary_powres = powers.group_by{ |p| p.date.strftime("%Y/%m")}
      ary_powres.each_with_index{ |month_powers,idx|
        path << "/tmp/shimada/shimada_power_temp%d"%idx
        open(path.last,"w"){ |f|
          f.puts "温度 #{month_powers.first}"
          month_powers.last.each{ |power|
            temperatures = Weather.find_or_feach("maebashi", power.date).temperatures
            power.powers.each_with_index{ |h,idx| f.printf "%.1f %.1f\n",temperatures[idx],h }
          }
        }
      }
    else
      path << "/tmp/shimada/shimada_power_temp"
      open(path.last,"w"){ |f|
        f.puts "温度 電力"
        powers.each{ |power|
          temperatures = Weather.find_or_feach("maebashi", power.date).temperatures
          power.powers.each_with_index{ |h,idx| f.printf "%.1f %.1f\n",temperatures[idx],h }
          f.puts
        }
      }
    end
    path
  end


  def self.gnuplot_data(powers,nomalized=false)
    path = "/tmp/shimada_power"
    open(path,"w"){ |f|
      f.puts "時刻 電力"
      if nomalized
          powers.each{ |power|
            power.each_with_index{ |h,idx| f.printf "%d %.4f\n",idx+1,h }
          f.puts
        }
      else
        powers.each{ |power|
          power.each_with_index{ |h,idx| f.printf "%d %.1f\n",idx+1,h }
          f.puts
        }
      end
    }
    path
  end

  def self.gnuplot(powers,nomalized=false)
    gnuplot_data(powers,nomalized)
    def_file = nomalized ? "nomalized.def" : "power.def"
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot app/models/shimada/#{def_file})`
  end

  def self.gnuplot_by_temp(powers,opt={ })
    path = gnuplot_data_by_temp(powers,opt)
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

  def powers ; Hours.map{ |h| self[h]} ; end

  def move_ave(num=3)
    @move_ave ||= []
    return @move_ave[num] if @move_ave[num]
    n = num/2
    @move_ave[num] = (0..powers.size-1).
      map{ |h| ary = powers[[0,h-n].max..[h+n,powers.size-1].min]
      ary.inject(0){ |s,e| s+e}/ary.size
    }
  end

  def normalized(num=3)
    ave = max_ave(num)
    move_ave(num)
    #Hours.map{ |h| self[h]/ave}
    move_ave(num).map{ |h| h/ave}
  end

  def max_powers(num=3)
    #Hours.map{ |h| self[h]}.sort.last(num)
    move_ave(num).sort.last(num)
  end

  def max_ave(num=3)
    max_powers(num).inject(0){ |s,e| s+=e}/num
  end

  def power_temp

  end
end
