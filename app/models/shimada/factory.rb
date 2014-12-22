# -*- coding: utf-8 -*-
#Shimada::PowerModels = [Shimada::Power,Shimada::PowerBy_30min] # power_model_idで探す
Shimada::PowerModels = [Shimada::Power,Shimada::Power] # power_model_idで探す
Shimada::MonthModels = [Shimada::Month,Shimada::Chubu::Month]  # power_model_idで探す
Shimada::TimeOffset  = [2,4]
class Shimada::Factory < ActiveRecord::Base
  has_many :shimada_powers ,:class_name =>  "Shimada::Power"
end

