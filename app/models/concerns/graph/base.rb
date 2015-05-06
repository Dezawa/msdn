# -*- coding: utf-8 -*-
module Graph
  class Base
    include ActiveModel::Model
    include Gnuplot
  delegate :logger, :to=>"ActiveRecord::Base"
    attr_reader :arry_of_data_objects,:option
    def initialize(arry_of_data_objects,opt={})
      @arry_of_data_objects = arry_of_data_objects
      @option  = DefaultOption.merge opt
    end
    def gnuplot_option 
      { 
      }.merge DefaultOption
    end

    def plot(opt={})
      opt = @option.merge opt

    datafile_pathes =  datafiles(@arry_of_data_objects ,opt)
    def_file = output_gnuplot_define(datafile_pathes,opt)
    `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
  end
  end
end
