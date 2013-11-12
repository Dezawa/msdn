# -*- coding: utf-8 -*-
class UbeSkdTest < ActiveSupport::TestCase
Excel_expect =
    { :shozoe => [ [2012,4,26],
                   [
                    ["2M0284", "05/26-07:00", "05/26-10:24", nil, nil],
                    ["2M0285", "05/26-10:24", "05/26-15:00", nil, nil],
                    ["2M0284", nil, nil, "06/06-10:40", 5],
                    ["2M0285", nil, nil, "06/06-15:10", 6]
                   ]
                 ],
    :shozow => [ [2012,4,25],
                 [
                  ["2W0314", "05/26-07:00", "05/26-13:40", nil, nil],
                  ["2W0315", "05/26-13:40", "05/26-15:00", nil, nil],
                  ["2W0315", "05/26-15:00", "05/26-20:15", nil, nil],
                  ["2W0316", "05/26-20:15", "05/26-23:00", nil, nil],
                  ["2W0316", "05/26-23:00", "05/27-02:05", nil, nil],
                  ["2W0317", "05/27-02:05", "05/27-07:00", nil, nil],
                  ["2W0314", nil, nil, "05/26-13:50", 5],
                  ["2W0315", nil, nil, "05/26-20:10", 3],
                  ["2W0316", nil, nil, "05/27-02:00", 4],
                  ["2W0317", nil, nil, nil, 6]
                 ]
               ],
    :dryo => [ [2012,4526],
               [
                [nil, nil               , "2M0276", "05/26-12:00"],
                ["2M0277", "05/26-09:00", "2M0277", "05/26-14:25"],
                ["2M0278", "05/26-11:15", "2M0278", "05/26-15:00"],
                [nil, nil               , "2M0278", "05/26-20:13"],
                ["2M0279", "05/26-17:30", "2M0279", "05/26-23:00"],
                [nil, nil               , "2M0279", "05/27-01:50"],
                [nil, nil               , "2M0280", "05/27-06:27"],
                [nil, nil               , "2M0280", "05/27-07:00"]
               ]
             ],
    :dryn => [[2012,5,19],
              [
               [nil, nil               , "2W0305", "05/26-08:20"],
               ["2W0307", "05/26-10:55", "2W0306", "05/26-15:00"],
               ["2W0307", "05/26-14:35", "2W0306", "05/26-16:15"],
               ["2W0308", "05/26-18:05", "2W0307", "05/26-21:30"],
               [nil, nil               , "2W0307", "05/26-23:00"],
               [nil, nil               , "2W0307", "05/27-00:45"],
               ["2W0309", "05/27-01:45", "2W0308", "05/27-07:00"]
              ]
             ],
    :kakou => [[2012,5,25],
               [["2M0260", "05/26-07:00", "05/26-10:35"],
                ["2M0260", "05/26-10:35", "05/26-11:40"],
                ["2M0261", "05/26-11:40", "05/26-15:00"],
                ["2M0261", "05/26-15:00", "05/26-17:25"],
                ["2M0262", "05/26-17:35", "05/26-21:10"],
                ["2M0263", "05/26-21:50", "05/26-23:00"],
                ["2M0263", "05/26-23:00", "05/27-01:20"],
                ["2M0263", "05/27-01:20", "05/27-02:00"],
                ["2M0264", "05/27-02:00", "05/27-05:05"],
                ["2M0265", "05/27-05:05", "05/27-07:00"],
                ["2M0260", nil, nil],
                ["2M0260", nil, nil],
                ["2M0261", nil, nil],
                ["2M0262", nil, nil],
                ["2M0263", nil, nil],
                ["2M0263", nil, nil],
                ["2M0264", nil, nil],
                ["2M0260", nil, nil],
                ["2M0261", nil, nil]
               ]
              ]
  }
  Excel_expect.each{|k,exp| exp[1].each{|row|
        row[1] = Time.parse row[1] if  row[1]
        row[2] = Time.parse row[2] rescue row[2] if  /\d\d\/\d\d-\d\d:\d\d/ =~ row[2]
        row[3] = Time.parse row[3] rescue row[3] if  /\d\d\/\d\d-\d\d:\d\d/ =~  row[3]
    }
 }
  CopyResult={
    :shozow => [
 ["2W0254", Time.parse("04/25-07:00"), Time.parse("04/25-13:30"), nil, nil, nil, nil, nil, nil, 1000],
 ["2W0255",  Time.parse("04/25-13:30"),  Time.parse("04/25-19:05"),  Time.parse("04/25-19:15"),  Time.parse("04/27-11:15"),  nil,  nil,  nil,  nil,  1000],
 ["2W0256", Time.parse("04/25-19:05"),  Time.parse("04/25-22:04"),  Time.parse("04/25-22:10"),  Time.parse("04/27-14:10"),  nil,  nil,  nil,  nil,  1000],
 ["2W0257", Time.parse("04/25-22:04"), Time.parse("04/26-02:38"), nil, nil, nil, nil, nil, nil, 1000],
 ["2W0258", Time.parse("04/26-02:38"), Time.parse("04/26-07:00"), nil, nil, nil, nil, nil, nil, 1000]
               ],
    :shozoe => [
 ["2M0221", Time.parse("04/26-07:00"), Time.parse("04/26-17:56"), nil, nil, nil, nil, nil, nil, 1000],
 ["2M0222", Time.parse("04/26-17:56"), Time.parse("04/27-01:20"), nil, nil, nil, nil, nil, nil, 1000],
 ["2M0223", Time.parse("04/27-01:20"), Time.parse("04/27-07:00"), nil, nil, nil, nil, nil, nil, 1000]
               ],
    :dryo => [
 ["2W0244", nil, nil, nil, nil, nil, Time.parse("04/26-09:00"), nil, nil, 1000],
 ["2W0245", nil, nil, nil, nil, nil, Time.parse("04/26-18:00"), nil, nil, 1000],
 ["2W0246", nil, nil, nil, nil, Time.parse("04/26-12:43"), Time.parse("04/27-00:30"), nil, nil, 1000],
 ["2W0247", nil, nil, nil, nil, Time.parse("04/26-21:00"), Time.parse("04/27-07:00"), nil, nil, 1000],
 ["2W0248", nil, nil, nil, nil, Time.parse("04/27-04:20"), nil, nil, nil, 1000]
             ],
    :dryn => [
 ["2W0231", nil, nil, nil, nil, nil, Time.parse("04/19-12:00"), nil, nil, 1000],
 ["2W0232", nil, nil, nil, nil, Time.parse("04/19-08:01"), Time.parse("04/19-16:40"), nil, nil, 1000],
 ["2W0233", nil, nil, nil, nil, Time.parse("04/19-12:30"), Time.parse("04/19-21:50"), nil, nil, 1000],
 ["2W0234", nil, nil, nil, nil, Time.parse("04/19-17:10"), Time.parse("04/20-03:10"), nil, nil, 1000],
 ["2W0235", nil, nil, nil, nil, Time.parse("04/19-22:45"), Time.parse("04/20-07:00"), nil, nil, 1000],
 ["2W0236", nil, nil, nil, nil, Time.parse("04/20-04:40"), nil, nil, nil, 1000]
             ],
    :kakou => [
 ["2M0216", nil, nil, nil, nil, nil, nil, Time.parse("04/25-07:00"), Time.parse("04/25-08:15"), 1000],
 ["2M0217", nil, nil, nil, nil, nil, nil, Time.parse("04/25-08:55"), Time.parse("04/25-12:00"), 1000],
 ["2M0218", nil, nil, nil, nil, nil, nil, Time.parse("04/25-12:40"), Time.parse("04/25-16:40"), 1000],
 ["2M0219", nil, nil, nil, nil, nil, nil, Time.parse("04/25-17:45"), Time.parse("04/25-22:05"), 1000],
 ["2M0220", nil, nil, nil, nil, nil, nil, Time.parse("04/25-22:20"), Time.parse("04/26-01:50"), 1000],
 ["2W0238", nil, nil, nil, nil, nil, nil, Time.parse("04/26-02:50"), Time.parse("04/26-05:55"), 1000],
 ["2W0239", nil, nil, nil, nil, nil, nil, Time.parse("04/26-06:20"), Time.parse("04/26-07:00"), 1000]
]
  }
Excel_data = {}
require 'excel_shozoe'
require 'excel_shozow'
require 'excel_dryn'
require 'excel_dryo'
require 'excel_kakou'

end
