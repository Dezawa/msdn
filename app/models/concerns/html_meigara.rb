# -*- coding: utf-8 -*-

class HtmlMeigara < HtmlSelect
  def initialize(args={})
    super(:meigara        ,"銘柄",args)
  end
  def disp(object)
    object.meigara.to_s
  end
  def edit(domain,obj,controller,opt)
    return "　" unless obj.ube_product && !obj.hozen?
    opt[:value] = obj.meigara
    opt[:include_blank]=true
     @choices= Ube::Meigara.meigaras[obj.ube_product.ope_condition]<<obj.meigara
     @choices =  @choices.uniq
    super #select( domain,:meigara,choices(obj),opt)
  end
end
