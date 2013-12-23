# -*- coding: utf-8 -*-
# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::Form9Test < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes,:bushos
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
    #@assign = Hospital::Assign.new(1,@month)
    @form9  = Hospital::Form9.new(@month)
  end

  #must "曜日が入るか" do
  #  @form9.weekly.save("/tmp/form9-1.xls")
  #end

  must "病院固定は入るか" do
    @form9.create_date.hospital_static(:hospital_name => "大日本帝国病院",:kubun => 10,
                                       :Kyuuseiki_addition => 25,:Yakan_Kyuuseiki_addition=> 50,
                                       :night_addition  => "有",
                                       :hospital_bed_num => 123
                                       ).
      save("/tmp/form9-2.xls")
  end
  must "病院月度は入るか" do
    @form9.create_date
    @form9.hospital_monthly(:hospital_name => "大日本帝国病院",:kubun => 10,
                                       #:Kyuuseiki_addition => 25,:Yakan_Kyuuseiki_addition=> 50,
                                       #:night_addition  => "有",
                                       :hospital_bed_num => 123
                                       )
    @form9.weekly
    @form9.nurces
    @form9.save("/tmp/form9-3.xls")
  end

  must "看護師"  do
    #puts @form9.nurces.size
    
 end
end
# -*- coding: utf-8 -*-
