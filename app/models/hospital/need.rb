# -*- coding: utf-8 -*-
class Hospital::Need < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'hospital_needs'
  include Hospital::Const

  
  @@need_roles = nil
  @@need_role_ids = nil

  def self.need_list_each_role_daytype_of(busho_id)
    ret = Hash.new{ |h,k| h[k]={  Weekday => [nil,nil,nil],Weekend=> [nil,nil,nil]}}
    needs = all(:conditions => ["busho_id = ? ",busho_id])
    needs.each{ |need| 
      next unless need_role_ids.include?(need.role_id) && [2,3].include?(need.daytype)
      ret[need.role_id][need.daytype][need.kinmucode_id-1]=need
    }
    need_role_ids.each{ |role_id|
      #ret.each_pair{ |role_id,hash| 
      [Weekday,Weekend].each{ |daytype|
        [0,1,2].each{ |kinm|
          ret[role_id][daytype][kinm] ||= 
          self.create(:role_id => role_id,:busho_id => busho_id,:daytype => daytype,
                      :kinmucode_id => kinm+1)
        }
      }
    }
logger.debug("*****Hospital::Need:need_list_each_role_daytype_of  #{ret.keys.sort.join(',')}")
    ret
  end

  def self.need_roles
    @@need_roles ||= Hospital::Role.all(:conditions => "need = true") 
  end
  def self.need_role_ids
   @@need_role_ids ||= need_roles.map(&:id)
  end


  def self.roles
    @@roles ||= self.all(:conditions => "minimun>0").map(&:role_id).uniq.sort
  end 

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

  def self.on_date_for_busho(month,day,busho_id)
    date = month+(day-1).day
    self.all(:conditions => ["minimun>0 and busho_id = ? and daytype in (1,?)",busho_id,what_day(date)])
  end

  def self.of_datetype_for_busho(month,what_day,busho_id)
    self.where( ["busho_id = ? and daytype in (1,?)",busho_id,what_day])
  end

  def self.what_day(day)
    (day.wday%6 == 0 || Holyday.holyday?(day)) ? Weekend : Weekday
  end
  # 着目している @monthlyの各日毎に、必要な　role毎の人数を保存する
  # [ [role,日準深]=>[min,max],, ,,,]
  def self.needs_all_days(month,busho_id)
    need_pat = self.need_patern(busho_id)
    needs_all_days= (0..month.end_of_month.day).map{|day|
      date = month+(day-1).day
      need_pat[(date.wday%6 == 0 || Holyday.holyday?(date)) ? 1 : 0]
    }
    #Hospital::Need.needs_all_days(@busho_id,@month)
    needs_all_days
  end

  # 平日か土日祝かで勤務必要数が変わる。
  # それを返す。
  # 戻り値 [ [ [資格,sft_str]=>[最低数、最大数], []=>[], []=>[] ],[ 土日の分] ]
  def self.need_patern(busho_id)
    need_patern =[Weekday,Weekend].map{|what_day|  # 1:毎日  2:平日、  3:土日休
      nd = Hash.new
      self.of_datetype_for_busho(what_day,busho_id).
      each{|need|            #shift_idとすべきであった
        nd[[need.role_id,need.kinmucode_id.to_s]] = [need.minimun||0 ,need.maximum||need.minimun]
      }
      nd
    }
    nurse_size = Hospital::Nurce.by_busho(busho_id).
      select{|nurce| nurce.shokushu_id == $HP_DEF.kangoshi}.size
    need_patern.each{ |nd| 
      nd[[$HP_DEF.kangoshi,Sshift0]] = 
      [0,
       nurse_size -  # 看護師の人数
       $HP_DEF.shifts123.inject(0){|s,shift| s + nd[[$HP_DEF.kangoshi,shift]].first } ]  # 看護師必要人数合計
    }
  end

  ############ 逼迫role関連
  def self.combination3
        @@combination3 ||= make_combination
  end

  def self.combination2
        @@combination2 ||= make_combination2
  end

#<<<<<<< HEAD
  def self.roles
    @@roles ||= self.where(["minimun>0"]).pluck(:role_id).uniq.sort

  end 

#=======
#>>>>>>> HospitalPower
  def self.make_combination
    comb = []
    roles.combination(3).to_a.each{|c0,c1,c2| 
      comb << [c0,c1,c2] << [c0,c2,c1] << [c1,c0,c2] << [c1,c2,c0] << [c2,c0,c1] << [c2,c1,c0]
    }
    logger.debug("=== Need::roles =#{roles.join(',')} comb:[#{comb.map{ |c| c.join(',')}.join']['}]")
    comb.sort
  end

  def self.make_combination2
    comb = []
    roles.combination(2).to_a.each{|c0,c1| 
      comb << [c0,c1] <<  [c1,c0]
    }
    logger.debug("=== Need::roles =#{roles.join(',')} comb:[#{comb.map{ |c| c.join(',')}.join']['}]")
    comb.sort
  end
  
  
  def after_save
    @@roles = self.class.all(:conditions=>["minimun>0"]).map(&:role_id).uniq.sort
    @@combination3 = self.class.make_combination
    Hospital::Nurce.make_cost_table
  end



end

__END__

def self.tights
@@tight ||= make_tightend



def after_find 
@@roles = make_roles
@@tight = make_tight
HO::Nurce.cost(true)
end


def self.cost(reculc)
return @@cost if @@cost && !reculc
@@cost




