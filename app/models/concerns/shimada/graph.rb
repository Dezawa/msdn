# -*- coding: utf-8 -*-



class Shimada::Graph < Graph::Base
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

  attr_reader :graph_item, :dayly
  def self.create(graph_type,dayly,opt= Gnuplot::OptionST.new)
    opt =
      case opt
      when Hash ;    opt.merge(TimeRange[opt[:time_range]])
      when Gnuplot::OptionST ;
         if opt[:header][:time_range]
           opt.merge(TimeRange[opt[:header].delete(:time_range)],[:body,:common])
         else
           opt
         end
      end
    Classes[graph_type.to_s].new(dayly,opt)
  end
  
  # type :: :single
  def initialize(graph_item,dayly,opt=Gnuplot::OptionST.new)
    case opt
    when Hash ;    opt.merge(TimeRange[opt[:time_range]])
    when Gnuplot::OptionST ;
      if opt[:header][:time_range]
        opt.dup.merge(TimeRange[opt[:header].delete(:time_range)],[:body,:common])
      else
        opt
      end
    end
  end
  
end

class  Shimada::GraphTemp
end
