# -*- coding: utf-8 -*-
module Graph
  class TempHumidity < Base
    attr_reader :objects
    
    def initialize(data_list,opt=Gnuplot::OptionST.new)
      super
      @option =@option.merge(TempHumidityDefST).merge(opt)
      pp @option
    end
  end
end
