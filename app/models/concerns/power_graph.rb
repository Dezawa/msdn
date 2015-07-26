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
      objs = group_by_(objects,opt)
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
      objs = group_by_(objects,opt)
      path = output_plot_data(objs,opt){ |f,obj|
        values = obj.send(opt["method"])
        ("01".."24").each_with_index{ |hr,idx| f.printf "%s %.3f\n",hr,values[idx] }
      }
      def_file = def_file_by_hour(path,opt)
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
    end

    def  def_file_by_days_hour(path,opt={ })
      opt.merge!( :point_size => 0.5,:point_type => [7,7,7,7,5,5,6,6,6,6])
      deffile = ( opt[:def_dir] || Rails.root+"tmp/graph")+"/"+(opt[:def_file] || "graph.def" )
      graph_dir,graph_file,title,set_key,xrange,tics = dif_opts(opt)
          range,fmt = opt[:min].year == opt[:max].year ? [[1,11,21],'%m/%d'] : [[1],'%Y/%m/%d']
      open(deffile,"w"){ |f|
        preunble = DefByDayHour%[graph_dir,graph_file,title,set_key,"[100:800]",xrange,tics ]
        f.puts preunble
        f.puts( "set x2tics ("+
               (opt[:min] .. opt[:max]).map{ |day|
                 next unless range.include?(day.day)
                  ( day - opt[:min] )+opt[:min].yday
               }.compact.join(" , ") + ")"
              )
        [:xlabel,:ylabel,:x2label,:y2label].each{ |sym|
          f.puts "set "+opt[sym] if opt[sym]
        }
        f.print plot_list("'%s' using %d:%d",path[0,4],opt)
        f.puts( " ,\\\n '#{path[-2]}' using 1:2 with lines axis x2y2 ,\\\n" 
                #" '' using 1:3 with lines axis x2y2 lc rgb 'red'  title '最高温度', \\\n" +
               # " '' using 1:4 with lines axis x2y2 title '最低温度', \\\n" 
              )
        f.puts " '#{path.last}' using 2:xtic(1) notitle "
      }
      deffile
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
