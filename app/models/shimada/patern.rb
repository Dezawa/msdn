# -*- coding: utf-8 -*-
module Shimada::Patern
  #module ClassStatic

  Paterns = {   "稼働無" => %w(0S) ,  "稼働1" => %w(1S), "稼働2" => %w(200 2O 2-+F),
    "稼働3" => %w(3F 3++ 3-+F 3--F),"稼働4" => %w(4F 4++ 4-+F 4--F), 
    "稼働3一時低下" => %w(3-+H)    ,"稼働4一時低下" => %w(4-+H)    ,
    "稼働3→2" => %w(3-+D 3--D)   ,"稼働4→3" =>  %w(4-+D 4--D)  ,
     "未分類" => nil
   }
{ "稼働1" => %w(1S),"稼働2" => %w(200 2O 2--F),
    "稼働3" => %w(3-- 3--F 30- 3"稼働2" => %w(200 2O 2--F),F 300 3O),"稼働4" => %w(400 4O 4F 4--F 4+-),
    "稼働3→2" => %w(3--D 3-+ 3-0)   ,"稼働4→3" =>  %w(4--D 4-+ 4-0),
    "稼働4一時低下" => %w(40+)    ,"稼働3一時低下" => %w(30+)    ,

    "稼働4→3" => %w(4-- 4-+ 4-0 4d),
   "稼働3→2" => %w(3d 3-0),
    "稼働2" => %w(2O),
    #"その他" => %w(1他遅 2他遅 3他遅 4他遅 1他急変 2他急変 3他急変 4他急変),
    "他遅" => %w(1他遅 2他遅 3他遅 4他遅), 
    "他急変1" => %w(1他急変1 2他急変1 3他急変1 4他急変1),    "他急変2" => %w(1他急変2 2他急変2 3他急変2 4他急変2),
    "未分類" => nil
   }
  PaternsKey = %w(稼働無 稼働1 稼働2 稼働3 稼働4 稼働3→2 稼働4→3 稼働3一時低下 稼働4一時低下 未分類)
  Deforms    = { "異常無" => "null",  "異常全て" => "all", "急変1" => "V" ,"急変2" => "U" ,
    "立ち遅れ" => "d","立上り乱れ" => "E" ,    "後引き" => "A" , "深夜低下悪し" => "O"}
  DeformKey  = %w(異常無 異常全て 急変1 急変2 立ち遅れ 立上り乱れ 後引き 深夜低下悪し)

  Shapes = Shimada::Power.all.map(&:shape).compact.uniq
  AllPatern = %w(0 1 2 3 4 5).product(Shapes).map{ |l,s| l+s } 
  Un_sorted = AllPatern - Paterns.values.flatten

  #end
 #def self.included(base) ;    base.extend(ClassStatic) ;end

  Err         = 0.01

    # F Flat          ほぼ平ら。稼働ライン数が一定なのだろう
    # U step Up       階段状に増える。稼働ラインが途中から増えたのだろう
    # D step Down     階段状に減る。　稼働ラインが途中で減ったのだろう
    # I Increace      ズルズル増える  稼働ラインの変化ではなく、なんかある？
    # R Reduce        ズルズル減る。  稼働ラインの変化ではなく、なんかある？
    # C Cup           途中で稼働ライン一時的に止めた
    # H Hat           途中で一時的に増えている。なんかある？
    # S Sleep         稼働なし
#  Shapes = %w(- 0 +).product(%w(- 0 +)).map{ |a,b| a+b }+%w(F O S H)

  def shape_calc
    return nil unless lines && max_diff_from_average_difference

    unless lines < 2
      if max_diff_from_average_difference > 200 ;  deforme("V") #; "他急変1"
      elsif [diffdiff(5..20).max,-diffdiff(5..20).min].max >  190 ; deforme("U")  #; "他急変2"
      end
      deforme("d") if revise_by_temp[6]  < 400          #  ;     "他遅"
      deforme("A") if revise_by_temp[23] > 600         #  
      deforme("O") if revise_by_temp_3[-3,3].max > 500 #  0 => 4時、2,3,4時
      deforme("E") if difference[3,3].min < -50 # || diffdiff[4,3].map{ |dd| dd.abs}.max>100
    end

    if lines < 2  ; "S"
    elsif discriminant.abs < 0.000002       ;"00"
    elsif na && na[4] > 0
     # if f3x3 < 9 && pw_peaks[1]-pw_peaks[2] > 120  ; "d" 
     # elsif f3x1 >-12 && pw_peaks[1]-pw_peaks[0] > 120  ; "d" 
     # else
        "O"
     # end
    elsif discriminant < 0.0                ; "F"
    elsif y1     >  Err && y2.abs <   Err   ;  "+0"  
    elsif y1     >  Err && y2     >   Err   ;  "++" 
    elsif y1     < -Err && y2.abs <   Err   ;  "-0"
    elsif y1     < -Err && y2     <  -Err   
      if difference_peak_sholder > 100 ; "--D"
      else ; "--F"
      end
      #"--"
    elsif y1     < -Err && y2     >   Err   # -+
      logger.debug("SHAPE-+: #{ date} #{difference_peaks < 100} && #{difference_peak_vary} > 150")
      if difference_peaks < 100 && difference_peak_vary > 100
         "-+H" #凹(H)は f3x1,f3x3 におけるf4の差が少なく、f3x2のf4の落ち込みが大
      elsif pw_peaks[0] - pw_peaks[1] > 100  ; "-+D"
      elsif pw_peaks[1] - pw_peaks[0] > 100  ; "-+U"
      else              ; "-+F"
      end
    elsif y1.abs <  Err && y2.abs <   Err   ;  "00" #
    elsif y1.abs <  Err && y2     >   Err    
   #   x0 = f3_solve((x1+x2)*0.5)
    #  max_powers[0] - min_powers[0] > 150 ? "H" :
      "0+"
    elsif y1     >  -Err && y2     <  -Err   ;  "+-" # と 0-
    else      ;   "他"
    end
  end

  def deforme(type)
    self.deform = self.deform ? self.deform + type : type
  end
end


