# -*- coding: utf-8 -*-
require 'test_helper'
Hyum   = TD0423   =
  "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
Power01 = TD0423svr =
  "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150423-060853.trz"

class Dumy
  attr_accessor :item1,:item2,:item3
  def initialize( *args )
    @item1,@item2,@item3 = args
  end
end

CaseString = Power01
CaseArryString = [Power01,Hyum]
CaseArryArry   = [["abc",10,20],["def",11,21]]
#CaseArryObject     = 


class GnuplotTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"

  RailsData = (Rails.root+"tmp"+"gnuplot"+"data").to_s + "/"
               
  def setup
    Shimada::Dayly.delete_all
  end
  #############################################
  # multiplot のための機能のテスト
  #############################################
  must "Shimada::GraphTempVaperPower の option" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
    gp = Shimada::GraphTempVaperPower.new(Shimada::Dayly.all )
    assert_equal 14, gp.option.size,"Shimada::GraphTempVaperPower の optionのkey数"
    assert_equal ["power000","temp_hyum00"],
      ["power","temp_hyum"].map{|key| gp.option[key][:data_file]},
      "Shimada::GraphTempVaperPower の データファイルbasename"
    
    assert_equal [(Rails.root+"tmp"+"gnuplot"+"data")]*2,
      ["power","temp_hyum"].map{|key| gp.option[key][:base_path]},
      "Shimada::GraphTempVaperPower の データファイルbase_path"
                  
    assert_equal (Rails.root+"tmp"+"gnuplot"+"graph.def"), gp.option[:define_file],
      "Shimada::GraphTempVaperPower の define_file"

  end
  
  must "Shimada::GraphTempVaperPower の arry_of_data_objects" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
    gp = Shimada::GraphTempVaperPower.new(Shimada::Dayly.all )
    assert_equal 2, gp.arry_of_data_objects.size,
      "Shimada::GraphTempVaperPower の  arry_of_data_objectsのkey数"
    assert_equal ["temp_hyum", "power"], gp.arry_of_data_objects.keys,
      "Shimada::GraphTempVaperPower の  arry_of_data_objectsのkey"
  end
  
  must "Shimada::GraphTempVaperPower の data files" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
    gp = Shimada::GraphTempVaperPower.new(Shimada::Dayly.all )
    #pp gp.option
    #pp gp.arry_of_data_objects
    #pp [gp.grouped_daylies.class,gp.grouped_daylies.keys]
    #pp gp.grouped_daylies.values.first.first.class
    datafile_pathes =  gp.datafiles(gp.arry_of_data_objects, gp.option )
    pp datafile_pathes
    data_power=RailsData+"power000.data"
    assert_equal [data_power],datafile_pathes["power"].map(&:to_s),
      "GraphTempVaperPower data file 最初"
    data_temp=RailsData+"temp_hyum00.data"
    assert_equal [data_temp],datafile_pathes["temp_hyum"].map(&:to_s),
      "GraphTempVaperPower data file 二つめ"
  end

  must "Shimada::GraphTempVaperPowerのdef" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
    gp = Shimada::GraphTempVaperPower.new(Shimada::Dayly.all)
    #pp gp.option
    define = gp.gnuplot_define({"power" =>["datafile_pathes"],
                                "temp_hyum" =>["datafile_pathes2"]},gp.option)
    puts define
    assert /set multiplot layout 2,1/ =~ define,"multiplot二段宣言"
    assert_equal 3, define.split("plot 'datafile_pathes").size,"multiplot plot コマンド2回"
    assert_equal 2,define.split("set terminal").size,"multiplot plot terminalコマンド1回"
  end

  must "default plot command" do
    gp = Graph::Base.new([])
    define = gp.gnuplot_define(["datafile_pathes"],gp.option)
    assert /plot 'datafile_pathes' using 1:2/ =~ define,
      "plot  command line"
  end
  
  must "default define " do
    gp = Graph::Base.new([])
    define = gp.gnuplot_define(["datafile_pathes"],gp.option)
    assert  /terminal jpeg/ =~ define, "terminal typoe"
    assert  /size 600,400/ =~ define , "size"
    assert  /using 1:2/    =~ define ,"graph type is scatter"
    assert  /set out '#{Rails.root}\/tmp\/img\/image.jpeg'/ =~ define, " Default output path"
  end
  #############################################
  # default option のテスト
  #############################################


  #############################################
  #  option over ride のテスト
  #############################################
  must "define option size" do
    gp = Graph::Base.new([],size: "1000,500")
    define = gp.gnuplot_define(["datafile_pathes"],gp.option)
    assert  /size 1000,500/ =~ define , "size"
  end
  must "define option graph_file" do
    gp = Graph::Base.new([],graph_file: "graph_file")
    define = gp.gnuplot_define(["datafile_pathes"],gp.option)
    assert  /set out '#{Rails.root}\/tmp\/img\/graph_file.jpeg'/ =~ define, "  output path"
  end

  #############################################
  # data_list の型のテスト
  #############################################

  must "CaseString" do
     gp = Graph::Base.new(CaseString)
     assert_equal [Power01], gp.datafiles#(gp.arry_of_data_objects,{})
   end
  
   must "CaseArryString" do
     gp = Graph::Base.new(CaseArryString)
     assert_equal [Power01,Hyum], gp.datafiles#(gp.arry_of_data_objects,{})
     end
   must "CaseArryArry" do
   gp = Graph::Base.new(CaseArryArry)
     path = Rails.root+"tmp"+"gnuplot"+"data"+"data000.data"
     assert_equal [path.to_s],
       gp.datafiles(gp.arry_of_data_objects,
                    gp.option.merge(column_format: ["%s ", "%d ","%d "]))
     assert_equal "abc 10 20 \ndef 11 21 \n\n", path.read
   end
      
   must "CaseArryObject " do
     i1i2 = [[ 1,2,"a"],[11,12,"b"]].map{|a| Dumy.new(*a) }
     gp = Graph::Base.new(i1i2,column_attrs: [:item1,:item2,:item3])
     path = Rails.root+"tmp"+"gnuplot"+"data"+"data000.data"
     gp.datafiles(gp.arry_of_data_objects,
                    gp.option.merge(column_format: "%.1f %d %s"))
     assert_equal "1.0 2 a\n11.0 12 b\n\n",path.read
   end
end
