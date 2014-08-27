# -*- coding: utf-8 -*-
module  Power::Scatter
 

  def graph_scatter(objects,opt={ })
    objs = group_by(objects,opt)
    path = output_plot_data(objs,opt){ |f,obj|
      values   = obj.send(opt["method"])
      x_values = obj.send(opt[:x_method]) 

      opt[:hour_range] = [1,2,3,4] if opt["night"] && opt[:hour_range]
      (opt[:hour_range] ||(0..23)).
      each{ |idx| f.printf "%.2f %.1f\n",
        case x_values; when Array;x_values[idx];else x_values;end,values[idx]  }
    }
    opt[:fitting_line] = objects.first.class.send(opt[:fitting],opt) if opt[:fitting]
    logger.debug("TEMP_VS_POWER: line = #{opt[:fitting_line]}")
    def_file = def_file_scatter(path,opt)
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
  end

  def  def_file_scatter(path,opt={ })
    deffile = ( opt[:def_dir] || RAILS_ROOT+"/tmp/graph")+"/"+(opt[:def_file] || "graph.def" )
    #graph_dir,graph_file,title,set_key,xrange,tics,grid = dif_opts(opt)
    open(deffile,"w"){ |f|
      preunble = DefScatter% dif_opts(opt)
      f.puts preunble
      [:xlabel,:ylabel].each{ |sym|
        f.puts "set "+opt[sym] if opt[sym]
      }
      f.print plot_list("'%s' using %d:%d",path,opt)
      f.puts ", \\", opt[:fitting_line] if opt[:fitting]
    }
    deffile
  end

  def dif_opts(opt)
    [ opt[:graph_dir]  || RAILS_ROOT+"/tmp/graph/jpeg",
      opt[:graph_file] || "graph",
      opt[:title]      || "",
      opt[:set_key]    || "",
      opt[:xrange]     || "[0:24]",
      opt[:tics]       || "set xtics 3,3\nset x2tics 3,3",
      opt[:grid]       || "set grid"
    ]
  end

    DefScatter =
      %Q!set terminal jpeg enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out '%s/%s.jpeg' #  graph_dir,graph_file,
set title "%s"
%s #
set yrange [0:1000]
set xrange %s #  [1:24]
%s 
%s #set grid #ytics
!
end
