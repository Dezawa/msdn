# -*- coding: utf-8 -*-
require 'test_helper'

class Book::BookMainTest < ActiveSupport::TestCase
 fixtures "book/kamokus","book/mains"
  Kamoku =[
           ["元入金"     , 1   ],
           ["雑費"       , 2   ],
           ["未払金"     , 3   ],
           ["消耗品費"   , 4   ],
           ["開始残高"   , nil ],
           ["普通預金"   , nil ],
           ["受取手形"   , nil ],
           ["工具器具備品", nil ],
           ["事業主貸"   , nil ],
           ["事業主借"   , nil ],
           ["売上"      , nil ],
           ["荷造運賃"   , nil ],
           ["旅費交通費"  , nil ],
           ["通信費"     , nil ],
           ["通信費"     , nil ],
           ["接待交際費"  , nil ],
           ["資料・教育"  , nil ]
  ]
  must "選択肢に出て来る課目一覧の順番"  do
    kamoku= Book::Kamoku.new
    #puts Book::Kamoku.all.map{|k| [k.id,k.code,k.bunrui,k.kamoku].join(",")}
    assert_equal Kamoku,
    Book::Kamoku.find_with_main("dezawa").map{|k| [k.kamoku,k.no]},
    "選択肢に出て来る課目一覧の順番,Arrayは 科目、順番"
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
