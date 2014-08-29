# -*- coding: utf-8 -*-
module  Power::MonthlyGraph
  extend Power::Graph
  extend Power::Scatter
  module ClassMethods
   def monthly_graph(opt = { } )
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
     objects = objects.select{ |pw| eval "pw.#{opt['select']}" } if opt["select"]
     opt[:set_key] ||= "set key outside  autotitle columnheader samplen 1 width 0"
     graph_scatter(objects,opt)
   end

  def graph_by_hour(objects,opt={ })
    opt = { :xlabel => "xl '時刻'",:ylabel => "yl '消費電力'"}.merge opt
    objs = group_by(objects,opt)
    path = output_plot_data(objs,opt){ |f,obj|
      values = obj.send(opt["method"])
      ("01".."24").each_with_index{ |hr,idx| f.printf "%s %.3f\n",hr,values[idx] }
    }
    def_file = def_file_by_hour(path,opt)
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
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
