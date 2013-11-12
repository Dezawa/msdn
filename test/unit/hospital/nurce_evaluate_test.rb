# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::Form9Test < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
    @assign = Hospital::Assign.new(1,@month)
    @form9  = Hospital::Form9.new(@assign)
  end

  must "作成日が入るか" do
    @form9.create_date.save
    
  end

end
