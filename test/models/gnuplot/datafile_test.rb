# -*- coding: utf-8 -*-
require 'test_helper'
require 'gnuplot_helper'
require 'ondotori/trz_files_helper'

#CaseArryObject     = 


class Dumy
  attr_accessor :item1,:item2,:item3
  def initialize( *args )
    @item1,@item2,@item3 = args
  end
end

class GnuplotTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"
               
  def setup
    Shimada::Dayly.delete_all
  end
  #############################################
  # multiplot のための機能のテスト
  #############################################
  
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
    #pp gp.options
    #pp gp.arry_of_data_objects
    #pp [gp.grouped_daylies.class,gp.grouped_daylies.keys]
    #pp gp.grouped_daylies.values.first.first.class
    datafile_pathes =  gp.datafiles(gp.arry_of_data_objects, gp.options )
    data_power=RailsData+"power000.data"
    assert_equal [data_power].map(&:to_s),datafile_pathes["power"],
      "GraphTempVaperPower data file 最初"
    data_temp=RailsData+"temp_hyum00.data"
    assert_equal [data_temp].map(&:to_s),datafile_pathes["temp_hyum"].map(&:to_s),
      "GraphTempVaperPower data file 二つめ"
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
                    gp.options.merge(column_format: ["%s ", "%d ","%d "]))
     assert_equal "abc 10 20 \ndef 11 21 \n\n", path.read
   end
      
   must "CaseArryObject " do
     i1i2 = [[ 1,2,"a"],[11,12,"b"]].map{|a| Dumy.new(*a) }
     gp = Graph::Base.new(i1i2,column_attrs: [:item1,:item2,:item3])
     path = Rails.root+"tmp"+"gnuplot"+"data"+"data000.data"
     gp.datafiles(gp.arry_of_data_objects,
                    gp.options.merge(column_format: "%.1f %d %s"))
     assert_equal "1.0 2 a\n11.0 12 b\n\n",path.read
   end

   DefaultOptionST = Graph::Base::DefaultOptionST
   expect = <<-EOF
set terminal jpeg enhanced size 600,400 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '/opt/www/rails41/msdntest1/tmp/img/image.jpeg'
set key outside autotitle columnheader
plot 'datafilepath' using 1:2
#########
   EOF

   must "Graph::Base無指定 Gnuplot::DefaultOption" do
     gp = Graph::Base.new([], Gnuplot::DefaultOption)
     assert_equal expect, 
       gp.gnuplot_define(["datafilepath"], Gnuplot::DefaultOption)
   end

   expect_datafiles =
     {"power"=>[RailsData+"power000.data"].map(&:to_s),
      "temp_hyum"=>[RailsData+"temp_hyum00.data"].map(&:to_s)}
    must "multi plot Shimada::Graph GraphTempVaperPowerのdatafile" do
    Shimada::Dayly.load_trz(TD0423)
    Shimada::Dayly.load_trz(TD0423svr)
      gp = Shimada::Graph.create("temp_vaper_power",
                                 Shimada::Dayly.all, Gnuplot::OptionST.new)
      datafile = gp.datafiles(gp.arry_of_data_objects ,gp.options)
      assert_equal expect_datafiles,datafile
     
    end
end
