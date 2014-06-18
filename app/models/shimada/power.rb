# -*- coding: utf-8 -*-
require "tempfile"

class Shimada::Power < ActiveRecord::Base
  set_table_name 'shimada_powers'
  belongs_to :month,:class_name => "Shimada::Month"
  Hours = ("hour01".."hour24")

  Header = "時刻"

  def self.gnuplot_data(powers)
    path = "/tmp/shimada_power"
    open(path,"w"){ |f|
      f.puts "時刻 電力"
      powers.each{ |power|
        Hours.each_with_index{ |h,idx| f.printf "%d %.1f\n",idx+1,power[h] }
        f.puts
      }
    }
    path
  end

  def self.gnuplot(powers)
    gnuplot_data(powers)
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot app/models/shimada/power.def)`
  end

  def gnuplot_data
    tmp = Tempfile.open("shimada_power")
    tmp.puts Header+date.strftime(" %m/%d")
    Hours.each_with_index{ |h,idx| tmp.printf "%d %.1f\n",idx+1,self[h] }
    tmp.close
    tmp.path
  end

end
