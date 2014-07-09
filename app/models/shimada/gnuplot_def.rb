# -*- coding: utf-8 -*-
module Shimada::GnuplotDef
  module ClassMethod
    # extend  Shimada::GnuplotDef::ClassMethod

    def output_plot_data(powers,method,opt = { },&block)
      path = []
      keys = nil
      ary_powres = if by_month = opt[:by_date]
                     powers.group_by{ |p| p.date.strftime(by_month)}
                   elsif by_month = opt[:by_month]
                     powers.group_by{ |p| p.date.strftime("%y/%m")}
                   elsif by_month = opt[:by_monthday]
                     powers.group_by{ |p| p.date.strftime("%m/%d")} 
                   elsif by_month = opt[:by_day]
                     powers.group_by{ |p| p.date.strftime("%d")} 
                   elsif opt[:by_line]
                     keys = (0..5).to_a
                     powers.group_by{ |p| "稼働数-#{p.lines}"}
                     
                   elsif opt[:by_line_shape]
                     #keys = Shapes
                     p=powers.group_by{ |p| "#{p.lines}#{p.shape_calc}"}#.sort_by{ |p,v| p}#.reverse
                     keys = p.keys.compact.sort
                     p
                   elsif opt[:by_shape]
                     p=powers.group_by{ |p| p.shape_calc}#.sort_by{ |p,v| p}#.reverse
                     keys = p.keys.compact.sort
                     p
                   else
                     powers.size > 0 ? { powers.first.date.strftime("%y/%m")=>powers} : {"" =>[]}
                     
                   end
      keys ||= ary_powres.keys.sort
      keys.each_with_index{ |k,idx|
        #ary_powres.each_with_index{ |month_powers,idx|
        path << "/tmp/shimada/shimada_power_temp%d"%idx
        open(path.last,"w"){ |f|
          #f.puts "時刻 #{month_powers.first}"
          f.puts "時刻 #{k}"
          #month_powers.last.each{ |power|
          ary_powres[k].each{ |power|
            yield f,power #power.send(method).each_with_index{ |h,idx| f.printf "%d %.3f\n",idx+1,h }
            f.puts
          }
        }
      }
      path
    end

    def average_out(power,method)
      open("/tmp/shimada/shimada_power_diff_ave","w"){ |f|
        f.puts "時刻 平均"
        power.send(method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+1,h ) if h } 
        f.puts
      }
    end

    DefaultTitle ={:normalized => "正規化消費電力",:difference => "温度差分",:powers => "消費電力",
      :difference_ave => "差分平均",:revise_by_temp => "温度補正電力",:diffdiff => "二階差分"}

    def gnuplot(powers,method,opt={ })
      logger.debug("GNUPLOT: powers.size=#{powers.size}")
      path = output_plot_data(powers,method,opt){ |f,power| 
        power.send(method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+1,h ) if h }
      }
      def_file = "/tmp/shimada/power.def"
      graph_file = opt[:graph_file] || "power"
      by_month = ( opt.keys & [:by_month,:by_monthday,:by_day,:by_line,:by_shape,:by_line_shape,:by_date] ).size>0 ? "set key outside autotitle columnheader" : "unset key"
      preunble = ( case method
                   when :normalized ;  Nomalized_def
                   when :difference, :difference_ave ,:diffdiff;  Differ_def 
                   else             ; Power_def 
                   end)% [ graph_file , opt[:title] || DefaultTitle[method ],by_month ]

      open(def_file,"w"){ |f|
        f.puts preunble 
        f.print "plot " + path.map{ |p| "'#{p}' using 1:2  with line"}.join(" , ")
        if  opt[:by_line] 
          f.print " , " + Lines.map{ |line| line.last}.join(" , ")
        elsif opt[:fitting]
          #logger.debug("powers = #{powers.first.class}")
          #a = method == :normalized ? powers.first.na : powers.first.a
                  logger.debug("method = #{method}")
          if method == :normalized 
            f.print f2_f3_f4_normalize( powers.first.na,1) 
          else
            f.print f2_f3_f4_line( powers.first.a,800) 
          end 
        elsif [:difference, :difference_ave].include? method
          average_out(average_diff,:difference)
          f.print ",\\\n  '/tmp/shimada/shimada_power_diff_ave'  using 1:2  with line lt -1 lw 2"
        end
        f.puts
        #f.puts "set terminal  eps enhanced color 'GothicBBB-Medium-UniJIS-UTF8-H'
        f.puts "set terminal  jpeg 
set out 'tmp/shimada/file.jpeg'
replot
"
      }
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
    end

    def f2_f3_f4_line(a,offset)
      i=0
       ",1,\\\n #{a[0]}"+ 
            a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{Shimada::Power::PolyFitX0})**#{i}" }.join + " lt -1" +
        ",\\\n (((%+f * (x-#{Shimada::Power::PolyFitX0+1}) %+f)*(x-#{Shimada::Power::PolyFitX0+1}) %+f)*(x-#{Shimada::Power::PolyFitX0}) %+f)+#{offset}"%
            [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{Shimada::Power::PolyFitX0+1}) %+f) * (x-#{Shimada::Power::PolyFitX0+1}) %+f)*5 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end

    def f2_f3_f4_normalize(a,offset)
      i=0
       ",1,\\\n #{a[0]}"+ 
            a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{Shimada::Power::PolyFitX0+offset})**#{i}" }.join + " lt -1" +
            ",\\\n (((%+f * (x-#{Shimada::Power::PolyFitX0+1}) %+f)*(x-#{Shimada::Power::PolyFitX0+1}) %+f)*(x-#{Shimada::Power::PolyFitX0+offset}) %+f)*5+1"%
            [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{Shimada::Power::PolyFitX0+1}) %+f) * (x-#{Shimada::Power::PolyFitX0+1}) %+f)*5 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end

    def gnuplot_by_temp(powers,opt={ })
      path = output_plot_data(powers,:powers,opt){ |f,power| 
        temperatures = Weather.find_or_feach("maebashi", power.date).temperatures
        power.powers.each_with_index{ |h,idx| 
          f.printf( "%.1f %.1f\n",temperatures[idx],h ) if h && temperatures[idx] 
        }
      }
      #    path = gnuplot_data_by_temp(powers,opt)
      def_file = "/tmp/shimada/power_temp.def"
      graph_file = opt[:graph_file] || "power"
      open(def_file,"w"){ |f|
        f.puts Temp_power_def%[graph_file,opt[:title]||"温度-消費電力 "]
        f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ") +
        #if opt[:with_Approximation]
        ", 780+9*(x-20) ,670+3*(x-20), 0.440*(x-5)**1.8+750"
        #else
        #  ""
        f.puts "set terminal  jpeg 
set out 'tmp/shimada/file_temp.jpeg'
replot
"        #end
      }
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
    end

  end # of module

  def self.included(base) ;    base.extend(ClassMethod) ;end

  ########## ↓ GNUPLOT ############
Temp_power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/%s.gif'

set title "%s" #"温度-消費電力 " 
set key outside autotitle columnheader
set yrange [0:1000]
set xrange [-10:40]
set xtics -10,5
!

Power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/%s.gif'
#set terminal x11

set title "%s" #"消費電力 " 
%s
set yrange [0:1000]
set xrange [1:24]
set xtics 1,1
set grid ytics
!

Differ_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/%s.gif'
#set terminal x11

set title "%s" # "消費電力 " 
%s
set yrange [-250:250]
set xrange [1:24]
set xtics 1,1
set ytics -250,50
set grid ytics
!

Nomalized_def=
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/%s.gif'
#set terminal x11

set title "%s" #"正規化消費電力 " 
%s
set yrange [0.0:1.1]
#set xrange [1:24]
#set yrange [0.0:10.1]
set xrange [-1:30]
set xtics 1,1
set x2tics 3,3
set grid x2tics
!

  ########## ↑ GNUPLOT ############
end
