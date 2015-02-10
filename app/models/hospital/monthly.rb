# -*- coding: utf-8 -*-
# 各看護師達の各月の勤務内容を登録する
# month  ::  
# nurce_id ::
# day00～day31  ::  各日の勤務code(Hospital::Kinmucode#id)を nil,(1～80)+{0|1000|2000}
#               ::  で登録する。+1000は弱い要望、+2000は強い要望。未割り当ては　nil
#               ::  day00はダミー
#               ::  読み込み後、@days[]にHospital::Kinmuで置き換える。
#               ::  また、@shift に1日1byte(_01239 )一月分32Byteの文字列で表現しなおす。
#               ::  割り当て作業はこの @shift で行い、saveまえにday\d\dに書き出す。
#               ::  @days[]にHospital::Kinmu は要らなくなるかも
class Hospital::Monthly < ActiveRecord::Base
  extend CsvIo
  #extend Forwardable

  attr_writer :days
  attr_accessor :shift,:nurce

  #def_delegators @days,:[],:each,:map
  after_find do
    store_days
   end

  # monthly_controller では直接 day\d\d にしまうことにする。
  #  よって before_save は不要
  #def before_save 
  #  :restore_days
  #end
  after_create do
    store_days
    end

  def store_days
    @days = ("day00".."day%02d"%lastday).
      map{|day| Hospital::Kinmu.create(send day.to_sym)}
    days2shift
  end


  def days
    @days ||= ("day00".."day%02d"%lastday).
      map{|day| Hospital::Kinmu.create(send day.to_sym)}
  end

  def days2shift
    @shift ||= days.map{|knm| knm.shift ? knm.shift : "_"}.join
  end
  def day2shift
    @shift ||= days.map{|id| 
      #Hospital::Kinmucode.find(id%1000).to_0123 if id && (id%1000) > 0
      Hospital::Kinmucode.k_code(id%1000).to_0123 if id && (id%1000) > 0
    }
  end

  def restore_days_and_save
    restore_days
    save
  end

  def restore_days
    kinmukubun_id = nurce.kinmukubun_id
    @shift.gsub!(/23/,"LM")    if     Hospital::Define.koutai3?
    @shift.gsub!(/2[0_]/,"NO") unless Hospital::Define.koutai3?
    @shift.gsub!(/2/,"N")      unless Hospital::Define.koutai3?
      
    (0..lastday).each{|day|
      knm = @shift[day,1]
      #current_kinmucode = days[day].kinmucode
      next if days[day].want && days[day].want>0
      if kinmucode_id = Hospital::Kinmucode.from_0123(knm,kinmukubun_id)
        #next if Hospital::Kinmucode.from_0123(knm,kinmukubun_id).
        #  include?(current_kinmucode.id)
        days[day].kinmucode_id = kinmucode_id
        #logger.debug("Shift=#{knm},kinmucode_id=#{kinmucode_id},CODE=#{days[day].kinmucode.code}")
          #Hospital::Kinmucode.from_0123(knm,kinmukubun_id)
      else
        days[day].kinmucode_id = nil
      end
    }
      #knm = @kinmu[3,1]
    (0..lastday).each{|day|
      self[("day%02d"%day).to_sym] = 
     (days[day].kinmucode_id ? days[day].kinmucode_id + days[day].want*1000 : nil)
    }
#print  day01+" "
    self
  end

  def set_shift(day,sft_str)
    #self.days[day].kinmucode_id = (sft == 0 ? Hospital::Kinmucode::Koukyuu : sft )
    self.shift[day,1] = sft_str ? sft_str : "_"
  end

  def lastday
    @lastday ||= month.end_of_month.day
  end
  
  def kinmucode(day)
    kinmucode_id = days[day].kinmucode_id
    return nil unless kinmucode_id && (kinmucode_id%1000)>0
    Hospital::Kinmucode.k_code(kinmucode_id%1000).code rescue nil
  end

  def color(day)
    kinmucode_id = days[day].kinmucode_id
    return "" unless kinmucode_id && (kinmucode_id%1000)>0
    ["","bgcolor='orange'","bgcolor='red'"][kinmucode_id/1000]
  end
end

class Time
  def weekday
    Holyday.holyday?(self) ? "<font color=red>祝" :    %w(日 月 火 水 木 金 土)[self.wday]
  end
end

class Date
  def weekday
     Holyday.holyday?(self) ? "祝" :    %w(日 月 火 水 木 金 土)[self.wday]
  end
end
