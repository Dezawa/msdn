# -*- coding: utf-8 -*-
require 'test_helper'
require 'pp'
require 'testdata/result_copy/result_copy_data.rb'
class UbeSkdTest < ActiveSupport::TestCase
  fixtures "ube/plans","ube/products","ube/operations","ube/holydays","ube/change_times","ube/maintains"
  Ope = [:shozow,:shozoe,:yojo,:dryero,:dryern,:kakou]
  # temp_assign_shozo(plan,yojoKo)
  #   temp_assign_maint_plan(plan,plan.shozo?) -> pre_condition
  #   searchfree 
  #   do_sansen?  -> hozen_date
  #         lot,    jun,pro_id,mass,養生庫,shozo_to       
  RAILS_ROOT = Rails.root.to_s
  Plans=[[ "1W0010", 10, 1 , 2304, 3,"2011/9/10 02:00"], # 0 12F化粧(西原) 休日前 9/10 8:00～9/11 08:00 #41700sec=11:35
         [ "1M0011", 20, 1 , 2304, 3,"2011/9/12 02:00"], # 1 12F化粧(西原) 休日明                       #41700sec=11:35
         [ "1W0012", 30, 1 , 2304, 3,"2011/9/12 07:50"], # 2 12F(西原) 平日切り替え10分前           #41700sec=11:35
         [ "1M0013", 40, 1 , 2304, 3,"2011/9/12 07:40"], # 3 12F(西原) 平日切り替え20分前前 #41700sec=11:35
         [ "1W0014", 50, 1 , 2304, 3,"2011/9/12 08:50"], # 4 12F(西原) 平日                 #41700sec=11:35
         [ "1M0015", 60, 1 , 2304, 4],                   # 5 12F(西原)                      #41700sec=11:35
         [ "1M0016", 70, 9 , 2304, 4],                   # 6 12F(西原)                      #5:45.6 -> 5:50
         [ "2W0030", 80, 4 , 2304,14,"2011/9/14 12:40"], # 7 12F(西新) 平日 9/14 12F 200枚/hr
         [ "2W0031",100, 2 , 1728, 9],                   # 8 12F(西新) 12F  2304 -> 11.2    #31200sec=8:40
         [ "2W0032",110, 2 , 1728, 7],                   # 9 12F(西新)                    1728 ->  8.62
         [ "2W0033",120, 2 , 2304,13],                   #10 12F(西新)
         #                                              [dry_to,           dry_end]
         [ "2M0054", 90, 8 , 2304,15,"2011/9/16 00:15",["2011/9/18 03:30","2011-09-18 01:00"]] #11 12普及(東新) 平日 9/16
        ]
  PLANS = 
    {
    :shozoe => [
                ["2M0221",100,2,1000,3],
                ["2M0222",100,2,1000,3],
                ["2M0223",100,2,1000,3]
               ],
    :shozow => [

                ["2W0254",100,2,1000,3],
                ["2W0255",100,2,1000,3],
                ["2W0256",100,2,1000,3],
                ["2W0257",100,2,1000,3],
                ["2W0258",100,2,1000,3]
               ],
    :dryn => [
              ["2W0231",100,2,1000,3],
              ["2W0232",100,2,1000,3],
              ["2W0233",100,2,1000,3],
              ["2W0234",100,2,1000,3],
              ["2W0235",100,2,1000,3],
              ["2W0236",100,2,1000,3]
             ],
    :dryo => [
              ["2W0244",100,2,1000,3],
              ["2W0245",100,2,1000,3],
              ["2W0246",100,2,1000,3],
              ["2W0247",100,2,1000,3],
              ["2W0248",100,2,1000,3]
             ],
    :kakou => [
               ["2M0216",100,2,1000,3],
               ["2M0217",100,2,1000,3],
               ["2M0218",100,2,1000,3],
               ["2M0219",100,2,1000,3],
               ["2M0220",100,2,1000,3],
               ["2W0238",100,2,1000,3],
               ["2W0239",100,2,1000,3]
              ]
  }


  def setup
    #@skd0=Ubeboard::Skd.find(96,:include=>:ube_plans)
    #@skd=Ubeboard::Skd.find(97,:include=>:ube_plans)
  end


  def make_skd(planidx,sansen,plans=Plans,pre_plans=0)
    skd=Ubeboard::Skd.create(:skd_from => Time.parse("2011/9/1"),:skd_to => Time.parse("2011/9/30"))
    skd.after_find_sub; skd.freeList
    skd.hozen_date[:shozow]=Time.parse(sansen).day    
    ube_plans = planidx.map{|p| plans[p]}.map{|lot,jun,pro_id,mass,yojoko,to,dry| 
      dry_to,dry_end = dry
      Ubeboard::Plan.new(:plan_shozo_to => (to ? Time.parse(to) : nil),
                  :plan_shozo_from => (to ? Time.parse(to)-10.hour : nil),
                  :plan_dry_to   => (dry_to ? Time.parse(dry_to) : nil ),
                  :plan_dry_end   => (dry_end ? Time.parse(dry_end) : nil ),
                  :mass => mass, :lot_no => lot,:jun => jun,
                  :ube_product_id => pro_id,:yojoko => yojoko)
    }

    skd.ube_plans = ube_plans
    #skd.pre_condition[:shozow] = ube_plans[0]
    skd
  end

  def all_time(plan)
    [:shozo,:yojo,:dry,:kakou].map{|ope| times = Ubeboard::Skd::PlanTimes[ope]
      "\n"+ope.to_s + "\t"+
      times.map{|t| plan[t] ? plan[t].strftime("%d-%H:%M") : "..-..:.."}.join(" ")
    }.join
  end
