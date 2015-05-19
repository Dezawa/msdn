# -*- coding: utf-8 -*-
require 'test_helper'
Testdata="./test/testdata/shimada/"
Power01 = Testdata+"dezawa_power01_20150401-191041.trz"
Hyum    = Testdata+"temp-hyumidity-20141223-060422.trz"
TD0424   = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150424-060350.trz"
TD0423   = "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_1F休憩所_20150423-060418.trz"
TD0423svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150423-060853.trz"
TD0424svr= "/home/dezawa/MSDN/おんどとり/data/ティアンドデイ社屋_サーバー_20150424-060837.trz"

class Shimada::FactoryTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"
  def setup
    Shimada::Dayly.delete_all
    @factory = Shimada::Factory.find 1
    [TD0424svr,TD0423svr,TD0424,TD0423].each{|trz|  Shimada::Dayly.load_trz(trz)}    
  end

  must "today_graph の結果のgrah_file_pathは" do
    assert_equal (Rails.root+"tmp"+"img"+"temp_vaper_power_1.jpeg").to_s,
                  @factory.today_graph( "temp_vaper_power")
  end

end
