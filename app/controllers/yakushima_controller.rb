# -*- coding: utf-8 -*-
# 複式簿記

class YakushimaController <  ApplicationController
  #include BookPermit
  #before_filter :login_required 
  before_filter :login_required 
  before_filter {|ctrl| ctrl.set_permit %w(屋久島 屋久島 屋久島)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
 
  def set_instanse_variable
    @jpegs = Dir.glob(RAILS_ROOT+"/public/images/YAKUSHIMA/CA3E*jpg").map{|f| File.basename f}
    @thims = @jpegs.map{|f| f.downcase }
    @dir = "/images/YAKUSHIMA/"
  end

  def index
    
  end

end
