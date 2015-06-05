# -*- coding: utf-8 -*-
module Gnuplot

  # 横軸が時間の時に横軸目盛の表示方法を指定するにあたり、その標準を定義する
  # 年単位、月単位、一日の中、の3つを定義
  TimeRange =
  { nil =>  {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%Y/%m/%d'"]},
   years:   {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%Y/%m/%d'"]},
   monthly: {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%m/%d'"   ]},
   dayly:   {xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'"   ]}
  }

# Gnuplotに与える option のための Structure
#   :header と :body の二つの要素があり、defaultでは :bodyには :common 要素が一つある。
#   二つに分けてあるのは multi plot の場合を考慮したため。
#   :header はグラフ全体のパラメータを定義する。multiplotの場合、全plotに共通な情報
#   :body   は個々のグラフのパラメータを定義する。
#      multiplot の場合は :body の要素として 個々のグラフ毎にパラメータを定義する。
#      multiplot ではない場合は :body の要素 :common でパラメータを定義する。
#
# :header、:body 及び:body直下の要素はHash
# :header は図の形状、画像フォーマットファイルpath関連を指定する。
# :body   はグラフのパラメータとデータファイルのbasenameを指定する。
#
# DefaultOptionST に、グラフ種類固有の OptionST がmergeされ、さらに
# グラフ固有の OptionST がmergeされる。
#   :header のmerge は単に この順に上書きされるだけ
#   :body :comon、key を各々mergeしたあと、common を keyで上書きしたものを keyに入れる
#
OptionST = Struct.new(:header,:body) do    
  def initialize(*args) # OptionST = Struct.new(:header,:body) do
    self[:header] = args[0] || {}
    self[:body]   = args[1] || {}
    self[:body][:common] = {} unless self[:body][:common]
  end

  # 横軸が時間の時に横軸目盛の表示方法を指定する、:xdata_time option を設定する。
  # 暗黙のうちに呼ばれることはないので、横軸が時間の時は明示的に呼ぶこと
  #   [:body][:common][:xdata_time] が設定されている場合はなにもしない
  #   [:header][:time_range] が設定されている時は その値 :dayly,:monthly,:years により決める
  #   何も指定されていない場合は、:year となる
  def set_timerange
    return if self[:body][:common][:xdata_time]
    self.merge(TimeRange[self[:header].delete(:time_range)],[:body,:common])
  end

  # 深いdupである
  def dup
    ret = OptionST.new(self[:header].dup,self[:body].dup)
    self[:body].keys.each{|key| ret[:body][key] = self[:body][key].dup }
    ret
  end

  def delete(*key_for_merge)
    return nil unless key_for_merge
    vv=key_for_merge.flatten[0..-2].inject(self){|v,k| v[k]}
    return nil unless vv
    return vv.delete(key_for_merge.flatten.last)
  end

  # key_for_merge がある場合は、その keyにmerge! される。
  #  keyの指定は [key1][key2][key3] のときに、[key1,key2,key3] の様にする
  # 無い場合は other は OptionST である
  # mergeしたのち、[:body][:common] に [:body][そのたのkey] をmergeしたものが
  # [:body][そのたのkey]にしまわれる  
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
      key_for_merge.flatten.inject(self){|v,k| v[k]}.merge!(other)
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

# 標準なoptionSTを定義している
module Options
  header = {
            ###### 図の形状、画像フォーマット ######
            terminal: "jpeg"    ,
            size:      "600,400",

            ########  ファイルpath関連 #######
            graph_file:       "image",
            graph_file_dir:   Rails.root+"tmp" + "img",
            define_file:      Rails.root+"tmp"+"gnuplot"+"graph.def",
           }.freeze
  body = {
          base_path:        Rails.root+"tmp"+"gnuplot"+"data" ,# データ書き出しパス。
          type:     "scatter", #  using 1:2,  無いときは using 2:xticlabel(1),
          data_file:     "data000" ,
          ###### データ関連 ######
          #
          # 入力データ構造
          #  形式１ [ [value,value,value,,,], [,,,], [,,,],,,,,]
          #  形式２ [ [objct,objct,objct,,,], [,,,], [,,,],,,,,]
          #  形式３ objct
          #  形式４ [ [key,Array],[key,[Array]], {key=>Array,key=>Array}
          #  
          # 中間ファイル関連
          # column_labels: "" , # gnuplotの入力データとなる中間ファイルのヘッダー文字列
          # column_attrs:  [] , # 入力データ構造が形式２のとき、obje.send[sym] としてデータを得る
          #                     # 出力ファイルが複数になり(group_byにて)、かつそれ毎にカラムラベルを
          #                     # 変更したい場合は Array of Array にする。
          #                     #  例  [%w(年月日 時刻 予報気温), %w(年月日 時刻 気温)],
          #              # 形式３のとき objctのserializeされている attrを指定し、そのデータを用いる
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
          # color:      ["red","blue"] http://d.hatena.ne.jp/yrgnah_yats/20090802/1249188972
          #             white , black ,grey ,red ,yellow ,green ,light-green
          #             dark-green ,blue ,cyan ,magenta ,turquoise ,pink ,salmon
          #            ,khaki ,orange,purple
          # line_type:
          #
          ####### set,unset ######
          #
          # set:   , #色々な set  ["...","....", ,,,]
          # unset: , #色々な unset  ["...","....", ,,,]
          #####  ######
          
          #additional_lines: , #  近似線などを書く式を生で記述
          #with:    [lines boxes,,,],   #
          #labels:  ,# ["label 1 'Width = 3' at 2,0.1 center","arrow 1 as 2 from -1.5,-0.6 to -1.5,-1"]
          #  実装まだ
          #
          #         :group_by    data_list.group_by{ |d| d.semd(opt[:group_by])}
          #         :keys        defaultではgroup_by の分類がsortされて使われる。
          #                      違うsort順にしたいときに設定
         }
  Gnuplot::DefaultOptionST = OptionST.new( header.freeze  ,  {common: body.freeze  }.freeze )
  Gnuplot::DefaultOption = header.merge(body)
end
end
