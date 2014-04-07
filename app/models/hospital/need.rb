# -*- coding: utf-8 -*-
class Hospital::Need < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'hospital_needs'
  
  def self.find_and_build(busho_id)
    ret = Hash.new{ |h,k| h[k]={  2 => [nil,nil,nil],3=> [nil,nil,nil]}}
    needs = all(:conditions => ["busho_id = ? ",busho_id])
    needs.each{ |need| 
      next unless need_role_ids.include?(need.role_id) && [2,3].include?(need.daytype)
      ret[need.role_id][need.daytype][need.kinmucode_id-1]=need
    }
    need_role_ids.each{ |role_id|
      #ret.each_pair{ |role_id,hash| 
      [2,3].each{ |daytype|
        [0,1,2].each{ |kinm|
          ret[role_id][daytype][kinm] ||= 
          self.create(:role_id => role_id,:busho_id => busho_id,:daytype => daytype,:kinmucode_id => kinm+1)
        }
      }

    }
logger.debug("*****Hospital::Need:find_and_build  #{ret.keys.sort.join(',')}")
    ret
  end

  def self.need_roles
    Hospital::Role.all(:conditions => "need = true") 
  end
  def self.need_role_ids
    need_roles.map(&:id)
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
    self.all(:conditions => ["minimun>0 and busho_id = ? and daytype in (1,?)",busho_id,what_day])
  end

  def self.what_day(day)
    (day.wday%6 == 0 || Holyday.holyday?(day)) ? 3 : 2
  end
  ############ 逼迫role関連
  def self.combination3
        @@combination3 ||= make_combination
  end

  def self.combination2
        @@combination2 ||= make_combination2
  end

  def self.make_combination
    comb = []
    roles.combination(3).to_a.each{|c0,c1,c2| 
      comb << [c0,c1,c2] << [c0,c2,c1] << [c1,c0,c2] << [c1,c2,c0] << [c2,c0,c1] << [c2,c1,c0]
    }
logger.debug("=== Need::roles =#{roles.join} comb:#{comb.join(',')}")
    comb.sort
  end
  def self.make_combination2
    comb = []
    roles.combination(2).to_a.each{|c0,c1| 
      comb << [c0,c1] <<  [c1,c0]
    }
logger.debug("=== Need::roles =#{roles.join} comb:#{comb.join(',')}")
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




