# -*- coding: utf-8 -*-
class Book::PermissionController < Book::Controller
  before_filter :login_required 
  before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  before_filter :set_const
  before_filter(:except => :error) {|ctrl|  ctrl.require_permit "/book_keeping/error" }
  
  Labels = 
    [ HtmlText.new(:id,"ID",:align =>:right,:ro=>true,:size =>7),
      HtmlText.new(:login,"協働ユーザ",:size => 20,:comment => "あなたの簿記を参照・編集出来るユーザ" ),
      HtmlText.new(:owner,"簿記ユーザ",:ro=>true,:size =>20),
      HtmlSelect.new(:permission,"権限",
                     :comment => "編集可能：伝票の作成、修正、削除が可能です。<br>"+
                                 "参照のみ：見る他、CSVのダウンロードが可能です",
                     :correction => [["編集可能",Book::Permission::EDIT],
                                     ["参照のみ",Book::Permission::SHOW],
                                     ["権限なし",Book::Permission::NON ]]
                     )
    ]
  CSVatrs = Labels.map{|lbl| lbl.symbol}
  CSVlabels= Labels.map{|lbl| lbl.label}
  
  def set_const
    @Model= Book::Permission
    @Domain=  @Model.name.underscore
    @TYTLE = "複式簿記：アクセス可能ユーザ"
    @labels = Labels
    @TYTLEpost = "#{@year.year}年度"
    #@#Links=BookKeepingController::Labels
    @FindOption = {:conditions => ["owner = ? ",current_user.login]  }
    @TableEdit =  editable ? [[:form,:new,"新ユーザ"]] : false
    @edit_vertical = true
    @New = { :owner => current_user.login }
    @Edit = editable
    @Delete=editable
    @Create = {:owner => current_user.login}
    #@conditions = { :conditions => "owner = '#{current_user.login}'" }
    #@SortBy   = :bunrui
    @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
    #@Pagenation = 10
    @PagenatTbl = true
    @PostMessage = ""
  end


    
      
end
