# -*- coding: utf-8 -*-
require 'test_helper'
class Shimada::GraphTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"

  MSDNDIR  =  "/home/dezawa/MSDN/おんどとり/data/"
  TD01rest = MSDNDIR + "ティアンドデイ社屋_1F休憩所_20150401-060343.trz"
  TD01svr  = MSDNDIR + "ティアンドデイ社屋_サーバー_20150401-063443.trz"
  TD0424   = MSDNDIR + "ティアンドデイ社屋_1F休憩所_20150424-060350.trz"
  TD0423   = MSDNDIR + "ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
  TD0423svr= MSDNDIR + "ティアンドデイ社屋_サーバー_20150423-060853.trz"
  TD0424svr= MSDNDIR + "ティアンドデイ社屋_サーバー_20150424-060837.trz"

  RailsTmp=Rails.root + "tmp"
  Img     = RailsTmp + "img"
  Gnuplot = RailsTmp + "gnuplot"
  def setup
    Shimada::Dayly.delete_all
    [TD0424svr,TD0423svr,TD0424,TD0423].each{|trz|  Shimada::Dayly.load_trz(trz)}
  end

  must "graph_type temp_vaper_power での default graph path " do
    dayly = Shimada::Dayly.all
    gp = Shimada::Graph.create("temp_vaper_power",dayly).plot
    expect = (Img + "image.jpeg").to_s
    assert_equal "'#{expect}'",
      `gawk   '/set out/ {print $3}' #{Gnuplot+"graph.def"}`.chomp
  end
  must "graph_type temp_vaper_power で graph_file指定したときのgraph path " do
    dayly = Shimada::Dayly.all
    gp = Shimada::Graph.create("temp_vaper_power",dayly,graph_file: "testfile").plot
    expect = (Img + "testfile.jpeg").to_s
    assert_equal "'#{expect}'",
      `gawk   '/set out/ {print $3}' #{Gnuplot+"graph.def"}`.chomp
  end
end
