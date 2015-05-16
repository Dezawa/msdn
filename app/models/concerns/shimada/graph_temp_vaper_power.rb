# -*- coding: utf-8 -*-
class Shimada::GraphTempVaperPower    < Graph::Ondotori::Base #TempHumidity
  attr_reader :grouped_daylies

  GnuplotDef =
    { multiplot:   "2,1",
     multi_margin: [10,15], 
     multi_order: ["power","temp_hyum"],
     header: DefaultOption.merge(size: "900,400"),
     
     "power" => { set: ["bmargin 0"
                       ],
                 #unset: ["xlabel", "xtics"],
                 data_file: "power000",
                 column_labels: %w(月日 時刻 電力),
                 #column_attrs:  [:time_and_converted_value],
                 column_format: ["%s " ,"%.3f "],
                 xy:            [[[1,3]]] ,
                 axis_labels:   {ylabel: "電力"},
                 point_type: 6,
                 point_size: 0.4
                },
      "temp_hyum" => { set: ["tmargin 0", "bmargin 3"],
                 axis_labels: {xlabel: "月日"},
                 #set: ["xlabel"],
                 data_file: "temp_hyum00",
                 column_labels: %w(月日 時刻 気温 水蒸気圧),
                 xy: [[[1,3],[1,4]]],
                 tics:       {xtics: "rotate by -90"},
                 axis_labels:   {ylabel: "気温、蒸気圧"},
                 point_type: [6,6],
                 point_size: 0.2
                 #column_attrs:  [:time_and_converted_value_with_vaper]
                }
    }
  
  # daylies :: Shimada::Dayly.by_factory_id(@factory_id).where(month: month)
  #               :: で得たrelation
  def initialize(daylies,opt={})
    option  = DefaultOption.merge(opt)
    option[:title]=  (option[:title] ? option[:title] : "" ) +
      ( option[:title_post] || "" )
    
    @option = option.merge GnuplotDef
    GnuplotDef[:multi_order].each{|key| @option[key] = option.merge(@option[key]) }
    
    @arry_of_data_objects = 
      combination(daylies).
      map{|serial,dayly_s|
      [Shimada::Graph::Type[Shimada::Instrument.find_by(serial: serial).measurement],
                            dayly_s]}.to_h
  end
  

end
