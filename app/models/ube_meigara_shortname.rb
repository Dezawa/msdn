# -*- coding: utf-8 -*-
class UbeMeigaraShortname < ActiveRecord::Base
  extend Function::CsvIo

  belongs_to   :ube_meigara

  def self.meigara(short)
    shortname=self.find_by_short_name(short)
    shortname ? shortname.meigara : short
  end

  def meigara; ube_meigara.meigara ;end
end
