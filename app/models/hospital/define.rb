# -*- coding: utf-8 -*-
class Hospital::Define < ActiveRecord::Base
  self.table_name = 'hospital_defines'

  def self.koutai3?
    #define=Hospital::Define.find_by_attribute("hospital_Koutai")
    define=Hospital::Define.find_by( attri: "hospital_Koutai")
    !!(define && define.value == "三交代")      
  end
  
end
