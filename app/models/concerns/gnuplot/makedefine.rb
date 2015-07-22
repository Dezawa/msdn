# -*- coding: utf-8 -*-

module Gnuplot::Makedefine
  # 通常は
  # datafile_pathes :: データファイルのパスの配列
  # arg_option      :: プロット条件の Gnuplot::OptionST
  #                    古い仕様の Hash の場合もまだ残してある
  # multiplotの場合は
  # datafile_pathes :: データファイルのパスの配列の配列
  # arg_option      :: プロット条件の Gnuplot::OptionST
  #                     古い仕様の Hash の場合は Hashの配列
  #   配列の要素数は multiplot の plotの数
  #
  # 戻り値 ： define ファイルpath
  def gnuplot_define(datafile_pathes,arg_option=nil)
    arg_option ||= @options
    
    return gnuplot_define_struct(datafile_pathes,arg_option) if arg_option.kind_of?(Gnuplot::OptionST)
    gnuplot_define_sub(datafile_pathes,arg_option)
  end

  # 新しい仕様
  def gnuplot_define_struct(datafile_pathes,arg_option)
    head     = header(arg_option[:header])
    plot_def = plot_define_struct(datafile_pathes,arg_option)
    head +"\n#########\n"+  plot_def +"\n#########\n"
  end
  
  def plot_define_struct(datafile_pathes,arg_option)
    if arg_option[:body].keys.size == 1
      plot_define_plot_list(datafile_pathes,arg_option[:body][:common])
    else
      arg_option[:body][arg_option[:header][:multi_order].last][:set] += ["xlabel","tics"]
      #reset_xtics = "set xlabel\nset tics"
      arg_option[:header][:multi_order].reverse.map{|key|
        plot_define_plot_list(datafile_pathes[key],arg_option[:body][key])
      }.reverse.join("\n")
    end
  end

  def plot_define_plot_list(datafile_pathes,opt)
    plot_define(opt)  +"\n"+
      plot_list(datafile_pathes,opt) +"\n"+
       ( opt[:additional_lines] ? ",\\\n"+ opt[:additional_lines] : "")
  end

  # terminal,size,出力ファイルを決める
  # multiplot の場合はさらに、その設定を行う。
  def header(opt)
    #pp opt
    opt[:graph_file_path] = "#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}"
    "set terminal #{opt[:terminal]} enhanced size #{opt[:size]} "+
      "enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'\n"+
      "set out '#{opt[:graph_file_path]}'" +
      if opt[:multiplot]
        "\nset multiplot layout #{opt[:multiplot]}\n" +
          if opt[:multi_margin]
            "set lmargin #{opt[:multi_margin][0]}\nset rmargin #{opt[:multi_margin][1]}\n" +
              "unset xlabel\nunset xtics\n"
          else ; ""; end
      else ; ""
      end
  end

  def plot_define(opt)
    title = opt_title(opt)
      key = opt[:set_key] || "set key outside autotitle columnheader" #: "unset key"
      
      tics  = opt[:tics] ? tics_str(opt) : nil
      grid  = opt[:grid] ? grid_str(opt) : nil
      set   = opt[:set]  ? opt[:set].map{ |str| "set #{str}"}.join("\n")  : nil
      unset   = opt[:unset]  ? opt[:unset].map{ |str| "unset #{str}"}.join("\n")  : nil
      axis_labels = opt[:axis_labels] ? axis_labels(opt) : nil
      [title,key ,data_time(opt),unset,set ,labels( opt[:labels]) ,
       range_str(opt),tics,grid,axis_labels
      ].flatten.compact.join("\n")
  end
  
  def output_gnuplot_define(datafile_pathes,opt)
    def_file = case opt
               when Hash ; opt[:define_file]
               when Gnuplot::OptionST ; opt[:header][:define_file]
               end
    #pp def_file
    open(def_file,"w"){ |f|   f.puts gnuplot_define(datafile_pathes,opt) }

    def_file 
  end

  def plot_fmt(opt)
    case opt[:type]
    when "scatter" ; "'%s' using %d:%d"
    when nil       ;  "'%s' using %d:xticlabel(%d)"
    end
  end

  def plot_list(path,opt,&block)
    xy_ary_ary = opt[:xy] ? opt[:xy].dup :  [[[1,2]]]
    idx = 0
    str = "plot "+
      (path||[]).map{ |p|
      xy_ary = xy_ary_ary.size > 1 ? xy_ary_ary.shift : xy_ary_ary.first.dup
      #      str += 
      s = xy_ary.map{ |idx_x,idx_y|
        idx_x,idx_y = idx_y,idx_x unless opt[:type] && opt[:type] ==  "scatter" 
        st = block_given? ? yield(plot_fmt(opt),p,idx_x,idx_y) : sprintf(plot_fmt(opt),p,idx_x,idx_y)
        st += 
        ( opt[:by_tics] && opt[:by_tics][idx] ? " axes #{opt[:by_tics][idx]}" : "") +
        point_type( opt[:point_type],idx) + color(opt[:color],idx) + 
        point_size( opt[:point_size],idx ) +# ?   " ps #{opt[:point_size]}" : "")+
        #( opt[:with] ? " with #{opt[:with]}" : "")
        case opt[:with]
        when nil ; ""
        when String ;  " with #{opt[:with]}"
        when Array
          opt[:with][idx] ? " with #{opt[:with][idx]}" : ""
        else ; ""
        end

        p=""
        idx += 1
        st
      }.join(" ,\\\n")
    }.join(" ,\\\n")
    str
  end

  def opt_title(opt)
    case opt[:title]
    when "" ; "set title ''"
    else
      opt[:title].blank? ? nil : "set title '#{opt[:title]}#{opt[:title_post]}'"
    end
  end

    def labels(arg_labels)   ; arg_labels ? arg_labels.map{ |l| "set #{l}"}.join("\n") : nil   ;  end
  def index_of_label(label); labels.index(label)                                       ;  end
  def axis_labels(opt)
    opt[:axis_labels].map{ |k,v|
      case v
      when String ; "set #{k} '#{v}'"
      when Array ; "set #{k} '#{v.first}' #{v[1]}"
      end
      }.join("\n")
  end

  def data_time(opt)
    [:xdata_time,:ydata_time,:x2data_time,:y2data_time].
      map{|data_time| 
      "set #{data_time.to_s.sub(/_/,' ')}\nset "+opt[data_time].join("\nset ") if opt[data_time]
    }.compact
  end
  
  def range_str(opt)
    return nil unless opt[:range]
    opt[:range].map{ |axis,str| "set #{axis}range #{str}"}.join("\n")
  end

  def  tics_str(opt)
    opt[:tics].map{ |xy,tics| "set #{xy} #{tics}"}.join("\n")
  end

  def  grid_str(opt)
    opt[:grid].map{ |grid| "set grid #{grid}"}.join("\n")
  end
  def point_size( opt_point_size,idx) # ?   " ps #{opt[:point_size]}" : "")+
    return "" unless opt_point_size
    " ps "+
      case opt_point_size
      when Integer,Float,String  ;  opt_point_size.to_s
      when Array ;      (opt_point_size[idx] || opt_point_size[-1]).to_s
      end
  end
  def color(opt_color,idx)
    return "" unless opt_color
    " lc rgb '#{opt_color[idx > opt_color.size ? -1 : idx]}'"
  end
  
  def point_type( opt_point_type,idx)
    return "" unless opt_point_type
    " pt " +
      case opt_point_type
      when Integer,Float,String ;  opt_point_type.to_s
      when Array ;      (opt_point_type[idx] || opt_point_type[-1]).to_s
      end
  end
  

  
  def gnuplot_define_sub(datafile_pathes,arg_option)
    if arg_option[:multiplot]
      head = header(arg_option[:header]) +
        "\nset multiplot layout #{arg_option[:multiplot]}\n" +
        "set lmargin #{arg_option[:multi_margin][0]}\n"  +
        "set rmargin #{arg_option[:multi_margin][1]}\n" +
        "unset xlabel\nunset xtics\n"
      reset_xtics = "set xlabel\nset tics"
      head +
        arg_option[:multi_order].reverse.map{|key|
        xtics = reset_xtics
        reset_xtics = nil
        opt = arg_option[key]
        plot_def = plot_define(opt)
        plot  = plot_list(datafile_pathes[key],opt)
        def_file = arg_option[key][:define_file]
        [ xtics,plot_def, plot   ].flatten.compact.join("\n") +
          ( opt[:additional_lines] ? ",\\\n"+ opt[:additional_lines] : "")
      }.reverse.join("\n")+"\n#########\n"
    else
      opt = arg_option
      head = header(opt)
      plot_def = plot_define(opt)
      plot  = plot_list(datafile_pathes,opt)
      
      def_file = opt[:define_file]

      [ head,plot_def, plot   ].flatten.compact.join("\n") +
        ( opt[:additional_lines] ? ",\\\n"+ opt[:additional_lines] : "")+"\n#########\n"
    end
  end
  
end
