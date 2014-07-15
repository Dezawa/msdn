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
      if opt[:vs_temp]
        case method.to_s 
        when /^deviation/ ;Shimada::Gnuplot::TempDeff.new(powers,method,opt).plot
        else              ;Shimada::Gnuplot::Temp.new(powers,method,opt).plot
        end
      else
        case method.to_s
        when /^normalized/ ;  Shimada::Gnuplot::Nomalized.new(powers,method,opt).plot
        when /^diff/       ;  Shimada::Gnuplot::Differ.new(powers,method,opt).plot
        when /^standerd/   ;  Shimada::Gnuplot::Standerd.new(powers,method,opt).plot
        else               ;  Shimada::Gnuplot::Power.new(powers,method,opt).plot
        end
      end
   end
  end # of module

  def self.included(base) ;    base.extend(ClassMethod) ;end

end
