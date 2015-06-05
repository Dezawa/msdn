# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'

class Dumy
  attr_accessor :item1,:item2,:item3
  def initialize( *args )
    @item1,@item2,@item3 = args
  end
end

class GnuplotTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"

  RailsData = (Rails.root+"tmp"+"gnuplot"+"data").to_s + "/"
               
  def setup
    #pp Shimada::GraphTempVaperPower::DefaultOptST[:header].keys.join(" ")
    Shimada::Dayly.delete_all
  end

  #############################################
  #  options over ride のテスト
  #############################################
  must "define options size" do
    gp = Graph::Base.new([],size: "1000,500")
    define = gp.gnuplot_define(["datafile_pathes"],gp.options)
    assert  /size 1000,500/ =~ define , "size"
  end
  must "define options graph_file" do
    gp = Graph::Base.new([],graph_file: "graph_file")
    define = gp.gnuplot_define(["datafile_pathes"],gp.options)
    assert  /set out '#{Rails.root}\/tmp\/img\/graph_file.jpeg'/ =~ define, "  output path"
  end

   expect_opt =
     {:common=>       {:type=>"scatter", :data_file=>"data000", :xy=>[[[1, 2]]],
                       :set_key=>"set key outside autotitle columnheader"},
      :dumy=>{:a=>10,:type=>"scatter", :data_file=>"data000", :xy=>[[[1, 2]]],
              :set_key=>"set key outside autotitle columnheader",
              base_path: Pathname.new(RailsData.chop)
             }
     }                                
   must "Graph::Base無指定 Graph::Base::DefaultOptionST" do
     #pp [DefaultOptionST.class,DefaultOptionST.kind_of?(Gnuplot::OptionST)]
     gp = Graph::Base.new([], Gnuplot::DefaultOptionST)
     assert_equal "set key outside autotitle columnheader",
       gp.plot_define( Gnuplot::DefaultOptionST[:body][:common])
     assert_equal "set terminal jpeg enhanced size 600,400 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '/opt/www/rails41/msdntest1/tmp/img/image.jpeg'
#########
set key outside autotitle columnheader
plot 'datafilepath' using 1:2

#########
",
       gp.gnuplot_define_struct(["datafilepath"], Gnuplot::DefaultOptionST.dup)
   end
end
