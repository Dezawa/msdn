# -*- coding: utf-8 -*-
module Graph::Ondotori
  class ConvertedValue < Graph::Base
    TempDef =
      {
       size: "900,400",
       xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'" ],
       tics: {xtics: "rotate by -90"},
       xy: [[[1,3]]],point_type: [7,7],point_size: 0.5,
       set_key: "set key outside autotitle columnheader width -9  samplen 1 "
      }

    attr_reader :objects
    
    def initialize(dayly,opt={})
      @option  = DefaultOption.merge(TempDef).merge(opt)
      @option[:title] += @option[:title_post] || ""
      
      @arry_of_data_objects =
        if dayly.kind_of?(ActiveRecord::Relation) ||dayly.class == Array
          multi_days(dayly)
        else        ; one_day(dayly)
        end
    end

    def multi_days(daylies)
      dayly_class = daylies.first.class
      @objects =
        daylies.map{|dayly| 
        dayly.time_values("%Y-%m-%d %H:%M").
          zip(dayly.converted_value)
      }.sort_by{|arry| arry.first }
    end
    
    def one_day(dayly)
      dayly.time_values("%Y-%m-%d %H:%M").
        zip(dayly.converted_value)
    end
    def gnuplot_option 
      super.merge( {} )
    end
  end
       
  class TempHumidityADay < Graph::Base #.transposeBaseBase
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
