# -*- coding: utf-8 -*-
module Graph
  class TempHumidity < Base
    attr_reader :objects
    
    def initialize(data_list,opt=Gnuplot::OptionST.new)
      super
      @option = Gnuplot::DefaultOptionST.merge(TempHumidityDefST).merge(opt) 
    end
  end
end
