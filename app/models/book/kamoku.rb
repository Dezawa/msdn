# -*- coding: utf-8 -*-

require 'pp'
# 複式簿記 Book::Keeping の勘定科目のModel
#
class Book::Kamoku < ActiveRecord::Base
  #extend Function::CsvIo
  self.table_name = 'book_kamokus'
  #attr_accessible :id ,:kamoku ,:bunrui ,:code
  attr_accessor   :no,:book_id,:book
  @@kamokus=nil
  #work = self.find_by_kamoku("開始残高")
  #Kaisizandaka = self.find_by_kamoku("開始残高").id

  # 開始残高の id を返す
  def self.kaisizandaka 
    @@Kaisizandaka ||= self.find_by(kamoku: "開始残高").id
  end

  def self.find_with_main(login)
    kamokus = Book::Kamoku.all.each{|kamoku| kamoku.book_id=login }
    mains   = Book::Main.all(:conditions => ["owner = ? and date = ? ",
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
    find_with_main(login)
    #if !@@kamokus || read
      #logger.info("KAMOKU: read=#{read}")
    #  begin 
        @@kamokus = self.all(:order => "bunrui,kamoku").map{|ch| [ch.kamoku,ch.id]} 
    #  rescue
    #    @@kamokus = []
    #  end
#      }.each{|p,m| @kamokus[p] << [m] }
    #end
    #@@kamokus
    find_with_main(login).map{|ch| [ch.kamoku,ch.id]}
  end

  def no
    @book.no rescue nil
  end
  #def book_id ; @book.id rescue nil ;end
  def update_attributes(attrs)
    unless (no = attrs[:no]).blank?
      #logger.debug "update_attributes no=#{no} book.id =#{attrs[:book_id]}"
      #puts  "update_attributes no=#{no} book.id =#{attrs[:book_id]}"
      begin
        Book::Main.find(attrs[:book_id]).update_attributes(:no => no)
      rescue
        book=Book::Main.create(:no=>no,:owner => attrs[:book_id],:date => "2000/1/1",
                          :karikata => id,:kasikata=> id ,:amount =>"0" ,:tytle => "表示順")
        #puts  "update_attributes no=#{no} book.id =#{attrs[:book_id]} karikata = #{id}"
        book.save
        #pp book.errors
      end
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
