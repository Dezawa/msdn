# -*- coding: utf-8 -*-
require 'test_helper'
require 'ondotori/trz_files_helper'

class GraphOndotoriTempHumidityTest < ActiveSupport::TestCase
  fixtures "shimada/instrument", "shimada/factory"
  def setup
    Shimada::Dayly.delete_all
    Shimada::Dayly.load_trz(Hyum1223)
    @dayly = Shimada::Dayly.find_by(date: "2014-12-22",
                                    ch_name_type: "フリーザーA-温度")
  end

  must "時刻 " do
    assert_equal [0,5,10,15,20,25], @dayly.time_values[0,6].map(&:min)
  end

  # must "dayly数は二つ" do
  #   gt = Graph::Ondotori::TempHumidity.new(@dayly)
  #   assert_equal 2, gt.objects.size
  # end
  must "12時の温湿度など" do
    gt = Graph::Ondotori::TempHumidity.new(@dayly)
    assert_equal [["2014-12-22 12:00", 3.9, 41.0, 3.31],
                  ["2014-12-22 12:05", 3.9, 40.0, 3.23],
                  ["2014-12-22 12:10", 4.3, 39.0, 3.24]],
      gt.arry_of_data_objects[12*12,3]
  end
  must "datafilesとその12時ころの3行" do
    gt = Graph::Ondotori::TempHumidity.new(@dayly)
    paths = gt.datafiles
    assert_equal ["/opt/www/rails41/msdntest1/tmp/gnuplot/data/data000.data"],
      paths.map(&:to_s)
    assert_equal ["2014-12-22 12:00 3.9 41.0 3.31 ",
                  "2014-12-22 12:05 3.9 40.0 3.23 ",
                  "2014-12-22 12:10 4.3 39.0 3.24 "],
      File.read(paths.first).split("\n")[12*12+1,3] # ＋１ は、ヘッダー行
  end

  must "def file" do
    gt = Graph::Ondotori::TempHumidity.new(@dayly)
    datafile_pathes = gt.datafiles
    def_file = gt.gnuplot_define(datafile_pathes,gt.options)
    #puts def_file
  end

  must "image file" do
    gt = Graph::Ondotori::TempHumidity.
      new(@dayly,
          title_post: "ー#{@dayly.instrument.base_name} " +
            @dayly.instrument.ch_name +
            @dayly.date.strftime(" %m月%d日"),
          #size:  "600,400",
         )
    gt.plot
  end

  must "複数の日選択" do
    Hyums.each{|hyum| Shimada::Dayly.load_trz(hyum)}
    daylies = Shimada::Dayly.where(month: "2015-4-1",
                                 ch_name_type: "1F休憩所-温度")
    gt = Graph::Ondotori::TempHumidity.
      new(daylies ,
          title_post: "ー 2015-4月",
          graph_file: "monthly",
          define_file:      Rails.root+"tmp"+"gnuplot"+"monthly.def",
       xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%m/%d'" ],
         )
    assert_equal 9*24*12, gt.arry_of_data_objects.size
    gt.plot
    
  end
    
end
