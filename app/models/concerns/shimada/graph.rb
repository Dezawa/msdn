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
     "temp_vaper_power" => Shimada::GraphTempVaperPower 
    }

  TimeRange = { nil =>  {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"']},
               monthly: {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%m/%d'" ]},
               dayly:   {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'" ]}
              }
  attr_reader :graph_item, :dayly
  def self.create(graph_type,dayly,opt=Gnuplot::OptionST.new)
    opt =
      case opt
      when Hash ;    opt.merge(TimeRange[opt[:time_range]])
      when Gnuplot::OptionST ;
        opt.merge(TimeRange[opt[:header].delete(:time_range)],[:body,:common])
      end
    Classes[graph_type.to_s].new(dayly,opt)
  end
  
  # type :: :single
  def initialize(graph_item,dayly,opt={})
    @dayly = dayly
    @graph_item  = graph_item
  end
  
end

class  Shimada::GraphTemp
end
