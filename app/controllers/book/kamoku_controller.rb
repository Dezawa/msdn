# -*- coding: utf-8 -*-
class Book::KamokuController  <  Book::Controller
  before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter {|ctrl| ctrl.require_allowed}
  #before_filter(:except => [:index,:csv_out,:edit_on_table,:update_on_table]){|ctrl| ctrl.require_editor}
  before_filter(:except => [:index,:csv_out,:edit_on_table,:update_on_table]){|ctrl| ctrl.require_configure} 
  before_filter :set_instanse_variable
  before_filter :set_const

  Labels = 
    [ HtmlText.new(:id,"ID",:align=>:right,:ro=>true,:size =>7),
      HtmlSelect.new( :code    ,"分類",:ro=>true,:correction => %w(資産 負債 資本 収入 経費 _).zip([1,2,3,4,5,0])),
      HtmlText.new( :bunrui  ,"順",:ro=>true,:align=>:right,:size=>3),
      HtmlLink.new( :kamoku ,"課目",:ro=>true,:size =>7,
                    :link => { 
                      :url => "/book/main/book_make",
                      :key => :kamoku_id ,:key_val => :id
                    }),
      HtmlText.new( :no     ,"選択時表示順",:size =>3),
      HtmlHidden.new( :book_id)
    ]
  Labels_edit_all_culmn = 
    [ HtmlText.new(  :id,    "ID" ,:align=>:right,:ro=>true,:size =>7),
      HtmlSelect.new(:code , "分類",:correction => %w(資産 負債 資本 収入 経費 _).zip([1,2,3,4,5,0])),
      HtmlText.new(  :bunrui,"順",:align=>:right,:size=>3),
      HtmlText.new(  :kamoku,"課目",:size =>7),
      HtmlText.new(  :no    ,"選択時表示順",:size =>3),
      HtmlHidden.new(:book_id)
    ]
  Model = Book::Kamoku
  Order = "bunrui,kamoku"
  CSVatrs = Labels.map{|lbl| lbl.symbol}
  CSVlabels= Labels.map{|lbl| lbl.label}

  def set_const
    @Model= Book::Kamoku
    @TYTLE = "複式簿記：課目"
    @labels=Labels
    @Links=Book::KeepingController::Links
    #@Pagenation = 100
    @TableEdit  = @configure ?  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table_all_column,"編集"]] :
      book_editor? ?  [[:form,:edit_on_table,"編集"]] : []
    @Delete = @configure
    @conditions = { :order => "bunrui,kamoku" }
    @Domain= @Model.name.underscore
    @Refresh = :kamokus
    @SortBy    = :bunrui
    @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
  end

  def find(page=1)
    Book::Kamoku.find_with_main(@owner.owner) #current_user.login)
  end

  def index
    unless readable
      redirect_to "/msg_book_permit.html"
    else
      super
    end
  end
  
  def add_on_table
    @labels=Labels_edit_all_culmn
    super
  end
  def edit_on_table_all_column
    @labels=Labels_edit_all_culmn
    @models= find
    #@page = params[:page] || 1 
    #find_and
    render  :file => 'application/edit_on_table',:layout => 'application'
  end
end

