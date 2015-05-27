# -*- coding: utf-8 -*-
module Graph
  class Base
    include ActiveModel::Model
    include Gnuplot

    TimeRange = { nil =>  {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%Y/%m/%d'"]},
                 years:   {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%Y/%m/%d'"]},
                 monthly: {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%m/%d'"   ]},
                 dayly:   {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'"   ]}
                }
  
    TempHumidityDefST = Gnuplot::OptionST.
      new({size: "900,400"},
          {common: {
                    title:  "気温・湿度・蒸気圧",
                    column_labels: %w(年月日 時刻 気温 湿度 水蒸気圧),
                    xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'" ],
                    axis_labels: {:ylabel =>"気温(℃),水蒸気圧(hPa)",
                                  :y2label => ["湿度(%RH)","offset -2,0"]},
                    tics: {xtics: "rotate by -90",y2tics: "20,10"},
                    xy: [[[1,3],[1,4],[1,5]]],
                    point_type: [6],point_size: 0.3,
                    color: ["red","green","blue"],
                    by_tics: {1 => "x1y2"},
                    range: {y: "[0:40]", y2: "[20:100]"},
                    set_key: "set key outside autotitle columnheader width -9  samplen 1 "
                   }
          } )

  delegate :logger, :to=>"ActiveRecord::Base"
    attr_reader :arry_of_data_objects,:option
    def initialize(arry_of_data_objects,opt={})
      @arry_of_data_objects = arry_of_data_objects
      @option  = case opt
                 when Hash ;      DefaultOption.merge opt
                 when Gnuplot::OptionST;  Gnuplot::DefaultOptionST.merge(opt)
                 end
    end
    def gnuplot_option 
      { 
      }.merge DefaultOption
    end


  end
end
