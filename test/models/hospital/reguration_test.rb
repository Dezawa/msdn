# -*- coding: utf-8 -*-
require 'test_helper'

#################
class Hospital::RegurationTest < ActiveSupport::TestCase
  include Hospital::Reguration
  #fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  #fixtures :holydays,:hospital_needs,:hospital_monthlies
  #fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @Reguration =    @Wants =  @Reguration_keys = [{ },{ },{ },{ }]
    @check_reg = check_reg
  end
  shift1 = "0000_0001111110000000"
  (4..9).each{ |day|
  must "renkin #{day}" do
    reguration = Hospital::Regrate.create(/[1-8LM]{6,}/,back: 5,length: 11,comment: "連続勤務5日まで")
    assert reguration.check(day,shift1)

    reguration = @check_reg[0][:renkin]
    assert reguration.check(day,shift1)
  end
  }
  [1,2,3,10,11,12].each{ |day|
  must "renkin #{day}" do
    reguration = Hospital::Regrate.create(/[1-8LM]{6,}/,back: 5,length: 11,comment: "連続勤務5日まで")
    assert !reguration.check(day,shift1)

    reguration = @check_reg[0][:renkin]
    assert !reguration.check(day,shift1)
  end
  }


  shift2 = "0000_00011101110000000" 
  (1..12).each{ |day|
  must "renkin #{day}" do
    reguration =  Hospital::Regrate.create(/[1-8LM]{6,}/,back: 5,length: 11,comment: "連続勤務5日まで")
    assert !reguration.check(day,shift2)

    reguration = @check_reg[0][:renkin]
    assert !reguration.check(day,shift2)
  end
  }
  #              12345678901234
  shift3 = "0000_0002210231_330_1101110000000"
  [4,5,6,8,9,10].each{ |day|
  must "after_nights #{day}" do
    reguration =  Hospital::Regrate.create(/[2L3M56]{2}[^0_]/,back: 2,length: 5,comment: "連続夜勤明けは休み")
    assert reguration.check(day,shift3)
  end
  }
  [1,2,3,7,11,12,13,14,15,18,19].each{ |day|
  must "after_nights #{day}" do
    reguration =  Hospital::Regrate.create(/[2L3M56]{2}[^0_]/,back: 2,length: 5,comment: "連続夜勤明けは休み")
    assert !reguration.check(day,shift3)
  end
  }
$day=3
  must "kinmu_total 10" do
    reguration =  Hospital::Regrate.create(/[^1-8LM]/,length: 10, comment: "勤務は22日まで",
                                           method: Hospital::Total)
    assert !reguration.check($day,"0000_01234567880100000")
  end
  must "kinmu_total 11" do
    reguration =  Hospital::Regrate.create(/[^1-8LM]/,length: 10, comment: "勤務は22日まで",
                                           method: Hospital::Total)
    assert reguration.check($day,"0000_012345678801020000")
  end
  must "kinmu_total 12" do
    reguration =  Hospital::Regrate.create(/[^1-8LM]/,length: 10, comment: "勤務は22日まで",
                                           method: Hospital::Total)
    assert reguration.check($day,"0000_0123456788010230000")
  end
end
