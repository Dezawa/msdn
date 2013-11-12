# -*- coding: utf-8 -*-
# == ユーザーオプション
# 1. ログインすると全員が会員用LiPSが使えるようになる。
#    その他のアプリをこのModelに登録する。
# 2. Userにhas_many されたUserOptionがそのユーザに利用可能となる。
# 3. 利用可能となったアプリはブラウザ画面のTopメニューに表示される。
#    表示順にしたがい、左から。ただし、表示順がゼロのものは表示されない。
#    これはメンテナンス権限などの付与に用いる
# 4. 表示は layoyt/application.erb が行う
#
# label  :: Topメニューに表示
# url  :: アプリへのリンク
# order  :: メニューでの表示順
# comment  :: 
class UserOption < ActiveRecord::Base
  extend Function::CsvIo
  has_and_belongs_to_many :users
  attr_accessible :label, :url ,:order,:comment,:authorized
end
