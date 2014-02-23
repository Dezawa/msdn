# -*- coding: utf-8 -*-
class Ubr::Controller < ApplicationController
  before_filter {|ctrl| ctrl.set_permit %w(UBR UBRメンテ UBRメンテ)}
  before_filter :set_instanse_variable
   Links = [MenuCsv.new("SCM在庫更新" ,"ubr/main"   ,:enable_csv_upload=> true,:size => 40,:buttonlabel=>"CSV/Excelで登録") ,
             Menu.new(   "在庫表示"    ,:main   ,:action => :occupy_pdf) ,
             Menu.new(   "再計算"      ,:main   ,:action => :reculc) ,
             Menu.new(   "枠管理"         ,:waku   ,:action => :index,:disable => :editor), 
             Menu.new(   "枠ブロック管理"  ,:waku_block   ,:action => :index,:disable => :editor) 
            ]
end
