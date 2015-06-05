# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'

class Shimada::FactoryTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"
  def setup
    Shimada::Dayly.delete_all
    @factory = Shimada::Factory.find 1
    [TD0424svr,TD0423svr,TD0424,TD0423].each{|trz|  Shimada::Dayly.load_trz(trz)}    
  end

  must "today_graph の結果のgrah_file_pathは" do
    assert_equal (Rails.root+"tmp"+"img"+"temp_vaper_power_2_1.jpeg").to_s,
                  @factory.today_graph( "全電力・気温")
  end

  must "today_graphの define file" do
    define_file =Rails.root+"tmp"+"gnuplot"+"test2graph.def"
    Shimada::Factory.find(1).
      today_graph("全電力・気温")
    assert_equal "set terminal jpeg enhanced size 900,400 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '/opt/www/rails41/msdntest1/tmp/img/temp_vaper_power_2_1.jpeg'
set multiplot layout 2,1\nset lmargin 10\nset rmargin 15
unset xlabel\nunset xtics\n
#########
set title '全電力と温度・蒸気圧'
set key outside autotitle columnheader
set xdata time\nset timefmt \"%Y-%m-%d %H:%M\"\nset format x '%H:%M'
set bmargin 0\nset ylabel '電力'
plot '/opt/www/rails41/msdntest1/tmp/gnuplot/data/power000.data' using 1:3 pt 6 ps 0.2

set title ''
set key outside autotitle columnheader
set xdata time
set timefmt \"%Y-%m-%d %H:%M\"
set format x '%H:%M'
set tmargin 0
set bmargin 3
set xlabel
set tics
set xtics rotate by -90
set ylabel '気温、蒸気圧'
plot '/opt/www/rails41/msdntest1/tmp/gnuplot/data/temp_hyum00.data' using 1:3 pt 6 ps 0.2 ,\\
'' using 1:4 pt 6 ps 0.2

#########
", File.read(Rails.root+"tmp"+"gnuplot"+"graph.def")
  end

  must "day_graph_newの define file" do
    define_file =Rails.root+"tmp"+"gnuplot"+"testgraph.def"
    Shimada::Factory.find(1).
      day_graph_new(Date.new(2015,4,23),
                    Shimada::GraphDefines[1][ "全電力・気温" ],
                    Gnuplot::OptionST.new(define_file: define_file)
                   )
    assert_equal "set terminal jpeg enhanced size 900,400 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '/opt/www/rails41/msdntest1/tmp/img/temp_vaper_power_2_1.jpeg'
set multiplot layout 2,1
set lmargin 10
set rmargin 15
unset xlabel
unset xtics

#########
set title '全電力と温度・蒸気圧'
set key outside autotitle columnheader
set xdata time
set timefmt \"%Y-%m-%d %H:%M\"
set format x '%H:%M'
set bmargin 0
set ylabel '電力'
plot '/opt/www/rails41/msdntest1/tmp/gnuplot/data/power000.data' using 1:3 pt 6 ps 0.2

set title ''
set key outside autotitle columnheader
set xdata time
set timefmt \"%Y-%m-%d %H:%M\"
set format x '%H:%M'
set tmargin 0
set bmargin 3
set xlabel
set tics
set xtics rotate by -90
set ylabel '気温、蒸気圧'
plot '/opt/www/rails41/msdntest1/tmp/gnuplot/data/temp_hyum00.data' using 1:3 pt 6 ps 0.2 ,\\
'' using 1:4 pt 6 ps 0.2

#########
", File.read(define_file)
  end

end
