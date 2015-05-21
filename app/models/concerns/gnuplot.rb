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


  
  def output_datafile(grouped_data_ary,opt,&block)
   # pp opt
    base_path = opt[:base_path].to_s+"/"+ opt[:data_file]
    datafile_pathes = []
    keys = opt[:keys] || grouped_data_ary.map{ |ary| ary.first}.sort
    keys.each_with_index{ |key,idx|
      datafile_pathes << "#{base_path}.data"
      open(datafile_pathes.last,"w"){ |f|
        f.puts opt[:column_labels].join(" ") if opt[:column_labels]
        yield f,key,grouped_data_ary[idx][1]
        f.puts
      }
      base_path.succ!
    }
    datafile_pathes 
  end
end
