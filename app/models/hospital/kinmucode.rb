# -*- coding: utf-8 -*-
#  code   ::             
#  kinmukubun_id   ::  
#  with_mousiokuri   ::  
#  main_daytime   ::  
#  main_nignt   ::  
#  sub_daytime   ::  
#  sub_night   ::  
#  name   ::  
#  color   ::  
#  start   ::  
#  finish   ::  
#  main_next   ::  
#  sub_next   ::  
#  daytime   ::  
#  night   ::  
#  midnight   ::  
#  daytime2   ::  
#  night2   ::  
#  midnight2   ::  
#  nenkyuu"
require 'pp'
class Hospital::Kinmucode < ActiveRecord::Base
  extend Function::CsvIo
  include Hospital::Const
  set_table_name 'hospital_kinmucodes'
  #belongs_to :kinmukubun,:class_name => "Hospital::inmukubun"
  @@From_0123 = nil

  CodeSym = { 
    :Nenkyu => "N", :Osode => "△", :Sankyu => "A" ,    :Ikukyu => "C" ,
    :Koukyu =>"0"  , :L2  => "L2", :L3  => "L3", :Night  => "夜" , :Ake => "明"
  } 

  # test:units のとき、load fixtures の前にここが実行されるので、
  # その時の番兵
   SymVal = { 
    :Nenkyu => 71 , :Osode => [8,9], :Sankyu => 79 ,    :Ikukyu => 74 ,
    :Koukyu => 67  , :L2  => 4, :L3  => 5, :Night  => 82 , :Ake => 81
  } 
  @@Code = { }
  def self.code(sym)
    @@Code[sym] ||= self.find_by_code(CodeSym[sym]).id rescue SymVal[sym]
  end

  Kubun=  Hash[*[:nikkin,:sankoutai,:part,:touseki,:l_kin,:gairai,:kyoutuu].
    zip([1,2,3,4,5,6,7]).flatten]

