# -*- coding: utf-8 -*-
require 'ondotori'
require 'ondotori/converter'
require 'ondotori/recode'

class Shimada::Dayly < ActiveRecord::Base
  serialize :measurement_value
  serialize :converted_value

  belongs_to :shimada_instrument
end
