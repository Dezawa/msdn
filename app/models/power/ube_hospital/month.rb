# -*- coding: utf-8 -*-
class Power::UbeHospital::Month < ActiveRecord::Base
  extend ExcelToCsv
  include Power::Month
  include Power::MonthlyGraph
  include Statistics
  extend  Power::Graph
  extend Power::Scatter
  set_table_name 'power_ube_hospital_months'
  has_many :powers ,:class_name =>  "Power::UbeHospital::Power" ,
  :dependent => :delete_all
  @@ave10hour = { }
  
  class << self
    def power_model ;   Power::UbeHospital::Power ;end

    def ave10hour(year_month)
      @@ave10hour[year_month] ||=
        if true
          rev10s = Power::UbeHospital::Month.find_by_month(year_month).powers.map(&:rev10)
          tmp_ave = rev10s.average
          rev10s.group_by{ |rev| rev >= tmp_ave}. # {true => [,,,],false => [,,,]}
            map{ |k,revs| revs.average}.          # [ ave1,ave 2]
            inject(0){ |s,e| s + e}*0.5           # 平日の平均と休日の平均の平均
        end
    end

    def search_year_month(lines)
      line=lines.shift
      until /平成(\d\d)年([01]\d)月分/ =~ line
        line=lines.shift 
        return nil unless line
      end
      Time.local($1.to_i+2000-12,$2.to_i).to_date.beginning_of_month
    end

    def set_power(powers,lines)
      Shimada::Power::Hours.each_with_index{ |hour,idx|
        clms = (line = lines.shift).split(",")
        raise RuntimeError,"時刻が合わない: #{line}" if idx+1 != clms.shift.to_i
        powers.each{ |power| power[hour] = clms.shift.to_f }
      }
      line=lines.shift until /袋数/ =~ line
      clms = line.split(",")
      clms.shift
      powers.each{ |power| power[:hukurosu] = clms.shift.to_f ;power.save}
    end

    Keys =                     %w(平日昼  休日昼   平日夜     休日夜     10時気温     日)
    KeyValues = Hash[ *Keys.zip([[2,:day],[1,:day],[2,:night],[1,:night],[nil,:temp],[nil,nil]]).flatten(1)]
    # 与えられたデータの24時間のデータを全て時間順に並べる
    # 9-16時と1-5時のものだけプロットする。
    # 横軸は時間単位。ただし軸は月初日付で表示する。
    # group は、平日昼 平日夜 休日昼 休日夜
    def graph_by_days_hour(objects,opt={ })
      # keys[平日昼] => [line=1,time_zone = :day]
      days = objects.map{ |pw| pw.date}
      min,max = [days.min,days.max]
      x2range = "[#{min.yday}:#{min.yday + (max-min)}]"
      opt = { :xlabel => "xl '日'",:ylabel => "yl '補正後 消費電力'", :y2label => "y2label '外気温'",
        :keys => Keys,
        :tics => "set xtics nomirror rotate by -90 scale 0
set x2range #{x2range}
set ytics 0,100,800",
        :by_tics => %w(x2y1 x2y1 x2y1 x2y1)
      }.merge opt
      opt[:method] ||= :revise_by_temp
      path = opt[:keys].map{ |key| output_plot_day_hour_data(objects,opt,key) }

      def_file = def_file_by_days_hour(path,opt.merge(:min => min,:max => max))
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
    end

    Hours = { :night => (0 .. 4) , :day => (8..15)}
    def  output_plot_day_hour_data(objects,opt,key)
      line,timezone = KeyValues[key]
      first_day = objects.first.date
logger.debug("OUTPUT_PLOT_DAY_HOUR_DATA : opt = #{opt.to_a.flatten.join(', ')}")
      path = RAILS_ROOT+"/tmp/graph/data/graphdata_#{line}#{timezone}"
      objes = objects.select{ |pw| pw.line == line}
      open(path,"w"){ |f|
        f.puts "日 #{key}"
        if line
          objes.each{ |pw|
            Hours[timezone].each{ |h|
              f.printf "%.2f %f\n",(pw.date - first_day) + first_day.yday+ h/24.0 , pw.send(opt["method"])[h]
            }
          }
        elsif timezone == :temp
          days = objects.map{ |pw| pw.date}
          objects.each{ |pw| 
            [9].each{ |h| 
              f.puts "#{(pw.date - first_day) + first_day.yday+ h/24.0} #{pw.temps[h]} #{pw.temps.max} #{pw.temps.min}"
            }
          }
        else
          days = objects.map{ |pw| pw.date}
          min,max = [days.min,days.max]
          range,fmt = min.year == max.year ? [[1,11,21],'%m/%d'] : [[1],'%Y/%m/%d']
          (min..max).each{ |day| 
            f.puts( range.include?(day.day) ? "#{day.strftime(fmt)} 0" : ". 0")
            (2..24).each{  f.puts ". 0"}
          }
        end
      }
      path
    end

    def  def_file_by_days_hour(path,opt={ })
      opt.merge!( :point_size => 0.7,:point_type => [7,7,7,7,5,5,6,6,6,6])
      deffile = ( opt[:def_dir] || RAILS_ROOT+"/tmp/graph")+"/"+(opt[:def_file] || "graph.def" )
      graph_dir,graph_file,title,set_key,xrange,tics = dif_opts(opt)
          range,fmt = opt[:min].year == opt[:max].year ? [[1,11,21],'%m/%d'] : [[1],'%Y/%m/%d']
      open(deffile,"w"){ |f|
        preunble = DefByDayHour%[graph_dir,graph_file,title,set_key,"[100:800]",xrange,tics ]
        f.puts preunble
        f.puts( "set x2tics ("+
               (opt[:min] .. opt[:max]).map{ |day|
                 next unless range.include?(day.day)
                  ( day - opt[:min] )+opt[:min].yday
               }.compact.join(" , ") + ")"
                )
        [:xlabel,:ylabel,:x2label,:y2label].each{ |sym|
          f.puts "set "+opt[sym] if opt[sym]
        }
        f.print plot_list("'%s' using %d:%d",path[0,4],opt)
        f.puts( " ,\\\n '#{path[-2]}' using 1:2 with lines axis x2y2 ,\\\n" 
                #" '' using 1:3 with lines axis x2y2 lc rgb 'red'  title '最高温度', \\\n" +
               # " '' using 1:4 with lines axis x2y2 title '最低温度', \\\n" 
                )
        f.puts " '#{path.last}' using 2:xtic(1) notitle "
      }
      deffile
    end

  end # of class method

  def ave10hour
    self.class.ave10hour(month)
  end

  DefByDayHour =
    %Q!set terminal jpeg enhanced size 800,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out '%s/%s.jpeg' #  graph_dir,graph_file,
set title "%s"
%s #  ,set_key
set yrange %s #[0:1000]
#set xrange %s #  [1:24]
set y2range [0:35]
%s # tics
set y2tics
set grid x2tics ytics
!
end
