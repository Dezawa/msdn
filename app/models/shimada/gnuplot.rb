# -*- coding: utf-8 -*-
module Shimada::Gnuplot
  class Plot
    attr_reader :factory_id
    def initialize(factory_id,powers,method,opt)
      @factory_id = factory_id
      @powers = powers
      @method = method
      @opt    = opt
      @time_ofset,@xrange =  
        if /_3$/ =~ method.to_s
          [ Shimada::Power::TimeOffset+1,"[#{Shimada::Power::TimeOffset+1}:#{Shimada::Power::TimeOffset+25}]"]
        else ;  [1,"[1:24]"]
        end
      @def_file = RAILS_ROOT+"/tmp/shimada/data/power.def"
      @graph_file = opt.delete(:graph_file) ||  "power"
      @size = opt[:graph_size] || "600,400"

    end


    def output_plot_data(&block)
      path = []
      keys = nil
      ary_powres = powers_group_by
      keys ||= ary_powres.keys.sort
      keys.each_with_index{ |k,idx|
        #ary_powres.each_with_index{ |month_powers,idx|
        path << RAILS_ROOT+"/tmp/shimada/data/shimada_power_temp%d"%idx
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

    def powers_group_by
      if by_month = @opt[:by_date]
        @powers.group_by{ |p| p.date.strftime(by_month)}
      elsif @opt[:by_]
        pws=@powers.group_by{ |p| p.send(@opt[ :by_ ])}#.sort_by{ |p,v| p}#.reverse
        keys = pws.keys.compact.sort
        pws
      else
        @powers.size > 0 ? { @powers.first.date.strftime("%y/%m") => @powers} : {"" =>[]}
      end
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
          f.print fitting_line( @powers.first,800) 
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

    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
      @std_data_file = RAILS_ROOT+"/tmp/shimada/data/"+@graph_file
    end

    def fitting_poly(power,offset)
      a = power.a
      i=0
      x_offset = Shimada::Power::PolyFitX0+1
      ",1,\\\n #{a[0]}"+ 
        a[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{x_offset})**#{i}" }.join + " lt -1" +
        ",\\\n (((%+f * (x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*(x-#{x_offset}) %+f)*10+#{offset}"%
        [ a[4] * 4,a[3]*3,a[2]*2,a[1]] +
        ", \\\n((%+f * (x-#{x_offset}) %+f) * (x-#{x_offset}) %+f)*10 +#{offset}"%[a[4] * 12,a[3]*6,a[2]*2]
    end


    def fitting_line(power,offset)
      if @opt[:fitting] == :standerd
        line = power.line
        return "" unless (2..4).include?(line)
        polyfits = Shimada::Power::PolyFits[line]
        a=polyfits[:ave]
        u=polyfits[:max]
        l=polyfits[:min]

        x_offset = Shimada::Power::PolyFitX0+1
        i=j=k=0
        ",\\\n #{u[0]}"+ u[1..-1].map{ |aa| i+=1 ;"+ #{aa}  * (x-#{x_offset})**#{i}" }.join + " lt -1" +
        ",\\\n #{a[0]}"+ a[1..-1].map{ |aa| j+=1 ;"+ #{aa}  * (x-#{x_offset})**#{j}" }.join + " lt -1 lw 2" +
        ",\\\n #{l[0]}"+ l[1..-1].map{ |aa| k+=1 ;"+ #{aa}  * (x-#{x_offset})**#{k}" }.join + " lt -1" 

      elsif @opt[:fitting] == :std_temp
         output_std_temp_file(power)
        ",\\\n '#{@std_data_file}' using 1:3 with line lt -1 lw 1.5, \\
        '' using 1:2 with line   lt -1  lw 2 ,\\
        '' using 1:4 with line  lt -1 lw 1.5 "
     else
        fitting_poly(power,offset)
      end
    end
 
    def f4(h,a)
      x = h - Shimada::Power::PolyFitX0
      (((a[4] * x + a[3])*x + a[2])*x + a[1])*x+a[0] 
    end

    def inv_revice(pw,temp,vaper) 
      pw =   inv_vaper(pw,vaper) 
      inv_temp(pw,temp)
    end
    def inv_temp(pw,temp)
      params = Shimada::Power::ReviceParms
      temp >  params[:threshold_temp]  ? pw + params[:slope_higher] * (temp - params[:threshold_temp]) : 
        pw + params[:slope_lower] * (temp - params[:threshold_temp])
    end

    def inv_vaper(pw,vaper)
      params = Shimada::Power::VaperParms
      vaper >  params[:threshold_vaper]  ?
        pw + params[:slope_higher] * (vaper - params[:threshold_vaper]) : 
        pw + params[:slope_lower] * (vaper - params[:threshold_vaper])
    end


   def output_std_temp_file(power)
     polyfits = Shimada::Power::PolyFits[ power.line]
     temp =  power.temps || Forecast.temperature24(:maebashi,power.date)
     vaper = power.vapers || Forecast.vaper24(:maebashi,power.date)
     ave = (0..23).map{ |h| inv_revice(f4(h,polyfits[:ave]),temp[h],vaper[h])}
     min = (0..23).map{ |h| inv_revice(f4(h,polyfits[:min]),temp[h],vaper[h])}
     max = (0..23).map{ |h| inv_revice(f4(h,polyfits[:max]),temp[h],vaper[h])}
     if @time_ofset > 1
       l = @time_ofset -1
       ave = ave[l..-1]+ave[0 .. l-1]
       min = min[l..-1]+min[0 .. l-1]
       max = max[l..-1]+max[0 .. l-1]
     end
     open(@std_data_file,"w"){ |f|
        f.print "時刻 平均 上限 下限\n"
        (0..21).
       each{ |h| f.printf( "%d %.3f %.3f %.3f\n", @time_ofset+h,ave[h],max[h],min[h]) }
      }
    end   
   def output_stdfile(line)
      pw = Shimada::Power.average_line(factory_id,line)
      open(@std_data_file,"w"){ |f|
        f.print "時刻 平均 上限 下限\n"
        (0..20).
        each{ |h| f.printf( "%d %.3f %.3f %.3f\n",
                            @time_ofset+h,pw.revise_by_temp_3[h],pw.powers_3[h],pw.aves_3[h]
                            )
        }
      }
    end
  end # of Power

 class Today < Power
    Def =
      %Q!set terminal gif enhanced size 600,350 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
set title "%s"
%s
set yrange [200:1000]
set xrange %s # [1:24]
set xtics 3,3 #1,1
set x2tics 3,3 # 2,2
set grid #ytics
!
   def initialize(factory_id,powers,method,opt)
     super
      @Def = Def
      @xrange =  "[3:24]"
   end
 end

 class Tomorrow < Power
   def initialize(factory_id,powers,method,opt)
     super
      @Def = Def
      @xrange =  "[3:24]"
   end

    Def =
      %Q!set terminal gif enhanced size 600,350 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
set title "%s"
%s
set yrange [200:1000]
set xrange %s # [1:24]
set xtics 3,3 #1,1
set x2tics 3,3 # 2,2
set grid #ytics
!
    def output_path
      return [@std_data_file] #unless @powers
      output_plot_data{ |f,pw| 
        f.print "時刻 中央 上限 下限\n"
        (0..23).
        each{ |h| f.printf( "%d %.3f %.3f %.3f\n",
                            h+@time_ofset,pw.revise_by_temp[h],pw.powers[h],pw.aves[h]
                            )
        }
      }
    end
    def doutput_def_file(path, group_by)
      preunble = @Def% [ @graph_file , @opt[:title] || "消費電力予想" ,group_by ,@xrange ]
      open(@def_file,"w"){ |f|
        f.puts preunble 
        f.print "plot '#{path[0]}'" + 
        " using 1:2 with line lt -1 ,'' using 1:3 with line lt -1,'' using 1:4 with line lt -1"
        #f.puts "set terminal  eps enhanced color 'GothicBBB-Medium-UniJIS-UTF8-H'
        f.puts "set terminal  jpeg size #{@size}\nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"
      }
    end

 end

  class Standerd < Power
    def initialize(factory_id,powers,method,opt)
      super
      @time_ofset,@xrange =  [ Shimada::Power::TimeOffset+1,
                               "[#{Shimada::Power::TimeOffset+1}:#{Shimada::Power::TimeOffset+25}]"]
      @method = @opt[:mode] || :revise_by_temp_3
      @opt[:fitting] = true

@f=open("/tmp/debug","w")
@f.puts "END init:powers"
    end

 
    def plot()
@f.puts "BF output_path"
      path = output_path
@f.puts path.size
      group_by = ( @opt.keys & [:by_,:by_date] ).size>0 ? "set key outside autotitle columnheader" : "unset key"
@f.puts group_by
      output_def_file(path, group_by)
      `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{@def_file})`
    end
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


    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
    end

    def fitting_line(power,offset)
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


    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
    end
  end

  class Bugs <  Shimada::Gnuplot::Plot
    Def = %Q!set terminal gif enhanced size %s enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'

set title "%s"
set key outside  autotitle columnheader #samplen 1 width -1
set yrange [0:18000]
set xrange [0:1600]
set xtics  0,250
set x2tics  0,250
!

    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
      #@graph_size = opt[:graph_size] || "700,400"  
    end

    def output_path
      output_plot_data{ |f,power| 
        f.printf( "%.1f %.1f\n",power.hukurosu,power.send(@method)) if power.hukurosu && power.send(@method)
        f.print "#{ @method} #{Shimada::Power::BugsFit[@method]}\n"
      }
    end

    def output_def_file(path, group_by)
      bugs_fit =  Shimada::Power.bugs_fit(@method)
      open(@def_file,"w"){ |f|
        f.puts  "# #{ @method} #{Shimada::Power::BugsFit[@method.to_sym]}\n"
          f.puts @Def%[@size,@graph_file,@opt[:title]||"袋数-消費電力 "]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 "}.join(" , ") +
        [0,1,2].map{ |offset|
          ", \\\n #{bugs_fit[:y0][offset]+bugs_fit[:offset][offset]} + #{bugs_fit[:slop][offset]}*x "
           # ", \\\n #{bugs_fit[:y0]} + #{bugs_fit[:slop]}*x " +
           # bugs_fit[:offset].map{|offset|
          #",\\\n #{bugs_fit[:y0]} + #{bugs_fit[:slop]}*x + #{offset}"
        }.join
          f.puts "set terminal  jpeg  size #{@graph_size} \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n" 
      }
    end
end

  class Temp <  Shimada::Gnuplot::Plot
    Def = %Q!set terminal gif enhanced size %s enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'

set title "%s" #"温度-消費電力 " 
set key outside  autotitle columnheader samplen 1 width -4
set yrange [0:1000]
set xrange %s  #[-10:40]
set xtics -10,5
set x2tics -10,5
!

    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
      @range = opt.delete(:range) || (0..23)
      @graph_size = opt[:graph_size] || "700,400"  
    end

    def output_path
      sym = case @opt[:vs_temp]
            when :vaper ;:vapers
            else        ; :temperatures
            end
      output_plot_data{ |f,power| 
        weather = Weather.find_or_feach("maebashi", power.date)#.temperatureseratures[idx] 
          power.send(@method).zip(weather.send(sym))[@range].each{ |pw,tmp| 
            f.printf( "%.1f %.1f\n",tmp,pw ) if pw && tmp
          } if weather
      }
    end

    def output_def_file(path, group_by)
      size = @opt[:vs_temp] == :vaper ? "[0:35]" : "[-10:40]"
      x0,y0,sll,slh = [:threshold_temp,:y0, :slope_lower, :slope_higher ].
        map{ |sym|Shimada::Power::ReviceParms[sym]}
      lines = case @opt[:vs_temp]
                when :vaper
                x0,slh = 20,5 #20
                x0,slh,y0 = 20,6,620 #20
          #  ",  (x>#{x0}) ? #{y0}+#{slh}*(x-#{x0}) : #{y0}+#{sll}+3*(x-#{x0}) title '蒸気補償' lt -1 lw 1.5\n"
            ",  (x>#{x0}) ? #{y0}+#{slh}*(x-#{x0}) : #{y0} title '蒸気補償' lt -1 lw 1.5\n"
        else
            ",  (x>#{x0}) ? #{y0}+#{slh}*(x-#{x0}) : #{y0}+#{sll}+3*(x-#{x0}) title '温度補償' lt -1 lw 1.5, \\
 0.440*(x-5)**1.8+750 title 'TopLine' lc rgbcolor '#FF0000' lw 1.5\n"
        end
      open(@def_file,"w"){ |f|
          f.puts @Def%[@graph_size,@graph_file,@opt[:title]||"温度-消費電力 ",size]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ") + lines +
           "set terminal  jpeg  size #{@graph_size} \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n" 
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

    def initialize(factory_id,powers,method,opt)
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

  class Histgram < Shimada::Gnuplot::Plot
    Def =
      %Q!set terminal gif enhanced size 500,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
set title "%s"
unset key 
set xrange [-1000:4000]
plot '%s'   using 1:2 with boxes
!

    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
    end
    def output_path
      path =  [ RAILS_ROOT+"/tmp/shimada/data/shimada_histgram"]
      open(path.first,"w"){ |f| 
        f.print "オフセット i頻度\n"
        (@opt[:min] .. @opt[:max]).step(@opt[:step]).
        each_with_index{ |o,idx| f.printf( "%.1f %d\n",o,@powers[idx])}
      }
      path
    end

    def output_def_file(path, group_by)
      open(@def_file,"w"){ |f|
          f.puts @Def%[@graph_file,@opt[:title],path[0] ]
          f.puts "set terminal  jpeg  size 600,200 \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"         #end
      }
    end
  end
end

