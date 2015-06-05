# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'
require "gnuplot_helper.rb"

class Shimada::GraphTempVaperPowerTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"


  def setup
    Shimada::Dayly.delete_all
  end

  must "grouping_daylies_by_graph_type " do
    load_trz(TD0424,    TD0423  ,  TD0423svr, TD0424svr)
    sgtvp = Shimada::GraphTempVaperPower.new(daylies)
    assert_equal %w(power temp_hyum), sgtvp.arry_of_data_objects.keys.sort,
      "grouping_daylies_by_graph_typeのkey"

  end

   def daylies
     Shimada::Dayly.by_factory_id(1).where(month: "2015-4-1")
   end
  
   def load_trz(*args)
     args.flatten.each{|file| Shimada::Dayly.load_trz file }
   end
   
  must "Shimada::GraphTempVaperPower::DefaultOptSTの初期値" do
    assert_equal [:terminal,:size,:graph_file,:graph_file_dir,:define_file,
                  :multiplot,:multi_margin,:multi_order],
      Shimada::GraphTempVaperPower::DefaultOptST[:header].keys,"Shimada::GraphTempVaperPower::DefaultOptSTのheaderのkey"
    assert_equal "900,400", Shimada::GraphTempVaperPower::DefaultOptST[:header][:size],
      "Shimada::GraphTempVaperPower::DefaultOptSTの画像サイズ"
    assert_equal [6,6,6],
      Shimada::GraphTempVaperPower::DefaultOptST[:body]["power"][:point_type],
      "Shimada::GraphTempVaperPower::DefaultOptSTのポイントサイズ"

  end
   expectST = <<-EOF
set terminal jpeg enhanced size 900,400 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '/opt/www/rails41/msdntest1/tmp/img/image.jpeg'
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
set format x '%Y/%m/%d'
set bmargin 0
set ylabel '電力'
plot '#{RailsData}/power000.data' using 1:3 pt 6 ps 0.2

set title ''
set key outside autotitle columnheader
set xdata time
set timefmt \"%Y-%m-%d %H:%M\"
set format x '%Y/%m/%d'
set tmargin 0
set bmargin 3
set xlabel
set tics
set xtics rotate by -90
set ylabel '気温、蒸気圧'
plot '#{RailsData}/temp_hyum00.data' using 1:3 pt 6 ps 0.2 ,\\
'' using 1:4 pt 6 ps 0.2

#########
   EOF

    must "multi plot Shimada::Graph GraphTempVaperPowerのdefine" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
      #pp [DefaultOptionST.class,DefaultOptionST.kind_of?(Gnuplot::OptionST)]
      gp = Shimada::Graph.create("temp_vaper_power",
                                 Shimada::Dayly.all, Gnuplot::OptionST.new)
      datafile = gp.datafiles(gp.arry_of_data_objects ,gp.options)
      define = gp.gnuplot_define_struct(datafile,gp.options)
      assert_equal expectST,define
     
    end

              
  #############################################
  # multiplot のための機能のテスト
  #############################################
  must "Shimada::GraphTempVaperPower の options" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
    gp = Shimada::GraphTempVaperPower.new([])#Shimada::Dayly.all )
    keys = %w(terminal size graph_file graph_file_dir define_file
               base_path type data_file xy set_key
               multiplot multi_margin multi_order size
               point_type point_size xdata_time).sort.uniq
    assert_equal keys,
       (gp.options[:header].keys + gp.options[:body][:common].keys).map(&:to_s).sort.uniq,
       "Shimada::GraphTempVaperPower の headerとcommon のoptionsのkey"

     assert_equal [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%Y/%m/%d'"   ] ,
       gp.options[:body]["power"][:xdata_time]

    assert_equal ["power000","temp_hyum00"],
      ["power","temp_hyum"].map{|key| gp.options[:body][key][:data_file]},
      "Shimada::GraphTempVaperPower の データファイルbasename"
    
    assert_equal [(Rails.root+"tmp"+"gnuplot"+"data")]*2,
      ["power","temp_hyum"].map{|key| gp.options[:body][key][:base_path]},
      "Shimada::GraphTempVaperPower の データファイルbase_path"
                  
    assert_equal (Rails.root+"tmp"+"gnuplot"+"graph.def"), gp.options[:header][:define_file],
      "Shimada::GraphTempVaperPower の define_file"
  end

end
