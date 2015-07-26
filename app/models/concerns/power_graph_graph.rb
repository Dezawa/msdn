# -*- coding: utf-8 -*-
module  PowerGraphGraph
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

  def  def_file_by_hour(path,opt={ })
    deffile = Pathname.new(( opt[:def_dir] || Rails.root+"tmp/graph"))+(opt[:def_file] || "graph.def" )
    graph_dir,graph_file,title,set_key,xrange,tics = dif_opts(opt)
    open(deffile,"w"){ |f|
      preunble = DefByHour% dif_opts(opt)
      f.puts preunble
      [:xlabel,:ylabel].each{ |sym|
        f.puts "set "+opt[sym] if opt[sym]
      }
      f.puts plot_list("'%s' using %d:%d",path,opt)
    }
    deffile
  end


  def dif_opts(opt)
logger.debug("DIF_OPTS opt=#{opt}")
    [ opt[:graph_dir]  || Rails.root+"tmp/graph/jpeg",
      opt[:graph_file] || "graph",
      opt[:title]      || "",
      opt[:set_key]    || "set key outside  autotitle columnheader samplen 1 width 0",
      opt[:xrange]     || "[0:24]",
      opt[:tics]       || "set xtics 3,3\nset x2tics 3,3",
      opt[:grid]       || "set grid"
    ]
  end

  def plot_list(plot_fmt,path,opt)
    xy_ary_ary = opt[:xy] ? opt[:xy].dup : nil
    idx = 0
    str = "plot "+
    path.map{ |p|
      xy_ary = xy_ary_ary ? xy_ary_ary.shift : [[1,2]]
#      str += 
      s = xy_ary.map{ |idx_x,idx_y|
        st = block_given? ? yield(plot_fmt,p,idx_x,idx_y) : sprintf(plot_fmt,p,idx_x,idx_y)
        st += 
        ( opt[:by_tics] && opt[:by_tics][idx] ? " axes #{opt[:by_tics][idx]}" : "") +
        ( opt[:point_type] && opt[:point_type][idx] ? " pt #{opt[:point_type][idx]}" : "")+
        ( opt[:point_size]  ?   " ps #{opt[:point_size]}" : "")+
        ( opt[:with] ? " with #{opt[:with]}" : "")
        p=""
        idx += 1
        st
      }.join(" ,\\\n")
    }.join(" ,\\\n")
    str
  end

  def output_plot_data(objs,opt,&block)
      path = []
      keys = unless opt[:keys] 
               if opt[:by_date] == "%a" ; %w(Mon Tue Wed Thu Fri Sat Sun)
               else           ; objs.keys.sort
               end
             else             ; opt[:keys] 
             end
#logger.debug("OUTPUT_PLOT_DATA:keys = #{keys.join(',')}")
      keys.each_with_index{ |k,idx|
        path << Rails.root+"tmp/graph/data/graphdata_%02d"%idx
        open(path.last,"w"){ |f|
          f.puts( opt[:data_file_labels] || "時刻 #{k}" )
          objs[k].each{ |obj|
            yield f,obj
            f.puts unless opt[:no_blank_line]
          }
        }
      }
      path
  end

  def powers_group_by
    if by_month = @opt[:by_date]
      @powers.group_by{ |p| p.date.strftime(by_month)}
    elsif @opt[:by_]
      pws=@powers.group_by{ |p| p.send(@opt[ :by_ ])}#.sort_by{ |p,v| p}#.reverse
      pws
    else
      @powers.size > 0 ? { @powers.first.date.strftime("%y/%m") => @powers} : {"" =>[]}
    end
  end

  def group_by_(objects,opt)
    pws = if opt[:by_date]
            objects.group_by{ |p| p.date.strftime(opt[:by_date])}
          elsif opt[:group_by] 
            objects.group_by{ |p| p.send( opt[:group_by])}
          else
            {true => objects } #.group_by{ |p| true}
          end
    pws
  end

    DefByHour =
      %Q!set terminal jpeg enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out '%s/%s.jpeg' #  graph_dir,graph_file,
set title "%s"
%s #
set yrange [0:1000]
set xrange %s #  [1:24]
%s #3,3 #1,1
set grid #ytics
!
    DefByDayHour =
      %Q!set terminal jpeg enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out '%s/%s.jpeg' #  graph_dir,graph_file,
set title "%s"
%s #
set xtics nomirror rotate by -90 scale 0
#set yrange [0:1000]
#set xrange %s #  [1:24]
%s #3,3 #1,1
set grid ytics
!
end
