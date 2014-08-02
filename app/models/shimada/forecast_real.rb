# -*- coding: utf-8 -*-

module Shimada::ForecastReal
  Def =
" set term gif  size 1000,600 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
 set output '%s/tmp/shimada/giffiles/forecast-real.gif'  
 
set title '%s地方 %s～%s の気温・水蒸気量と予報の誤差'
set key outside autotitle columnheader samplen 2 width -10

#unset key
set x2range [0:%f]
#set xtics 1,1 
set x2tics 1
set xtics  rotate by -90
set  grid noxtics x2tics ytics

plot '/opt/www/msdntest0/tmp/shimada/forecast-real'  using 3:xticlabel(2)  with line lc 1, \
     '' using 4   with line lc 1 lw 2,\
     '' using 5  with line lc 4,\
      '' using 6   with line lc 3, \
      '' using 7   with line lc 3 lw 2,\
      '' using 8  with line lc 2 
#ause -1
set output '%s/tmp/shimada/jpeg/forecast-real.jpeg'  
set term jpeg  size 1000,600 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
replot
"
end
