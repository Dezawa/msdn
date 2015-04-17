# -*- coding: utf-8 -*-
# うどんのシマダヤ

class Shimada::Controller <  CommonController #ApplicationController
  include Actions
  #before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  #before_filter(:except => :error) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
   Links =
    [
     Menu.new(   "工場一覧"  ,"shimada/factory"    , :action => :index ) ,
     Menu.new(   "測定器一覧","shimada/instrument" , :action => :index) ,
     Menu.new(   "電池残量"  ,"status/tand_d" ,
              { :action => :list,:controller => "status/tand_d"}) ,
    ]

  def set_instanse_variable
    super
    @Links = Links
    if @factory_id = session[:shimada_factory] 
      @factory    = Shimada::Factory.find @factory_id
    else
      @factory = Shimada::Factory.find_by(name: "GMC")
      @factory_id = @factory.id
    end
  end

end
