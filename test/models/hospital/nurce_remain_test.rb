# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

#################
class Hospital::NurceTest < ActiveSupport::TestCase
  fixtures "hospital/nurces","hospital/roles","hospital/nurces_roles","hospital/limits"
  fixtures "holydays","hospital/needs","hospital/monthlies"
  fixtures "hospital/kinmucodes"
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
  end


  shift_remain = [
                  {"3"=>5, "2"=>5, "1"=>20.0, "0"=>7.0, :kinmu_total =>22, :night_total =>9},
                  {"3"=>5, "2"=>5, "1"=>20.0, "0"=>8.0, :kinmu_total =>22, :night_total =>9},
                  {"3"=>5, "2"=>4, "1"=>16.0, "0"=>5.0, :kinmu_total =>17, :night_total =>8},
                  {"3"=>4, "2"=>5, "1"=>19.0, "0"=>7.0, :kinmu_total =>20, :night_total =>8}
                 ]
  must "38,39,43,44のshift_remain" do
    nurce38,nurce39,nurce43,nurce44 = [38,39,43,44].map{|id| nurce(id)}
    assert_equal shift_remain, [nurce38,nurce39,nurce43,nurce44].map(&:shift_remain)
  end


  assinable = {
    [3,"1"]=>20,[3,"2"]=>5,[3,"3"]=>5, [3, :kinmu_total]=>22, [3, :night_total]=>9,
    [4,"1"]=>20,[4,"2"]=>5,[4,"3"]=>5, [4, :kinmu_total]=>22, [4, :night_total]=>9,
    [9,"1"]=>20,[9,"2"]=>5,[9,"3"]=>5, [9, :kinmu_total]=>22, [9, :night_total]=>9
  }
  shift_remain1 = { "1"=>17,"2"=>4,"3"=>5, "0"=>8.0, :kinmu_total =>18,  :night_total=>8}
  shift_remain2 = { "1"=>17,"2"=>4,"3"=>4, "0"=>8.0, :kinmu_total =>17,  :night_total=>7}

  must "Nurce 6 id 40 寺田輝子のアサイン可能なrole" do
    assert_equal assinable, nurce(40).assinable_roles
  end

  must "Nurce 6 id 40 寺田輝子の残っているrole" do
    assert_equal shift_remain1, nurce(40).shift_remain
  end

  must "Nurce 6 id 40 寺田輝子に 2/2 shift3を割り振ると、usedとremainは" do
    nrc =  nurce(40)
    assert_equal  shift_remain1, nurce(40).shift_remain,"割り振り前 remain"
    nrc.set_shift(2,"3")
    assert_equal  shift_remain2, nrc.shift_remain,"割り振り後 remain save前"
    nrc.save_month
    assert_equal  shift_remain2, nurce(40).shift_remain,"割り振り後 remain"
  end
  must "石川トシ子さんの2/4 の [role,勤務]" do
    assert_equal [ [4, "3"],  [10, "3"]],nurce(36).role_shift(@month)[4].sort,"role_shift"
    assert_equal [ [4, 3],[10, 3]],nurce(36).role_shift_of(3).sort,"role_shift_of"
    assert_equal [ [4, 2], [10, 2]],nurce(36).role_shift_of(2).sort,"role_shift_of"
  end
end
