# -*- coding: utf-8 -*-
class Hospital::Const
  class Selection
    attr_accessor :id,:name
    def initialize(id0,name0)
      @id = id0
      @name = name0
    end
  end 

  Idou =  [["新人",1],["中途",2],["異動",3]]
  Shokui = [[ "看護師長",1],["主任",2]]

  Shokushu = [
    [ "看護師",  1 ],
    [ "準看護師",2 ],
    [ "看護助手",3 ]
  ]

  Kinmukubun = [
     [ "日勤",  1 ],
     [ "三交代",2 ],
     [ "二交代",8 ],
     [ "パート",3 ],
     [ "透析",  4 ],
     [ "L勤",   5 ],
     [ "外来",  6 ],
     [ "共通",  7 ]
  ]

  Daytype = [ ["毎日",1],["平日",2],["土日休",3]]

  Timeout     = 4.minute
  TimeoutMult = 3.minute
  Sleep       = 30
end
