# -*- coding: utf-8 -*-

Users = %w(dezawa  aaron     quentin    ubeboard  guest  testuser old_password_holder)
Permissions =  [TTT,TTF,FFF,TTF,TFF,TFF,FFF]

  def book_create( option = {})
    attr = {
      date: "2013/10/10",   amount: 1010 , karikata: 1, kasikata: 2,
      tytle: "売上"      ,memo: nil, owner: "dezawa"
    }.merge(option)
    Book::Main.create attr
  end
  def book_this_year
    Book::Main.this_year_of_owner("dezawa",Time.local(2012,1,1))
  end

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
