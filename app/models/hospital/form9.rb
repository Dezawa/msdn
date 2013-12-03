# -*- coding: utf-8 -*-
class Hospital::Form9

require 'rubygems'
require 'spreadsheet'
#require '9ns100'

Sheet9ns    = File.join(RAILS_ROOT,"lib","hospital","9ns100.xls")
Sheet9nsNew = File.join(RAILS_ROOT,"tmp","hospital","form9.xls")

Spreadsheet.client_encoding = 'UTF-8'

Items = 
    { 
    :create_year   => [0,17] ,  :create_month      => [0,19] , :create_day => [0,21] , # 作成日
    :hospital_name => [2,5]  ,      # 保険医療機関名           
    :hospital_ward_num => [2,14] , :hospital_bed_num => [2,20], # 病棟数   病床数
    :kubun         => [4,8]  ,  :patient_num       => [4,16] ,  # 届出区分 届出時入院患者数	
    :KangoHaichi_addition     => [6,12],  # 看護配置加算の有無
    :Kyuuseiki_addition       => [7,12],  # ,急性期看護補助体
    :Yakan_Kyuuseiki_addition => [8,13],  #夜間急性期看護補助体制
    :night_addition           => [9,12],  #看護職員夜間配置,
    :KangoHojo_additon        => [10,12], #,看護補助
    :average_patient          => [13,9],  #１日平均入院患者数
    :patient_start_year=> [13,15], :patient_start_month => [13,17], #(算出期間）
    :patient_stop_year => [13,19], :patient_stop_month => [13,21],
    :average_Nyuuin=> [26,9],       # 平均在院日数
    :Nyuuin_start_year=> [26,15], :Nyuuin_start_month => [26,17],  #(算出期間）
    :Nyuuin_stop_year => [26,19], :Nyuuin_stop_month => [26,21],
    :night_from => [28,8], :night_stop => [28,13], :night_time_fmt   => "%4s時 %4s分" ,# 夜勤時間帯(16時間)
    :month  => [39,2],   # 今月
    :month_day => [38,13] ,    # ]※今月の稼働日数
    :weekly_hour => [39,13] ,    # ]※常勤職員の週所定労働時間

    :column_Shubetu => 1, :column_ward => 3, :column_nurce => 4,  #種別、病棟、名前
    :column_Joukin  => 5, :column_part => 6, :column_Hijoukin =>7, :column_night_only => 12,
    :column_first_weekday => 14,
    :line_weekday      => [44,261],
    :line_nurce        => [45,262] #   262 = 45+100*2+2(247)+ sum(15): 45,1272 1272 = 45+6*(202) + 15 = 45+1212+15
  }

  attr_accessor :form9, :sheet
  def initialize(month)
    @month = month
    @form9 = Spreadsheet.open(Sheet9ns)
    @sheet = @form9.worksheet('NS100')
  end

  def calc(items)
    item_list = { }
    items.each{ |k,v| item_list[k.to_sym]=v}
    create_date
    weekly
    defines = Hash[*Hospital::Define.all.
                   map{ |define| [define.attribute.to_sym,define.value]}.flatten]

    hospital_monthly(item_list.merge(defines))
    nurces
    save
  end

  def save(path=nil)
    @form9.write(path||= Sheet9nsNew)
    self
  end

  def create_date(date = nil)
    date ||= Time.now
    @sheet[ *Items[:create_year]]  = date.year
    @sheet[ *Items[:create_month]] = date.month
    @sheet[ *Items[:create_day]]  = date.day
    self
  end
  
  # 保険医療機関名  病棟数   病床数 届出区分 看護配置加算の有無,急性期看護補助体 
  # 夜間急性期看護補助体制 看護職員夜間配置,看護補助 夜勤時間帯(16時間)
  def hospital_static(arg={ })
    args = {
      #:night_stop => Hospital::Kinmucode.find_by_code(3).finish.split(/[^\d]+/)
      #:night_from => Hospital::Kinmucode.find_by_code(2).start.split(/[^\d]+/),
     :hospital_ward_num => Hospital::Busho.count
    }.merge(arg)
