# -*- coding: utf-8 -*-
module Sola::Graph
  include Gnuplot
  module ClassMethod
  include Gnuplot

    def monthly_graph(graph_file=nil,graph_file_dir=nil)
      opt = { 
        :graph_file => graph_file || "sola_monthly" ,
        :graph_file_dir => graph_file_dir || Rails.root+"tmp" + "img",
        :define_file => Rails.root+"tmp/gnuplot/sola_monthly.def",
        :column_labels => %w(年月 発電量),
        :axis_labels   => { :xlabel => "年月",:ylabel => "月間発電量/kW"},
        :title => "月間発電量推移" , 
        :tics =>  { :xtics => "rotate by -90"},
        :point_type => [7],
        :set_key => "unset key",
        :xy => [[[2,3]]]
      }

      data_list = Sola::Monthly.all.order("month").pluck(:month, :sum_kwh, :sum_kwh)
      file = Rails.root+"tmp"+"Sola_monthly.data"
      data_file_output_monthly(file,data_list,"No 年月 電力")
      gnuplot_(file.to_s,opt)
    end


    def dayly_graph(graph_file=nil,graph_file_dir=nil)
      opt = { 
        :graph_file => graph_file || "sola_dayly" ,
        :graph_file_dir => graph_file_dir || Rails.root+"tmp" + "img",
        :define_file => Rails.root+"tmp/gnuplot/sola_dayly.def",
        :column_labels => %w(年月日 発電量), :column_format => %w(%s %.1f),
        :axis_labels   => { :xlabel => "年月日",:ylabel => "発電量/kW"},
        :title => "発電量推移" , 
        :tics =>  { :xtics => "rotate by -90"},
        :point_type => [7],
        :type => "scatter",
        :set_key => "unset key",
        :set => ["xdata time",
                 "timefmt '%Y-%m-%d'",
                 #"xrange ['03/21/95':'03/22/95']",
                 "format x '%Y-%m-%d'"],
        :xy => [[[1,2]]]
      }

      data_list = Sola::Monthly.all.order("month")
      file = Rails.root+"tmp"+"Sola_dayly.data"
      data_file_output_dayly(file,data_list,"No 年月日 発電量")
      gnuplot_(file.to_s,opt)
    end

    def peak_graph(graph_file=nil,graph_file_dir=nil)
      opt = { 
        :graph_file => graph_file || "peak" ,
        :graph_file_dir => graph_file_dir || Rails.root+"tmp" + "img",
        :define_file => Rails.root+"tmp/gnuplot/peak.def",
        :column_labels => %w(日付 ピーク発電量), :column_format => %w(%s %.1f),
        :axis_labels   => { :xlabel => "日",:ylabel => "ピーク発電量/kW",:y2label => "一日発電量"},
        :title => "日間発電量推移" , 
        :tics =>  { :xtics => "rotate by -90"},
        :point_type => [7,8],:with => ["","with line"],
        :set_key => "unset key",
        :xy => [[[2,3],[2,4]]], :by_tics => { 1 => "x1y2" }
      }

      data_list = Sola::Dayly.all.order("date").pluck(:date, :peak_kw, :kwh_day)
      file = Rails.root+"tmp"+"Sola_peak.data"
      data_file_output(file,data_list,"Daies 年月日 発電量")
      gnuplot_(file.to_s,opt)
    end

    # 横軸1年分。毎月1日だけ日付をいれ、その他は ""
    # 
    def data_file_output(filename_or_pathname,data_list,labels)
      start_day = data_list.first.first
      open(filename_or_pathname,"w"){ |f|
        f.puts labels
        data_list.each{ |date,pw,spw|
          f.puts "%3d %-10s %4.2f %4.2f"%
          [date-start_day,date.day == 1 ? date.strftime("%Y-%m-%d") : '""' ,pw,spw]
        }
      }
    end
    def data_file_output_monthly(filename_or_pathname,data_list,labels)
      start_day = data_list.first.first
      open(filename_or_pathname,"w"){ |f|
        f.puts labels
        data_list.each{ |date,pw|
          f.puts "%3d %-10s %4.2f"%
          [date-start_day,[1,7].include?(date.month) ? date.strftime("%Y-%m") : '""' ,pw]
        }
      }
    end
    def data_file_output_dayly(filename_or_pathname,data_list,labels)
      start_day = data_list.first.month
      open(filename_or_pathname,"w"){ |f|
        f.puts labels
        data_list.each{ |monthly|
          first_date = monthly.month.beginning_of_month
          last_day   = (first_date + 1.month - 1.day).day
          # f.printf("%3d %-10s %-4s\n",
          #          date-start_day,
          #          ([1,4,7,10].include?(date.month)  ? date.strftime("%Y-%m ") : '""'),
          #          ( monthly.kwh01 ? "%4.1f"%monthly.kwh01 : '""')
          #          )
          # (2..((monthly.month.beginning_of_month + 1.month - 1.day).day)).
          #  each_with_index{ |day,idx| 
          #   f.printf( "%3d \"\"         %-4s\n", 
          #             date-start_day+idx+1,
          #             (monthly.kwh(day) ? "%4.2f"%monthly.kwh(day) : "--")
          #             )
          # }
          (1..last_day). each{ |day|
            date = first_date + day - 1
            f.printf("%s %s\n",date.strftime("%Y-%m-%d"),(monthly.kwh(day) ? "%4.2f"%monthly.kwh(day) : "--"))
          }
        }
      }
    end

  end
  def self.included(base)
    base.extend(ClassMethod)
  end
  
end


__END__
set title '岐阜地方 2014/08/05～2014/09/02 の気温・水蒸気量と予報の誤差'
set key outside autotitle columnheader samplen 2 width -10

#unset key
set x2range [0:26.875000]
#set xtics 1,1 
set x2tics 1
set xtics  rotate by -90
set  grid noxtics x2tics ytics

plot '/opt/www/msdntest0/tmp/shimada/forecast-real' using 3:xticlabel(2)  with line lc 1, \\
     '' using 4   with line lc 1 lw 2, \\
     '' using 5   with line lc 4,\\
     '' using 6   with line lc 3,\\
     '' using 7   with line lc 3 lw 2,\\
     '' using 8   with line lc 2 

No 日時 気温 当日予報誤差 前日予報誤差 蒸気圧 当日予報誤差 前日予報誤差
0.0 "2014-08-05 03:00" 26.9  -0.2  -0.2  29.1  0.4  1.1 
0.125 "" 26.9  -0.8  -0.8  29.4  0.4  0.4 
0.25 "" 30.8  0.0  -1.0  30.7  -3.1  -3.0 
0.375 "" 34.4  0.5  -0.4  28.8  -1.9  -2.2 
0.5 "" 34.2  2.8  2.8  28.5  0.4  0.4 
0.625 "" 28.7  6.9  5.5  31.9  0.7  -0.7 
0.75 "" 26.4  5.9  5.1  30.6  -0.6  -1.9 
0.875 "" 26.4  3.2  2.7  31.3  1.1  -3.1 
1.0 "2014-08-06 03:00" 26.3  0.9  0.9  30.1  1.0  2.4 
