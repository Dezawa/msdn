# -*- coding: utf-8 -*-
# UbeSkd の銘柄入力選択肢のためのモデル
# 品種ごとに銘柄を登録する
#  meigara ::
#  proname ::
class Ubeboard::Meigara < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'ube_meigaras'
  # 選択肢入力のための choise を返す。
  # UbeMeigara datqawabseの変更にダイナミックに追随するために、
  # UbeMeigaraController にてnew, update, csv_upload のときに
  # 呼び出され、更新される。
  #  @meigara が nil であるか、パラメータ read が true のときに
  #  DBから読み直される。
  def self.meigaras(read = nil )
    if !@meigara || read
      @meigara = Hash.new{|h,k| h[k]=[]}
      self.all(:order => "meigara").map{|ch| [ch.proname,ch.meigara]
      }.each{|p,m| @meigara[p] << m }
    end
    @meigara
  end

  # 銘柄略称の　edit_ontableなどで、銘柄一覧のselectに用いる
  def self.all_meigara(read = nil )
    if !@all_meigara || read
      @all_meigara = self.where( "meigara",:select=>"meigara,id" ).
        map{|ch| [ch.meigara,ch.id]}
    end
    @all_meigara
  end

  def self.error_check
    error = []
    count = Hash.new{|h,k| h[k]=[]}
    self.all.each{|um| count[um.meigara] << um}
    count.map{|k,v| v if v.size>1}.compact.each{|v|
      error << "銘柄:「#{v[0].meigara}」が重複しています。品種=[#{v.map(&:proname).join(',')}]"
    }
    error
  end
end
