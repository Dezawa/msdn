# -*- coding: utf-8 -*-
module Function
module Gnuplot
  #
  # option
  #   必須  :column_labels   例  %w(日 中央 - + 気温),          必須
  #   必須  :column_format   例 "%s %.1f %.1f %.1f %.1f\n",
  #         :terminal        default    "jpeg"
  #         :
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
  #         :graph_file_dir             RAILS_ROOT+"/tmp"
  #         :define_file           絶対path  RAILS_ROOT+"/tmp/gnuplot/graph.def"
  # 出力される画像fileは  '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'
  def gnuplot_(data_list,opt)
    opt = { :terminal => "jpeg",:size => "600,400" ,
      :graph_file => "image", :graph_file_dir => RAILS_ROOT+"/tmp",
      :define_file => RAILS_ROOT+"/tmp/gnuplot/graph.def",
      :base_path   =>  "tmp/gnuplot/data"
    }.merge opt

    group_by = opt[:group_by] ? data_list.group_by{ |d| d.semd(opt[:group_by])} : [["",data_list]]
    path = output_datafile(group_by,opt){ |f,k,data|
      data.each{ |datum| f.printf opt[:column_format],*datum}
    }
    def_file = output_gnuplot_define(path,opt)
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
  end

  def output_gnuplot_define(path,opt)
    
    head = "set terminal #{opt[:terminal]} enhanced size #{opt[:size]} enhanced font 'usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'
set title '#{opt[:title]}"
    key = "set key outside autotitle columnheader" #: "unset key"
    range = nil
    tics  = opt[:tics] ? tics_str(opt) : nil
    grid  = opt[:grid] ? grid_str(opt) : nil
    axis_labels = opt[:axis_labels] ? axis_labels(opt) : nil
    plot  = "plot " + case opt[:type]
                      when "scatter"  ; plot_scatter path,opt
                      else            ; plot_by_column path,opt
                      end
    def_file = opt[:define_file]
    open(def_file,"w"){ |f|
      f.puts head,key
      [range,tics,grid,axis_labels].each{ |item| f.puts item if item }
      f.print plot
      f.puts opt[:additional_lines] if opt[:additional_lines]
      f.puts
    }
    def_file 
  end

  def  plot_by_column(path,opt)
    str = ""
    path.each{ |p| 
       str += (1..opt[:column_labels].size-1).map{ |idx|
        st = "'#{p}' using #{idx+1}:xticlabel(1)" +
        ( opt[:by_tics][idx] ? " axes #{opt[:by_tics][idx]}" : "")
        p=""
        st
      }.join(" ,\\\n")
    }
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
    path = []
    keys = opt[:keys] || grouped_data_ary.map{ |ary| ary.first}.sort
    keys.each_with_index{ |k,idx|
      path << "#{RAILS_ROOT}/#{base_path}.data"
      open(path.last,"w"){ |f|
        f.puts opt[:column_labels].join(" ") if opt[:column_labels]
        yield f,k,grouped_data_ary[idx][1]
        f.puts
      }
      base_path.succ!
    }
    path 
  end
end
end
