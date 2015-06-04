# -*- coding: utf-8 -*-
=begin

Graph > Graph::Base > Graph::Ondotori::Base >

グラフは大きく３つにわかれる。
 １ おんどとり による測定値のグラフ化
 ２ その他のデータ。たとえば気象庁からの温湿度、電力会社からの電力でーた
 ３ 1,2両方を同時に扱う

１のケースはさらに３つに分かれる
  1-1 工場全体グラフ
  1-2 測定器毎のグラフ
  1-3 グルーピングされた測定器のグラフ

温湿度計のデータは、1-2の場合は温度、湿度、水蒸気圧 を表示するが
1-1、1-3の場合はゴチャゴチャになるので、温度、水蒸気圧の二つにする

Graph.newに与えるデータは次のケースがある
A Dayly,[Dayly]     :: Dayly または要素が一つのDaylyのRelation
B [Dayly,Dayly,,,,] :: 一つの測定器のある期間分の DaylyのArrayまたはRelation
C [[Dayly,Dayly,,,,]] :: 内側のArryはグルーピングされた測定器の Dayly、またはRelation
D [[Dayly,Dayly,,,,],[Dayly,Dayly,,,,],,,,] :: C の期間分のArray

これらは、次の様に使われる
     一日分のグラフ   ある期間のグラフ
1-1      A                   B
1-2      C                   D
1-3      C                   D
BとCの区別は、最初の二つの要素の日付が同じかどうかで分かる）

Graph::Base(及びその子供の Graph::XXXX)はnewの引数として、
プロットデータ ArryのArryを受ける。
         内側のArrayはデータファイルの1行分。

Graph::Ondotori::Baseはnewの引数として上記 ABCD のどれかを受ける。
このABCDを Graph::Ondotori::Base#arry_of_data を用いて Graph::Base形式に
変換する。
２、３ 形式を Graph::Base形式に変換するのにもこれを用いることになるがその
拡張は ToDo
=end

module Graph::Ondotori
  class Base < Graph::Base
    
    def initialize(dayly,opt={})
      @options  =
        case opt
        when Hash
          option  = DefaultOption.merge(opt)
          option[:title]=
           (option[:title] ? option[:title] : "" ) + ( option[:title_post] || "" )
         option
        when Gnuplot::OptionST
          option  = Gnuplot::DefaultOptionST.merge(opt)
          st = option[:body][:common]
          st[:title] = (st[:title] ? st[:title] : "") + (st[:title_post] || "" )
          option
        end
      @arry_of_data_objects =
        if dayly.kind_of?(ActiveRecord::Relation) ; multi_days(dayly)
        elsif dayly.class == Array
          if dayly.first.kind_of?(ActiveRecord::Relation) || dayly.first.class == Array
                      combination(dayly)       #case C
          else      ; multi_days(dayly)        #case B
          end
        else        ; one_day(dayly)           #case A
        end
    end

    # case C :: 複数の測定器のデータのセット
    #        :: interbal が異なるかもしれないので、測定器毎に出力ファイルを分ける
    #        :: { 装置 => [[item1,item2,item3,,],[item1,item2,item3,,],,,] }
    def combination(arry_of_daylies)
      #                    day1             day2                day3
      # arry_of_daylies =>
      #   [ [装置11,装置21,装置31],[装置12,装置22,装置32],[装置13,装置23,装置33],,]
      arry_of_daylies.flatten.
        # {serial => [装置11,装置21,装置12,装置22,装置13,装置23],
        #  serial => [装置31,装置32,装置33] }
        group_by{|dayly| dayly.instrument.serial}. 
        map{|serial,daylies|          # {serial => [装置11,装置21,装置12,装置22,装置13,装置23],
        values = daylies.group_by{|dayly| dayly.date}. #{1day => [装置11,装置21]}
          values.map{|dayly|
          dayly[0].time_values("%Y-%m-%d %H:%M").
            zip( *dayly.map(&:converted_value))
        }.flatten(1)
        [serial,values]
      }.to_h
    end
    
    # case B :: 一つの測定器の Daylyの配列 ｜ DaylyのRelation
    #        :: 要素数が１の時は case A
    def multi_days(daylies)
      dayly_class = daylies.first.class
      daylies.map{|dayly| dayly.time_and_converted_value
      }.flatten(1).sort_by{|arry| arry.first }
    end

    # case A :: Dayly
    def one_day(dayly)
        dayly.time_and_converted_value 
    end
  end
end
