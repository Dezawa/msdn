# -*- coding: utf-8 -*-
class UserOptionsController < ApplicationController
  before_filter :login_required 
  before_filter {|ctrl| ctrl.require_permit_label "ユーザメンテ"}
  before_filter :set_instanse_variable
  #View 表示すべき項目の定義
  # 第4フィールド type については、 ApplicationHelper#edit_field 参照
  # 基本はLiPS会員汎用のみ。それ以外のユーザ毎のoption機能の登録
  # MSDNの画面の上にメニューを並べる
  #           sym,  lbl,   hlpnsg,type,width
  #          column label   memo  type size action                          
  Labels = [HtmlText.new( :order,"順",:comment=>"表示順",:type =>:text),
            HtmlText.new( :label,"ラベル",:type =>:text,:size =>10),
            HtmlText.new( :url,"URL",:type =>:text,:size =>15),
            HtmlText.new( :authorized,"許可",:type =>:text,:size =>15),
            HtmlText.new( :comment,"コメント",:comment=>"コメント",:type =>:text,:size =>30)
            ]

  def set_instanse_variable
    @Model= UserOption
    @TYTLE = "ユーザオプション"
    @labels=Labels
    @TableEdit = 
      [ "</td><td colspan=2>「順」に従って左からメニューバーに表示される。　順がゼロのものは表示されない <br>"+
        "権限設定にはラベルが使われる</td></tr>\n<tr>",
        :add_edit_buttoms,[:form,:csv_out,"CVS_OUT"]
      ]
    #@Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
  end

  def find(page=1)
    @Model.all.sort{|a,b| (a.order <=> b.order)*1000 + (a.label <=> b.label)}
  end
end
