# -*- coding: utf-8 -*-
class Shimada::GraphTemp    < Graph::Ondotori::ConvertedValue

  def initialize(daylies,opt={})
    dayly=
        if daylies.kind_of?(ActiveRecord::Relation) ||dayly.class == Array
          daylies.first
        else        ; daylies
        end
      option = {title:  "気温",
                column_labels: %w(年月日 時刻 気温),
                axis_labels: {:ylabel =>"気温(℃)"},
                range: {y: "[0:40]"},
                title_post: "ー#{dayly.instrument.base_name} " +
                  dayly.instrument.ch_name + dayly.date.strftime(" %m月%d日")
               }
      option =
      case opt
      when Hash ; option
      when  Gnuplot::OptionST ; Gnuplot::OptionST.new({},{common: option})
      end
      super(daylies,option)
    plot
  end
end