###########  休転が ##################
###########  ### 実績コピー ##################
  files = Dir.glob("/home/dezawa/MSDN/Deverop/ubeboad/提供資料/gomi.*").sort
  ope = [:shozoe,:shozoe,:shozow,:shozow,:dryn,:dryn,:dryo,:dryo,:kakou,:kakou]
  #puts files
  files.each_with_index{|file,idx|
    must "file #{file.sub(/.*\//,'')} のu工程" do
      skd = make_skd([1,4],"2011/9/11")
      lines = File.read file
      assert_equal ope[idx],skd.extruct_real_ope(lines)
    end
  }
  
  # Excel_dataから実績データの日付ぬきとりd=Date.new(1899,12,30)
  files = Dir.glob(RAILS_ROOT+"/test/testdata/各運転日報.csv.*").sort
  ymd = [[2012,4,21],[2012,4,26],[2012,4,25],[2012,4,26],[2012,4,19],
         [2012,4,20],[2012,4,25],[2012,4,26],[2012,4,25],[2012,4,26]
       ]
  files.each_with_index{|file,idx|
    must "file #{file.sub(/.*\//,'')} の日付" do
      skd = make_skd([1,4],"2011/9/11")
      lines = File.read file
#puts [file,lines.split("\n")[1],/(\d{4})\/(\d{1,2})\/(\d{1,2}) / =~ lines]
      assert_equal ymd[idx],skd.extract_ymd(lines)
    end
  }
  
  
  dir = RAILS_ROOT+"/test/testdata/result_copy/"
  # Excel データがCSVに変換される
  Excel2Csv=[
             [ "複数シート、拡張子xls","各運転日報.xls","各運転日報",%w(.0 .1 .2 .3 .4 .5 .6 .7 .8 .9)],
             [ "複数シート、拡張子なし","各運転日報拡張子無","各運転日報拡張子無",%w(.0 .1 .2 .3 .4 .5 .6 .7 .8 .9)],
             [ "単一シート、拡張子xls","reporte21.xls","reporte21",[".0"]],
             [ "複数シート、拡張子xlsx","敬老対象者H22.xlsx","敬老対象者H22",%w(.0 .1 .2 .3)]
            ]
  NotExcel = [[ "PDFファイル","HL-2240D.pdf","",["HL-2240D.pdf"]]]
  
  # 型を調べ、excelならCSVに変換する
  (Excel2Csv+NotExcel).each{|msg,path,base,csvs|
    must "型を調べ、excelならCSVに変換す　"+msg do
      File.unlink(*Dir.glob(dir+base+".[0-9]"))
      skd = make_skd([1,4],"2011/9/11")
      file = open(dir + path)
      files = skd.ssconvert_if_excel(file, dir+base).
        map{|path| File.basename(path)}
      csvfiles = csvs.map{|c| base+c}
      #File.unlink( *files)
      assert_equal_array csvfiles,files
    end
  }

  Excel2Csv.each{|msg,path,base,csvs|
    must "Excel データがCSVに変換される　"+msg do
      File.unlink(*Dir.glob(dir+base+".[0-9]"))
      skd = make_skd([1,4],"2011/9/11")
      files = skd.ssconvert(dir+path, dir+base).
        map{|path| File.basename(path)}
      csvfiles = csvs.map{|c| base+c}
      #File.unlink( *files)
      assert_equal_array csvfiles,files
    end
  }
  CsvFiles = {
    :shozoe =>dir+"東抄造.csv",
    :shozow =>dir+"西抄造.csv",
    :dryn   =>dir+"新乾燥.csv",
    :dryo   =>dir+"原乾燥.csv",
    :kakou  =>dir+"加工.csv"
  }
  FirstLot =  {
    :shozoe => [1,"2M0284",4],  #4
    :shozow => [1,"2W0314",11],  #11
    :dryn   => [7,"2W0305",13], #13
    :dryo   => [7,"2M0276",14], #14
    :kakou  => [1,"2M0260",19]  #21
  }
  [:shozow,:shozoe,:dryo,:dryn,:kakou].each{|real_ope|
    must "Csvからデータ行抜きだし 最初のロット#{CsvFiles[real_ope]}" do
      lines = File.read CsvFiles[real_ope]
      skd = make_skd([1,4],"2012/5/26")
      rows = skd.extruct_rows(real_ope,lines)
      assert_equal(
                   FirstLot[real_ope][1],
                   skd.normalize_lotno(rows[0][ FirstLot[real_ope][0]])

                   )
    end
  }


  [:shozow,:shozoe,:dryo,:dryn,:kakou].each{|real_ope|
    must "Csvからデータ行抜きだし 行数 #{CsvFiles[real_ope]}" do
      lines = File.read CsvFiles[real_ope]
      skd = make_skd([1,4],"2012/5/26")
      rows = skd.extruct_rows(real_ope,lines)
      assert_equal( FirstLot[real_ope][2], rows.size  )
    end
  }
  # Excel_dataから 抄造データの抽出
  [:shozow,:shozoe].each{|real_ope|
    must "Excel_dataから抄造データ：必要カラム抜き取り #{real_ope} #{CsvFiles[real_ope]}" do
      skd = make_skd([1,4],"2012/5/26")
      lines = File.read CsvFiles[real_ope]
      extract = skd.extract_data(real_ope,[2012,5,26],lines).map{|l,s,e,m,y,yy| [l,s,e,y,yy]}
      
      assert_equal Excel_expect[real_ope][1],extract
    end
  }

  # Excel_dataから 乾燥データの抽出
  [:dryo,:dryn].each{|real_ope|
    must "Excel_dataから乾燥データ：必要カラム抜き取り #{real_ope} #{ CsvFiles[real_ope]}" do
      skd = make_skd([1,4],"2012/4/26")
      lines = File.read CsvFiles[real_ope]
      extract = skd.extract_data(real_ope,[2012,5,26],lines)
      rslt = Excel_expect[real_ope][1]
      assert_equal_array rslt, extract# ((rslt|extract)-(rslt&extract))
      
    end
  }

  must "Excel_dataから加工データ：必要カラム抜き取り #{CsvFiles[:kakou]}" do
    skd = make_skd([1,4],"2012/5/26")
      lines = File.read CsvFiles[:kakou]
    extract = skd.extract_data(:kakou,[2012,5,26],lines)
    rslt = Excel_expect[:kakou][1]
