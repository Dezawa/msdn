# -*- coding: utf-8 -*-
class Sola::Controller < CommonController 
  Links =
    [
     Menu.new(   "日々データ",:dayly   ,:action => :index) ,
     Menu.new(   "月データ"  ,:monthly ,:action => :index) ,
    ]

  def set_instanse_variable
    @Links = Links
  end

end
