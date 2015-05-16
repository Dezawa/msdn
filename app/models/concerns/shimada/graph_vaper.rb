# -*- coding: utf-8 -*-
class Shimada::GraphVaper    < Graph::Ondotori::ConvertedValue

  def initialize(daylies,opt={})
    dayly=
        if daylies.kind_of?(ActiveRecord::Relation) ||dayly.class == Array
          daylies.first
        else        ; daylies
        end
    super(daylies,
          title_post: "ー#{dayly.instrument.base_name} " +
            dayly.instrument.ch_name +
            dayly.date.strftime(" %m月%d日"),
          title:  "湿度・水蒸気圧",
          column_labels: %w(年月日 時刻 水蒸気圧 湿度),
          axis_labels: {y2label:"湿度(%Rh)",ylabel: "水蒸気圧(hPa)"},
          xy: [[[1,3],[1,4]]],by_tics: {1 => "x1y2"},
          tics: {xtics: "rotate by -90",y2tics: "20,10"},
          range: {y: "[0:40]",y2: "[20:100]"}
          )
    plot
  end
  
  def multi_days(daylies)
    dayly_class = daylies.first.class
    @objects =
      daylies.map{|dayly| 
      dayly.time_values("%Y-%m-%d %H:%M").
        zip(dayly.converted_value,dayly.measurement_value)
    }.sort_by{|arry| arry.first }
  end
  
  def one_day(dayly)
    dayly.time_values("%Y-%m-%d %H:%M").
      zip(dayly.converted_value,dayly.measurement_value)
  end
end
