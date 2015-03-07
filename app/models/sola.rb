# -*- coding: utf-8 -*-
# 太陽光発電の記録
#   積算、季節変動、長期劣化 を知る
#   1分毎発電量の毎日peakをとる。     長期劣化がわかる
#   一日発電量を残す
#   積算発電量を残す
#
#  Model
#    Dayly     1recodeに一日分のデータを残す。1分毎の値、peak値、積算値
#              1分データ1440個をどう見せるか？？ 60行24カラムで見せる
#    Ondotori::Current   Solaに限らず、このサーバで管理する全おんどとりのCurrentの電池データ、電波状態を残す
#                        
module Sola
  # 無補正での一日発電量の回帰は  モニター = 2.15 * おんどとり - 0.72
  # 一日の発電量(kWh)は1分毎の値を17時間分 17*60 個積算し、1/60 した
  # ものだから、この 0.72 の 1/17 は 1分毎の値を17時間分積算したときの累積だから、
  # 1分データをr補正するときの切片は 1/(17*60)倍
  Scale = [2.1486,-0.78/(17)]
  def self.table_name_prefix
    'sola_'
  end

  def self.eqution
    "電力(kW) = #{Scale[0]} * 電圧 #{Scale[1]>0 ? '+' : '-'} #{'%.4f'%Scale[1].abs}"
  end

end
