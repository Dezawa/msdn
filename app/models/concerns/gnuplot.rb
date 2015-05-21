# -*- coding: utf-8 -*-

module Gnuplot
  include Gnuplot::Options
  include Gnuplot::Datafile
  include Gnuplot::Makedefine
  # 出力される画像fileは  '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'
  #     このpathは opt[:graph_file_path] に代入される。
  # detalistの形式は #datafiles の説明参照
  def plot ;logger.debug("##########  @option=#{@option}")
    gnuplot_(arry_of_data_objects,@option);end
  
  def gnuplot_(data_list,opt)
    #opt = DefaultOption.merge opt

    datafile_pathes =  datafiles(data_list,opt)
    def_file = output_gnuplot_define(datafile_pathes,opt)
    `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
    opt.is_a?(OptionST) ? opt[:header][:graph_file_path] :  opt[:graph_file_path]
  end


end
