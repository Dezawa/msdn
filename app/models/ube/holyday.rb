# -*- coding: utf-8 -*-
# ==休日情報:UbeHolyday
# * 休日を登録する
# * １歴月を１オカレンスで表す。
# * 各ラインごとに休日を別にする事も有るので、ライン別にcolumnを用意する
# 各工程とも、一月分を [0123]{月の日数} なる文字列で表す
# 0 :: 通常出勤日
# 1 :: 休日。 その日の 08:00 から翌朝の 08:00 まで
# 2 :: 休出。 その日の16:00まで勤務。16:00から翌朝の 08:00 までが非稼働
# 3 :: 過労働日。その日の 12:00まで勤務。12:00 から翌朝の 08:00 までが非稼働。
#
# アプリ内ではそのままでは扱いにくいので、after_find にて一日ごとにばらした
# 配列としてしまいなおしている。
#
# ======注意
# 1.  0番目の要素が1日目
# 2.  乾燥、加工は製造、切り替え、保守いずれも割り当てできないが、
#     抄造の切り替え、保守は割り付けできる。外注する。
# 3.  抄造の保守、切り替えの割付を止めるには休転 UbeMaintain にその期間を登録する。
class Ube::Holyday < ActiveRecord::Base
  #self.table_name = 'ube_holydays'

  Fields =  [:shozow,:shozoe,:dryo,:dryn,:kakou]

  StartFrom = {"0" => nil,
               "1" => 0,
               "2" => 8.hour,        #休日出勤日の出勤時間
               "3" => 4.hour        #過労働日
  }

  # 一月分の文字列を日ごとのデータに分解する
  after_find{
    # 0/1 is false/true for checkbox
    lastday = Time.parse(month).end_of_month.day
    @holyday=HashWithIndifferentAccess.new
    Fields.each{|sym| 
      @holyday[sym] = send(sym).split("") rescue ["0"]*lastday
      self[sym]=  @holyday[sym] #: [0]*lastday
    }
  }

  #alias_method after_initialize after_find
  
  #日ごとのデータを一月分の文字列にする
  def before_save
    #month = month.beginning_of_month
     Fields.each{|sym| 
      if self[sym].class == Array ; self[sym]=self[sym].join;end 
    }   
  end

  # 一月分、ライン毎の勤務情報 Hash { real_ope => [ 0,0,0,1,2,3,,,] }を返す。
  def holyday; @holyday; end
  def holyday=(v); @holyday=v; end
  

end
