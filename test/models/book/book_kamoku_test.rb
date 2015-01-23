# -*- coding: utf-8 -*-
require 'test_helper'

class Book::BookKamokuTest < ActiveSupport::TestCase
 fixtures "book/kamokus","book/mains"
  KamokuChoise =[
                 ["接待交際費",3],     # 514
                 ["工具器具備品",10],  # 180
                 ["売上",11],          # 410
                 ["開始残高",18],      # 0 
                 ["現金",22],          # 100
                 ["普通預金",6],       # 110
                 ["受取手形",8],       # 140
                 ["売掛金",23] ,       # 150
                 ["事業主貸",12],       # 190
                 ["未払金"  ,2],       # 210
                 ["事業主借",16],      # 280
                 ["元入金",4],         # 310
                 ["租税公課",21],      # 508
                 ["荷造運賃",15],      # 509
                 ["旅費交通費",19],    # 511
                 ["通信費",13],        # 512
                 ["消耗品費",14],      # 517
                 ["資料・教育",20],    # 525
                 ["紹介料",17]  ,      # 526
                 ["雑費",7],           # 531
  ]
  must "選択肢に出て来る課目一覧の順番"  do
    kamoku= Book::Kamoku.new
    #puts Book::Kamoku.all.map{|k| [k.id,k.code,k.bunrui,k.kamoku].join(",")}
    assert_equal KamokuChoise.map{ |name,id| id},
    Book::Kamoku.find_with_main("dezawa").map(&:id)
    "選択肢に出て来る課目一覧の順番,Arrayは 科目ID"
  end

  KamokuAll  = [
                 ["開始残高",18],      # 0 
                 ["現金",22],          # 100
                 ["普通預金",6],       # 110
                 ["受取手形",8],       # 140
                 ["売掛金",23] ,       # 150
                 ["工具器具備品",10],  # 180
                 ["事業主貸",12],      # 190
                 ["未払金"  ,2],       # 210
                 ["元入金",4],         # 210
                 ["事業主借",16],      # 280
                 ["売上",11],          # 410
                 ["租税公課",21],      # 508
                 ["荷造運賃",15],      # 509
                 ["旅費交通費",19],    # 511
                 ["通信費",13],        # 512
                 ["接待交際費",3],     # 514
                 ["消耗品費",14],      # 517
                 ["資料・教育",20],    # 525
                 ["紹介料",17]  ,      # 526
                 ["雑費",7],           # 531
                ]
  #  3  接待交際費
  #  10 工具器具備品
  #  11  売上
  Karikata_no=[[3, 1], [10, 2], [11, 4]]
  must "selectカスタマイズ用Book::Main " do
    assert_equal 3,Book::Main.where(owner: "dezawa", date: "2000-01-01").count,"カスタマイズ用Book::Mainの数は3"
    assert_equal Karikata_no,
    Book::Main.where(owner: "dezawa", date: "2000-01-01").map{ |book| [book.karikata,book.no]},
    "カスタマイズ用Book::Mainの karikata,no"
      
    assert_equal Karikata_no.map{ |karikata,no| karikata},
    Book::Kamoku.find_with_main("dezawa")[0,3].map(&:id),"カスタマイズされた先頭は"
  end

  must "select用一覧" do
    #puts Book::Kamoku.kamokus.map{|k| "["+k.join(",")+"],"}
    assert_equal KamokuChoise,Book::Kamoku.kamokus("dezawa")
  end

  must "工具器具備品の表示順を 2 から6に変更" do
    zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="工具器具備品"}
    zappi.update_attributes(:no => 6,:book_id=> zappi.book_id)
    new_zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="工具器具備品"}
    assert_equal 6, new_zappi.no
  end
  must "普通預金の表示順を 6 に設定" do
    kamoku = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="普通預金"}
    #pp zappi
    kamoku_book = ""
    kamoku.update_attributes(:no => 6,:book_id=> "dezawa")
    new_kamoku_book = Book::Main.find_by(date: "2000/1/1",karikata: kamoku.id)
    assert_equal 6, new_kamoku_book.no
    assert_equal 6, 
    Book::Kamoku.find_with_main("dezawa").select{ |kmk| kmk.id ==  kamoku.id}.first.no
  end

  must "SQL" do
    kamokus = 
      Book::Kamoku.connection.
      select_all(
                 "select  book_kamokus.id as id,code,bunrui,kamoku,no,date "+
                 " from book_kamokus left join book_mains on book_kamokus.id=book_mains.kasikata "+
                 " where (book_mains.date='2000-01-01' )"
                               )
  end

  must "SQL" do
    kamokus = 
      Book::Kamoku.connection.
      select_all(
                 "select  book_kamokus.id as id,code,bunrui,kamoku,no,date "+
                 " from book_kamokus left join book_mains on book_kamokus.id=book_mains.kasikata "+
                 " where (book_mains.date='2000-01-01' )"
                               )
  end
end
# -*- coding: utf-8 -*-
