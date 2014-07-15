# -*- coding: utf-8 -*-
module Shimada::Gnuplot
  class Plot

    def initialize(powers,method,opt)
      @powers = powers
      @method = method
      @opt    = opt
      @time_ofset,@xrange =  
        if /_3$/ =~ method.to_s
          [ Shimada::Power::TimeOffset+1,"[#{Shimada::Power::TimeOffset+1}:#{Shimada::Power::TimeOffset+25}]"]
        else ;  [1,"[1:24]"]
        end
      @def_file = RAILS_ROOT+"/tmp/shimada/power.def"
      @graph_file = opt.delete(:graph_file) ||  "power"
      @size = opt[:graph_size] || "600,400"

    end


    def output_plot_data(&block)
      path = []
      keys = nil
      ary_powres = if by_month = @opt[:by_date]
                     @powers.group_by{ |p| p.date.strftime(by_month)}
                   elsif @opt[:by_]
                     pws=@powers.group_by{ |p| p.send(@opt[ :by_ ])}#.sort_by{ |p,v| p}#.reverse
                     keys = pws.keys.compact.sort
                     pws
                   else
                     @powers.size > 0 ? { @powers.first.date.strftime("%y/%m") => @powers} : {"" =>[]}
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

    def output_path
      output_plot_data{ |f,power| 
        power.send(@method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+@time_ofset,h ) if h }
      }
    end

    def plot()

      path = output_path
      group_by = ( @opt.keys & [:by_,:by_date] ).size>0 ? "set key outside autotitle columnheader" : "unset key"
      output_def_file(path, group_by)
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{@def_file})`
    end

    def output_def_file(path, group_by)
      preunble = @Def% [ @graph_file , @opt[:title] || "消費電力" ,group_by ,@xrange ]
      open(@def_file,"w"){ |f|
        f.puts preunble 
        f.print "plot " + path.map{ |p| "'#{p}' using 1:2  with line"}.join(" , ")
        if  @opt[:by_line] 
          f.print " , " + Lines.map{ |line| line.last}.join(" , ")
        elsif @opt[:fitting]
          f.print f2_f3_f4_line( @powers.first,800) 
        end
        f.puts
        #f.puts "set terminal  eps enhanced color 'GothicBBB-Medium-UniJIS-UTF8-H'
        f.puts "set terminal  jpeg size #{@size}\nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"
      }
    end

  end

  class Power <  Shimada::Gnuplot::Plot
    Def =
      %Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
set title "%s"
%s
set yrange [0:1000]
set xrange %s # [1:24]
set xtics 3,3 #1,1
set x2tics 3,3 # 2,2
set grid #ytics
!

    def initialize(powers,method,opt)
      super
      @Def = Def
    end

    def f2_f3_f4_line(power,offset)
      a = power.a
      i=0
      x_offset = Shimada::Power::PolyFitX0+1
      ",1,\\\n #{a[0]}"+ 
        a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{x_offset})**#{i}" }.join + " lt -1" +
        ",\\\n (((%+f * (x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*10+#{offset}"%
        [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{x_offset}) %+f) * (x-#{x_offset}) %+f)*10 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end
    
  end # of Power

  class Standerd < Power


  end


  class Nomalized <  Shimada::Gnuplot::Plot
    Def = %Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
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


    def initialize(powers,method,opt)
      super
      @Def = Def
    end

    def f2_f3_f4_line(power,offset)
      a = power.na
      i=0
      x_offset = Shimada::Power::PolyFitX0+1
      ",1,\\\n #{a[0]}"+ 
        a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{x_offset})**#{i}" }.join + " lt -1" +
        ",\\\n (((%+f * (x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*5+1"%
        [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{x_offset}) %+f) * (x-#{x_offset}) %+f)*5 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end

  end

  class Differ <  Shimada::Gnuplot::Plot
    Def = %Q!set terminal gif enhanced size 600,300 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
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


    def initialize(powers,method,opt)
      super
      @Def = Def
    end
  end

  class Temp <  Shimada::Gnuplot::Plot
    Def = %Q!set terminal gif enhanced size %s enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'

set title "%s" #"温度-消費電力 " 
set key outside  autotitle columnheader samplen 1 width -5
set yrange [0:1000]
set xrange [-10:40]
set xtics -10,5
set x2tics -10,5
!

    def initialize(powers,method,opt)
      super
      @Def = Def
      @range = opt.delete(:range) || (0..23)
      @graph_size = opt[:graph_size] || "700,400"  
    end

    def output_path
      output_plot_data{ |f,power| 
        weather = Weather.find_or_feach("maebashi", power.date)#.temperatureseratures[idx] 
          power.powers.zip(weather.temperatures)[@range].each{ |pw,tmp| 
            f.printf( "%.1f %.1f\n",tmp,pw ) if pw && tmp
          }
      }
    end

    def output_def_file(path, group_by)
      x0,y0,sll,slh = [:threshold_temp,:y0, :slope_lower, :slope_higher ].
        map{ |sym|Shimada::Power::ReviceParms[sym]}
      open(@def_file,"w"){ |f|
          f.puts @Def%[@graph_size,@graph_file,@opt[:title]||"温度-消費電力 "]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ") +
            ",  (x>#{x0}) ? #{y0}+#{slh}*(x-#{x0}) : #{y0}+#{sll}+3*(x-#{x0}) title '温度補償' lt -1 lw 1.5, \\
 0.440*(x-5)**1.8+750 title 'TopLine' lc rgbcolor '#FF0000' lw 1.5"
          f.puts "set terminal  jpeg  size #{@graph_size} \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n" 
      }
    end
  end
  class TempDeff < Temp
Def =
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

    def initialize(powers,method,opt)
      super
      @Def = Def
    end

    def output_path
      output_plot_data{ |f,power| 
        weather = Weather.find_or_feach("maebashi", power.date)#.temperatures
          f.printf( "%.1f %.1f\n",weather.max_temp, power.send(@method)) if  weather
      }
    end
    def output_def_file(path, group_by)
      open(@def_file,"w"){ |f|
          f.puts @Def%[@graph_file,@opt[:title] ]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ")
          f.puts "set terminal  jpeg  size 600,200 \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"         #end
      }
    end
  end
end