#pp rslt-extract
#pp extract-rslt
    assert_equal rslt,extract
  end

end
__END__
#
###########  ### 実績コピー ##################

  
  #実際にデータを入れる
   #[:shozow,:shozoe,:dryo,:dryn,:kakou].each{|real_ope|
   [:shozow,:shozoe,:dryo,:dryn,:kakou].each{|real_ope|
    must "実際にデータを入れる #{real_ope}" do
    puts "## 実際にデータを入れる #{real_ope} ###"
      skd = make_skd((0..PLANS[real_ope].size-1),"2012/4/26",PLANS[real_ope])
      skd.result_update({real_ope => Excel_data[real_ope]})
      rslt= skd.ube_plans.map{|plan| [plan.lot_no]+Ubeboard::Skd::Reuslts.map{|t| plan[t]}+[plan.mass] }
      expect = CopyResult[real_ope]
      e_r = expect - rslt
      r_e = rslt - expect
      assert_equal e_r,r_e
    end
  }
  

end
__END__

###########
R0 ="
shozo	01-21:40 02-09:15 ..-..:.. ..-..:..
yojo	02-10:15 04-02:15 ..-..:.. ..-..:..
dry	04-02:25 04-13:05 ..-..:.. ..-..:.. 04-05:33 04-09:57
kakou	07-08:00 07-11:35 ..-..:.. ..-..:.."
R1 ="
shozo	01-21:40 02-09:15 01-23:00 02-03:00
yojo	02-10:15 04-02:15 ..-..:.. ..-..:..
dry	04-02:25 04-13:05 ..-..:.. ..-..:.. 04-05:33 04-09:57
kakou	07-08:00 07-11:35 ..-..:.. ..-..:.."
R2 ="
shozo	01-21:40 02-09:15 01-23:00 02-06:00
yojo	02-10:15 04-02:15 ..-..:.. ..-..:..
dry	04-02:25 04-13:05 ..-..:.. ..-..:.. 04-05:33 04-09:57
kakou	07-08:00 07-11:35 ..-..:.. ..-..:.."
R3 ="
shozo	01-21:40 02-09:15 ..-..:.. ..-..:..
yojo	02-10:15 04-02:15 02-10:15 04-02:15
dry	04-02:25 04-13:05 04-03:00 04-06:59 04-05:33 04-09:57
kakou	07-08:00 07-11:35 ..-..:.. ..-..:.."
R = [R0,R0,R1,R2,R3]
Date ="2011 年\t9月1日\n"
  Shozow = ["1W0002\t\t\t\t\t23:00\t03:00\t\t\t\t\t\t2800","1W0002\t\t\t\t\t03:00\t06:00","1W0002\t\t\t\t\t07:00\t08:00"]
  Sozo   = [["07-23は今日、00-06は明日",[2011,9,1,23] ,[2011,9,2,3]] ,
            ["00-06は明日0", [2011,9,2,3],[2011,9,2,6]]  ,
            ["07～は今日",[ 2011,9,1,7],[2011,9,1,8]]
           ]
