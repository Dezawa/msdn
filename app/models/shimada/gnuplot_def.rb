# -*- coding: utf-8 -*-
module Shimada::GnuplotDef
  module ClassMethod
    # extend  Shimada::GnuplotDef::ClassMethod

    def output_plot_data(powers,method,opt = { },&block)
      path = []
      keys = nil
      ary_powres = if by_month = opt[:by_date]
                     powers.group_by{ |p| p.date.strftime(by_month)}
                   elsif opt[:by_]
                     pws=powers.group_by{ |p| p.send(opt[ :by_ ])}#.sort_by{ |p,v| p}#.reverse
                     keys = pws.keys.compact.sort
                     pws
                   else
                     powers.size > 0 ? { powers.first.date.strftime("%y/%m")=>powers} : {"" =>[]}
                     
                   end
      keys ||= ary_powres.keys.sort
      keys.each_with_index{ |k,idx|
        #ary_powres.each_with_index{ |month_powers,idx|
        path << RAILS_ROOT+"/tmp/shimada/shimada_power_temp%d"%idx
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

    def average_out(power,method,time_ofset)
      open(RAILS_ROOT+"/tmp/shimada/shimada_power_diff_ave","w"){ |f|
        f.puts "時刻 平均"
        power.send(method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+time_ofset,h ) if h } 
        f.puts
      }
    end

    DefaultTitle ={:normalized => "正規化消費電力",:difference => "温度差分",:powers => "消費電力",
      :difference_ave => "差分平均",:revise_by_temp => "温度補正電力",:diffdiff => "二階差分"}

    def gnuplot(powers,method,opt={ })
      time_ofset,xrange =  
        if /_3$/ =~ method.to_s
          [ Shimada::Power::TimeOffset+1,"[#{Shimada::Power::TimeOffset+1}:#{Shimada::Power::TimeOffset+25}]"]
        else ;  [1,"[1:24]"]
        end
      path = output_plot_data(powers,method,opt){ |f,power| 
        power.send(method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+time_ofset,h ) if h }
      }
      def_file = RAILS_ROOT+"/tmp/shimada/power.def"
      graph_file = opt[:graph_file] ||  "power"
      group_by = ( opt.keys & [:by_,:by_date] ).size>0 ? "set key outside autotitle columnheader" : "unset key"
      preunble = ( case method.to_s
                   when /^normalized/ ;  Nomalized_def
                   when /^diff/       ;  Differ_def 
                   else               ;  Power_def 
                   end)% [ graph_file , opt[:title] || DefaultTitle[method ],group_by ,xrange ]

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
        elsif /^difference/ =~ method.to_s
          average_out(average_diff,method,time_ofset)
          f.print ",\\\n  '" + RAILS_ROOT+"/tmp/shimada/shimada_power_diff_ave'  using 1:2  with line lt -1 lw 2"
        end
        f.puts
        #f.puts "set terminal  eps enhanced color 'GothicBBB-Medium-UniJIS-UTF8-H'
        f.puts "set terminal  jpeg \nset out 'tmp/shimada/jpeg/#{graph_file}.jpeg'\nreplot\n"
      }
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
    end

    def f2_f3_f4_line(a,offset)
      i=0
      x_offset = Shimada::Power::PolyFitX0+1
       ",1,\\\n #{a[0]}"+ 
            a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{x_offset})**#{i}" }.join + " lt -1" +
        ",\\\n (((%+f * (x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*10+#{offset}"%
            [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{x_offset}) %+f) * (x-#{x_offset}) %+f)*10 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end

    def f2_f3_f4_normalize(a,offset)
      i=0
      x_offset = Shimada::Power::PolyFitX0+1
       ",1,\\\n #{a[0]}"+ 
            a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{x_offset})**#{i}" }.join + " lt -1" +
            ",\\\n (((%+f * (x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*5+1"%
            [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{x_offset}) %+f) * (x-#{x_offset}) %+f)*5 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end

    def gnuplot_by_temp(powers,opt={ })
      path = output_plot_data(powers,:powers,opt){ |f,power| 
        weather = Weather.find_or_feach("maebashi", power.date)#.temperatures
        if (method = opt[:method])
          f.printf( "%.1f %.1f\n",weather.max_temp, power.send(method)) if  weather
        else
          power.powers.each_with_index{ |h,idx| 
            f.printf( "%.1f %.1f\n",weather.temperatures[idx],h ) if h && weather.temperatures[idx] 
          }
        end
      }
      #    path = gnuplot_data_by_temp(powers,opt)
      def_file = RAILS_ROOT+"/tmp/shimada/power_temp.def"
      graph_file = opt[:graph_file] || "power"
      open(def_file,"w"){ |f|
        if opt[:method]
          f.puts Temp_something_def%[graph_file,opt[:title] ]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ")
        else
          f.puts Temp_power_def%[graph_file,opt[:title]||"温度-消費電力 "]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ") +
            ", 780+9*(x-20) ,670+3*(x-20), 0.440*(x-5)**1.8+750"
        end
          f.puts "set terminal  jpeg \nset out 'tmp/shimada/jpeg/#{graph_file}.jpeg'\nreplot\n"        #end
        }
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{def_file})`
    end

  end # of module

  def self.included(base) ;    base.extend(ClassMethod) ;end

  ########## ↓ GNUPLOT ############
Temp_something_def =
%Q!set terminal gif enhanced size 600,200 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'

set title "%s"
set key outside autotitle columnheader
#set yrange [0:1000]
set xrange [-10:40]
set xtics -10,5
set x2tics -10,5
set grid
!
Temp_power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'

set title "%s" #"温度-消費電力 " 
set key outside autotitle columnheader
set yrange [0:1000]
set xrange [-10:40]
set xtics -10,5
set x2tics -10,5
!

Power_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
#set terminal x11

set title "%s" #"消費電力 " 
%s
set yrange [0:1000]
set xrange %s # [1:24]
set xtics 3,3 #1,1
set x2tics 3,3 # 2,2
#set grid  xtics 3,3
set grid #ytics
!

Differ_def =
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
#set terminal x11

set title "%s" # "消費電力 " 
%s
set yrange [-250:250]
set xrange %s #[1:24]
set xtics 3,3 #1,1
set x2tics 3,3
set ytics -250,50
set grid #ytics
!

Nomalized_def=
%Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
#set terminal x11

set title "%s" #"正規化消費電力 " 
%s
set yrange [0.0:1.1]
#set xrange [1:24]
#set yrange [0.0:10.1]
set xrange %s #[-1:30]
set xtics 1,1
set x2tics 2,2
set grid x2tics
!

  ########## ↑ GNUPLOT ############
end
