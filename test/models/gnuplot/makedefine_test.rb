# -*- coding: utf-8 -*-
require 'test_helper'
require "gnuplot_helper"
require 'ondotori/trz_files_helper'

class GnuplotMakedefileTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"
  
  
  must "default plot command" do
    gp = Graph::Base.new([])
    define = gp.gnuplot_define(["datafile_pathes"],gp.options)
    assert /plot 'datafile_pathes' using 1:2/ =~ define,
      "plot  command line"
  end

  must "default define " do
    gp = Graph::Base.new([])
    define = gp.gnuplot_define(["datafile_pathes"],gp.options)
    assert  /terminal jpeg/ =~ define, "terminal typoe"
    assert  /size 600,400/ =~ define , "size"
    assert  /using 1:2/    =~ define ,"graph type is scatter"
    assert  /set out '#{Rails.root}\/tmp\/img\/image.jpeg'/ =~ define, " Default output path"
  end

   must "multi plot Shimada::Graph GraphTempVaperPowerのDefaultoptionでのheader define" do
     #pp [DefaultOptionST.class,DefaultOptionST.kind_of?(Gnuplot::OptionST)]
     gp = Shimada::Graph.create("temp_vaper_power",[])

     assert_equal  "set terminal jpeg enhanced size 900,400 "+
      "enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'\n"+
      "set out '#{RailsImg}/image.jpeg'"+
        "\nset multiplot layout 2,1\nset lmargin 10\nset rmargin 15\n" +
        "unset xlabel\nunset xtics\n", gp.header(gp.options[:header])
   end

   PowerDef =  "set title '全電力と温度・蒸気圧'\n" +
     "set key outside autotitle columnheader\n" +
     "set xdata time\nset timefmt \"%Y-%m-%d %H:%M\"\nset format x '%H:%M'\n"+
     "set bmargin 0\n"+
       "set ylabel '電力'\nplot 'datafilepoewr' using 1:3 pt 6 ps 0.2\n"
     
   TempDef =  "set title ''\n"+
     "set key outside autotitle columnheader\n" +
     "set xdata time\nset timefmt \"%Y-%m-%d %H:%M\"\nset format x '%H:%M'\n"+
     "set tmargin 0\nset bmargin 3\n"+
     "set xlabel\nset tics\nset xtics rotate by -90\n" +
     "set ylabel '気温、蒸気圧'\n" +
     "plot 'datafiletemp' using 1:3 pt 6 ps 0.2 ,\\\n"+
     "'' using 1:4 pt 6 ps 0.2\n"

     
   must "multi plot Shimada::Graph GraphTempVaperPowerのDefaultoptionでの  plot_define_plot_list" do
     #pp [DefaultOptionST.class,DefaultOptionST.kind_of?(Gnuplot::OptionST)]
     gp = Shimada::Graph.create("temp_vaper_power",[])

     assert_equal PowerDef,
       gp.plot_define_plot_list(["datafilepoewr"],gp.options[:body]["power"])

   end
      
   must "multi plot Shimada::Graph GraphTempVaperPowerのDefaultoptionでのplot_define_struct" do
     #pp [DefaultOptionST.class,DefaultOptionST.kind_of?(Gnuplot::OptionST)]
     gp = Shimada::Graph.create("temp_vaper_power",[])

     assert_equal PowerDef + "\n" + TempDef,
       gp.plot_define_struct({"power"=>["datafilepoewr"],"temp_hyum" =>["datafiletemp"]},gp.options)
   end       
  

end
