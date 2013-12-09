# -*- coding: utf-8 -*-
class Ubeboard::MeigaraShortname < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'ube_meigara_shortnames'
  belongs_to   :ube_meigara

  def self.meigara(short)
    shortname=self.find_by(short_name: short)
    shortname ? shortname.meigara : short
  end

  def meigara; ube_meigara.meigara ;end
end
