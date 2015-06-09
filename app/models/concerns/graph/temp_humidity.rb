# -*- coding: utf-8 -*-
module Graph
  class TempHumidity < Base
    attr_reader :objects
    
    def initialize(data_list,opt=Gnuplot::OptionST.new)
      super
      @options = Gnuplot::DefaultOptionST.merge(TempHumidityDefST).merge(opt) 
    end

    def self.create_by_models(models,option=Gnuplot::OptionST.new)
      title ,time_range = title_post_time_range(models,option)

      location=models.first.location
      class_name = models.first.class.name.underscore.sub(/\//,"_")
      option = 
        Gnuplot::OptionST.
        new({graph_file: "#{class_name}_#{location}"},
            common: { point_type: [6,6,6],point_size: [0.5,0.3,0.5],
                     title_post: title,
                    }.merge(time_range)
           ).merge(option)
      #pp option
      data_list =
        models.map{|model|
        #pp [:temp,:vaper,:humi].map{|sym| weather[sym]}
        model.times.map{|t| t.str("%Y-%m-%d %H:%M")}.
          zip( *[:temperature,:humidity,:vaper].map{|sym| model.send sym }  )
      }.flatten(1).sort_by{|d| d[0]}
      self.new( data_list,option )
    end

    def self.create_by_multi_models(array_of_models,option=Gnuplot::OptionST.new)
      title ,time_range = title_post_time_range(array_of_models.flatten,option)

      location=array_of_models.first.first.location
      class_name = array_of_models.
        map{|models| models.first.class.name.underscore.sub(/\//,"_")}.join("_")
      option = 
        Gnuplot::OptionST.
        new({graph_file: "#{class_name}_#{location}"},
            common: { point_type: [6,6,6],point_size: [0.5,0.3,0.5],
                     title_post: title,
                    }.merge(time_range)
           ).merge(option)
      #pp option
      data_list =  array_of_models_to_data_list( array_of_models )
      self.new( data_list,option )
    end

    def self.array_of_models_to_data_list( array_of_models )
      array_of_models.map.with_index{|models,idx|
        [%w(予報 実測)[idx],
         models.map{|model|
           model.times.map{|t| t.str("%Y-%m-%d %H:%M")}.
             zip( *[:temperature,:humidity,:vaper].map{|sym| model.send sym }  )
         }.flatten(1).sort_by{|d| d[0]}
        ]
      }
    end

    def self.title_post_time_range(models,option)
      time_range =
        if option[:header][:time_range] ;   option[:header].delete(:time_range)
        elsif models.size ==1            ; :dayly
        elsif models.first.date.year < models.last.date.year ; :years
        else                             ; :monthly
        end
      
      title_post = "(#{models.first.date.str('%Y-%m-%d)')}" +
        if models.size > 1 ;" - #{models.last.date.str('%Y-%m-%d)')})"
        else               ;")"
        end
      [ title_post, Graph::Base::TimeRange[time_range] ]
    end          
  end
end
