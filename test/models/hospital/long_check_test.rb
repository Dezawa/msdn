# -*- coding: utf-8 -*-
require 'test_helper'
require 'nurce_test_helper'

#################
class Hospital::LongCheckTest < ActiveSupport::TestCase
  include Hospital::Reguration
  fixtures "hospital/nurces"
  fixtures "hospital/monthlies"
  # Replace this with your real tests.
  def setup
     @month  = Date.new(2013,2,1)
    @busho_id = 1
    @assign=Hospital::Assign.new(@busho_id,@month)
    @nurces=@assign.nurces
    srand(1)
  end

  def self.long_patern(sft_str,pat_id)
    Hospital::Nurce::LongPatern[true][sft_str][pat_id]
  end

  def result(long_check_return)
    long_check_return.first ? long_check_return.first.patern :
      long_check_return.last.first.first
  end

  [ [38,2,"3",0,"330"],[38,4,"3",0,"330"],[38,2,"2",1,"220"],
    [38,3,"2",1,"220"],
    [36,1,"3",0,:shinya], [36,1,"3",1,"30"],
    [35,1,"2",0,"220330"],[35,1,"2",1,"220"],[35,1,"2",2,"20"],[35,1,"2",3,"2"],
    [39,1,"3",0,"330"],[39,1,"3",1,"30"],[39,1,"3",2,"3"]
  ].each{ |nurce,day,sft,pat_id,ret|
    long_pat = long_patern(sft,pat_id)
    pat = long_pat.patern
    must "看護師ID#{nurce} 2/#{day}に #{long_pat.patern} OK" do
      assert_equal ret, result(nurce_by_id(nurce,@nurces).
                               long_check(day,sft,long_pat))
    end
  }

  [  [38,5,"3",0,:no_space],[38,2,"2",0,:no_space] ].each{ |nurce,day,sft,pat_id,errorr|
    long_pat = long_patern(sft,pat_id)
    pat = long_pat.patern
    must "看護師ID#{nurce} 2/#{day}に #{pat} #{errorr}" do
      assert_equal [[errorr]],nurce_by_id(nurce,@nurces).
        long_check(day,sft,long_pat).last
    end
  }

  ## re_entrant.rbとの関連
  # [1日に, "3"を, 看護師[45 36]に充てる],"2"を34,46にあてる
  [ [36,1,"3",0,:shinya],[36,1,"3",1,"30"],[36,1,"3",2,"3"],
    [45,1,"3",0,:no_space,1,"3",1,"30"],[45,1,"3",2,"3"],
    [34,1,"2",0,:no_space],[34,1,"2",1,:renkin],[34,1,"2",2,"20"],[34,1,"2",3,"2"],
    [46,1,"2",0,:renkin],[46,1,"2",1,:renkin],[46,1,"2",2,"20"],[46,1,"2",3,"2"],
    [51,1,"2",0,:no_space],[51,1,"2",1,:no_space],[51,1,"2",2,"20"],[51,1,"2",3,"2"],
  ].each{ |nurce,day,sft,pat_id,ret|
    long_pat = long_patern(sft,pat_id)
    pat = long_pat.patern
    must "看護師ID#{nurce} 2/#{day}に #{long_pat.patern} OK" do
      assert_equal ret, result(nurce_by_id(nurce,@nurces).
                               long_check(day,sft,long_pat))
    end
  }
end
