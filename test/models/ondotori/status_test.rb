# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori'
class Ondotori::StatusTest < ActiveSupport::TestCase
  XML = "test/testdata/ondotori/ondotori_current.xml"
  XML2 = "test/testdata/ondotori/ondotori_current2.xml"
  XML3 = "test/testdata/ondotori/ondotori_current_dmy.xml"
  def setup
    Ondotori::Status.delete_all
  end

  must "Load XML " do
    Ondotori::Status.load_xml(XML)
    assert_equal 1, Ondotori::Status.count
  end
  must "Load XML 電波強度 " do
    Ondotori::Status.load_xml(XML)
    assert_equal 5, Ondotori::Status.first.group_remote_rssi
  end
  must "Load XML 電池残量 " do
    Ondotori::Status.load_xml(XML)
    assert_equal 5, Ondotori::Status.first.group_remote_ch_current_batt
  end
  must "groupから最新" do
    [XML,XML2,XML3].each{ |xml| Ondotori::Status.load_xml(xml)}
    assert_equal [],
    Ondotori::Status.select_each_one_from_every_group_by([:base_name, :group_name, :group_remote_name],
                                                         "group_remote_ch_unix_time DESC").
      map{ |st| [st.group_remote_ch_unix_time,st.base_name,st.group_remote_ch_current_batt]}
  end
end
