# -*- coding: utf-8 -*-

# lotの検索のとき、引き合いがあるものもとるか、引き合いがないものをとるか、
# を指定する場合に用いる。
WithoutPull = true
WithPull    = false
OnlyExport  = :export # 出荷,輸出のみ
AllPull     = false
Export      = :export

# 図表示上の統計（総量、穴数の集計）の表示に用いるフォントのセット
# あまり意味なかったな
StatFont = [[Postscript::Gothic,1.4],[Postscript::Bold,1.8],[Postscript::Gothic,1.4]]

module Ubr::Const

  SCM_stock_stat_FILEBASE = File.join(RAILS_ROOT,"tmp","ubr","SCM_stock_stat")

  @dir= File.dirname(__FILE__)
    $LOAD_PATH << @dir
    MasterDir =  @dir

  # ワンウェイなフレコンを用いる銘柄。
  # 占有桝数を計算する時に用いる。
  Oneways = %w(G123DC700V------F7 G123DC6061------F7 
               G123DC820------F7 G123DC830------F7 
               G123DC720------F7 G123DZ691------F7)

  # 2号倉庫のコンベレーターの座標。 これ Wallに移すべきかも
Converator = [[80.7,30.5],[80.7,32.5],[83.7,32.5],[83.7,30.5],[80.7,30.5]]


end
__END__
require 'pp'
Ubr::Const::SP.each{ |h| pp [[h[:name],h[:offset],h[:stat_offset]],h[:stat_names],h[:stat_reg]]}
$Floors.keys.sort
k.each{ |souko| f=$Floors[souko]; f.contents.each_with_index{|c,i| pp [souko,c,f.sufix[i],f.max[i],f.base_points[i][0],f.base_points[i][1],f.label_pos[i][0],f.label_pos[i][1]] }}
