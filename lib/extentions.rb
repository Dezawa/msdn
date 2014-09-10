# -*- coding: utf-8 -*-
class Array
  # 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15 の順に並んでいる配列を
  # re_order_by_column(count)
  # 例えばcount=3 のとき
  # 下の順に並べ替える  6行=16/3 ceil
  # 0, 6, 12
  # 1, 7, 13,
  # 2, 8, 14, 
  # 3, 9, 15, 
  # 4, 10, nil, 
  # 5, 11, nil,
  #
  # re_order_by_line(count)
  # 1 4 7 10 13 16
  # 2 5 8 11 14
  # 3 6 9 12 15
  # 
  # 
  # 
  # 
#class Array
  def re_order_by_column(count)
    lines = (size.to_f/count).ceil
    (0..lines-1).map{ |c| (c..lines*count-1).step(lines).map{ |i| self[i]}}.flatten(1)
  end
  def re_order_by_line(count)
    clmns = (size.to_f/count).ceil
    (0..count-1).map{ |c| (c..clmns*count-1).step(count).map{ |i| self[i]}}.flatten(1)
  end
end
