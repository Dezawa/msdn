# -*- coding: utf-8 -*-
require 'test_helper'

class GnuplotTest < ActiveSupport::TestCase
  include Sola::Graph::ClassMethod
  extend Sola::Graph::ClassMethod
 Opt = { :terminal => "jpeg",:size => "600,400" ,
      :graph_file => "image", :graph_file_dir => Rails.root+"tmp" + "img",
      :define_file => Rails.root+"tmp/gnuplot/graph.def",
      :base_path   =>  "tmp/gnuplot/data",
    :column_format => "%d %d %d"
    }

  must "plot_list scatter" do
    assert_equal "plot 'file1' using 1:2 ,\\\n'path2' using 1:2" ,
    plot_list(%w(file1 path2),{type: "scatter"})
  end
  must "plot_list" do
    assert_equal "plot 'file1' using 2:xticlabel(1) ,\\\n'path2' using 2:xticlabel(1)",
    plot_list(%w(file1 path2),{})
  end

  must "plot_list scatter opt[xy]" do
    assert_equal "plot 'file1' using 1:2 ,\\\n'' using 3:4" ,
    plot_list(%w(file1),{type: "scatter", xy: [[[1,2],[3,4]]]})
  end

  must "plot_list scatter 2files 2 opt[xy]" do
    assert_equal "plot 'file1' using 1:2 ,\\\n'' using 3:4 ,\\\n'path2' using 5:6" ,
    plot_list(%w(file1 path2),{type: "scatter", xy: [[[1,2],[3,4]],[[5,6]]]})
  end
  must "plot_list scatter 2files 1 opt[xy]" do
    assert_equal "plot 'file1' using 1:2 ,\\\n'' using 3:4 ,\\\n'path2' using 1:2 ,\\\n'' using 3:4" ,
    plot_list(%w(file1 path2),{type: "scatter", xy: [[[1,2],[3,4]]]})
  end

  must "gnuplot_define" do
    assert_equal "set terminal jpeg enhanced size 600,400 enhanced font 'usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '/opt/www/rails41/msdntest1/tmp/img/image.jpeg'
set title '
set key outside autotitle columnheader
plot 'file1' using 2:xticlabel(1)",    gnuplot_define(["file1"],Opt)
  end

  must "datafiles String" do
    assert_equal ["pathname"],datafiles("pathname",{ })
  end

  must "datafiles Array of String" do
    assert_equal ["pathname","path2"],datafiles(["pathname","path2"],{ })
  end
  must "datafiles data list" do
    path = datafiles([[1,2,2],[2,3,4],[3,4,5]],Opt)
    assert_equal "1 2 2\n2 3 4\n3 4 5\n\n",File.read( path.first )
  end

  must "peak data file " do
    start = Date.new(2014,12,28)
    data_list =(0..7).map{ |d| start+d}.zip([1.23,1.45,1.89,1.30,2.5,2.1,1.9,2.0])
    data_file_output("/tmp/gomi",data_list)
    assert_equal 'Daies 年月日 発電量
  0 ""         1.23
  1 ""         1.45
  2 ""         1.89
  3 ""         1.30
  4 2015-01-01 2.50
  5 ""         2.10
  6 ""         1.90
  7 ""         2.00
',File.read("/tmp/gomi")
  end
end
