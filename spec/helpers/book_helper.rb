# -*- coding: utf-8 -*-

Users = %w(dezawa  aaron     quentin    ubeboard  guest  testuser old_password_holder)
Permissions =  [TTT,TTF,FFF,TTF,TFF,TFF,FFF]


  URL_permit    = "/msg_book_permit.html"
  URL_error   = "/book/keeping/error"

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
           [20,5,589,"資料・教育",nil, "dezawa"],
           [14, 5, 580, "消耗品", nil, "dezawa"],
           [21, 5, 580, "租税公課", nil, "dezawa"]
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
