# -*- coding: utf-8 -*-



class Shimada::Graph
   Type = {
           "温度"    => "temp_hyum" ,
           "蒸気圧"  => "temp_hyum" ,
           "電力"    => "power"
          }
  Classes =
  {"power"     => Shimada::GraphPower         ,
   "temp"      => Shimada::GraphTemp          ,
   "vaper"     => Shimada::GraphVaper         ,
   "hyum"      => Shimada::GraphVaper     ,
   "temp_hyum" => Shimada::GraphTempHyumVaper ,
   "temp_vaper_power" => Shimada::GraphTempVaperPower ,
  }

attr_reader :graph_item, :dayly
def self.create(graph_type,dayly,opt={})
    Classes[graph_type].new(dayly,opt)
  end
  
  # type :: :single
  def initialize(graph_item,dayly,opt={})
    @dayly = dayly
    @graph_item  = graph_item
  end
  
end

class  Shimada::GraphTemp
end
