# -*- coding: utf-8 -*-
require 'test_helper'

Testdata="./test/testdata/shimada/"
Power01 = Testdata+"dezawa_power01_20150401-191041.trz"
Hyum    = Testdata+"temp-hyumidity-20141223-060422.trz"

class Dumy
  attr_accessor :item1,:item2,:item3
  def initialize( *args )
    @item1,@item2,@item3 = args
  end
end

CaseString = Power01
CaseArryString = [Power01,Hyum]
CaseArryArry   = [["abc",10,20],["def",11,21]]
#CaseArryObject     = 


class GnuplotTest < ActiveSupport::TestCase

  must "CaseString" do
     gp = Graph::Base.new(CaseString)
     assert_equal [Power01], gp.datafiles#(gp.arry_of_data_objects,{})
   end
  
   must "CaseArryString" do
     gp = Graph::Base.new(CaseArryString)
     assert_equal [Power01,Hyum], gp.datafiles#(gp.arry_of_data_objects,{})
     end
   must "CaseArryArry" do
   gp = Graph::Base.new(CaseArryArry)
     path = Rails.root+"tmp"+"gnuplot"+"data"+"data000.data"
     assert_equal [path],
       gp.datafiles(gp.arry_of_data_objects,
                    gp.option.merge(column_format: "%s %d %d"))
     assert_equal "abc 10 20 \ndef 11 21 \n\n", path.read
   end
   
   must "CaseArryObject " do
     i1i2 = [[ 1,2,"a"],[11,12,"b"]].map{|a| Dumy.new(*a) }
     gp = Graph::Base.new(i1i2,column_attrs: [:item1,:item2,:item3])
     path = Rails.root+"tmp"+"gnuplot"+"data"+"data000.data"
     gp.datafiles(gp.arry_of_data_objects,
                    gp.option.merge(column_format: "%.1f %d %s"))
     assert_equal "1.0 2 a\n11.0 12 b\n\n",path.read
   end
end
