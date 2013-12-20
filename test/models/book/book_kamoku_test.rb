# -*- coding: utf-8 -*-
require 'test_helper'

class Book::BookKamokuTest < ActiveSupport::TestCase
 fixtures "book/kamokus","book/mains"
  Kamoku =[
           [ 3,3,310,"元入金",1, 84],
           [ 5,5,590,"雑費", 2, 85],
           [ 1,2,210,"未払金",3, 83],
           [11,5,565,"消耗品費",4, 95],
           [18,0,  0,"開始残高", nil, "dezawa"],
           [ 4,1,110,"普通預金", nil, "dezawa"],
           [ 6,1,140,"受取手形", nil, "dezawa"],
           [ 7,1,180,"工具器具備品", nil, "dezawa"],
           [ 9,1,190,"事業主貸", nil, "dezawa"],
           [16,2,280,"事業主借", nil, "dezawa"],
           [ 8,4,410,"売上", nil, "dezawa"],
           [12,5,525,"荷造運賃", nil, "dezawa"],
           [19,5,535,"旅費交通費", nil, "dezawa"],
           [10,5,540,"通信費", nil, "dezawa"],
           [13,5,540,"通信費", nil, "dezawa"],
           [ 2,5,560,"接待交際費",nil, "dezawa"],
           [20,5,589,"資料・教育",nil, "dezawa"]
  ]
  must "課目一覧"  do
    kamoku= Book::Kamoku.new
    #puts Book::Kamoku.all.map{|k| [k.id,k.code,k.bunrui,k.kamoku].join(",")}
    assert_equal_array Kamoku,Book::Kamoku.find_with_main("dezawa").
      map{|k| [k.id,k.code,k.bunrui,k.kamoku,k.no,k.book_id]}
  end

  KamokuChoise= [
                 ["元入金",3],
                 ["雑費",5],
                 ["未払金"  ,1],
                 ["消耗品費",11],
                 ["開始残高",18],
                 ["普通預金",4],
                 ["受取手形",6],
                 ["工具器具備品",7],
                 ["事業主貸",9],
                 ["事業主借",16],
                 ["売上",8],
                 ["荷造運賃",12],
                 ["旅費交通費",19],
                 ["通信費",10],
                 ["通信費",13],
                 ["接待交際費",2],
                 ["資料・教育",20]
                ]

  must "select用一覧" do
    #puts Book::Kamoku.kamokus.map{|k| "["+k.join(",")+"],"}
    assert_equal KamokuChoise,Book::Kamoku.kamokus("dezawa")
  end

  must "雑費のy表示順を 2 から6に変更" do
    zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="雑費"}
    zappi.update_attributes(:no => 6,:book_id=> zappi.book_id)
    new_zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="雑費"}
    assert_equal 6, new_zappi.no
  end
  must "普通預金の表示順を 6 に設定" do
    zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="普通預金"}
    #pp zappi
    zappi_book = ""
    zappi.update_attributes(:no => 6,:book_id=> "dezawa")
    new_zappi = Book::Main.find_by_date_and_karikata("2000/1/1",4)
    assert_equal 6, new_zappi.no
  end

  must "SQL" do
    kamokus = 
      Book::Kamoku.connection.
      select_all(
                 "select  book_kamokus.id as id,code,bunrui,kamoku,no,date "+
                 " from book_kamokus left join book_mains on book_kamokus.id=book_mains.kasikata "+
                 " where (book_mains.date='2000-01-01' )"
                               )
    #pp kamokus#.map{|k| [k.id,k.code,k.bunrui,k.kamoku,k.no,k.book_id]}
    #pp Book::Main.find(:all,:conditions => "date='2000/01/01'")
  end
end
# -*- coding: utf-8 -*-
