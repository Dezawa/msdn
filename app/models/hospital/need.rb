# -*- coding: utf-8 -*-
class Hospital::Need < ActiveRecord::Base
  extend Function::CsvIo
  set_table_name 'hospital_needs'
  
  def self.need_roles
    Hospital::Role.all(:conditions => "need = true") 
  end

  def self.roles
    @@roles ||= self.all(:conditions => "minimun>0").map(&:role_id).uniq.sort
  end 

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

  def self.on_date_for_busho(month,day,busho_id)
    date = month+(day-1).day
    self.all(:conditions => ["busho_id = ? and daytype in (1,?)",busho_id,what_day(date)])
  end

  def self.of_datetype_for_busho(month,what_day,busho_id)
    self.all(:conditions => ["busho_id = ? and daytype in (1,?)",busho_id,what_day])
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




