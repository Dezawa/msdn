# -*- coding: utf-8 -*-
class Shimada::GraphPower    < Graph::Ondotori::ConvertedValue

  def initialize(daylies,opt=Gnuplot::OptionST.new)
    dayly=
      if daylies.kind_of?(ActiveRecord::Relation) ||dayly.class == Array
        daylies.first
      else        ; daylies
      end
    super(daylies,opt)
    option =
      {
       title_post: "ー#{dayly.instrument.base_name} " +
         dayly.instrument.ch_name +
         dayly.date.strftime(" %m月%d日"),
       title:  "電力",
       column_labels: %w(年月日 時刻 電力),
       axis_labels: {:ylabel =>"電力(kWh)"},
       range: nil
      }
    
    case opt
    when Hash ;
      @options.merge!(option).merge!(opt)
    when Gnuplot::OptionST
      @options.merge(option,[:body,:common]).merge(opt)
    end
    plot
  end
end
