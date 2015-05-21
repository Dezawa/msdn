# -*- coding: utf-8 -*-

module Gnuplot
  # :header、:body共に中身はHash
  # :header は図の形状、画像フォーマットファイルpath関連を指定する。
  # :body   はグラフのパラメータとデータファイルのbasenameを指定する。
  # :body は multiplotをもサポートするために、さらに構造をもつ
  #    共通・defaultのパラメータを置く :common => {} と
  #    plot固有のパラメータを置く key => {} が 〇個以上
  #
  # DefaultOptionST に、グラフ種類固有の OptionST がmergeされ、さらに
  # グラフ固有の OptionST がmergeされる。
  #   :header のmerge は単に この順に上書きされるだけ
  #   :body :comon、key を各々mergeしたあと、common を keyで上書きしたものを keyに入れる
  #
  # 描画用のdefineを書き出すさい、keyが指定されないか、該当するkeyがないばあい、commonが
  # つかわれる。
  
  OptionST = Struct.new(:header,:body) do
    def initialize(*args)
      self[:header] = args[0] || {}
      self[:body]   = args[1] || {}
      self[:body][:common] = {} unless self[:body][:common]
    end
    
    def merge(other,key_for_merge=nil)
      unless key_for_merge
        ret = OptionST.new(self[0].dup,self[1].dup)
        #headerのマージ
        ret[:header] = ret[:header].merge(other[:header])
        # bodyのマージ
        #
        ret[:body] = ret[:body]
        (ret[:body].keys+other[:body].keys).uniq.
          each{|key|
          ret[:body][key] =
            ret[:body][key] ? ret[:body][key].merge(other[:body][key]||{}) : other[:body][key]
        }
        (ret[:body].keys-[:common]).each{|key|
          ret[:body][key] = ret[:body][:common].merge( ret[:body][key] ? ret[:body][key] : {} )
        }
        ret
      else
        key_for_merge.inject(self){|v,k| v[k]}.merge!(other)
        self
      end
    end
    def merge!(other,key_for_merge=nil)
      unless key_for_merge
        ret = self.merge(other)
        self[:header] = ret[:header]
        self[:body]   = ret[:body]
      else
        self[key_for_merge.first].merge!(other)
      end
      self
    end
  end
  DefaultOptionST = OptionST.
    new( #header
        {
         ###### 図の形状、画像フォーマット ######
         terminal: "jpeg"    ,
         size:      "600,400",

         ########  ファイルpath関連 #######
         graph_file:       "image",
         graph_file_dir:   Rails.root+"tmp" + "img",
         define_file:      Rails.root+"tmp"+"gnuplot"+"graph.def",
        },
        #body
        {common: {
                  base_path:        Rails.root+"tmp"+"gnuplot"+"data" ,# データ書き出しパス。
                  type:     "scatter", #  using 1:2,  無いときは using 2:xticlabel(1),
                  data_file:     "data000" ,
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
                  xy:       [[[1,2]]]   ,  #  [ [[1,2],[3,4]]     ,[[5,6]]
                  #                             ↑最初のファイル   ↑二つ目のファイル  への指示
                  ####### 軸 ######
                  # tics:        , #  軸目盛  例 { :xtics => "rotate by -90",:y2tics=> "-5,5"},
                  # by_tics:     , #  例 => { 4 => "x1y2" },    x1y1以外の軸を使うとき
                  #     
                  # grid:        , #   例 => "ytics"
                  set_key:     "set key outside autotitle columnheader",
                  #                 描画された曲線の説明や表題を表示
                  # axis_labels: , # {x: "X軸",y2: "Y2軸"}
                  # range:       , # {x: "[0:100]",y2: "[11:59]"}
                  #
                  ##### 点、線 ######
                  # point_type: [1,2,6]  idx番目のtypeが point_type[idx]
                  # point_size: [1,2,6] 
                  # line_type:
                  #
                  ####### set,unset ######
                  #
                  # set:   , #色々な set  ["...","....", ,,,]
                  # unset: , #色々な unset  ["...","....", ,,,]
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
        }
       )
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
     data_file:     "data000" ,
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
     # xy:       [[[1,2]]]   ,  #  [ [[1,2],[3,4]]     ,[[5,6]]
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
     ####### set,unset ######
     #
     # set:   , #色々な set  ["...","....", ,,,]
     # unset: , #色々な unset  ["...","....", ,,,]
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
  #     このpathは opt[:graph_file_path] に代入される。
  # detalistの形式は #datafiles の説明参照
  def plot ;logger.debug("##########  @option=#{@option}")
    gnuplot_(arry_of_data_objects,@option);end
  
  def gnuplot_(data_list,opt)
    #opt = DefaultOption.merge opt

    datafile_pathes =  datafiles(data_list,opt)
    def_file = output_gnuplot_define(datafile_pathes,opt)
    `(cd #{Rails.root};/usr/local/bin/gnuplot #{def_file})`
    opt.is_a?(OptionST) ? opt[:header][:graph_file_path] :  opt[:graph_file_path]
  end

  
  # data_list のデータを gnuplotの入力形式のfileを出力し、そのpathの配列を返す。
  # detalistの形式は以下を想定
  #  (1)既にgnuplotの入力形式のfileができていて、そのpathが渡される
  #  (1.1) データファイルpath :: String, or Pathname ::
  #                       :: Sola::Dayly.monthly_graph_with_peak, minute_graph
  #                                                       dayly_graph_with_peak,peak_graph
  #                                                       correlation_graph
  #  (1.2) データファイルpathの配列 ::   [ String, String ] or [Pathname,Pathname]
  #
  #  (2) データ配列 の配列 ::  内側の配列は１サンプルの全項目。外側の配列がサンプル
  #                        ::  [ [clm0,clm1,clm,,] ,[clm1,clm2,clm3,,] ]
  #                        ::  これらは opt[:group_by] でグループ別に分けられ、
  #                        ::  { key1 => [[clm0,clm1,clm,,] ,[clm1,clm2,clm3,,] ]
  #                        ::    key2 => [[clm0,clm1,clm,,] ,[clm1,clm2,clm3,,] ]
  #                        ::  }
  #                        ::  という形になってからファイル出力される。
  #                        ::  1グループ毎に1ファイル。
  #                     温湿度グラフ Graph::Ondotori::Base#one_day,multi_days
  # (3) グループ化された配列 :: (2)のグループ化がされたあとのデータ
  #                          :: { key1 => Array_of_Array } でもよいし、to_aされた形
  #                          :: [ [key1, Array_of_Array] ,[key2, Array_of_Array] ] でもよい
  #                          :: [ [key1,Array_of_Object] ,,, でもよい
  # (4) Objectの配列       :: データ配列 ではなく、Objectが渡される。
  #                        :: Objectのどのattrを使うかは opt[:column_attrs] で知る。
  #
  #  (1.1) String,Pathname
  #  (1.2) Array              String,Pathname
  #  (2)                      Array                     data,data
  #  (3)                      Array                     key,Array
  #  (4)                      Object,opt[:column_attrs]
  #  (3)   Hash               Array                     Array
  #
  # multiplot の場合は opt[:multiplot] にその形状が渡される(例 layout 2,1の場合 [2,1]
  # このとき、 opt、data_list ともに 上記の構造が layout 分の要素のHashとして渡される）
  #  opt = { :multiplot => [2,1],
  #          :multi_order => ["power","temp_hyum"],
  #          "power"     => {},
  #          "temp_hyum" => {},
  #        }
  # data_list ={
  #             "power"     => data_list_of_power,
  #             "temp_hyum" => data_list_of_temp_hyum,
  #            } 
  #      また、opt[idx][:data_file] が定義されている必要がある。ないとみな data000になり、
  #      上書きされてしまう。
  def datafiles(data_list=nil,opt=nil)
    opt ||= @option || DefaultOptionST
    data_list ||= @arry_of_data_objects
    case @option
    when Hash
      if opt[:multiplot]
        opt[:multi_order].
          map{|key| [key,datafiles_case_data_list(data_list[key],opt[key])] }.to_h
      else ; datafiles_case_data_list(data_list,opt)
      end
    when Gnuplot::OptionST
      if opt[:header][:multiplot]
        opt[:header][:multi_order].
          map{|key| [key,datafiles_case_data_list(data_list[key],opt[:body][key])] }.to_h
      else ; datafiles_case_data_list(data_list,opt[:body][:common])
      end
    end
  end
  
  def datafiles_case_data_list(data_list,opt)
    case data_list
    when String,Pathname ; [ data_list] # データファイルパス
    when Array  ; datafiles_case_array(data_list,opt)
    when Hash   ; datafiles_case_hash(data_list,opt)
    end
  end

  def datafiles_case_hash( group_by,opt)
    case  group_by.values.first
    when Array
      output_datafile(group_by,opt){ |f,k,data|
        data.each{ |datum|  output_line(f,datum,opt)  }
      }
    else
      output_datafile(group_by,opt){ |f,k,objects|
        objects.each{ |object|
          datum = opt[:column_attrs].map{|sym| object.send(sym)}
          f.puts (opt[:column_format] ?
                  opt[:column_format]%datum : datum.join(" "))
        }
      }
    end
  end
    
  def datafiles_case_array(data_list,opt)
    case data_list.first
    when String,Pathname ; data_list # Array of データファイルパス
    when  Array
      group_by =
        if data_list.first[1].class != Array
          opt[:group_by] ? data_list.group_by{ |d| d.send(opt[:group_by])} : [["",data_list]]
        else
          data_list
        end
      output_datafile(group_by,opt){ |f,k,data|
        data.each{ |datum|  output_line(f,datum,opt)  }
      }
    else
      group_by = 
        opt[:group_by] ? data_list.group_by{ |d| d.send(opt[:group_by])} : [["",data_list]]
      output_datafile(group_by,opt){ |f,k,objects|
        objects.each{ |object|
          datum = opt[:column_attrs].map{|sym| object.send(sym)}
          f.puts (opt[:column_format] ?
                  opt[:column_format]%datum : datum.join(" "))
        }
      }
    end
  end
  
  # 通常は
  # datafile_pathes :: データファイルのパスの配列
  # arg_option      :: プロット条件のHash
  #
  # multiplotの場合は
  # datafile_pathes :: データファイルのパスの配列の配列
  # arg_option      :: プロット条件のHashの配列
  # 
  # 配列の要素数は multiplot の plotの数
  def gnuplot_define(datafile_pathes,arg_option=nil)
    arg_option ||= @option
    
    return gnuplot_define_struct(datafile_pathes,arg_option) if arg_option.kind_of?(Gnuplot::OptionST)
    gnuplot_define_sub(datafile_pathes,arg_option)
  end

  def gnuplot_define_struct(datafile_pathes,arg_option)
    head     = header(arg_option[:header])

    plot_def =
      if arg_option[:body].keys.size == 1
         plot_def = plot_define(arg_option[:body][:common])
        plot  = plot_list(datafile_pathes,arg_option[:body][:common])
        [ plot_def,  plot ].flatten.compact.join("\n")+"\n#########\n"
      else
        reset_xtics = "set xlabel\nset tics"
        arg_option[:header][:multi_order].reverse.map{|key|
          xtics = reset_xtics
          reset_xtics = nil
          opt = arg_option[:body][key]
          plot_def = plot_define(opt)
          plot  = plot_list(datafile_pathes[key],opt)
          def_file = opt[:define_file]
          [ xtics,plot_def, plot   ].flatten.compact.join("\n") +
            ( opt[:additional_lines] ? ",\\\n"+ opt[:additional_lines] : "")
        }.reverse.join("\n")+"\n#########\n"
      end
    head +"\n"+  plot_def
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
  
  def header(opt)
    #pp opt
    opt[:graph_file_path] = "#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}"
    "set terminal #{opt[:terminal]} enhanced size #{opt[:size]} "+
      "enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'\n"+
      "set out '#{opt[:graph_file_path]}'" +
      if opt[:multiplot]
        "\nset multiplot layout #{opt[:multiplot]}\n" +
        "set lmargin #{opt[:multi_margin][0]}\n"  +
        "set rmargin #{opt[:multi_margin][1]}\n" +
        "unset xlabel\nunset xtics\n"
      else ; ""
      end
  end

  def plot_define(opt)
      title = opt[:title] ? "set title '#{opt[:title]}'" : nil
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
      path.map{ |p|
      xy_ary = xy_ary_ary.size > 1 ? xy_ary_ary.shift : xy_ary_ary.first.dup
      #      str += 
      s = xy_ary.map{ |idx_x,idx_y|
        idx_x,idx_y = idx_y,idx_x unless opt[:type] && opt[:type] ==  "scatter" 
        st = block_given? ? yield(plot_fmt(opt),p,idx_x,idx_y) : sprintf(plot_fmt(opt),p,idx_x,idx_y)
        st += 
        ( opt[:by_tics] && opt[:by_tics][idx] ? " axes #{opt[:by_tics][idx]}" : "") +
        point_type( opt[:point_type],idx) +
        point_size( opt[:point_size],idx ) +# ?   " ps #{opt[:point_size]}" : "")+
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

  def point_type( opt_point_type,idx)
    return "" unless opt_point_type
    " pt " +
      case opt_point_type
      when Integer,Float,String ;  opt_point_type.to_s
      when Array ;      (opt_point_type[idx] || opt_point_type[-1]).to_s
      end
  end
  
  def output_line(f,datum,opt)
    if opt[:column_attrs]
      datum.each{|data|
        if data
          data_array = opt[:column_attrs].
            each{|sym| value = data.send sym
            f.printf opt[:column_format] ? opt[:column_format]%value : value.to_s
          }
        else ;  f.printf " - "
        end
      }
    else
      datum.each_with_index{|data,idx|
        f.printf( data ? (opt[:column_format] && opt[:column_format][idx] ? opt[:column_format][idx]%data : "#{data} ") : " - " )
        #f.printf( data ?  "#{data} " : " - " )
      }
    end
    f.puts
  end
  
  def output_datafile(grouped_data_ary,opt,&block)
    pp opt
    base_path = opt[:base_path].to_s+"/"+ opt[:data_file]
    datafile_pathes = []
    keys = opt[:keys] || grouped_data_ary.map{ |ary| ary.first}.sort
    keys.each_with_index{ |key,idx|
      datafile_pathes << "#{base_path}.data"
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
