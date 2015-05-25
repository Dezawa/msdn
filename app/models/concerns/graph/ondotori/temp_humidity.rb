# -*- coding: utf-8 -*-
module Graph::Ondotori
  class TempHumidity < Base
    TempHumidityDef =
      {size: "900,400",
       title:  "気温・湿度・蒸気圧",
       column_labels: %w(年月日 時刻 気温 湿度 水蒸気圧),
       xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'" ],
       axis_labels: {:ylabel =>"気温(℃),水蒸気圧(hPa)",
                     :y2label => ["湿度(%RH)","offset -2,0"]},
       tics: {xtics: "rotate by -90",y2tics: "20,10"},
       xy: [[[1,3],[1,4],[1,5]]],point_type: [6],point_size: 0.3,
       by_tics: {1 => "x1y2"},
       range: {y: "[0:40]", y2: "[20:100]"},
       set_key: "set key outside autotitle columnheader width -9  samplen 1 "
      }

    attr_reader :objects
    
    def initialize(dayly,opt={})
      super
      @option = case @option
                when Hash  ; @option.merge(TempHumidityDef)
                when Gnuplot::OptionST;@option.merge(TempHumidityDefST)
                end
    end
    
    # case B :: 一つの測定器の Daylyの配列 ｜ DaylyのRelation
    #        :: 要素数が１の時は case A
    def multi_days(daylies)
      dayly_class = daylies.first.class
      daylies.map{|dayly| dayly.time_and_converted_value_with_vaper
      }.flatten(1).sort_by{|arry| arry.first }
    end

    # case A :: Dayly
    def one_day(dayly)
        dayly.time_and_converted_value_with_vaper
    end
    def gnuplot_option 
      super.merge( {} )
    end
  end
       
       
end
