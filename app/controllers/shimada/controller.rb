# -*- coding: utf-8 -*-
# うどんのシマダヤ

class Shimada::Controller <  ApplicationController
  #before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  #before_filter(:except => :error) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
 
  def set_instanse_variable
    super
    @factory = session[:shimada_factory] || "GMC"
  end

end
