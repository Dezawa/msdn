# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  set_table_name 'shimada_powers'
  belongs_to :month,:class_name => "Shimada::Month"
  Hours = ("hour01".."hour24")

  Header = "時刻"

  def self.gnuplot_data_by_temp(powers,opt = { })
    path = "/tmp/shimada_power_temp"
    open(path,"w"){ |f|
      f.puts "温度 電力"
      powers.each{ |power|
        temperatures = Weather.find_or_feach("maebashi", power.date).temperatures
        power.powers.each_with_index{ |h,idx| f.printf "%.1f %.1f\n",temperatures[idx],h }
        f.puts
      }
    }
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
    gnuplot_data_by_temp(powers,opt)
    def_file = "power_temp.def"
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot app/models/shimada/#{def_file})`
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
