# -*- coding: utf-8 -*-
class Ube::MeigaraShortname < ActiveRecord::Base
  extend CsvIo
  #self.table_name = 'ube_meigara_shortnames'
  belongs_to   :ube_meigara ,:class_name => Ube::Meigara

  def self.meigara(short)
    shortname=self.find_by(short_name: short)
    shortname ? shortname.meigara : short
  end

  def meigara; ube_meigara.meigara ;end
end
