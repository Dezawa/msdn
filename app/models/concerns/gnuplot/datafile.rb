# -*- coding: utf-8 -*-
module Gnuplot::Datafile
  
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
  def output_datafile(grouped_data_ary,opt,&block)
    base_path = opt[:base_path].to_s+"/"+ opt[:data_file]
    datafile_pathes = []
    keys = opt[:keys] || grouped_data_ary.map{ |ary| ary.first}.sort
    keys.each_with_index{ |key,idx|
      datafile_pathes << "#{base_path}.data"
      open(datafile_pathes.last,"w"){ |f|
        f.puts column_labels(opt[:column_labels],idx) if opt[:column_labels]
        yield f,key,grouped_data_ary[idx][1]
        f.puts
      }
      base_path.succ!
    }
    datafile_pathes 
  end
  def datafiles(data_list=nil,opt=nil)
    opt ||= @option || DefaultOptionST
    data_list ||= @arry_of_data_objects
    case opt
    when Hash
      if opt[:multiplot]
        opt[:multi_order].
          map{|key| [key,datafiles_case_data_list(data_list[key],opt[key])] }.to_h
      else ; datafiles_case_data_list(data_list,opt)
      end
    when Gnuplot::OptionST,Gnuplot::Options::OptionST
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

  def column_labels(labels,idx)
    case labels.first
    when Array ; labels[idx]
    else labels
    end.join(" ")
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
end
