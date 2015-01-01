# -*- coding: utf-8 -*-
class Sola::Controller < CommonController 
  Links =
    [
     Menu.new(   "日々データ",:dayly   ,:action => :index) ,
     Menu.new(   "月データ"  ,:monthly ,:action => :index) ,
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
