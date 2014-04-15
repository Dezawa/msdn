# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::Form9Test < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes,:bushos,:hospital_defines
  Items = Hospital::Form9::Items
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
    #@assign = Hospital::Assign.new(1,@month)
    @form9  = Hospital::Form9.new(@month)
    @sheet  = @form9.sheet
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
  must "作成月度は入るか" do
    @form9.create_date
    assert_equal Time.now.year ,@form9.sheet[ *Items[:create_year]] ,"作成年"
    assert_equal Time.now.month,@form9.sheet[ *Items[:create_month]] ,"作成月"
    assert_equal Time.now.day  ,@form9.sheet[ *Items[:create_day]] ,"作成日"
  end

  must "病院 定数" do
    defines = Hash[*Hospital::Define.all.
                   map{ |define| [define.attri.to_sym,define.value]}.flatten]

    @form9.hospital_monthly(defines)
    assert_equal 44,@form9.sheet[ *Items[:average_Nyuuin]] ,"１日平均入院患者数"
  end

  must "病院月度" do
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
    defines = Hash[*Hospital::Define.all.
                   map{ |define| [define.attri.to_sym,define.value]}.flatten]

    @form9.hospital_monthly(defines)
    @row =  Items[:line_nurce].first

    monthlies =Hospital::Monthly.all(:conditions => ["month =?",@month]).
      sort_by{ |monthly| monthly.nurce_id}
pp [:column_Joukin,Items[:column_Joukin]]

    @sheet[ @row+1,Items[:column_Joukin]] = 1
    @sheet[ @row+3,Items[:column_Joukin]+1] = 1
    @sheet[ @row+5,Items[:column_Joukin]+2] = 1
    assert_equal 1,@sheet[ @row+1,Items[:column_Joukin]]
    assert_equal 1,@sheet[ @row+3,Items[:column_Joukin]+1]
    assert_equal 1,@sheet[ @row+5,Items[:column_Joukin]+2]
 end
end
