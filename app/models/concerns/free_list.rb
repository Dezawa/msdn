# -*- coding: utf-8 -*-
class FreeList
  delegate :logger, :to=>"ActiveRecord::Base"
  attr_accessor :freeList,:hozenFree
  def initialize(real_ope,time_from_to,skd)#holydays,maintains)
    @real_ope = real_ope
#pp time_from_to
    @freeList=[time_from_to.dup]#[[time_from,time_to]]
    @time_from,@time_to = time_from_to
    @skd=skd
    assign_holyday skd.holydays[real_ope]
    assign_kyuuten skd.maintain[real_ope]
    @hozenFree = FreeListHozen.new(real_ope,time_from_to,skd)#,holydays,maintains)
    #add_kyuuten 
  end
  def freetime ; @freeList.inject(0){|s,free| s += free[1]-free[0]} ;end
  def map ; @freeList.map ;end
  def each; @freeList.each ;end
  def compact! ;@freeList.compact! ;end
  def sort! ;  @freeList.sort! ;end
  def [](idx) ; @freeList[idx] ;end
  def []=(idx,a);@freeList[idx]=a;end
  def size ;@freeList.size;end
  def insert(idx,v);@freeList.insert(idx,v);end
  def <<(v) ; @freeList << v ; end
  def freeList; @freeList; end
  #def inspect ; @freeList.inspect ;end
  #def self ; @freeList;end
  #指定された工程の、指定された時刻以降の、指定された長さが可能な時間帯を探す
  # <tt>real_ope</tt> :: 工程
  # <tt>start</tt> :: この時刻以降の空き時間を探す
  # <tt>periad</tt> :: この長さの空き時間を探す
  # <tt>is_hozen</tt> ::  nil: @FreeList から探す:製造
  #                   ::  true @freelist から探す:保守
  # 
  #           f         t　　　　 空き時間の from,to
  #       <-->                    前に外れているときは、fromから割り当てて試す
  #         <---<---------<-->    指定時刻がいつから始まろうと、指定終了時刻が to より後だと NG
  #         <------->　　　　　 　指定時刻がfromより前の時は、fromから割り当てて試す
  #             <------->　　　　 すっぽり収まるときは OK
  def searchfree(start,periad,is_hozen=nil)
    return hozenFree.searchfree(start,periad) if is_hozen
    freeList.each{|free| from,to = free
      #  指定時刻がいつから始まろうと、指定終了時刻が to より後だと NG
      #       期間終 < 終了        期間開始からの長さ不足
      next if to < start+periad || to < from + periad

      #  fromからでもstartからでも、後ろに出ないのは確認済
      #  from start の遅い方から始めれば、OK
      s = from <= start ? start : from
      return [ s,s+periad]
    }
    return nil
  end
  #####################################################################
  # 与えられた時刻から始まる、連続した製造可能空き時間を返す
  # あれば start,stop  無いときは nil
  def rest_time(start)
    #logger.debug("rest_time #{@real_ope} start #{start.mdHM} \n"+
    #             "#{freeList.map{|se| se.map{|t| t.mdHM}.join('-')}.join(' ')}")
    freeList.select{|free| free[0]<= start && start <= free[1]}[0]
  end

  # free list から指定の領域を削除する
  #   オプショナルパラメータ conditionにより、
  #   抄造の特別扱いを行う
  # 
  #         |====================|  free エリア
  # 　a←   b←    c←           d←  e←  指定領域の始まり
  #  →E  →D             →C  →B  →A    指定領域の終わり
  #
  #          指定領域の始まり
  #         start<=e
  #           a  b   c   d   e
  #  終  A   @@@@@@ *** XXXXXXX      X 範囲外
  #  わ  B   @@@@@@ *** XXXXXXX      @ この free はなくなった。
  #  り  C   ****** === XXXXXXX      * 前半または後半が残る
  #      D   XXXXXXXXXXXXXXXXXX      = 二つに分かれる
  #      E   XXXXXXXXXXXXXXXXXX
  #
  #ope :: real_ope、=> :shozow,:shozoe,:yojo,:dryo,:dryn,:kakou
  #condition ::  nil => @Freeも@freeも両方反映、
  #              true=> @freeには反映しない。初期化の終業始業の割り当てにのみ使う
  def assignFreeList(start,stop)
    remove_skd_from_freelist(start,stop)
    hozenFree.remove_skd_from_freelist(start,stop)
  end
  def remove_skd_from_freelist(start,stop)
    logger.debug("\nremove_skd_from_freelist #{start}-#{stop}\n")
    #lists.each_with_index{|free,indx|  # @freelist と freeList についてやる
    free_size = @freeList.size
    (1..free_size).each{|idx| f_idx = free_size - idx #each_with_index{|fr,f_idx| s,e = fr 
      s,e = fr = @freeList[f_idx]
      next if (stop <= s || e <= start)  # 完全に外れてる  de,DE
      case [start <= s , e <= stop]
      when [true,true]   ; @freeList.delete_at(f_idx)     # ab,AB 完全に範囲に入ってる。削除
      when [true,false]  ; @freeList[f_idx]    = [stop,e] # ab,C  後半だけ残る
      when [false,true]  ; @freeList[f_idx][1] = start #  = [s,start]  ;# c ,AB 前半が残る
      else    # c ,C
        @freeList[f_idx][1] = start
        @freeList.insert(f_idx+1,[stop,e])
      end
    }
    #}
    self
  end
  def assign_holyday holyday
    holyday.each{|start,stop,type|  remove_skd_from_freelist(start,stop) }
  end

  def assign_kyuuten( maintains)
    maintains.each{|plan_start,plan_end,maintain|
      remove_skd_from_freelist(plan_start,plan_end) 
    }
  end

  def add_kyuuten( maintains)
    maintains.each{|plan_start,plan_end,maint|
      @freeList<<[plan_start,plan_end]
    }
    @freeList.sort!{|a,b| a[0]<=>b[0]}
    @freeList[1..-1].each_with_index{|fl,idx|
      if @freeList[idx][1] >= fl[0]
        fl[0]=@freeList[idx][0]
        fl[1]=@freeList[idx][1] if @freeList[idx][1] >= fl[1]
        @freeList[idx] = nil
      end 
    }
    @freeList.compact!
  end

