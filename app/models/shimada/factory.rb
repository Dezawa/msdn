# -*- coding: utf-8 -*-
Shimada::PowerModels = [Shimada::Power,Shimada::PowerBy_30min] # power_model_idで探す
Shimada::MonthModels = [Shimada::Month,Shimada::Chubu::Month]  # power_model_idで探す

class Shimada::Factory < ActiveRecord::Base
  
end

