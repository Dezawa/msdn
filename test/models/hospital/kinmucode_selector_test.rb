# -*- coding: utf-8 -*-
require 'test_helper'

class Hospital::KinmucodeSelector_Test < ActiveSupport::TestCase
  fixtures :hospital_kinmucodes,:hospital_roles
  fixtures :hospital_defines

  Kubun=  { }
  def setup
  Hash[:nikkin,"日勤",:sankoutai,"三交代",:part,"パート",:touseki,"透析",
                   :l_kin,"L勤",:gairai,"外来",:kyoutuu,"共通"].
    each_pair{ |kinmu,name|  Hospital::Kinmucode::Kubun[kinmu] = (k=Hospital::Role.find_by_name(name)) ? k.id : nil }
  end

  must "勤務区分 " do
    assert_equal ({:part=>8, :nikkin=>6, :kyoutuu=>14, :sankoutai=>7,
                    :touseki=>nil, :l_kin=>nil, :gairai=>nil}
                  ),    Hospital::Kinmucode::Kubun
  end
  
   must "日勤 選択肢" do
    assert_equal "4□ 管",Hospital::Kinmucode.code_nikkin.map{|c| c.code}.join(" ")
   end
  must "三交代 選択肢" do
    assert_equal "1 2 3",Hospital::Kinmucode.code_sanchoku.map{|c| c.code}.join(" ")
   end

  must "休み 選択肢" do
    assert_equal "0 D N",Hospital::Kinmucode.code_holyday.map{|c| c.code}.sort.join(" ")
   end

    must "日勤の希望時 選択肢は" do
      assert_equal "4□ 管 0 N D 1 2 3 S A 会□ 会１  Z□ G R1□ Z/R□ R/G□ J1 出 出/1□ 1/出 出/G Z/出",
      Hospital::Kinmucode.code_for_hope(Hospital::Kinmucode::Kubun[:nikkin]).map{|c,i| c}.join(" ")
    end

  must "三交代の希望時 選択肢は" do
    assert_equal "0 N D 1 2 3 S A L2 L3 会 会1 □ △ ▲ Z G R1 Z/R R/G R2 R3 H1 H2 H3 イ１ イ２ イ３ 1/セ 出 出/1 1/出 出/G Z/出",
    Hospital::Kinmucode.code_for_hope(Hospital::Kinmucode::Kubun[:sankoutai]).map{|c,i| c}.join(" ")
  end
    
end
