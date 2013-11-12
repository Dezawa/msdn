# -*- coding: utf-8 -*-
module UbrHelper
  def volume_list(waku_by_volume_occupied)
    waku_by_volume_occupied.keys.sort.uniq
  end

  def waku_count(waku_by_volume_occupied,key)
    waku_by_volume_occupied[key].values.inject(0){ |sum,waku_list| sum + waku_list.size}
  end

  def html_occupy(waku_by_volume_occupied,key )
    waku_by_occupied = waku_by_volume_occupied,[key]
    (0..10).map{ |occu|
      count = (waku_by_volume_occupied[key][occu]||[]).size
      case count
      when 0;  "<td>0</td>"
      else  ; "<td align=right>"+
          link_to( count,
                   :action => "detail_"+key.join("_") +"_"+occu.to_s)+
          "</td>"
      end
    }.join
  end

  def html_index(key)
    key.map{ |v| "<td align=right>#{v}</td>" }.join
  end

end
