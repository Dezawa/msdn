# -*- coding: utf-8 -*-
module Shimada::GnuplotDef
  #include  Shimada::Gnuplot

  module ClassMethod
    # extend  Shimada::GnuplotDef::ClassMethod

    def average_out(power,method,time_ofset)
      open(Rails.root+"tmp/shimada/data/shimada_power_diff_ave","w"){ |f|
        f.puts "時刻 平均"
        power.send(method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+time_ofset,h ) if h } 
        f.puts
      }
    end

    DefaultTitle ={:normalized => "正規化消費電力",:difference => "温度差分",:powers => "消費電力",
      :difference_ave => "差分平均",:revise_by_temp => "温度補正電力",:diffdiff => "二階差分"}

    def gnuplot(factory_id,powers,method,opt={ })
 logger.debug("GRAPH_BUGS_: :vs_temp #{opt[:vs_temp]},:vs_bugs #{opt[:vs_bugs]} method #{method} powers.size =#{powers.size}")

      if opt[:vs_temp]
        case method.to_s 
        when /^deviation/ ;TempDeff.new(factory_id,powers,method,opt).plot
        else              ;Temp.new(factory_id,powers,method,opt).plot
        end
      elsif opt[:vs_bugs] ; logger.debug("GNUPLOT: moethod=#{method}")
        Bugs.new(factory_id,powers,method,opt).plot
      else
        case method.to_s
        when /^normalized/ ;  Nomalized.new(factory_id,powers,method,opt).plot
        when /^diff/       ;  Differ.new(factory_id,powers,method,opt).plot
        when /^standerd/   ;  Standerd.new(factory_id,powers,method,opt).plot
        else               ;  Power.new(factory_id,powers,method,opt).plot
        end
      end
    end

    def gnuplot_by_month(factory_id,powers_group_by_month,method,opt={ })
      PowerByMonth.
        new(factory_id,powers_group_by_month,method,opt.merge(:fitting => true)).plot
    end

    def gnuplot_histgram(factory_id,powers,method,opt={ })
      values = powers.map{ |pw| pw.send(method) }
      min   = opt[:min]   ||= values.min
      max   = opt[:max]   ||= values.max
      steps = opt[:steps] ||= 10
      step = opt[:step] = (max-min)/steps
      histgram = [0]*steps
      histgram = values.inject([0]*steps){ |s,e| s[e/step] += 1 ;s   }
      Histgram.new(factory_id,histgram,method,opt).plot
    end
  end # of module

  def self.included(base) ;    base.extend(ClassMethod) ;end

  def tomorrow_graph(factory_id,line)
    temperature = Forecast.temperature24(:maebashi,self.date)
    #[:revise,:max,:min].each{ |method| self.copy_and_inv_revise(temperature,method)  }
    Tomorrow.new(factory_id,[self],:powers,{:graph_file => "tomorrow_#{factory_id}"  ,
                                :fitting => :std_temp }).plot
  end
  def today_graph factory_id
    temperature = Forecast.temperature24(:maebashi,self.date)
   Today.new(factory_id,[self],:powers,{:graph_file => "today_#{factory_id}" ,
                                :fitting => :std_temp }).plot
  end
  class Plot
    attr_reader :factory_id
    def initialize(factory_id,powers,method,opt)
      @factory_id = factory_id
      @factory    = Shimada::Factory.find @factory_id
      @powers = powers
      @method = method
      @opt    = opt
      @time_ofset,@xrange =  
        if /_3$/ =~ method.to_s
          [ Shimada::TimeOffset[@factory.power_model_id]+1,"[#{Shimada::TimeOffset[@factory.power_model_id]+1}:#{Shimada::TimeOffset[@factory.power_model_id]+25}]"]
        else ;  [1,"[1:24]"]
        end
      @def_file = Rails.root+"tmp/shimada/data/power.def"
      @graph_file = opt.delete(:graph_file) ||  "power"
      @size = opt[:graph_size] || "600,400"

    end


    def output_plot_data(ary_powres,idx_offset = 0,&block)
      path = []
      keys = @keys
      keys ||= ary_powres.keys.sort
      lbl  = @labels || keys
      keys.each_with_index{ |k,idx|
        path << 
        Rails.root+"tmp/shimada/data/shimada_power_temp%d"%(idx+idx_offset)
        open(path.last,"w"){ |f|
          f.puts "時刻 #{lbl[idx]}"
          ary_powres[k].each{ |power|
            yield f,power
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

    def output_path(method,path_offset=0,ary_powers=nil)
      output_plot_data(ary_powers || powers_group_by,path_offset){ |f,power| 
        power.send(method).each_with_index{ |h,idx| f.printf( "%d %.3f\n",idx+@time_ofset,h ) if h }
      }
    end

    def output_path_with_data(path_offset=0,ary_powers=nil)
      ary_powers ||= powers_group_by
      @labels = case with=@opt["with"]
              when /temps/ ; ["気温"]
              when /vapers/; ["蒸気圧"]
              when /tempvapers/; ["気温","蒸気圧"]
              end#090-5317-3448
      case with
      when /temps|vapers/ 
        return output_plot_data({ "気温 蒸気圧" => @powers},path_offset ){ |f,power| 
          power.send(with).each_with_index{ |h,idx| 
            f.printf( "%d %.3f\n",idx+@time_ofset,h ) if h
          }
        }
      when /tempvaper/
          return output_plot_data({  "気温 蒸気圧" =>  @powers},path_offset ){ |f,power| 
            power.send(with).each_with_index{ |h,idx| f.printf( "%d %.3f %.3f\n",idx+@time_ofset,*h ) if h 
          }
        }
        
      end
      
    end

    def plot()
      path = output_path(@method)
      opt_path =  @opt["with"] ? output_path_with_data(path.size) : []
      group_by = ( @opt.keys & [:by_,:by_date] ).size>0 ? "set key outside autotitle columnheader" : "unset key"
      output_def_file(path, group_by,opt_path)
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{@def_file})`
      "#{opt[:graph_file_dir]}/#{opt[:graph_file]}.#{opt[:terminal]}"
    end
        
    def ytics_for_with_option
       case @opt["with"]
       when /temps|vapers|tempvaper/ ; "set y2tics\nset y2range [-10:40]\nset xtics nomirror\nset key autotitle columnheader"
       end
    end

    def plot_with_option(optpath)
      return "" unless  @opt["with"]
      case @opt["with"]
      when /temps|vapers/ ;",\\\n " + optpath.map{ |p| "'#{p}' using 1:2  with line axis x1y2 "}.join(" , ") 
      when /tempvaper/    
        ",\\\n " + optpath.map{ |p| 
          "'#{p}' using 1:2  with line axis x1y2 ,'' using 1:3  with line axis x1y2 "}.join(" , ") 
      end
    end

    def output_def_file(path, group_by,optpath=[])
      preunble = @Def% [ @graph_file , @opt[:title] || "消費電力" ,group_by ,@xrange ,@xrange ]
      open(@def_file,"w"){ |f|
        f.puts preunble 
        f.puts  ytics_for_with_option if @opt["with"]
        f.print "plot " + path.map{ |p| "'#{p}' using 1:2  with line"}.join(" , ")
        f.print plot_with_option(optpath)
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

  class Power <  Plot
    Def =
      %Q!set terminal gif enhanced size 600,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'
set title "%s"
%s
set yrange [0:1000]
set xrange %s # [1:24]
set x2range %s # [1:24]
set xtics 3,3 #1,1
set x2tics 3,3 # 2,2
set grid #ytics
!

    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
      @std_data_file = Rails.root+"tmp/shimada/data/"+@graph_file
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

    # 標準稼動ラインを温湿度補正したデータ
    def output_std_temp_file(power)
      polyfits = Shimada::Power::PolyFits[ power.line]
      temp =  power.temps || Forecast.temperature24(@factory.weather_location,power.date)
      vaper = power.vapers || Forecast.vaper24(@factory.weather_location ,power.date)
      ave = []
      min = []
      max = []
      (0..23).each{ |h| 
        av,mn,mx = Shimada::Power.simulate_a_hour(power.line,h,temp[h],vaper[h],@factory_id)
        ave << av; min << mn ; max << mx
      }

     if @time_ofset > 1
       l = @time_ofset -1
       ave = ave[l..-1]+ave[0 .. l-1]
       min = min[l..-1]+min[0 .. l-1]
       max = max[l..-1]+max[0 .. l-1]
     end
    #  open(@std_data_file,"w"){ |f|
    # #    f.print "時刻 平均 上限 下限\n"
    # #    (0..21).
    # #   each{ |h| f.printf( "%d %.3f %.3f %.3f\n", @time_ofset+h,ave[h],max[h],min[h]) }
    #   }
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
    def output_path(method)
      return [@std_data_file] #unless @powers
      # output_plot_data(powers_group_by){ |f,pw| 
      #   f.print "時刻 中央 上限 下限\n"
      #   (0..23).
      #   each{ |h| f.printf( "%d %.3f %.3f %.3f\n",
      #                       h+@time_ofset,pw.revise_by_temp[h],pw.powers[h],pw.aves[h]
      #                       )
      #   }
      # }
    end
    def doutput_def_file(path, group_by,optpath=[])
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
      @time_ofset,@xrange =  [ Shimada::TimeOffset[@factory.power_model_id]+1,
                               "[#{Shimada::TimeOffset[@factory.power_model_id]+1}:#{Shimada::TimeOffset[@factory.power_model_id]+25}]"]
      @method = @opt[:mode] || :revise_by_temp_3
      @opt[:fitting] = true

@f=open("/tmp/debug","w")
@f.puts "END init:powers"
    end

 
    def plot()
@f.puts "BF output_path"
      path = output_path(@method)
@f.puts path.size
      group_by = ( @opt.keys & [:by_,:by_date] ).size>0 ? "set key outside autotitle columnheader" : "unset key"
@f.puts group_by
      output_def_file(path, group_by,optpath=[])
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{@def_file})`
    end
  end


  class Nomalized <  Plot
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

  class Differ <  Plot
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

  class Bugs <  Plot
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

    def output_path(method)
      output_plot_data(powers_group_by){ |f,power| 
        f.printf( "%.1f %.1f\n",power.hukurosu,power.send(method)) if power.hukurosu && power.send(method)
        f.print "#{method} #{Shimada::Power::BugsFit[method]}\n"
      }
    end

    def output_def_file(path, group_by,optpath=[])
      bugs_fit =  Shimada::Power.bugs_fit(@method)
      open(@def_file,"w"){ |f|
        f.puts  "# #{@method} #{Shimada::Power::BugsFit[@method.to_sym]}\n"
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

  class Temp <  Plot
    Def = %Q!set terminal gif enhanced size %s enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/shimada/giffiles/%s.gif'

set title "%s" #"温度-消費電力 " 
set key outside  autotitle columnheader samplen 1 width -4
set yrange [0:1100]
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

    def output_path(method)
      sym = case @opt[:vs_temp]
            when :vaper ; :vapers
            else        ; :temperatures
            end
      output_plot_data(powers_group_by){ |f,power| 
        weather = Weather.find_or_feach(@factory.weather_location , power.date)#.temperatureseratures[idx] 
          power.send(method).zip(weather.send(sym))[@range].each{ |pw,tmp| 
            f.printf( "%.1f %.1f\n",tmp,pw ) if pw && tmp
          } if weather
      }
    end

    def output_def_file(path, group_by,optpath=[])
      size = @opt[:vs_temp] == :vaper ? "[0:35]" : "[-10:40]"
      title,line_params = 
        case @opt[:vs_temp]
        when :vaper  ;
          if @method == :revise_by_temp ;['蒸気補償', Shimada::Power::VaperParams]
          else ;                        ; ['蒸気補償', Shimada::Power.vaper_params_raw(@factory_id)]
          end
        else         ; ['温度補償', Shimada::Power.revise_params(@factory_id)]
        end

      x0,y0,sll,slh = [:threshold,:y0, :slope_lower, :slope_higher ].
        map{ |sym| line_params[sym]}

      lines = 
        ",  (x>#{x0}) ? #{y0}+#{slh}*(x-#{x0}) : #{y0}+#{sll}*(x-#{x0}) title '#{title}' lt -1 lw 1.5\n" 
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

    def output_path(method)
      output_plot_data(powers_group_by){ |f,power| 
        weather = Weather.find_or_feach(@factory.weather_location , power.date)#.temperatures
          f.printf( "%.1f %.1f\n",weather.max_temp, power.send(method)) if  weather
      }
    end
    def output_def_file(path, group_by,optpath=[])
      open(@def_file,"w"){ |f|
          f.puts @Def%[@graph_file,@opt[:title] ]
          f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 ps 0.3"}.join(" , ")
          f.puts "set terminal  jpeg  size 600,200 \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"         #end
      }
    end
  end

  class PowerByMonth <Plot
    Def =
      %Q!set term gif  size 800,400 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
 set output 'tmp/shimada/giffiles/%s.gif'  
 
set title "%s"
set key outside autotitle columnheader samplen 2 width -10

set xrange [1:12]
set xtics 1,1
!
    def initialize(factory_id,powers,method,opt)
      super
      @Def = Def
    end

    def output_def_file(path, group_by,optpath=[])
      open(@def_file,"w"){ |f|
        f.puts @Def%[@graph_file,@opt[:title] ]
        i=5
        f.puts "plot " + path.map{ |p| i+=1; "'#{p}' using 1:2  pt #{i} ps 2 "}.join(" , ")
        f.puts "set terminal  jpeg  size 800,400 \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"         #end
      }
    end

    def output_path(method)
      powers_by_year = @powers.group_by{ |m,_p_array| m.year }
      path = []
      powers_by_year.each{ |year,powers|
        path << Rails.root+"tmp/shimada/data/shimada_power_by_month_#{year}"
        open(path.last,"w"){ |f|
          f.print "月 #{year}\n"
          powers.each{ |month,average| f.printf("%s %.1f\n",month.month,average)}
        }
      }
      path
    end

    def fitting_line(*args)
      ""
    end
  end

  class Histgram < Plot
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
    def output_path(method)
      path =  [ Rails.root+"tmp/shimada/data/shimada_histgram"]
      open(path.first,"w"){ |f| 
        f.print "オフセット i頻度\n"
        (@opt[:min] .. @opt[:max]).step(@opt[:step]).
        each_with_index{ |o,idx| f.printf( "%.1f %d\n",o,@powers[idx])}
      }
      path
    end

    def output_def_file(path, group_by,optpath=[])
      open(@def_file,"w"){ |f|
          f.puts @Def%[@graph_file,@opt[:title],path[0] ]
          f.puts "set terminal  jpeg  size 600,200 \nset out 'tmp/shimada/jpeg/#{@graph_file}.jpeg'\nreplot\n"         #end
      }
    end
  end
end
