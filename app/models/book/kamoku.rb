# -*- coding: utf-8 -*-

require 'pp'
# 複式簿記 Book::Keeping の勘定科目のModel
#
class Book::Kamoku < ActiveRecord::Base
  extend CsvIo
  #self.table_name = 'book_kamokus'
  attr_accessor   :no,:book_id,:book

   validates_presence_of :code ,:message=> "分類は必須項目です"
   validates_presence_of :bunrui ,:message=> "順は必須項目です。"
   validates_presence_of :kamoku ,:message=> "課目は必須項目です"

  @@kamokus=nil
  # 開始残高の id を返す
  def self.kaisizandaka 
    @@Kaisizandaka ||= self.find_by(kamoku: "開始残高").id
  end

  def self.order_no_for_display(owner_name,kamoku_id)
    book = Book::Main.find_by(owner: owner_name, date: "2000/1/1",karikata: kamoku_id)
    book ? book.no : nil
  end

  def self.change_order_no_for_display(owner_name,kamoku_id,new_no)
    book = Book::Main.find_by(owner: owner_name, date: "2000/1/1",karikata: kamoku_id)
    if book 
      book.update_attributes(no: new_no)
    else
      Book::Main.create(owner: owner_name, date: "2000/1/1",karikata: kamoku_id,
                        kasikata: kamoku_id ,amount: 0, no: new_no, tytle: "表示順")
    end
  end

  def self.find_with_main(login)
    kamokus = Book::Kamoku.all.each{|kamoku| kamoku.book_id=login }
    mains   = Book::Main.where(["owner = ? and date = ? ",
                                             login,
                                             "2000/1/1"]
                             )
    mains.each{|book| 
      kamoku=kamokus.find{|kamoku| kamoku.id == book.karikata}
      kamoku.book_id=book.id; kamoku.book = book
    }
    kamokus.sort{|a,b| 
      ((a.no || 10000000)<=>(b.no|| 10000000))*4 +
      (a.bunrui<=>b.bunrui)*2 + (a.kamoku<=>b.kamoku)
    }
  end

  # 全科目データをの[科目名,id]を返す。
  # optional arg が !nil の時は読み直す。これは Book::Kamokuの
  # create、update、csv_upload があると実行される。
  def self.kamokus(login=nil,read = nil )
    #find_with_main(login)
    @@kamokus = self.order(:bunrui,:kamoku).
      to_a.map{|ch| [ch.kamoku,ch.id]} 
    find_with_main(login).map{|ch| [ch.kamoku,ch.id]}
  end

  def no
    @book.no rescue nil
  end
  #def book_id ; @book.id rescue nil ;end
  def update_attributes(attrs)
    unless (no = attrs[:no]).blank?
      Book::Kamoku.change_order_no_for_display(attrs[:book_id],id,no)
    end
    #pp no
    super(attrs)
  end
  # 科目が貸方か借方か返す。
  # 貸方 1、借方 2。開始残高 は 0
  def taishaku
    @taishaku ||= case code 
                  when 1,5   ; 1
                  when 2,3,4 ; -1
                  else ;       0
                  end
  end

end
