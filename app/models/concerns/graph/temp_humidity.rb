# -*- coding: utf-8 -*-
module Graph
  class TempHumidity < Base
    attr_reader :objects
    
    def initialize(data_list,opt=Gnuplot::OptionST.new)
      super
      @option = Gnuplot::DefaultOptionST.merge(TempHumidityDefST).merge(opt) 
    end

    def self.create(models,option=Gnuplot::OptionST.new)
      location=models.first.location
      class_name = models.first.class.name.underscore.sub(/\//,"_")
        title ,time_range=
          case models.size
          when 1 ;
            ["(#{models.first.date.str('%Y-%m-%d)')})",
             Graph::Base::TimeRange[:dayly]
            ]
          else   ;
            ["(#{models.first.date.str('%Y-%m-%d')} - #{models.last.date.str('%Y-%m-%d)')})",
             Graph::Base::TimeRange[ if models.first.date.year < models.last.date.year ; :years
                                     else ; :monthly
                                     end
                                   ]
            ]
          end          
        option = 
          Gnuplot::OptionST.
          new({graph_file: "#{class_name}_#{location}"},
              common: { point_type: [6,6,6],point_size: [0.5,0.3,0.5],
                       title_post: title,
                      with: ["lines","lines","lines",nil],
                      }.merge(time_range)
             )#.merge!(option)
        #pp option
        data_list =
          models.map{|model|
          #pp [:temp,:vaper,:humi].map{|sym| weather[sym]}
          model.times.map{|t| t.str("%Y-%m-%d %H:%M")}.
              zip( *[:temperature,:humidity,:vaper].map{|sym| model.send sym }  )
        }.flatten(1).sort_by{|d| d[0]}
        self.new( data_list,option )
      end
  end
end
