# -*- coding: utf-8 -*-
module Sola::Graph
  include Gnuplot
  module ClassMethod
    include Gnuplot

    OptionCorrelation =
      Gnuplot::OptionST.
      new({:define_file => Rails.root+"tmp/gnuplot/sola_correlation.def",
           :graph_file_dir => Rails.root+"tmp" + "img",
           :size => "500,500",        :type => "scatter",
           :graph_file =>  "sola_correlation" ,
          },
          {common: {
                    :set_key => "unset key" ,
                    :set  => [ "lmargin 0", "rmargin 0","size 0.8,0.8", "origin 0.15 ,0.1"  ],
                    :xy => [[[2,1]]],        :point_type => [7,6],
                    :range => { :y => "[0:35]",:x => "[0:35]"},
                    :axis_labels   => { :ylabel => "モニター/kWh",
                                       :xlabel => "おんどとり/kWh"},
                   }
          }
         )

    def std_opt_with_peak(xly,graph_file,graph_file_dir=nil)
      Gnuplot::DefaultOptionST.
        merge( Gnuplot::OptionST.
              new(
                  { 
                   :graph_file => graph_file || "sola_#{xly}" ,
                   :define_file => Rails.root+"tmp/gnuplot/sola_#{xly}.def",
                   :graph_file_dir => graph_file_dir || Rails.root+"tmp" + "img",
                   :size => "1000,230",
                  },
                  {common: {
                            :set_key => "set key center horizontal top box autotitle columnheader width -7 samplen 0.0",
                            :type => "scatter",
                            :by_tics => { 1 => "x1y2" }, # 3600*24*
                            :grid    => ["xtics"],
                            :tics =>  { :xtics => "'2011-5-1',#{3600*24*30.5*2},'#{Time.now.end_of_year.strftime('%Y-%m-%d')}' rotate by -90",
                                       :ytics => "300,100 nomirror",:y2tics => "0,1"},
                           }        
                  }
                 )
             )
    end

    def correlation_graph(graph_file=nil,graph_file_dir=nil)
      @options =  Gnuplot::DefaultOptionST.merge(OptionCorrelation  )
      @options.merge({graph_file: graph_file},[:header])         if graph_file
      @options.merge({graph_file_dir: graph_file_dir},[:header]) if graph_file_dir
      #return if graph_updated?(@options[:header])

      data_list = self.where("kwh_day is not null  and kwh_monitor is not null").pluck(:kwh_monitor,  :kwh_day)
      #logger.debug("##### Sola_correlation data_list.size=#{data_list.size}")
      if data_list.size > 2
        a,resudal = multiple_regression data_list
        #logger.debug("##### Sola_correlation a,resudal = #{a},#{resudal}")
        @options.merge( { :additional_lines => "#{a[0]}+#{a[1]}*x" ,
                         :labels => ["label 1 'モニタ = %.2f + %2f * おんどとり' at 3,32"%a,
                                     "label 2 '1-R=%f データ数=%d' at 10,30"%[1.0-resudal,data_list.size]]
                        },[:body,:common]
                      )
        logger.debug("##### Sola_correlation @options[:body][:common] = #{@options[:body][:common]}")
      end
      #logger.debug("##### Sola_correlation option[:body].keys=#{opt[:body].keys.join(' ')}")
      file = Rails.root+"tmp"+"Sola_correlation.data"
      open(file,"w"){ |f|
        f.puts "おんどとり発電量 モニター発電量"
        data_list.each{ |powers| f.puts "%.1f %.1f"%powers}
      }
      gnuplot_(file.to_s,@options)
    end

    def monthly_graph_with_peak(graph_file=nil,graph_file_dir=nil)
      @options = std_opt_with_peak(:minthly,graph_file,graph_file_dir).
        merge({ 
               :set  => [ "lmargin 0", "rmargin 0","size 0.8,1.1", "origin 0.09 ,-0.07",
                         "xdata time", "timefmt '%Y-%m-%d'"      , "format x '%Y-%m'"
                        ],
               :xy => [[[1,2],[1,3]]],        :point_type => [7,6],
               :range => { :y => "[300:780]",:y2 => "[0:6]",
                          :x => "['2011-5-1':'#{Time.now.end_of_year.strftime('%Y-%m-%d')}']"},
               :axis_labels   => { :ylabel => "月間発電量/kW時", :y2label => "月間ピーク/kW分"},
              },[:body,:common])

      #return if graph_updated?(@options)
      
      peaks  = Sola::Dayly.select("max(peak_kw) peak",:month).group(:month).
        map{|m| [m.month,m.peak]}.to_h
      powers = Sola::Dayly.select("sum(kwh_monitor) power",:month).group(:month).
        map{|m| [m.month,m.power]}.to_h
      data_list = (powers.keys + peaks.keys).uniq.sort.map{ |month| [month,powers[month],peaks[month]]}

      file = Rails.root+"tmp"+"Sola_monthly.data"
      data_file_output_with_date(file,data_list,"年月 月間発電量 月間ピーク発電")
      gnuplot_(file.to_s,@options)
    end 

    def dayly_graph_with_peak(graph_file=nil,graph_file_dir=nil)
      opt = std_opt_with_peak(:dayly,graph_file,graph_file_dir).
        merge({ 
               :axis_labels   => { :xlabel => "年月日",:ylabel => "日発電量/kW時", :y2label => "ピーク/kW分"},
               :xy => [[[1,2],[1,3]]],
               :range => { :y => "[0:39]", :y2 => "[0:6]",
                          :x => "['2011-5-1-1':'#{Time.now.end_of_year.strftime('%Y-%m-%d')}']"},

               :tics =>  { :xtics => "'2011-5-1',#{3600*24*30.5*2},'#{Time.now.end_of_year.strftime('%Y-%m-%d')}' rotate by -90",
                          :ytics => "0 5 nomirror",:y2tics => "0,1"},
               #:tics =>  {  :xtics => "'2012-12-1' #{3600*24*30}", :ytics => "0,5 nomirror",:y2tics => "0,1"}  ,
               :point_type => [7,6],:point_size => 0.6 ,
               :type => "scatter",
               :set => [ "lmargin 0","rmargin 0","size 0.8,0.9","origin 0.09 ,0.15",
                        "xdata time",  "timefmt '%Y-%m-%d'",
                        "format x ''"
                       ],
              },[:body,:common]
             )

      #return if graph_updated?(opt)

      data_list  = Sola::Dayly.order(:date).pluck(:date, :kwh_monitor, :peak_kw)
      file = Rails.root+"tmp"+"Sola_dayly.data"
      data_file_output_with_date(file,data_list,"年月日 一日発電量 ピーク発電量")
      gnuplot_(file.to_s,opt)
    end

    def graph_updated?(opt)
      file_path = "#{opt[:graph_file_dir]}/#{opt[:graph_file]}.jpeg"
      return false unless File.exist? file_path
      logger.debug("Sola::Graph::graph_updated file_path=#{file_path} ")
      db_updated = [Sola::Dayly].
        map{|model| model.select("max(updated_at) max_updated_at").first.max_updated_at}.max
      File::Stat.new(file_path).mtime >= db_updated
    end

    def peak_graph(graph_file=nil,graph_file_dir=nil)
      header = { :graph_file => (graph_file || "peak") ,
                :graph_file_dir => graph_file_dir || Rails.root+"tmp" + "img",
                :define_file => Rails.root+"tmp/gnuplot/peak.def",
                :type => "scatter",
               }
      common = { :column_labels => %w(日付 ピーク発電量), :column_format => %w(%s %.1f),
                :axis_labels   => { :xlabel => "日",:ylabel => "ピーク発電量/kW",
                                   :y2label => "一日発電量/kWh"},
                :title => "日間発電量推移" ,
                :set  => [ "xdata time", "timefmt '%Y-%m-%d'"      , "format x '%Y-%m-%d'"  ],
                :range => { :y => "[0:6]",:y2 => "[0:35]",
                           :x => "['2015-1-1':'#{Time.now.end_of_year.strftime('%Y-%m-%d')}']"},
                :tics =>  { :xtics => "'2015-1-1',#{3600*24*30.5*2},'#{Time.now.end_of_year.strftime('%Y-%m-%d')}' rotate by -90",
                           :ytics => "0,1 nomirror",:y2tics => "0,10"},
                :point_type => [7,8],:with => ["","with line"],
                :set_key => "set key left horizontal bottom box autotitle columnheader width -7 samplen 1",
                :xy => [[[1,2],[1,3]]], :by_tics => { 1 => "x1y2" }
               }
      @options =
        Gnuplot::DefaultOptionST.merge(Gnuplot::OptionST.new(header,{:common => common}))

      data_list = Sola::Dayly.all.order("date").pluck(:date, :peak_kw, :kwh_day).delete_if{ |_a,b,_c| !b}
      
      opt_max_peak!(data_list,@options)

      file = Rails.root+"tmp"+"Sola_peak.data"
      data_file_output_with_date(file,data_list,"年月日 ピーク発電量 一日発電量")
      gnuplot_(file.to_s,@options)
    end

    def opt_max_peak!(data_list,opt)
      max_day,max_peak,_dmy = data_list.max_by{ |_date, peak_kw, _kwh_day| peak_kw}
      return unless max_day && max_peak
      opt.merge({:labels=> ["label 1 '最高 #{max_day} #{'%.2f'%max_peak}kW' at '2015-01-10',5.5 left" ,
                            "arrow 1 as 1 from '2015-05-01',5.3 to '#{max_day}',#{max_peak}"
                           ]},[:body,:common] )
    end



    # 横軸1年分。毎月1日だけ日付をいれ、その他は ""
    # 
    def data_file_output(filename_or_pathname,data_list,labels)
      start_day = data_list.first.first
      open(filename_or_pathname,"w"){ |f|
        f.puts labels
        data_list.each{ |date,pw,spw|
          f.puts "%3d %-10s %-4s %-4s"%
            [date-start_day,date.day == 1 ? date.strftime("%Y-%m-%d") : '""' ,strfflt(pw),strfflt(spw)]
        }
      }
    end

    def strfflt(val,fmt="%f") ;      val ? fmt%val : "" ; end

    def data_file_output_with_date(filename_or_pathname,data_list,labels)
      open(filename_or_pathname,"w"){ |f|
        f.puts labels
        data_list.each{ |monthly|
          date = monthly.shift
          f.print date.strftime("%Y-%m-%d　")
          f.puts monthly.map{ |pw| pw ? " %5.2f"%pw : "  --  "  }.join
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
          (1..last_day). each{ |day|
            date = first_date + day - 1
            f.printf("%s %s\n",date.strftime("%Y-%m-%d"),(monthly.kwh(day) ? "%4.2f"%monthly.kwh(day) : "--"))
          }
        }
      }
    end
    def data_file_output_peak_dayly(filename_or_pathname,data_list,labels)
      open(filename_or_pathname,"w"){ |f|
        f.puts labels
        data_list.each{ |dayly|
          date = dayly.shift
          f.print date.strftime("%Y-%m-%d　")
          f.puts dayly.map{ |pw| pw ? " %5.2f"%pw : "  --  "  }.join
        }
      }
    end

  end
  def self.included(base)
    base.extend(ClassMethod)
  end


  def minute_graph(graph_file=nil,graph_file_dir=nil)
    opt = Gnuplot::DefaultOptionST.merge(Gnuplot::OptionST.
                                         new({ 
                                              :graph_file => graph_file || "minute" ,
                                              :graph_file_dir => graph_file_dir || Rails.root+"tmp" + "img",
                                              :define_file => Rails.root+"tmp/gnuplot/minute.def",
                                             },
                                             {common: {
                                                       :column_labels => %w(分 ピーク発電量), :column_format => %w(%s %.1f),
                                                       :axis_labels   => { :xlabel => "分",
                                                                          :ylabel => "発電量/kW",:y2label => "一日発電量"},
                                                       :title => "日間発電量推移" , 
                                                       :tics =>  { :xtics => "rotate by -90"}, :range =>{ :y => "[0:6]"},
                                                       :point_type => [7],:point_size => 0.2,:with => ["with line"],
                                                       :set_key => "unset key",
                                                       :type => "scatter",
                                                       :set => ["xdata time","timefmt '%H:%M'",
                                                                #"xrange ['03/21/95':'03/22/95']",
                                                                "format x '%H:%M'"],
                                                       :xy => [[[1,2]]]
                                                      }
                                             }
                                            ))
    file = Rails.root+"tmp"+"Sola_minute.data"
    data_file_output_minute(file,kws,"時刻 年月日 発電量")
    logger.debug("####### data_file_output_minute(file) = #{file}")
    gnuplot_(file.to_s,opt)
  end

  def data_file_output_minute(filename_or_pathname,data_list,labels)
    open(filename_or_pathname,"w"){ |f|
      f.puts labels
      data_list.each_with_index{ |kw,min|
        f.puts "%d:%d %.2f"%[min/60,min%60,kw] if kw && min
      }
    }
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
