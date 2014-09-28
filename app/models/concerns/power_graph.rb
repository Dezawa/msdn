# -*- coding: utf-8 -*-
module  PowerGraph
  #include PowerGraph::MonthlyGraph
  #extend  PowerGraph::MonthlyGraph::ClassMethods
  #include PowerGraph::Graph
  #extend PowerGraphScatter
  #extend PowerGraphGraph
  #extend PowerGraph::Scatter
  module ClassMethods
    def monthly_graph(opt = { } )
      objects = target_powers(opt)
      opt[:set_key] ||= "set key outside  autotitle columnheader samplen 1 width 0"
      graph_scatter(objects,opt)
    end

    def monthly_by_days_hour(opt = { } )
      objects = target_powers(opt)
      opt[:set_key] ||= "set key outside  autotitle columnheader samplen 1 width -4"
      opt[:by_date] = nil
      graph_by_days_hour(objects,opt)
    end

    def target_powers(opt={ })
      objects = 
        if year = opt["year"] 
          opt[:by_date] = "%m"  
          self.all.select{ |m| m.month.year == year.to_i}
        elsif month = opt["month"]
          opt[:by_date] = "%d"
          self.all.select{ |m| m.month == Time.parse(month)}
        else
          self.all
        end.map(&:powers).flatten
      objects = objects.select{ |pw| eval opt['select'] } if opt["select"]
      objects
    end

    # 与えられたデータの24時間のデータを全て時間順に並べる
    def graph_by_days_hour(objects,opt={ })
      opt = { :xlabel => "xl '時刻'",:ylabel => "yl '消費電力'"}.merge opt
      objs = group_by(objects,opt)
      path = output_plot_data(objs,opt.merge(:no_blank_line => true)){ |f,obj|
        values = obj.send(opt["method"])
        xvalue = obj.date.day == 1 ? obj.date.strftime("%m/%d") : "."
         f.printf "%s %.3f\n",xvalue,values[0] 
        ("02".."24").each_with_index{ |hr,idx| f.printf "'' %.3f\n",values[idx+1] }
      }
      def_file = def_file_by_days_hour(path,opt)
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
    end

    def graph_by_hour(objects,opt={ })
      opt = { :xlabel => "xl '時刻'",:ylabel => "yl '消費電力'"}.merge opt
      objs = group_by(objects,opt)
      path = output_plot_data(objs,opt){ |f,obj|
        values = obj.send(opt["method"])
        ("01".."24").each_with_index{ |hr,idx| f.printf "%s %.3f\n",hr,values[idx] }
      }
      def_file = def_file_by_hour(path,opt)
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
    end

  end
  ############
  def self.included(base)
    base.extend ClassMethods
  end

  def monthly_graph(opt = { } )
    objects = self.powers
    graph_by_hour(objects,opt)
  end

  def monthly_scatter(opt = { } )
    objects = self.powers
    graph_scatter(objects,opt)
  end
end
