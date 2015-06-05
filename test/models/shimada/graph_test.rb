# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'

class Shimada::GraphTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"


  RailsTmp=Rails.root + "tmp"
  Img     = RailsTmp + "img"
  Gnuplotpath = RailsTmp + "gnuplot"
  def setup
    Shimada::Dayly.delete_all
    [TD0424svr,TD0423svr,TD0424,TD0423].each{|trz|  Shimada::Dayly.load_trz(trz)}
  end

  must "graph_type temp_vaper_power での default graph path " do
    dayly = Shimada::Dayly.all
    gp = Shimada::Graph.create("temp_vaper_power",dayly).plot
    expect = (Img + "image.jpeg").to_s
    assert_equal "'#{expect}'",
      `gawk   '/set out/ {print $3}' #{Gnuplotpath+"graph.def"}`.chomp
  end
  must "graph_type temp_vaper_power で graph_file指定したときのgraph path " do
    dayly = Shimada::Dayly.all
    gp = Shimada::Graph.
      create("temp_vaper_power",dayly,
             Gnuplot::OptionST.new(graph_file: "testfile")).plot
    expect = (Img + "testfile.jpeg").to_s
    assert_equal "'#{expect}'",
      `gawk   '/set out/ {print $3}' #{Gnuplotpath+"graph.def"}`.chomp
  end
    must "Shimada::GraphTempVaperPowerのdef" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
    gp = Shimada::GraphTempVaperPower.new(Shimada::Dayly.all)

    define = gp.gnuplot_define({"power" =>["datafile_pathes"],
                                "temp_hyum" =>["datafile_pathes2"]},gp.options)
    assert /set multiplot layout 2,1/ =~ define,"multiplot二段宣言"
    assert_equal 3, define.split("plot 'datafile_pathes").size,"multiplot plot コマンド2回"
    assert_equal 2,define.split("set terminal").size,"multiplot plot terminalコマンド1回"
  end

end
