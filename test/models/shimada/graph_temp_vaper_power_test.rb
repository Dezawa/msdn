# -*- coding: utf-8 -*-
require 'test_helper'
class Shimada::GraphTempVaperPowerTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"

  Testdata="./test/testdata/shimada/"
  Power01 = Testdata+"dezawa_power01_20150401-191041.trz"
  Hyum    = Testdata+"temp-hyumidity-20141223-060422.trz"

  MSDNDIR  =  "/home/dezawa/MSDN/おんどとり/data/"
  TD01rest = MSDNDIR + "ティアンドデイ社屋_1F休憩所_20150401-060343.trz"
  TD01svr  = MSDNDIR + "ティアンドデイ社屋_サーバー_20150401-063443.trz"
  TD0424   = MSDNDIR + "ティアンドデイ社屋_1F休憩所_20150424-060350.trz"
  TD0423   = MSDNDIR + "ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
  TD0423svr= MSDNDIR + "ティアンドデイ社屋_サーバー_20150423-060853.trz"
  TD0424svr= MSDNDIR + "ティアンドデイ社屋_サーバー_20150424-060837.trz"

  def setup
    Shimada::Dayly.delete_all
  end

  must "grouping_daylies_by_graph_type " do
    load_trz(TD0424,    TD0423  ,  TD0423svr, TD0424svr)
    sgtvp = Shimada::GraphTempVaperPower.new(daylies)
    assert_equal %w(power temp_hyum), sgtvp.grouped_daylies.keys,
      "grouping_daylies_by_graph_typeのkey"

  end

   def daylies
     Shimada::Dayly.by_factory_id(1).where(month: "2015-4-1")
   end
  
   def load_trz(*args)
     args.flatten.each{|file| Shimada::Dayly.load_trz file }
   end
end
