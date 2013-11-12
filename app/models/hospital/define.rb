# -*- coding: utf-8 -*-
class Hospital::Define < ActiveRecord::Base
  set_table_name 'hospital_defines'

  def self.koutai3?
    #define=Hospital::Define.find_by_attribute("hospital_Koutai")
    define=Hospital::Define.all(:conditions => ["attri = ?","hospital_Koutai"])[0]
    !!(define && define.value == "三交代")      
  end
  
end
