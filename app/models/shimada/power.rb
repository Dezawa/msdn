# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  set_table_name 'shimada_powers'
  belongs_to :month,:class_name => "Shimada::Month"
  Hours = ("hour01".."hour24")

  Header = "時刻"

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
          Hours.each_with_index{ |h,idx| f.printf "%d %.1f\n",idx+1,power[h] }
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

  def normalized(num=3)
    ave = max_ave(num)
    Hours.map{ |h| self[h]/ave}
  end

  def max_powers(num=3)
    Hours.map{ |h| self[h]}.sort.last(num)
  end
  def max_ave(num=3)
    max_powers(num).inject(0){ |s,e| s+=e}/num
  end

end
