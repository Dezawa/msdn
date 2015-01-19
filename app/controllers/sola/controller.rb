# -*- coding: utf-8 -*-
class Sola::Controller < CommonController 
  Links =
    [
     Menu.new(   "日々ピーク",:dayly   ,:action => :index) ,
     Menu.new(   "日々発電量",:dayly   ,:action => :index_day_total) ,
     Menu.new(   "モニタデータ",:dayly ,:action => :index_monitor) ,
     Menu.new(   "月データ"    ,:monthly ,:action => :index) ,
     Menu.new(   "ピークグラフ",:dayly ,{ :action => :peak_graph}  ,:win_name => "newtab", :target =>"newtab") ,
     Menu.new(   "相関"  ,:dayly ,{ :action => :correlation},:target =>"newtab") ,
     Menu.new(   "電池残量"  ,"status/tand_d" ,{ :action => :list}) ,
    ]

  def set_instanse_variable
    @Links = Links
  end
  def peak_graph
    @graph_file = "sola_peak"
    @graph_file_dir = Rails.root+"tmp" + "img"
    Sola::Dayly.peak_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end


end
