# -*- coding: utf-8 -*-
module Graph
  class TempHumidity < Base
    TempHumidityDef =
      {size: "900,400",
       title:  "気温・湿度・蒸気圧",
       column_labels: %w(年月日 時刻 気温 湿度 水蒸気圧),
       set: [ "xdata time",'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'"
            ],
       axis_labels: {:ylabel =>"気温(℃),水蒸気圧(hPa)",
                     :y2label => ["湿度(%RH)","offset -2,0"]},
       tics: {xtics: "rotate by -90",y2tics: "20,10"},
       xy: [[[1,3],[1,4],[1,5]]],point_type: [7,7,7],point_size: 0.5,
       by_tics: {1 => "x1y2"},
       range: {y: "[0:40]", y2: "[20:100]"},
       set_key: "set key outside autotitle columnheader width -9  samplen 1 "
      }
     

     attr_reader :objects 
    def initialize(dayly,opt={})
      dayly_class = dayly.class
      @objects =
        dayly_class.where(serial: dayly.serial, date:   dayly.date).
        order(:ch_name_type) # ****-温度、****-湿度
      @option  = DefaultOption.merge(TempHumidityDef).merge(opt)
      @option[:title] += @option[:title_post] || ""
      @arry_of_data_objects =
        objects[0].time_values("%Y-%m-%d %H:%M").
        zip(objects[0].converted_value,
            objects[1].measurement_value,
            objects[1].converted_value)#.transpose
    end
    def gnuplot_option 
      super.merge( {} )
    end
  end
end