Date2="2011 年\t9月3日\n"
  Dryo   = ["1W0002\t\t\t\t\t03:00\t06:59"]
  Kako   = ""
  CopyResult = [[ "データがないので、実績には何も入らない ",{:shozow=>""}], 
                [ "日付が無いので実績には何も入らない ",{:shozow=>Shozow[0]}],
                [ "抄造に実績が入る " ,{:shozow => Date+Shozow[0]}],
                [ "抄造に実績,組の切れ目の処理",{:shozow => Date+Shozow[0..1].join("\n")}],
                [ "加工に実績を入れる。養生にも入る",{:dryo => Date2+Dryo.join("\n")}]
               ]
  must "実績データのぬきとり" do
    skd = make_skd([1,4],"2011/9/11")
    assert_equal %w(1W0002 23:00 03:00 2800),skd.extract_data(:shozow,Date+Shozow[0])
  end
  Shozow.each_with_index{|sh,idx|
    must "実績データの時刻補正 "+Sozo[idx][0] do
      skd = make_skd([1,4],"2011/9/11")
      y,m,d = skd.extract_ymd(Date+sh)
      results=skd.extract_data(:shozow,Date+sh)
      rsrt=  ["1W0002", Time.gm(*Sozo[idx][1]), Time.gm(*Sozo[idx][2])]
      assert_equal rsrt , skd.modify_time(:shozow,results,y,m,d)
    end
  }
  must "実績データの日付ぬきとり " do
      skd = make_skd([1,4],"2011/9/11")
      assert_equal [2011,9,1],skd.extract_ymd(Date+Shozow[0])
  end

  CopyResult.each_with_index{|data,idx|
    must "実績コピー_"+data[0] do
      # No 1,4 を割り付ける。 "1W0014", 50, 1 , 2304, 3,"2011/9/12 08:50"], # 4 12F(西原) 平日 
      skd = make_skd([1,4],"2011/9/11")
      #puts all_time(skd.ube_plans[0])
      skd.make_plan
      skd.result_update(data[1])
      assert_equal R[idx], all_time(skd.ube_plans[1])
    end
  }
