# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori'

class Status::TadnDTest < ActiveSupport::TestCase
  XML = "test/testdata/ondotori/ondotori_current.xml"
  XML2 = "test/testdata/ondotori/ondotori_current2.xml"
  XML3 = "test/testdata/ondotori/ondotori_current_dmy.xml"
  XML4 = "test/testdata/shimada/temp-hyumidity-20150421-120854.xml"
  def setup
   Status::TandD.delete_all
  end

  must "Load XML " do
    Status::TandD.load_xml(XML)
    assert_equal 1,Status::TandD.count
  end
  must "Load XML 電波強度 " do
   Status::TandD.load_xml(XML)
    assert_equal 5,Status::TandD.first.group_remote_rssi
  end
  must "Load XML 電池残量 " do
   Status::TandD.load_xml(XML)
    assert_equal 5,Status::TandD.first.group_remote_ch_current_batt
  end
  must "groupから最新" do
    [XML,XML2,XML3].each{ |xml|Status::TandD.load_xml(xml)}
    assert_equal [[Time.local(2015,1,4,3,52,13), "dumy", 4],
                  [Time.local(2015,1,4,3,48,13), "dezawa", 4]],
   Status::TandD.select_each_one_from_every_group_by([:base_name, :group_name, :group_remote_name],
                                                         "group_remote_ch_unix_time DESC").
      map{ |st| [st.group_remote_ch_unix_time,st.base_name,st.group_remote_ch_current_batt]}
  end

  must "複数channelのデータのchannel名" do
    Status::TandD.load_xml(XML4)
    assert_equal ["渓流", "渓流", "渓流", "渓流", "社屋環境",
                  "社屋環境", "社屋環境", "社屋環境", "社屋環境",
                  "電力監視", "電力監視", "電力監視"
                 ], Status::TandD.all.pluck( :group_name)
    assert_equal ["水源", "上流", "中流", "下流", "フリーザーA", "2F室内",
                  "2F室外E", "2F室外W", "2F室内M", "電力量計", "Office2F", "サーバー"
                 ], Status::TandD.all.pluck( :group_remote_name)
    assert_equal ["", "", "", "", "", "", "", "", "", "", "", ""
                 ], Status::TandD.all.pluck( :group_remote_ch_name)
    assert_equal ["52BA0401", "52BA02DE", "52BA0404", "52BA0400", "52BC036E",
                  "52B8018E", "52BA02DA", "52C000C1", "5FC4003E", "52C203EA",
                  "52C204E6", "52C204E9"
                 ], Status::TandD.all.pluck( :serial)
  end
end