#pp args
#pp Items[:night_time_fmt]%args[:night_from] 
    [:hospital_name, :hospital_ward_num  , :hospital_bed_num,:kubun,:Kyuuseiki_addition,
    :Yakan_Kyuuseiki_addition ,   :night_addition ,  :KangoHojo_additon
    ].each{ |sym|
      @sheet[ *Items[sym]] = args[sym] if args[sym]
    }
    [:night_from, :night_stop].each{ |sym|
      @sheet[ *Items[sym]] = Items[:night_time_fmt]%args[sym] if args[sym]
    }
    self
  end

  def hospital_monthly(args={ })
    night_from =  Time.local(2013,1,1,*Hospital::Kinmucode.`find_by(code: 2).start.split(/[^\d]+/))
    night_stop = night_from + 16.hour
    arg = { 
      :night_stop => [night_stop.hour,night_stop.min],
      :night_from => [night_from.hour,night_from.min],
      :hospital_ward_num => Hospital::Busho.count,
      :month => @month.month,
      :month_day =>  @month.end_of_month.day
    }.merge(args)
    Items.keys.each{ |sym| 
       if arg[sym] 
         case sym
         when :night_from, :night_stop ; #puts @sheet[ *Items[sym]]
            @sheet[ *Items[sym]] =  Items[:night_time_fmt]%arg[sym] #"16時00分"
         when :hospital_name,:KangoHaichi_addition,:night_addition
           @sheet[ *Items[sym]]  = arg[sym] if arg[sym] 
         else ;@sheet[ *Items[sym]]  = arg[sym].to_i if arg[sym] 
         end
       end
       }
    self
  end

  def weekly
    row = Items[:line_weekday].first ; column = Items[:column_first_weekday]
    (@month.beginning_of_month..@month.end_of_month).each{ |day|
      @sheet[ row,column]  = %w(日曜 月曜 火曜 水曜 木曜 金曜 土曜)[day.wday]
      column += 1
    }
    self
  end

  def nurces
    row =  Items[:line_nurce].first ; column = Items[:column_first_weekday]
    monthlies =Hospital::Monthly.all(:conditions => ["month =?",@month]).
      sort_by{ |monthly| monthly.nurce_id}
    monthlies.each{ |monthly|
      nurce = Hospital::Nurce.find(monthly.nurce_id)
      @sheet[ row,Items[:column_Shubetu]]  = Hospital::Const::Shokushu.rassoc(nurce.shokushu_id)[0]
      @sheet[ row,Items[:column_ward]]  = Hospital::Busho.find(nurce.busho_id).name
      @sheet[ row,Items[:column_nurce]]  = nurce.name
      sym = case nurce.kinmukubun_id
                         when 1, 2 ,4,6  ; :column_Joukin
                         when 3          ; :column_part
                         when 5          ; :column_night_only
                         else            ; :column_Hijouki
                         end
#pp [nurce.name,nurce.kinmukubun_id,sym,Items[sym],row,monthly.shift]
     #@sheet[ row+1,Items[:column_part]] = 1
pp [row+1,Items[sym], @sheet[ row+1,Items[sym]]]
      @sheet[ row+1,Items[sym]] = 1

      monthly_shift(nurce,monthly,row)
      row += 2
    }
  end

  def monthly_shift(nurce,monthly,row)
      #puts row
kinmus = monthly.days
    offset = 1
    clm = Items[:column_first_weekday]-1
    next_night   = 0.0
    (1..@month.end_of_month.day).each{ |day|
      kinmucode =  kinmus[day].kinmucode
      daytime = (kinmucode.main_daytime||0.0) + (kinmucode.sub_daytime||0.0)
      @sheet[ row,clm+day] = daytime if  daytime > 0.00
      night = next_night + (kinmucode.main_nignt||0.0) + (kinmucode.sub_night||0.0)
#pp @sheet[ row+1,clm+day] if night > 0.00
      @sheet[ row+1,clm+day] = night.to_f if  night > 0.00
      next_night =(kinmucode.main_next||0.0) + (kinmucode.sub_next||0.0)
      #pp @sheet[ row+1,clm+day].class if night > 0.00
     #print day," ",kinmucode.id," ",night,":"

    }
    #
  end

end
__END__
 対１入院基本料 
 

看護補助加算の届出区分						無
		○１日平均入院患者数〔A〕
		※端数切上げ整数入力
①月平均１日当たり看護配置数		
1日看護配置数　　〔(A ／配置比率)×３〕※端数切上げ		
＜看護職員夜間配置加算を届け出る場合＞		
①-2　うち、月平均１日当たり夜間看護配置数		
1日夜間看護配置数 〔A/12〕※端数切上げ		
		
		
②看護職員中の看護師の比率		
月平均1日当たり配置数		
		
		
③平均在院日数 ※端数切上げ整数入力		
		
④夜勤時間帯(16時間)		


require 'rubygems'
require 'spreadsheet'

book = Spreadsheet.open('/tmp/9ns100.xls')
sheet = book.worksheet(0)

puts sheet[45,14].class
sheet[45,14] = 7.5
puts sheet[45,14].class
book.write('/tmp/9ns2.xls')

book2 = Spreadsheet.open('/tmp/9ns2.xls')
sheet2 = book2.worksheet(0)

puts sheet2[45,14].class