########################
  #休日は9/10
  #             酸洗した日   抄造割り当て開始(要5hr)
  DoSansen = [ [ "2011/9/09", "2011/9/11 11:00",  false ,"休日明けは酸洗するが始業に含まれる"],
               [ "2011/9/09", "2011/9/12 02:00",  false ,"休日明けは酸洗するが始業に含まれる"],
               [ "2011/9/12", "2011/9/12 12:00",  false ,"酸洗した日はもうしない"],
               [ "2011/9/12", "2011/9/13 12:00",  true  ,"酸洗してないからやる"],
               [ "2011/9/12", "2011/9/13 02:00",  false  ,"深夜は前の日扱いなので、酸洗しない"],
               [ "2011/9/12", "2011/9/13 06:00",  false  ,"8:00をまたぐ抄造は前の日扱いなので、酸洗しない"]
             ]
  # do_sansen?(shozo_assign,real_ope)
  #
  
  DoSansen.each{|done,from,result,msg|
    must msg do
      skd=Ubeboard::Skd.new(:skd_from => Time.parse("2011/9/1"),:skd_to => Time.parse("2011/9/30"))
      skd.hozen_date[:shozow]=Time.parse(done).day
      shozo_from = Time.parse(from) ; shozo_to = shozo_from+5.hour
      assert_equal result, skd.do_sansen?([shozo_from,shozo_to],:shozow)
    end
  }


  AssignMult = [ [[7,8,9,10],"2011/9/13",
                  ["09141240 09141440 45 09141440 09142320", #31200sec=8:40
                   "09142320 09142325 切替 09142325 09150805",
                   "09150805 09151005 45 09151005 09152140"],"複数の割付。抄造だけ"]] #41700sec=11:35

  # 休日確認
  Holyday={:shozow => [3,4,10,16,22,23,24,25,30]}

  #               plans  酸洗        結果  保全              抄造             memo 
  AssignShozo = [[[0,5] ,"2011/9/9" ,"09100200 09100205 09111100 09112235","休日前->始業作業後。酸洗はない" ],
                 [[1,5] ,"2011/9/9" ,"09120200 09120205 09120205 09121340","休日明け->　。酸洗は済んでる"], 
                 [[2,5] ,"2011/9/11","09120750 09120755 09120755 09121930","8時直前に切り替え終了"],     
                 [[3,6] ,"2011/9/11","09120740 09120940 09120940 09121530","08:00をまたぐ切り替え"]
                ]
  #抄造1ロットのテスト 
  AssignShozo.each{|plans,sansen,result,memo|
    must "抄造仮割付 #{memo}" do
      skd = make_skd(plans,sansen)
      skd.pre_condition[:shozow] = skd.ube_plans[0]
      plan = skd.ube_plans[1]
      hozen,shozo = skd.temp_assign_shozo(plan,skd.yojoko[plan.yojoko])
      times=(hozen[0..1]+shozo[0..1]).map{|t| t.mdHM }
      hozen_code = hozen[2]
      assert_equal result,times.join(" ")
    end
  }

  #抄造連続のテスト
AssignMult.each{|plans,sansen,results,memo|
    (0..plans.size-2).each{|idx|
      must "抄造複数 #{memo} idx=#{idx}" do
        ho_sh=[]
        skd = make_skd(plans,sansen)
        skd.pre_condition[:shozow] = skd.ube_plans[0]
        ube_plans = skd.ube_plans[1..-1].sort_by{|p| p.jun}
        ube_plans[0..idx].each{|plan|
          ho_sh = skd.temp_assign_shozo(plan,:shozow)
          skd.assign_maint_plan_by_temp(plan,:shozow,ho_sh)
        }
        plan = ube_plans[idx]
        # puts "#{idx}:lot #{plan.lot_no} mass=#{plan.mass} #{plan.ope_length(:shozow)[0]/60}"
        hozen,shozo=ho_sh
        times=ho_sh.flatten[0..4].map{|t| if t.class==Time ; t.mdHM ; else;t.to_s;end }
        hozen_code = hozen[2]
        assert_equal results[idx],times.join(" ")
      end
    }
  }

 
 # 乾燥の空き具合もみながらわりつける。
  # 　2W0030のあと2W0031の前後に同じ日に二度酸洗がはいってしまうげんいん
  #   2W0032の前に24時間の空きができてしまう原因を探る
  #   乾燥が詰っているための再割付が絡んでいそうなことまでは確認した
  # 2W0030が西抄造の pre_condition, 2M0054 が原乾燥のpre_conditon
  # idx7                              idx 11,  idx 8,9,10 を割り付ける
         # 0 12F化粧(西原) 休日前 9/10 8:00～9/11 08:00 #41700sec=11:35
         # 1 12F化粧(西原) 休日明                       #41700sec=11:35
         # 2 12F(西原) 平日切り替え10分前           #41700sec=11:35
         # 3 12F(西原) 平日切り替え20分前前 #41700sec=11:35
         # 4 12F(西原) 平日                 #41700sec=11:35
         # 5 12F(西原)                      #41700sec=11:35
         # 6 12F(西原)                      #5:45.6 -> 5:50
         # 7 12F(西新) 平日 ～/14 12:40 12F 200枚/hr
         # 8 12F(西新) 12F  2304 -> 11.2    #31200sec=8:40
         # 9 12F(西新)                    1728 ->  8.62
         #10 12F(西新)
         #11 12普及(東新) 平日 9/16 乾燥 ~～/18 1:00

  Results = 
    [ #   保守・切り替え　　　,　　　　抄造　　　　 ,　　　　　養生　　　 ,　　　　　　乾燥
     [45,"乾燥が開かないので開始は 遅れる",
      ["14 12:40","14 14:40","14 14:40","14 23:20","15 10:05","17 02:05","18 01:05","18 08:10","18 05:40"]],
     ["切替","乾燥が開かないので養生が遅れる",
      ["14 23:20","14 23:25","14 23:25","15 08:05","15 14:45","17 6:45","18 05:45","18 12:50","18 10:20"]],
     [45,"酸洗が入る",
      ["15 08:05","15 10:05","15 10:05","15 21:40","15 22:40","17 14:40","18 10:25","18 19:00","18 16:30"]]
    ]
 