end

class FreeListShozo < FreeList
  def initialize(real_ope,time_from_to,skd)#holydays,maintains)
    @real_ope = real_ope
#pp time_from_to
    @freeList=[time_from_to.dup]#[[time_from,time_to]]
    @time_from,@time_to = time_from_to
    @skd=skd
    assign_holyday skd.holydays[real_ope]
    assign_kyuuten skd.maintain[real_ope]
    @hozenFree = FreeListHozenShozo.new(real_ope,time_from_to,skd)
    #add_kyuuten 
  end

  def assign_holyday(holydays)
    holydays.each{|start,stop,type|
      remove_skd_from_freelist(start,stop) 
      remove_skd_from_freelist(start-@skd.ending(@real_ope,type),start)#,freeList[real_ope])
      remove_skd_from_freelist(stop,stop+@skd.starting(@real_ope,type))#,freeList[real_ope])
    }
  end

end

class FreeListHozen < FreeList
  attr_accessor :freeList
  def initialize(real_ope,time_from_to,skd)#,holydays,maintains)
#pp time_from_to
    @real_ope = real_ope
    @freeList=[time_from_to]#[[time_from,time_to]]
    @time_from,@time_to = time_from_to
    assign_holyday skd.holydays[real_ope]
    assign_kyuuten skd.maintain[real_ope]
    add_kyuuten  skd.maintain[real_ope]
  end
  def searchfree(start,periad)
    freeList.each{|free| from,to = free
      #  指定時刻がいつから始まろうと、指定終了時刻が to より後だと NG
      #       期間終 < 終了        期間開始からの長さ不足
      next if to < start+periad || to < from + periad

      #  fromからでもstartからでも、後ろに出ないのは確認済
      #  from start の遅い方から始めれば、OK
      s = from <= start ? start : from
      return [ s,s+periad]
    }
    return nil
  end
end
class FreeListHozenShozo < FreeListHozen
  attr_accessor :freeList

  def assign_holyday(holydays)
    holydays.each{|start,stop,type| next if type == 4
       remove_skd_from_freelist(start,stop) 
    }
  end
end

class FreeListYojo < FreeList
  def remove_skd_from_freelist(start,stop);return;end
  def searchfree(start,periad,is_hozen=nil) ; return [start,start+periad] ;end
  def holydays;[]; end
  def assign_holyday( holydays);end
  def assign_kyuuten( holydays);end
  def add_kyuuten( holydays);end
  def maintains; end
end
