# -*- coding: utf-8 -*-

class HtmlProname < HtmlSelect
  def initialize(args={})
    super(:product_id ,"製品名",args)
  end
  def disp(object)
    object.proname.to_s
  end
  def edit(domain,obj,controller,opt)
    return disp(obj) unless obj.ube_product && !obj.ube_product.hozen
     @choices= Ube::Product.products
    super 
  end
end
