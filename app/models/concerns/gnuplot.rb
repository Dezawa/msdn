# -*- coding: utf-8 -*-
module Gnuplot
  #
  # option  :
  #   必須  :column_labels   例  %w(日 中央 - + 気温),          必須
  #   必須  :column_format   例 "%s %.1f %.1f %.1f %.1f\n",
  #         :terminal        default    "jpeg"
  #         :xy              例 [ [[1,2],[3,4]]     ,[[5,6]]
  #                                ↑最初のファイル   ↑二つ目のファイル  への指示
  #         :axis_labels     例  { :xlabel => "日",:ylabel => "推定電力",:y2label => "気温"},
  #         :title  例 => "電力推定",
  #         :tics   例 => { :xtics => "rotate by -90",:y2tics=> "-5,5"},
  #         :by_tics 例  => { 4 => "x1y2" },    x1y1以外の軸を使うとき
  #         :size             default  "600,400"
  #         :grid   例 => "ytics"                
  #         :additional_lines  近似線などを書く式を生で記述
  #  実装まだ
  #         :type   => "scatter"  using 1:2,  無いときは using 2:xticlabel(1)
  #         :with   => "line",
  #
  #         :group_by    data_list.group_by{ |d| d.semd(opt[:group_by])}
  #         :keys        defaultではgroup_by の分類がsortされて使われる。
  #                      違うsort順にしたいときに設定
  #  ファイルpath関連
  #         :base_path              データ書き出しパス。RAILS_ROOTからの相対 tmp/gnuplot/data
  #         :graph_file                "image"
  #         :graph_file_dir             RAILS_ROOT+"/tmp/img"
  #         :define_file           絶対path  RAILS_ROOT+"/tmp/gnuplot/graph.def"
  # 出力される画像fileは  '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'
  def gnuplot_(data_list,opt)
    opt = { :terminal => "jpeg",:size => "600,400" ,
      :graph_file => "image", :graph_file_dir => Rails.root+"tmp" + "img",
      :define_file => Rails.root+"tmp/gnuplot/graph.def",
      :base_path   =>  "tmp/gnuplot/data"
    }.merge opt

    datafile_pathes =  datafiles(data_list,opt)
    def_file = output_gnuplot_define(datafile_pathes,opt)
    `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
  end

  def datafiles(data_list,opt)
    if data_list.class == String ; [ data_list] # データファイルパス
    elsif data_list.class == Array
      if data_list.first.class == String ; data_list # Array of データファイルパス
      elsif data_list.first.class == Array
        group_by = 
        opt[:group_by] ? data_list.group_by{ |d| d.semd(opt[:group_by])} : [["",data_list]]
        output_datafile(group_by,opt){ |f,k,data|
          data.each{ |datum| f.puts opt[:column_format]%datum}
        }
      end
    end
  end
  
  def gnuplot_define(datafile_pathes,opt)
    head = "set terminal #{opt[:terminal]} enhanced size #{opt[:size]} enhanced font 'usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'
set title '#{opt[:title]}"
    key = opt[:set_key] || "set key outside autotitle columnheader" #: "unset key"
    range = nil
    tics  = opt[:tics] ? tics_str(opt) : nil
    grid  = opt[:grid] ? grid_str(opt) : nil
    set   = opt[:set]  ? opt[:set].map{ |str| "set #{str}"}.join("\n")  : ""
    axis_labels = opt[:axis_labels] ? axis_labels(opt) : nil

    plot  = plot_list(datafile_pathes,opt)
    def_file = opt[:define_file]

    [ head,key ,set ,
      range,tics,grid,axis_labels,
      plot,    opt[:additional_lines]
    ].flatten.compact.join("\n")
  end

  def output_gnuplot_define(datafile_pathes,opt)
    def_file = opt[:define_file]
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
      path.map{ |p|
      xy_ary = xy_ary_ary.size > 1 ? xy_ary_ary.shift : xy_ary_ary.first.dup
      #      str += 
      s = xy_ary.map{ |idx_x,idx_y|
        idx_x,idx_y = idx_y,idx_x unless opt[:type] && opt[:type] ==  "scatter" 
        st = block_given? ? yield(plot_fmt(opt),p,idx_x,idx_y) : sprintf(plot_fmt(opt),p,idx_x,idx_y)
        st += 
        ( opt[:by_tics] && opt[:by_tics][idx] ? " axes #{opt[:by_tics][idx]}" : "") +
        ( opt[:point_type] && opt[:point_type][idx] ? " pt #{opt[:point_type][idx]}" : "")+
        ( opt[:point_size]  ?   " ps #{opt[:point_size]}" : "")+
        #( opt[:with] ? " with #{opt[:with]}" : "")
        case opt[:with]
        when nil ; ""
        when String ;  opt[:with]
        when Array
          opt[:with][idx] ? opt[:with][idx] : ""
        else ; ""
        end

        p=""
        idx += 1
        st
      }.join(" ,\\\n")
    }.join(" ,\\\n")
    str
  end


  def axis_labels(opt)
    opt[:axis_labels].map{ |k,v| "set #{k} '#{v}'"}.join("\n")
  end

  def  tics_str(opt)
    opt[:tics].map{ |xy,tics| "set #{xy} #{tics}"}.join("\n")
  end

  def  grid_str(opt)
    opt[:grid].map{ |grid| "set grid #{grid}"}.join("\n")
  end

  def output_datafile(grouped_data_ary,opt,&block)
    base_path = opt[:base_path]+"000"
    datafile_pathes = []
    keys = opt[:keys] || grouped_data_ary.map{ |ary| ary.first}.sort
    keys.each_with_index{ |k,idx|
      datafile_pathes << Rails.root+"#{base_path}.data"
      open(datafile_pathes.last,"w"){ |f|
        f.puts opt[:column_labels].join(" ") if opt[:column_labels]
        yield f,k,grouped_data_ary[idx][1]
        f.puts
      }
      base_path.succ!
    }
    datafile_pathes 
  end
end
