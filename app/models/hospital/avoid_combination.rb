# -*- coding: utf-8 -*-
class Hospital::AvoidCombination < ActiveRecord::Base
  extend CsvIo

  belongs_to :nurce1,:class_name => "Hospital::Nurce"
  belongs_to :nurce2,:class_name => "Hospital::Nurce"
  belongs_to :busho,:class_name => "Hospital::Busho"

  def dvalidate
    if self.nurce1_id > self.nurce2_id
      nurce_id  = self.nurce2_id
      self.nurce2_id = self.nurce1_id
      self.nurce1_id = nurce_id
    end
    if self.nurce1_id == self.nurce2_id
      errors.add_to_base("同じ看護師が 指定されています #{nurce1.name}") 
    end
  end

  def busho_name ; busho ? busho.name : "" ; end
  def dump ; "[#{nurce1_id},#{nurce2_id}]:weight:#{weight}" ; end

end
