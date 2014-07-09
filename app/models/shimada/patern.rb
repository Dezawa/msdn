# -*- coding: utf-8 -*-
module Shimada::Patern
  #module ClassStatic

  Paterns = {
    "稼働無" => %w(0S 1S)        ,"稼働4一時低下" => %w(4H)    ,"稼働4" => %w(400 4F),"稼働4→3" => %w(4-- 4-+ 4-0 4d),
    "稼働3" => %w(3-- 30- 3F 300 3O),"稼働3一時低下" => %w(3H)    ,"稼働3→2" => %w(3d 3-0),
    "稼働2" => %w(2O),
    #"その他" => %w(1他遅 2他遅 3他遅 4他遅 1他急変 2他急変 3他急変 4他急変),
    "他遅" => %w(1他遅 2他遅 3他遅 4他遅), 
    "他急変1" => %w(1他急変1 2他急変1 3他急変1 4他急変1),    "他急変2" => %w(1他急変2 2他急変2 3他急変2 4他急変2),
    "未分類" => nil
   }
  PaternsKey = %w(稼働無 稼働4一時低下 稼働4 稼働4→3 稼働3 稼働3一時低下 稼働3→2 稼働2 他遅 他急変1 他急変2 未分類)
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
    return nil unless lines
    if lines < 2  ; "S"
    #elsif max_diff_from_average_difference > 200 ; "他急変1"
    #elsif [diffdiff(3..20).max,-diffdiff(3..20).min].max >  190 ; "他急変2"
    elsif discriminant.abs < 0.000002       ;"00"
    #elsif revise_by_temp[6] < 400           ;     "他遅"
    elsif na[4] > 0
     # if f3x3 < 9 && pw_peaks[1]-pw_peaks[2] > 120  ; "d" 
     # elsif f3x1 >-12 && pw_peaks[1]-pw_peaks[0] > 120  ; "d" 
     # else
        "O"
     # end
    elsif discriminant < 0.0                ; "F"
    elsif y1     >  Err && y2.abs <   Err   ;  "+0"
    elsif y1     >  Err && y2     >   Err   ;  "++"
    elsif y1     >  Err && y2     <  -Err   
      #max_powers[0] - min_powers[0]  > 120 ? "H" : 
      "+-"
    elsif y1     < -Err && y2.abs <   Err   ;  "-0"
    elsif y1     < -Err && y2     <  -Err   ;  "--"
    elsif y1     < -Err && y2     >   Err   # -+
      pw_values = pw_peaks
      #unless f3_solve.all?{ |x| Shimada::Power::PolyFitHour.include?(x+Shimada::Power::PolyFitX0)}
         "-+"
      #else
      #logger.debug("===== pw_values = #{pw_values.join(',')} f3_solve=#{f3_solve.join(',')}")
      #logger.debug("===== ID=#{id} #{date} difference_peak_vary = #{difference_peak_vary} difference_peaks=#{difference_peaks}")
     # difference_peak_vary > 99 && difference_peaks < 100  ? "H" : "-+" # H
     # end
    elsif y1.abs <  Err && y2.abs <   Err   ;  "00" #
    elsif y1.abs <  Err && y2     >   Err    
   #   x0 = f3_solve((x1+x2)*0.5)
    #  max_powers[0] - min_powers[0] > 150 ? "H" :
      "0+"
    elsif y1.abs <  Err && y2     <  -Err   ;  "0-"
    else      ;   "他"
    end
  end

end


