# -*- coding: utf-8 -*-
# 立案に影響を与える定数をUbeSkdから取り除き、DBに定義することで
# ユーザによる変更を可能にする。
#
# UbeSkd,Function::Ubeboad::boad::SkdFreelistに,DBに未定義であったときの番兵と参照メソッドが必要。
# 検索の Keyとなる column name の値を変更してはならない。
#  2012/6/20現在の定義::休日前製造最小数 終業作業 始業作業 
class Ubeboard::Constant < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'ubeboard_constants'
end
