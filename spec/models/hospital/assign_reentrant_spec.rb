# -*- coding: utf-8 -*-
require 'spec_helper'
require 'testdata/hospital_assign_data'

def init
  mar=Date.new(2013,3,1)
  feb=Date.new(2013,2,1)
  @assign=Hospital::Assign.new(1,mar)
  @nurces=@assign.nurces
  @nurces.each_with_index{|nurce,idx|
    def nurce.shift_with_last_month
      Monthly2[id-34][-5..-1]+shifts
    end
    nurce.monthly(mar) #Monthly3
    nurce.set_shift_days(1, Monthly3[idx][1..-1])
  }

end

