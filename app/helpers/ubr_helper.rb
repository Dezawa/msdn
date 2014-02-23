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

 def waku_block_header
   list = [2,[2,"枠名後半"],[2,"対倉庫相対位置"],[2,"ブロック名相対位置対ブロック"] ]
   row = "<tr>"
   lbl_idx=0
   list.each_with_index{|style,idx|
     case style
     when Integer   ;
       (1..style).each{
         row += "<td rowspan=2>#{@labels[lbl_idx].label}</td>"
         lbl_idx += 1
       }
     when Array; 
       row += "<td colspan=#{style[0]}>#{style[1]}</td>"
       lbl_idx += style[0]
     end
   }
   row += "</tr>\n"
   lbl_idx=0
   list.each_with_index{|style,idx|
     case style
     when Integer   ;        lbl_idx += style
     when Array; 
       (1..style[0]).each{
         row += "<td>#{@labels[lbl_idx].label}</td>"
         lbl_idx += 1
       }
     end
   }
   return row
 end
 
  def html_index(key)
    key.map{ |v| "<td align=right>#{v}</td>" }.join
  end

end
