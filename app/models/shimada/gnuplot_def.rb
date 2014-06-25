# -*- coding: utf-8 -*-
module Shimada::GnuplotDef

  ########## ↓ GNUPLOT ############
Temp_power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/power.gif'

set title "温度-消費電力 " 
set key outside autotitle columnheader
set yrange [0:1000]
set xrange [-10:40]
set xtics -10,5
!

Power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/power.gif'
#set terminal x11

set title "消費電力 " 
%s
set yrange [0:1000]
set xrange [1:24]
set xtics 1,1
set grid ytics
!

Differ_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/power.gif'
#set terminal x11

set title "消費電力 " 
%s
set yrange [-50:50]
set xrange [1:24]
set xtics 1,1
set ytics -50,10
set grid ytics
!

Nomalized_def=
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/power.gif'
#set terminal x11

set title "正規化消費電力 " 
%s
set yrange [0.2:1.1]
set xrange [1:24]
set xtics 1,1
set x2tics 3,3
set grid x2tics
!

  ########## ↑ GNUPLOT ############
end
