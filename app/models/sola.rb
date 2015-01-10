# -*- coding: utf-8 -*-
# 太陽光発電の記録
#   積算、季節変動、長期劣化 を知る
#   1分毎発電量の毎日peakをとる。     長期劣化がわかる
#   一日発電量を残す
#   積算発電量を残す
#
#  Model
#    Monthly   1recodeに一月分の日毎発電量を残す。
#    Dayly     1recodeに一日分のデータを残す。1分毎の値、peak値、積算値
#              1分データ1440個をどう見せるか？？ 60行24カラムで見せる
#    Ondotori::Current   Solaに限らず、このサーバで管理する全おんどとりのCurrentの電池データ、電波状態を残す
#                        
module Sola
  def self.table_name_prefix
    'sola_'
  end
end
