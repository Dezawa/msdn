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
           [3, 5, 514, "接待交際費", 1, 184],
           [5, 5, 510, "水道光熱費", 2, 185],
           [1, 5, 522, "利子割引料", 3, 183],
           [11, 4, 410, "売上", 4, 195], 
           [18, 0, 0, "開始残高", nil, "dezawa"],
           [16, 2, 280, "事業主借", nil, "dezawa"],
           [22, 1, 100, "現金", nil, "dezawa"], 
           [6, 1, 110, "普通預金", nil, "dezawa"],
           [8, 1, 140, "受取手形", nil, "dezawa"],
           [23, 1, 150, "売掛金", nil, "dezawa"], 
           [24, 1, 160, "棚卸資産", nil, "dezawa"],
           [10, 1, 180, "工具器具備品", nil, "dezawa"], 
           [12, 1, 190, "事業主貸", nil, "dezawa"], 
           [2, 2, 210, "未払金", nil, "dezawa"], 
           [25, 2, 270, "買掛金", nil, "dezawa"],
           [4, 3, 310, "元入金", nil, "dezawa"], 
           [26, 4, 420, "雑収入", nil, "dezawa"],
           [27, 4, 430, "自家消費", nil, "dezawa"],
           [21, 5, 508, "租税公課", nil, "dezawa"],
           [15, 5, 509, "荷造運賃", nil, "dezawa"],
           [28, 5, 510, "仕入", nil, "dezawa"], 
           [19, 5, 511, "旅費交通費", nil, "dezawa"],
           [13, 5, 512, "通信費", nil, "dezawa"], 
           [14, 5, 517, "消耗品費", nil, "dezawa"],
           [29, 5, 518, "減価償却費", nil, "dezawa"], 
           [30, 5, 523, "地代家賃", nil, "dezawa"], 
           [20, 5, 525, "資料・教育", nil, "dezawa"],
           [17, 5, 526, "紹介料", nil, "dezawa"], 
           [7, 5, 531, "雑費", nil, "dezawa"] 
         ]

  KamokuChoise= [["接待交際費", 3],
                 ["水道光熱費", 5],
                 ["利子割引料", 1],
                 ["売上", 11],
                 ["開始残高", 18],
                 ["現金", 22],
                 ["普通預金", 6],
                 ["受取手形", 8],
                 ["売掛金", 23],
                 ["棚卸資産", 24],
                 ["工具器具備品", 10],
                 ["事業主貸", 12],
                 ["未払金", 2],
                 ["買掛金", 25],
                 ["事業主借", 16],
                 ["元入金", 4],
                 ["雑収入", 26],
                 ["自家消費", 27],
                 ["租税公課", 21],
                 ["荷造運賃", 15],
                 ["仕入", 28],
                 ["旅費交通費", 19],
                 ["通信費", 13],
                 ["消耗品費", 14],
                 ["減価償却費", 29],
                 ["地代家賃", 30],
                 ["資料・教育", 20],
                 ["紹介料", 17],
                 ["雑費", 7]
                ]
