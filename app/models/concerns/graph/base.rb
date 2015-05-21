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


  end
end