#Hospital::Kinmucode::From0123, To0123 の見直し
#  例えば出張は1日n勤務だが病棟の勤務人数集計ではゼロ。これに対応する
#  shiftの表記が　十進の数字だったがこれを16進数の数字に変える
  @@from123 = Hash.new{ |h,k| h[k]= Hash.new{ |h,k| h[k]=nil}}
  ToFrom0123 = 
   {  
  # [nenky,am, pm, night,mid,  am2, pm2,nig2,midnight2]
    [1.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0] => "0" , #  休み系  公年代欠勤
    [0.0,  0.5, 0.5, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0] => "1" , # 日勤 1 会 □ △ 4 
    [0.0,  0.0, 0.0, 1.0, 0.0,  0.0, 0.0, 0.0, 0.0] => "2" , # 準夜、L2          
    [0.0,  0.0, 0.0, 0.0, 1.0,  0.0, 0.0, 0.0, 0.0] => "3" , # 深夜  L3          
    [0.0,  0.0, 0.0, 0.0, 0.0,  0.5, 0.5, 0.0, 0.0] => "4" , # 出 イ１ H1 R1  J1 
    [0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 1.0, 0.0] => "5" , # 管    イ２ H2 R2
    [0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 1.0] => "6" , # イ３ H3 R3
    [0.0,  0.5, 0.0, 0.0, 0.0,  0.0, 0.5, 0.0, 0.0] => "7" , # AM勤務 1/出  1/セ  Z/R Z/出
    [0.0,  0.0, 0.5, 0.0, 0.0,  0.5, 0.0, 0.0, 0.0] => "8" , # PM勤務 出/1 出/G R/G
    [0.5,  0.0, 0.5, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0] => "9" , # Z
    [0.5,  0.5, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0] => "A" , # G
    [0.5,  0.0, 0.0, 0.0, 0.0,  0.0, 0.5, 0.0, 0.0] => "B" , # 
    [0.5,  0.0, 0.0, 0.0, 0.0,  0.5, 0.0, 0.0, 0.0] => "C" , # 
    [0.0,  0.0, 0.0, 0.0, 0.0,  0.0, 0.0, 0.0, 0.0] => "F"   # ▲ 遅 早 外
   }                              
                                  
  From0123 = ToFrom0123.invert

  @@KCode = Hash[*self.all.map{ |kc| [kc.id,kc]}.flatten]
  def self.k_code(id)
    @@KCode[id] ||= self.find(id)
  end

  @@Code = Hash[*@@KCode.to_a.map{ |id,kcode| [id,kcode.code]}.flatten]
  def self.id2code(id)
    @@Code[id]
  end

  def self.sanchoku
    @@sanchoku ||= Hospital::Role.find_by_name("三交代").id
  end


  # 割振りを休日準深勤務に応じ　0123　に置き換える。以外は　nil
  def to_0123
    ToFrom0123[[nenkyuu,am,pm,night,midnight,am2,pm2,night2,midnight2]]
  end

  # 0123 と 5 から勤務コードを得る。
  #  46789ABCDEFに対応は不要。自動では割り振らないから。
  #  ただし、3直の 2→L2、 3→L3、二直の 2→夜, 0→明 は入れ替える
  #  これらは      L       M             N      O に置き換えられているはず
  def self.from_0123(shift,kinmukubun_id)
    @@from123[shift][kinmukubun_id] ||=
      case shift
      when "2","3" ; return shift.to_i
      when "0"     ; return code(:Koukyu)
      when "L","M" ; 
        return Hospital::Kinmucode.find_by_code_and_kinmukubun_id({"L"=>"L2","M"=>"L3"}[shift],sanchoku).id
      when "N","O" ; 
        code = {"N"=>"夜","O"=>"明"}[shift]
        #puts code
        return Hospital::Kinmucode.find_by_code(code).id
      when "1","5"
        value = From0123[shift] ||  [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        Hospital::Kinmucode.all(:conditions => ["(kinmukubun_id=? or kinmukubun_id= #{Kubun[:kyoutuu]})"+
                                                " and nenkyuu=? and am=? and pm=? and "+
                                                "night=? and midnight=? and am2=? and "+
                                                "pm2=? and night2=? and midnight2=? ",
                                                kinmukubun_id,*value]
                                )[0].id
      else ; nil
      end

    #Hospital::Kinmucode.all(:conditions => [""])
  end

  def self.from_0123_old(shift,kinmukubun_id)
    { Kubun[:nikkin]   => { "0" => Hospital::Kinmucode.code(:Koukyu), "1" => 30, "2" => 2 , "3" => 3 ,"5" => 33},
      Kubun[:sankoutai]=> { "0" => Hospital::Kinmucode.code(:Koukyu), "1" =>  1, "2" => 2 , "3" => 3 ,"5" => 33},
      Kubun[:part]     => { "0" => Hospital::Kinmucode.code(:Koukyu), "1" => 46},
      Kubun[:touseki]  => { "0" => Hospital::Kinmucode.code(:Koukyu), "1" => 51},
      Kubun[:l_kin]    => { "0" => Hospital::Kinmucode.code(:Koukyu), "1" => 53},
      Kubun[:gairai]   => { "0" => Hospital::Kinmucode.code(:Koukyu), "1" => 61}
    }[kinmukubun_id][shift]
     # from0123[kinmukubun_id][shift]
    end

  # def am ; main_daytime > 5 ? 1 : 0 ;end
  def self.code_for_hope(shift)
    @code_for_hope ||= []
    sql="code in (?) and kinmukubun_id = ?"
    @code_for_hope[shift] ||=
      (case shift
       when  Kubun[:nikkin] #日勤
         self.all(:conditions => [sql,%w(0 D N),Kubun[:kyoutuu]])+
           self.all(:conditions => [sql,%w(4□ 管),Kubun[:nikkin]])+
           self.all(:conditions => [sql,%w(1 2 3),Kubun[:sankoutai]])+
           self.all(:conditions => [sql,%w(S A),Kubun[:kyoutuu]])+
           self.all(:conditions => ["kinmukubun_id = ?",Kubun[:nikkin]])
       when Kubun[:sankoutai]
         self.all(:conditions => [sql,%w(0 D N),Kubun[:kyoutuu]])+
           self.all(:conditions => [sql,%w(1 2 3),Kubun[:sankoutai]])+
           self.all(:conditions => [sql,%w(S A),Kubun[:kyoutuu]])+
           self.all(:conditions => ["kinmukubun_id = ?",Kubun[:kyoutuu]])
       when Kubun[:part]
         self.all(:conditions => [sql,%w(0 D N),Kubun[:kyoutuu]])+
           self.all(:conditions => ["kinmukubun_id = ?",3])+
           self.all(:conditions => [sql,%w(S A),Kubun[:kyoutuu]])
       else
         self.all(:conditions => [sql,%w(0 D N),Kubun[:kyoutuu]])+
           self.all(:conditions => ["kinmukubun_id = ?",shift])+
           self.all(:conditions => [sql,%w(S A),Kubun[:kyoutuu]])
       end
       ).uniq.map{|kinmucode| [ kinmucode.code,kinmucode.id]}
  end
  @@shift1 ={ }
  @@shift2={ }
  @@shift3={ }
  def self.shift1(id)
    return @@shift1[id] if  @@shift1[id] 
    kcode=self.find(id)
    @@shift1[id] = [:am,:pm,:am2,:pm2].inject(0){|s,sym| s +  (kcode[sym] ? kcode[sym] : 0)}
  end

  def self.shift2(id)
    return @@shift2[id] if  @@shift2[id] 
     @@shift2[id] ||= (kcode=self.find(id)).night + kcode.night2 
  end

  def self.shift3(id)
    return @@shift3[id] if  @@shift3[id] 
     @@shift3[id] ||= (kcode=self.find(id)).midnight + kcode.midnight2 
  end

  def self.daytime(id)
    return @@shift1[id] if  @@shift1[id] 
    kcode=self.find(id)
    @@shift1[id] = [:am,:pm,:am2,:pm2].inject(0){|s,sym| s +  (kcode[sym] ? kcode[sym] : 0)}
  end

  def self.night(id)
     @@shift1[id] ||= (kcode=self.find(id)).night + kcode.night2 
  end

  def self.midnight(id)
     @@shift1[id] ||= (kcode=self.find(id)).midnight + kcode.midnight2 
  end
  
end
