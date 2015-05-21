# -*- coding: utf-8 -*-
module Graph
  class Base
    include ActiveModel::Model
    include Gnuplot
  delegate :logger, :to=>"ActiveRecord::Base"
    attr_reader :arry_of_data_objects,:option
    def initialize(arry_of_data_objects,opt={})
      @arry_of_data_objects = arry_of_data_objects
      @option  = case opt
                 when Hash ;      DefaultOption.merge opt
                 when Gnuplot::OptionST;  Gnuplot::DefaultOptionST.merge(opt)
                 end
    end
    def gnuplot_option 
      { 
      }.merge DefaultOption
    end

    def plot(opt=nil)
      @option = opt ? @option.merge( opt) : @option
      #option =  @option.is_a?(Gnuplot::OptionST) ? @option[:header] :  @option
      
      datafile_pathes =  datafiles(@arry_of_data_objects ,@option)
      def_file = output_gnuplot_define(datafile_pathes,@option)
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
      
      @option.is_a?(OptionST) ? @option[:header][:graph_file_path] : @option[:graph_file_path]
    end
  end
end
