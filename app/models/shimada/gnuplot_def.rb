# -*- coding: utf-8 -*-
module Shimada::GnuplotDef
  include  Shimada::Gnuplot

  module ClassMethod
    # extend  Shimada::GnuplotDef::ClassMethod

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
 logger.debug("GRAPH_BUGS_: :vs_temp #{ opt[:vs_temp]},:vs_bugs #{opt[:vs_bugs]}")

      if opt[:vs_temp]
        case method.to_s 
        when /^deviation/ ;Shimada::Gnuplot::TempDeff.new(powers,method,opt).plot
        else              ;Shimada::Gnuplot::Temp.new(powers,method,opt).plot
        end
      elsif opt[:vs_bugs] ; logger.debug("GNUPLOT: moethod=#{method}")
        Shimada::Gnuplot::Bugs.new(powers,method,opt).plot
      else
        case method.to_s
        when /^normalized/ ;  Shimada::Gnuplot::Nomalized.new(powers,method,opt).plot
        when /^diff/       ;  Shimada::Gnuplot::Differ.new(powers,method,opt).plot
        when /^standerd/   ;  Shimada::Gnuplot::Standerd.new(powers,method,opt).plot
        else               ;  Shimada::Gnuplot::Power.new(powers,method,opt).plot
        end
      end
   end

    def gnuplot_histgram(powers,method,opt={ })
      values = powers.map{ |pw| pw.send(method) }
      min   = opt[:min]   ||= values.min
      max   = opt[:max]   ||= values.max
      steps = opt[:steps] ||= 10
      step = opt[:step] = (max-min)/steps
      histgram = [0]*steps
      histgram = values.inject([0]*steps){ |s,e| s[e/step] += 1 ;s   }
      Shimada::Gnuplot::Histgram.new(histgram,method,opt).plot
    end
  end # of module

  def self.included(base) ;    base.extend(ClassMethod) ;end

  def tomorrow_graph(line)
    temperature = Forecast.temperature24(:maebashi,self.date)
    #[:revise,:max,:min].each{ |method| self.copy_and_inv_revise(temperature,method)  }
    Shimada::Gnuplot::Tomorrow.new([self],:powers,{:graph_file => "tomorrow"  ,
                                :fitting => :std_temp }).plot
  end
  def today_graph
    temperature = Forecast.temperature24(:maebashi,self.date)
    Shimada::Gnuplot::Today.new([self],:powers,{:graph_file => "today" ,
                                :fitting => :std_temp }).plot
  end
end
