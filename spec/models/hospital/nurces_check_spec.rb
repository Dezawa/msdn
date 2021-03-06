# -*- coding: utf-8 -*-
require 'spec_helper'

#class Hospital::NurceChecTest < ActiveSupport::TestCase
describe Hospital::Nurce do
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes","hospital/defines"
  #fixtures "holydays"

    before do
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
    # @save = @nurces.map{ |n| n.monthly(@month);n.shifts}
  end
  def teardown
    # @nurces.each_with_index{ |n,i| n.monthly(@month); n.shifts = @save[i]}
  end


  #######
  def nurce(id); 
    n = Hospital::Nurce.find id
    n.monthly(@month)
    n
  end
  

  #"時廣眞弓さんの先月末月初は '12011__0___'
  # 2日から233勤務を埋め込んだとき、1日に勤務3を入れると:renkinのエラー
  # ~      ^^^                      ^        ^           ^^^^^^
  [[2,"0_111220",3,1,[[:renkin,5]],"6連勤OUT"],
   [2,"0_11120" ,3,1,[],"6連勤OK"],
   [2,"0_20"    ,3,1,[],"勤務間隔12時間以上OK"], #12
   [2,"0_30"    ,3,1,[[:interval,1]],"勤務間隔12時間以上NG"], #13
   [2,"0_10"    ,3,2,[[:interval,1]],"勤務間隔12時間以上NG"], #21
   [2,"0_30"    ,3,2,[],"勤務間隔12時間以上OK"], #23
   [2,"0_10"    ,3,3,[],"勤務間隔12時間以上OK"], #31
   [2,"0_20"    ,3,3,[],"勤務間隔12時間以上OK"], #32
   [2,"0_302302302030203",3,2,[[:nine_nights,true]],"夜勤9回NG"],
   [2,"02_02302302030203",4,3,[[:nine_nights,true]],"夜勤9回NG"],
   [2,"0_30230230202020" ,3,2,[[:junya,true]]     ,"準夜Over"],
   [2,"02_0230230303030" ,4,3,[[:shinya,true]]     ,"深夜Over"],
   [2,"02210"   ,3,2,[[:after_nights,2]],"夜勤連続の翌日公休NG"],
   [2,"03210"   ,3,3,[[:after_nights,2]],"夜勤連続の翌日公休NG"],
   [2,"03310"   ,3,3,[[:after_nights,2]],"夜勤連続の翌日公休NG"],
   [2,"023123102302030203",3,2,[  [:after_nights, 2],[:nine_nights,true],[:renkin, 5]],"エラー満載"],
   #["220",false,:nights,"夜勤連続の翌日公休OK"],
   nil
  ].each{|day0,pat,day,shift,ret,msg|
    next unless day0
    #"時廣眞弓さんの先月末月初は '12011__0___'
    # 今月初期値は "_00_______________________10"
    msg0 ="2/#{day0}から#{pat}勤め,2/#{day} に#{shift} 勤めると#{msg}"
    it  msg0 do
      nurce37 = nurce( 37)
      nurce37.set_shift_days(day0,pat)
      nurce37.set_shift_days(day,shift.to_s)
      assert_equal ret,nurce37.check(day,shift,false).sort,"*****"+msg0
    end
  }
