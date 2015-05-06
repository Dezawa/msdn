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
A Dayly ::
B [Dayly,Dayly,,,,] :: 一つの測定器のある期間分の Dayly
C [Dayly,Dayly,,,,] :: Arryはグルーピングされた測定器の Dayly
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
      @option  = DefaultOption.merge(opt)
      @option[:title]=  (@option[:title] ? @option[:title] : "" ) +
        ( @option[:title_post] || "" )
      
      @arry_of_data_objects =
        if dayly.kind_of?(ActiveRecord::Relation) ||dayly.class == Array
          multi_days(dayly)
        else        ; one_day(dayly)
        end
    end
    
    def multi_days(daylies)
      dayly_class = daylies.first.class
      @objects =
        daylies.map{|dayly|
        logger.debug("##### serial:#{ dayly.serial}, date: #{  dayly.date}")
        objects =dayly_class.where( serial: dayly.serial, date:   dayly.date).
          order(:ch_name_type) # ****-温度、****-湿度
        logger.debug("##### #{objects.map{|o| o.id}}")
        objects[0].time_values("%Y-%m-%d %H:%M").
          zip(objects[0].converted_value,
              objects[1].measurement_value,
              objects[1].converted_value)
      }.flatten(1).sort_by{|arry| arry.first }
    end
    
    def one_day(dayly)
      @objects = 
        dayly.class.where(serial: dayly.serial, date:   dayly.date).
        order(:ch_name_type) # ****-温度、****-湿度
        @objects[0].time_values("%Y-%m-%d %H:%M").
        zip(objects[0].converted_value,
            objects[1].measurement_value,
            objects[1].converted_value)
    end
  end
end
