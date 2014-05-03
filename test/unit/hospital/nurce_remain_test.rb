# -*- coding: utf-8 -*-
require 'test_helper'

#################
class Hospital::Nurce < ActiveRecord::Base
  # [0,0,0,1,3,0.....]
  def day_store(shift_list)
    shift_list.each_with_index{|shift,day|  set_shift(day+1,shift.to_s)}
  end


end

class Hospital::NurceTest < ActiveSupport::TestCase
  fixtures :nurces,:hospital_roles,:nurces_roles,:hospital_limits
  fixtures :holydays,:hospital_needs,:hospital_monthlies
  fixtures :hospital_kinmucodes
  # Replace this with your real tests.
  def setup
    @nurces = Hospital::Nurce.all
    @month  = Date.new(2013,2,1)
  end

  def nurce(id); 
    n = Hospital::Nurce.find id
    n.monthly(@month)
    n
  end

  def set_code(nurce,day,code)
    nurce.monthly.day10 = code
    nurce.monthly.store_days
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
  role_used = {
    [3, "0"]=>0,[3,"1"]=>3,[3,"2"]=>1,[3,"3"]=>0, [3, :kinmu_total]=>4, [3, :night_total]=>1,
    [4, "0"]=>0,[4,"1"]=>3,[4,"2"]=>1,[4,"3"]=>0, [4, :kinmu_total]=>4, [4, :night_total]=>1,
    [9, "0"]=>0,[9,"1"]=>3,[9,"2"]=>1,[9,"3"]=>0, [9, :kinmu_total]=>4, [9, :night_total]=>1
  }

  role_remain = {
    [3,"1"]=>17,[3,"2"]=>4,[3,"3"]=>5, [3, :kinmu_total]=>18, [3, :night_total]=>8,
    [4,"1"]=>17,[4,"2"]=>4,[4,"3"]=>5, [4, :kinmu_total]=>18, [4, :night_total]=>8,
    [9,"1"]=>17,[9,"2"]=>4,[9,"3"]=>5, [9, :kinmu_total]=>18, [9, :night_total]=>8
  }

  role_used_2 = {
    [3, "0"]=>0,[3,"1"]=>3,[3,"2"]=>1,[3,"3"]=>1, [3, :kinmu_total]=>5, [3, :night_total]=>2,
    [4, "0"]=>0,[4,"1"]=>3,[4,"2"]=>1,[4,"3"]=>1, [4, :kinmu_total]=>5, [4, :night_total]=>2,
    [9, "0"]=>0,[9,"1"]=>3,[9,"2"]=>1,[9,"3"]=>1, [9, :kinmu_total]=>5, [9, :night_total]=>2
  }
  role_remain_2 = {
    [3,"1"]=>17,[3,"2"]=>4,[3,"3"]=>4, [3, :kinmu_total]=>17, [3, :night_total]=>7,
    [4,"1"]=>17,[4,"2"]=>4,[4,"3"]=>4, [4, :kinmu_total]=>17, [4, :night_total]=>7,
    [9,"1"]=>17,[9,"2"]=>4,[9,"3"]=>4, [9, :kinmu_total]=>17, [9, :night_total]=>7
  }

  must "Nurce 6 id 40 寺田輝子のアサイン可能なrole" do
    assert_equal assinable, nurce(40).assinable_roles
  end

  must "Nurce 6 id 40 寺田輝子の使われたrole" do
    assert_equal role_used, nurce(40).role_used
  end


  must "Nurce 6 id 40 寺田輝子の残っているrole" do
    assert_equal role_remain, nurce(40).role_remain
  end

  must "Nurce 6 id 40 寺田輝子に 2/2 shift3を割り振ると、usedとremainは" do
    nrc =  nurce(40)
    assert_equal role_used  ,nrc.role_used,"割り振り前 used"
    assert_equal role_remain,nrc.role_remain,"割り振り前 remain"
    nrc.set_shift(2,"3")
    assert_equal role_used_2  ,nrc.role_used,"割り振り後 used"
    assert_equal role_remain_2,nrc.role_remain,"割り振り後 remain"
  end
  must "石川トシ子さんの2/4 の [role,勤務]" do
    assert_equal [ [4, "3"],  [10, "3"]],nurce(36).role_shift(@month)[4],"role_shift"
    assert_equal [ [4, 3],[10, 3]],nurce(36).role_shift_of(3),"role_shift_of"
    assert_equal [ [4, 2], [10, 2]],nurce(36).role_shift_of(2),"role_shift_of"
  end


end
