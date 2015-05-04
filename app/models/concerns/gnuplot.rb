# -*- coding: utf-8 -*-
module Gnuplot
  DefaultOption =
    {
     ###### 図の形状、画像フォーマット ######
     terminal: "jpeg"    ,
     size:      "600,400",
     type:     "scatter", #  using 1:2,  無いときは using 2:xticlabel(1)

     ########  ファイルpath関連 #######
     base_path:        Rails.root+"tmp"+"gnuplot"+"data" ,# データ書き出しパス。
     graph_file:       "image",
     graph_file_dir:   Rails.root+"tmp" + "img",
     define_file:      Rails.root+"tmp"+"gnuplot"+"graph.def",
     
     ###### データ関連 ######
     #
     # 入力データ構造
     #  形式１ [ [value,value,value,,,], [,,,], [,,,],,,,,]
     #  形式２ [ [objct,objct,objct,,,], [,,,], [,,,],,,,,]
     #  形式３ objct
     #
     # 中間ファイル関連
     # column_labels: "" ,       # gnuplotの入力データとなる中間ファイルのヘッダー文字列
     # column_attrs:  [] ,       # 入力データ構造が形式２のとき、obje.send[sym] としてデータを得る
     #                           # 形式３のとき objctのserializeされている attrを指定し、そのデータを用いる
     # column_format:    ,       # 中間ファイルへの出力format
     #
     ###################################
     ######## プロットデータ関連 #######
     ###################################
     #
     ####### title達 ######
     # title:       , #  グラフのタイトル。図枠の上外側中央に表示される
     # axis_labels: , #  軸   例  { :xlabel => "日",:ylabel => "推定電力",:y2label => "気温"},
     #
     #
     ### データファイルの何カラム目を用いるか ######
     # xy:       [[1,2]]   ,  #  [ [[1,2],[3,4]]     ,[[5,6]]
     #                             ↑最初のファイル   ↑二つ目のファイル  への指示
     ####### 軸 ######
     # tics:        , #  軸目盛  例 { :xtics => "rotate by -90",:y2tics=> "-5,5"},
     # by_tics:     , #  例 => { 4 => "x1y2" },    x1y1以外の軸を使うとき
     #     
     # grid:        , #   例 => "ytics"
     # set_key:     , # 描画された曲線の説明や表題を表示
     #                # default "set key outside autotitle columnheader"
     # axis_labels: , # {x: "X軸",y2: "Y2軸"}
     # range:       , # {x: "[0:100]",y2: "[11:59]"}
     #
     ##### 点、線 ######
     # point_type: [1,2,6]  idx番目のtypeが point_type[idx]
     # point_size: [1,2,6] 
     # line_type:
     #
     ####### set ######
     #
     # set:   , #色々な set  ["...","....", ,,,]
     #####  ######
     
     #additional_lines: , #  近似線などを書く式を生で記述
     #with:     "line",   #
     #labels:  ,# ["label 1 'Width = 3' at 2,0.1 center","arrow 1 as 2 from -1.5,-0.6 to -1.5,-1"]
     #  実装まだ
  #
  #         :group_by    data_list.group_by{ |d| d.semd(opt[:group_by])}
  #         :keys        defaultではgroup_by の分類がsortされて使われる。
  #                      違うsort順にしたいときに設定
    }
  # 出力される画像fileは  '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'
  # detalistの形式は以下を想定
  #   データファイルpath          String
  #   データファイルpathの配列    [ String, String ]
  #   データ                      [ [clm0,clm1,clm,,] ,[clm1,clm2,clm3,,] ]
  def plot ;gnuplot_(arry_of_data_objects,option);end
  def gnuplot_(data_list,opt)
    opt = DefaultOption.merge opt

    datafile_pathes =  datafiles(data_list,opt)
    def_file = output_gnuplot_define(datafile_pathes,opt)
    `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
  end

  # data_listの形式にしたがって、output_gnuplot_define の入力形式(データファイルのpathのArray)に
  # 変換する
  # detalistの形式は以下を想定
  #   データファイルpath          String
  #   データファイルpathの配列    [ String, String ]
  #   データ                      [ [clm0,clm1,clm,,] ,[clm1,clm2,clm3,,] ]
  # StringでもArrayでも無い場合
  #   データObjectの配列          [ Object, Object,,, ] :: 各Objectから column_attrs のデータを使う
 

  def datafiles(data_list=nil,opt=nil)
    opt ||= @option || DefaultOption
    data_list ||= @arry_of_data_objects
    if data_list.class == String ; [ data_list] # データファイルパス
    elsif data_list.class == Array
      case data_list.first
      when String ; data_list # Array of データファイルパス
      when  Array
        group_by = 
          opt[:group_by] ? data_list.group_by{ |d| d.semd(opt[:group_by])} : [["",data_list]]
        output_datafile(group_by,opt){ |f,k,data|
          data.each{ |datum|  output_line(f,datum,opt)  }
        }
      else
        group_by = 
          opt[:group_by] ? data_list.group_by{ |d| d.semd(opt[:group_by])} : [["",data_list]]
          output_datafile(group_by,opt){ |f,k,objects|
            objects.each{ |object|
              datum = opt[:column_attrs].map{|sym| object.send(sym)}
              f.puts (opt[:column_format] ?
                    opt[:column_format]%datum : datum.join(" "))
            }
          }
      end        
    end
  end
  
  def gnuplot_define(datafile_pathes,opt)
    head = "set terminal #{opt[:terminal]} enhanced size #{opt[:size]} enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set out '#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}'"
    title = opt[:title] ? "set title '#{opt[:title]}'" : nil
    key = opt[:set_key] || "set key outside autotitle columnheader" #: "unset key"
    
    tics  = opt[:tics] ? tics_str(opt) : nil
    grid  = opt[:grid] ? grid_str(opt) : nil
    set   = opt[:set]  ? opt[:set].map{ |str| "set #{str}"}.join("\n")  : ""
    axis_labels = opt[:axis_labels] ? axis_labels(opt) : nil

    plot  = plot_list(datafile_pathes,opt)
    def_file = opt[:define_file]

    [ head,title,key ,set ,labels( opt[:labels]) ,
      range_str(opt),tics,grid,axis_labels,
      plot
    ].flatten.compact.join("\n") +
     ( opt[:additional_lines] ? ",\\\n"+ opt[:additional_lines] : "")
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

  def labels(arg_labels)   ; arg_labels ? arg_labels.map{ |l| "set #{l}"}.join("\n") : ""   ;  end
  def index_of_label(label); labels.index(label)                                       ;  end
  def axis_labels(opt)
    opt[:axis_labels].map{ |k,v|
      case v
      when String ; "set #{k} '#{v}'"
      when Array ; "set #{k} '#{v.first}' #{v[1]}"
      end
      }.join("\n")
  end

  def range_str(opt)
    return "" unless opt[:range]
    opt[:range].map{ |axis,str| "set #{axis}range #{str}"}.join("\n")
  end

  def  tics_str(opt)
    opt[:tics].map{ |xy,tics| "set #{xy} #{tics}"}.join("\n")
  end

  def  grid_str(opt)
    opt[:grid].map{ |grid| "set grid #{grid}"}.join("\n")
  end

  def output_line(f,datum,opt)
    if opt[:column_attrs]
      datum.each_with_index{|data,idx|
        data ? f.printf(opt[:column_attrs][idx],data) : " - "
      }
    else
      datum.each{|data|
        f.printf( data ? "#{data} " : " - " )
      }
    end
    f.puts
  end
  
  def output_datafile(grouped_data_ary,opt,&block)
    base_path = opt[:base_path].to_s+"/data000"
    datafile_pathes = []
    keys = opt[:keys] || grouped_data_ary.map{ |ary| ary.first}.sort
    keys.each_with_index{ |key,idx|
      datafile_pathes << Rails.root+"#{base_path}.data"
      open(datafile_pathes.last,"w"){ |f|
        f.puts opt[:column_labels].join(" ") if opt[:column_labels]
        yield f,key,grouped_data_ary[idx][1]
        f.puts
      }
      base_path.succ!
    }
    datafile_pathes 
  end
end
