# -*- coding: utf-8 -*-
# うどんのシマダヤ

class Shimada::Controller <  CommonController #ApplicationController
  #before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  #before_filter(:except => :error) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
 
  def set_instanse_variable
    super
    if @factory_id = session[:shimada_factory] 
      @factory    = Shimada::Factory.find @factory_id
    else
      @factory = Shimada::Factory.find_by(name: "GMC")
      @factory_id = @factory.id
    end
  end

end