(0..2).each{|idx|  # Plans 8,9,10 について順次割り付ける
  must "連続割付_#{Results[idx][1]}" do
    ho_sh=[]
    skd = make_skd([7,11,8,9,10],"2011/9/13")
    skd.pre_condition[:shozow] = skd.ube_plans[0]
    # 7 12F(西新)    平日 ～/14 12:40 これが西のpre
    #11 12普及(東新) 平日 乾燥空き 9/18 01:00 
    # 8 12F(西新) 　乾燥が開かないので遅れる。31200sec=8:40
    #     18 01:00 - 8:40 - 72h - 24h - 40h = 18d1:00 - 6d0:40 = 12 0:20以降
    # 9 12F(西新)   09142320+0:05+ 8:40 = 15d08:00               1728 ->  8.62
    #10 12F(西新)   No9が08:05に終わるから酸洗が入る

    skd.pre_condition[:dryn] = skd.ube_plans.sort_by{|p| p.jun}[1]
    #pp skd.freeList[:dryn]
    ube_plans = skd.ube_plans.sort_by{|p| p.jun}[2..-1]
    ube_plans[0..idx].each{|plan|
      #ho_sh = skd.temp_assign_shozo(plan,:shozow)
      #skd.assign_temp_and_real(plan,skd.yojoko[plan.yojoko])
      shozo,yojo,dry = skd.temp_assign_all_plan(plan,skd.yojoko[plan.yojoko])
      ho_sh << shozo[0]
      skd.assign_maint_plan_by_temp(plan,plan.shozo?,shozo)
      skd.assign_maint_plan_by_temp(plan,:yojo,yojo) 
      skd.assign_maint_plan_by_temp(plan,plan.dry?,dry) 
    }
    plan = ube_plans[idx]
    # puts "#{idx}:lot #{plan.lot_no} mass=#{plan.mass} #{plan.ope_length(:shozow)[0]/60}"
    #hozen,shozo=ho_sh
    # 45 抄造保守f,t、抄造f,t 養生f,t 乾燥f,t,e
    times=[ho_sh[idx][2]] + 
      ho_sh[idx][0..1].map{|t| t.mdHM} +
      Ubeboard::Skd::PlanTimesSym[0..6].map{|t| plan[t].mdHM }
    #hozen_code = hozen[2]              
    result = ([Results[idx][0]]+Results[idx][2].map{|t| Time.parse("2011/09/"+t).mdHM}).join(" ")
    assert_equal result,times.join(" ")
  end
}




end
__END__


  must  "holyday" do
    #skd=Ubeboard::Skd.find 2
    #asser _equal 5,skd.holydays.size
  end

  must  "freelis " do
#    skd=Ubeboard::Skd.find 2
#    asser _equal 5,skd.freeLis 
  end
end
__END__
