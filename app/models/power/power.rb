# -*- coding: utf-8 -*-
module Power::Power
  module ClassMethods
  end
  def self.included(base)
    base.extend ClassMethods
  end

    def update_by_day_data(day_data)
      ("01".."24").each{ |hr| self["power#{hr}"] = day_data.shift.to_f}
      self.save
    end

end