end
__END__

  #"時廣眞弓さんの先月末月初は '12011__0___'
  # 2日から233勤務を埋め込んだとき、1日に勤務3を入れると:renkinのエラー
  # ~      ^^^                      ^        ^           ^^^^^^
  [[2,"0_111220",3,"1",[[:renkin,5]],"6連勤OUT"],
   [2,"0_30"    ,3,"1",[[:interval,1]],"勤務間隔12時間以上NG"], #13
   [2,"0_10"    ,3,"2",[[:interval,1]],"勤務間隔12時間以上NG"], #21
   [2,"0_302302302030203",3,"2",[[:nine_nights,true]],"夜勤9回NG"],
   [2,"0__02302302032023",4,"3",[[:nine_nights,true]],"夜勤9回NG"],
   [2,"0_30230230202020" ,3,"2",[[:junya,true]]     ,"準夜Over"],
   [2,"0__0230230303030" ,4,"3",[[:shinya,true]]     ,"深夜Over"],
   [2,"0_210"             ,3,"2",[[:after_nights,2]],"夜勤連続の翌日公休NG"],
   [2,"0_210"             ,3,"3",[[:after_nights,2]],"夜勤連続の翌日公休NG"],
   [2,"0_310"             ,3,"3",[[:after_nights,2]],"夜勤連続の翌日公休NG"],
   [2,"0_3123102302030203",3,"2",[[:renkin, 5], [:nine_nights, true], [:after_nights, 2]],"エラー満載"],
   #["220",false,:nights,"夜勤連続の翌日公休OK"],
   nil
  ].each{|day0,pat,day,shift,ret,msg|
    next unless day0
    #"時廣眞弓さんの先月末月初は '12011__0___'
    msg0 ="2/#{day0}から#{pat}勤めた時,2/#{day} に#{shift} をassignするのは#{msg}"
    it msg0 do
      nurce37 = nurce( 37)
      nurce37.set_shift_days(day0,pat)
      assert_equal [],ret-nurce37.check_at_assign(day,shift,false),"*****"+msg0
    end
  }

  [[2,"0_11120" ,3,"1",nil,"6連勤OK"],
   [2,"0_20"    ,3,"1",nil,"勤務間隔12時間以上OK"], #12
   [2,"0_30"    ,3,"2",nil,"勤務間隔12時間以上OK"], #23
   [2,"0_10"    ,3,"3",nil,"勤務間隔12時間以上OK"], #31
   [2,"0_20"    ,3,"3",nil,"勤務間隔12時間以上OK"], #32
   nil
  ].each{|day0,pat,day,shift,ret,msg|
    next unless day0
    #"時廣眞弓さんの先月末月初は '12011__0___'
    msg0 ="2/#{day0}から#{pat}勤めた時,2/#{day} に#{shift} をassignするのは#{msg}"
    must msg0 do
      nurce37 = nurce( 37)
      nurce37.set_shift_days(day0,pat)
      assert_equal nil,nurce37.check_at_assign(day,shift,false),"*****"+msg0
    end
  }

  # [勤務初期値  , 割当日 ,勤務,成否,[抵触reguration ] ,msg]    
  #12345678901234567890
  [  ["000000000_111110000"         ,10,"3",true,[:renkin],"2/10への3は連勤に抵触-1"],
     ["000000011_1110000"           ,10,"3",true,[:interval,:renkin],"2/10への3は連勤に抵触-2"],
     ["000000001_1100000"           ,10,"3",true,[:interval],"2/10への3は勤務間隔12時間以上に抵触"],
     ["002203302_0200011_1110020"   ,10,"2",true,[:junya],"2/10への2は準夜制限に抵触"],
     ["003302203_0300011_1110300"   ,10,"3",true,[:shinya],"2/10への3は深夜制限に抵触"],
     ["220111220_301112201330111101",10,"3",true,[:nine_nights],"2/10への3は夜勤数に抵触"],
     nil
  ].each{|init,day,shift,ret,val,msg|
    next unless init
    it  "勤務初期値 #{init} で #{day}日に勤務#{shift}をいれると"+msg do
      #uts "勤務初期値 #{init} で #{day}日に勤務#{shift}をいれると"+msg
      nurce=nurce 44
      init.split("").each_with_index{|sft,d| nurce.set_shift(1+d,sft)}
      check = nurce.check_at_assign(day,shift,false)
      
      assert_equal [msg,val],[msg,check ? check.map{|c| c.first}.sort_by{|s| s.to_s} : nil]
    end
  }

  # [勤務初期値  , 割当日 ,勤務,成否,[抵触reguration ] ,msg]    
  #12345678901234567890
  #    ..330110220.
  LP = Hospital::Nurce::LongPatern[true]
  [  ["00__________0000000000111110000",3,"3" ,LP["3"][0],true,[:renkin],"2/3へ3はlongpatern9"],
     ["00_______2__0000000000111110000",3,"3" ,LP["3"][0],true,[:renkin],"2/3へ3はlongpatern9"],
     ["00___2___2__0000000000111110000",3,"3" ,LP["3"][0],true,[:renkin],"2/3へ3はlongpatern3"],
     ["00_31122__2__0000000000111110000",3,"3",LP["3"][0],false,[[:after_nights, 2]],"2/3へ3はlongpatern3"],
     ["00__１____2__0000000000111110000",3,"3",LP["3"][2],true,[:renkin],"2/3へ3はlongpaternなし"],
     ["00_______2__0033000000111110000" ,3,"3",LP["3"][0],true,[:renkin],"2/3へ3はlongpatern9"],
     ["00__1____2__00330003000111110000",3,"3",LP["3"][2],true,[:renkin],"2/3へ3はlongpatern"],
     #   220330110       
     ["00__________00330000000111110000",3,"2",LP["2"][0],true,[:renkin],"2/3へ2はlongpatern"],
     ["00_______1__0000000000111110000" ,3,"2",LP["2"][0],true,[:renkin],"2-2"],
     ["00_______2__0000000000111110000" ,3,"2",LP["2"][0],true,[:renkin],"2-3"],
     ["00___2___2__0000000000111110000" ,3,"2",LP["2"][1],true,[:renkin],"2-4"],
     ["00_31122__2__0000000000111110000",3,"2",LP["2"][3],false,[[:after_nights, 2]],"2-5"],
     ["00__１____2__0000000000111110000",3,"2",LP["2"][3],true,[:renkin],"2-6"],
     ["00_______2__0033000000111110000" ,3,"2",LP["2"][0],true,[:renkin],"2-7"],
     nil
  ].each{|init,day,sft_str,long_patern,ret,err,msg|
       next unless init
       must "勤務初期値 #{init} で #{day}日に勤務#{sft_str}で長い割り当てをいれる(#{msg})" do
      nurce=nurce 44
      nurce.shifts[1,init.size] = init
      check = nurce.long_check(day,sft_str,long_patern,false)
      assert_equal ret,!!check[0]
    end
  }

  #######
  def nurce(id); 
    n = Hospital::Nurce.find id
    n.monthly(@month)
    n
  end
  

end
# -*- coding: utf-8 -*-
