# -*- coding: utf-8 -*-
class Function::Maintain
  attr_accessor  :periad,:hozen_code_list
  def initialize(hozendata) #(periad,hozen_code_list)
    @periad         = hozendata[0] || 0 #periad
    @hozen_code_list = hozendata[1]|| []  #hozen_code_list
  end

  def self.null
    self.new([0,[nil]])
  end

  def self.hozen_data(hozen,real_ope=nil)
    @hozen_data ||= Hash.new
    unless @hozen_data[[hozen,real_ope]]
      hozencode = UbeProduct.hozen_code(hozen,real_ope)
      @hozen_data[[hozen,real_ope]] = 
        hozencode ? self.new([UbeOperation.hozen_periad[hozencode],[hozencode[0]]]) : 
        self.null #[0,[nil],nil]
    end
    @hozen_data[[hozen,real_ope]]
  end


  def arranged_code
    return ["切替"] if @hozen_code_list.size ==0
    if (@hozen_code_list & UbeSkd.named_mult).size >0
      @hozen_code_list & UbeSkd.named_mult
    else
      @hozen_code_list
    end
  end

  def longer(other)
    ret = Function::Maintain.null
    ret.periad = [self.periad,other.periad].max
    ret.hozen_code_list = (@hozen_code_list + other.hozen_code_list).compact
    ret
  end
  def to_a
    [@periad, @hozen_code_list]
  end

  def +(other)
    ret = Function::Maintain.null
    ret.periad = self.periad+other.periad
    ret.hozen_code_list = (self.hozen_code_list + other.hozen_code_list).compact
    ret.hozen_code_list = [nil] if ret.hozen_code_list == []
    ret
  end
end
