# -*- coding: utf-8 -*-
class Shimada::GraphTempVaperPower    < Graph::Ondotori::Base #TempHumidity
  attr_reader :grouped_daylies

  DefaultOptST = Gnuplot::DefaultOptionST.
    merge(
          Gnuplot::OptionST.
            new(
                #header
                { multiplot:   "2,1",
                 multi_margin: [10,15], 
                 multi_order: ["power","temp_hyum"],
                 size: "900,400"},
                {#body
                 common: { point_type: [6,6,6],   point_size: [0.2,0.2,0.2]},
                 "power" => { set: ["bmargin 0"    ],
                             title: "全電力と温度・蒸気圧",
                             data_file: "power000",
                             column_labels: %w(月日 時刻 電力),
                             #column_attrs:  [:time_and_converted_value],
                             column_format: ["%s " ,"%.3f "],
                             xy:            [[[1,3]]] ,
                             axis_labels:   {ylabel: "電力"},
                            },
                 "temp_hyum" => { set: ["tmargin 0", "bmargin 3"],
                                 axis_labels: {xlabel: "月日"},
                                 title: "",
                                 data_file: "temp_hyum00",
                                 column_labels: %w(月日 時刻 気温 水蒸気圧),
                                 xy: [[[1,3],[1,4]]],
                                 tics:       {xtics: "rotate by -90"},
                                 axis_labels:   {ylabel: "気温、蒸気圧"},
                                }
                }
               )
         )
  
  GraphTempVaperPowerDef =
    { multiplot:   "2,1",
     multi_margin: [10,15], 
     multi_order: ["power","temp_hyum"],
     header: DefaultOption.merge(size: "900,400"),
     
     "power" => { set: ["bmargin 0"
                       ],
                 title: "",
                 data_file: "power000",
                 column_labels: %w(月日 時刻 電力),
                 #column_attrs:  [:time_and_converted_value],
                 column_format: ["%s " ,"%.3f "],
                 xy:            [[[1,3]]] ,
                 axis_labels:   {ylabel: "電力"},
                 point_type: [6],
                 point_size: 0.8
                },
     "temp_hyum" => { set: ["tmargin 0", "bmargin 3"],
                     axis_labels: {xlabel: "月日"},
                     title: "",
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
  def initialize(daylies,opt= Gnuplot::OptionST.new)
    #opt  = DefaultOption.merge(opt)


    @option =
      case opt
      when Hash
        title = (opt.delete(:title) || "") + ( opt.delete(:title_post) || "" )
        option = DefaultOption.merge(GraphTempVaperPowerDef).merge(opt)
        GraphTempVaperPowerDef[:multi_order].
          each{|key| option[key] = DefaultOption.merge(option[key]).merge(opt) }
        option[:header] = DefaultOption.merge(option[:header]).merge(opt)
        # pp  @option[:header] 
        option[option[:multi_order].first][:title]=  title
        option
      when Gnuplot::OptionST
        title_post = opt[:body][:common][:title_post]
        DefaultOptST.merge(opt).merge({title_post: title},[:body,"power"])
        #DefaultOptST.merge({title: title},[:body,"power"])
      end
    
    @arry_of_data_objects = 
      combination(daylies).
      map{|serial,dayly_s|
      [Shimada::Graph::Type[Shimada::Instrument.find_by(serial: serial).measurement],
                            dayly_s]}.to_h
  end
  

end
