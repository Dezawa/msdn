# -*- coding: utf-8 -*-
require 'pp'

class Weather < ActiveRecord::Base
  include PowerGraph
  extend PowerGraphGraph

  serialize :temp
  serialize  :vaper
  serialize :humi
  
  Temperature = ("hour01".."hour24").to_a
  Vaper       = ("vaper01".."vaper24").to_a
  Humidity    = ("humidity01".."humidity24").to_a


    Block= { "maebashi" => [42,47624],
             "minamiashigara" => [46,1008]
  }


  class << self
    def plot_year(weather_location,day_from,day_to,hour_from,hour_to)
      day_from  = Time.parse(day_from || "2013-1-1") 
      day_to    = Time.parse(day_to   || "2020-12-31")
      hour_from = (hour_from||9).to_i - 1
      hour_to   = (hour_to ||15).to_i - 1
      weathers  = self.where(["location =? and date >= ?  and date <= ?",
                             weather_location,day_from,day_to])
      graph_by_days_hour weathers
      #output_plot_year_data(weathers,hour_from,hour_to)
      #opt = {:def_file => Rails.root+"tmp/weather_temp_vaper.def",
      #  :location => WeatherLocation.find_by(location: weather_location) 
      #}.merge(opt)
      #graph_file = output_plot_year_def_file(path,opt)
      #`(cd #{Rails.root};/usr/local/bin/gnuplot #{opt[:def_file]})`
      graph_file
      
    end

    def temp_vaper_graph(weather_location,opt={ })
      path = output_plot_data(weather_location,opt)
      opt = {:def_file => Rails.root+"tmp/weather_temp_vaper.def",
        :location => WeatherLocation.find_by(location: weather_location) }.merge(opt)
      graph_file = output_def_file(path,opt)
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{opt[:def_file]})`
      graph_file
    end

    def output_plot_data(weather_location,opt={ })
      path = []
      self.where( ["location = ?" , weather_location]).
        group_by{ |w| w.month.year}.
        each{ |year,weathers|
        path << Rails.root+"/tmp/weather_temp_vaper#{year}"
        open( path.last,"w"){ |f|
          f.puts "温度 #{year}"
          weathers.each{ |w| 
            w.temperatures.each_with_index{ |temp,idx| 
              f.printf("%.1f %.1f\n",temp,w.vapers[idx])
            }
          }
        }
      }
      path
    end

    def output_plot_year_data(weathers,hour_from,hour_to)
      path = [Rails.root+"/tmp/weather_temp_vaper_year"]
      open( path.last,"w"){ |f|
        f.puts "年初からの日数 温度 水蒸気圧"
        weathers.each{ |w| 
          year_date = w.date.yday
          (hour_from..hour_to).each
            w.temperatures.each_with_index{ |temp,idx| 
              f.printf("%.1f %.1f\n",temp,w.vapers[idx])
            }
          }
        }

    end

    Def =
%Q!set terminal jpeg enhanced size 700,400 enhanced font "/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10"
set out 'tmp/img/%s.jpeg'
set title "%s " #"温度-消費電力 " 
set key outside  autotitle columnheader #samplen 1 width -4
set yrange [0:40]
set xrange [-5:40]  #[-10:40]
set xtics -5,5
set x2tics -5,5
set grid
set ylabel "水蒸気圧/hPa"
set xlabel "気温/℃"

  pc = 221200   #[hPa]：　臨界圧
  tc = 647.3    # [K]：　臨界温度
  invtc = 1.0/tc
  #x = 1 - (t + 273.15) / Tc
  a = -7.76451
  b = 1.45838
  c = -2.7758
  d = -1.23303
  xx(x) = 1.0 - (x + 273.15) * invtc 
  p(a,b,c,d,x)=pc*exp((a*xx(x) + b*xx(x)**1.5 + c*xx(x)**3 + d*xx(x)**6) / (1.0 - xx(x)))
!
    def output_def_file(path,opt={ })
      grapf_file = opt[:grapf_file] || "temp_vaper_#{opt[:location].location}"
      title      = opt[:title]      || "温度-水蒸気圧(#{opt[:location].name})"
      open(opt[:def_file],"w"){ |f|
        f.printf Def,grapf_file,title
        f.puts "plot " + path.map{ |p| "'#{p}' using 1:2 "}.join(" , ") +
        " , \\"
       f.puts  [100,80,60,40,20].map{ |r| rr = 0.01 * r
          "p(a,b,c,d,x)*#{rr} with line title '#{r}%'"
        }.join(" , ")
      }
      grapf_file
    end

    def fetch(location,day)
      y,m,d = [day.year, day.month, day.day]
      #emp_vaper_humidity = `/usr/local/bin/weather_past.rb #{location} #{y} #{m} #{d}`
      temp,vaper,humidity = hours_data_of(location,y,m,d) #mp_vaper_humidity.split(/[\n\r]+/)
      logger.info("WEATHER:: #{temp.class}")
      return unless temp
      weather = self.create({ :location => location.to_s,
                             :date => day,
                             :month => day.beginning_of_month ,# }.
                             :temp => temp, :vaper => vaper, :humi => humidity
                             }
                             # merge(Hash[*Temperature.zip(temp).flatten]).
                             # merge(Hash[*Vaper.zip(vaper).flatten]).
                             # merge(Hash[*Humidity.zip(humidity).flatten])

                             )
    end

    def find_or_feach(location,day)
      weather = find_by(location: location.to_s,month: day.beginning_of_month ,date: day)
      return weather if weather
      fetch(location,day)
    end
    
    Hour,Atmospher,Atmospher_sea,Rain,Temperature0,Dew,Vaper0,Humidity0,Wind_blow,Wind_speed,Daytime,Daylight,Snow,Snow_stack,Weather,Cloud,View = (0..16).to_a

    PhantomJS = "/usr/local/bin/phantomjs"
    JS ="
(function () {
  'use strict';
  var page = require('webpage').create();

  page.open('%s', function (status) {
    if (status === 'success') {
	console.log(page.content);
    } else {
      console.log('failed.');
    }
    phantom.exit();
  });
}());
"

    URLPast_s   = "http://www.data.jma.go.jp/obd/stats/etrn/view/hourly_s1.php?prec_no=%d&block_no=%s&year=%d&month=%02d&day=%d&view="
    URLPast_a   = "http://www.data.jma.go.jp/obd/stats/etrn/view/hourly_a1.php?prec_no=%d&block_no=%s&year=%d&month=%02d&day=%d&view="

    def get_data(location,y,m,d)
      url_past = /47\d{3}/ =~ location.weather_block ? URLPast_s : URLPast_a
      url = url_past%[location.weather_prec,location.weather_block,y,m,d]
logger.debug("HOURS_DATA_OF: url =#{url}")
      fp = Tempfile.open("js.js")
      fp.write JS%url
      jspath = fp.path
      fp.close
      content = `#{PhantomJS} #{jspath}`     
    end

    def hours_data_of(*block_y_m_d)
      logger.debug("###### hours_data_of block_y_m_d=#{block_y_m_d}")
      block = block_y_m_d.shift
      y,m,d = case block_y_m_d.first
              when Integer,Float   ;  block_y_m_d
              when Date,Time; [ block_y_m_d.year, block_y_m_d.month, block_y_m_d.day]
              end
      location = WeatherLocation.find_by(location: block)
      
      content =  get_data(location,y,m,d)
      lines = content.split(/[\n\r]+/)  
      while ( line = lines.shift) && /tablefix[12]/ !~ line ;end
      return nil unless line
      /(201\d年\d{1,2}月\d{1,2}日)/ =~ line
      date = $1
      temp = []
      humi = []
      vaper= []
      (1..24).each{ |d|
        #( line = lines.shift) until /<tr class="mtx"/ =~ line
        while  /<td class="data_0_0/ !~ ( line = lines.shift);end
        # puts line
        clms = line.split(/<\/td><td.*?>/)
        if /47\d{3}/ =~ location.weather_block
          temp << clms[Temperature0].to_f
          humi << clms[Humidity0].to_f
          vaper << clms[Vaper0].to_f
        else
          temp << clms[2].to_f
          
        end
      }
      [temp,vaper,humi]
    end

  end
  
  def temperatures ;  temp ; end # Temperature.map{ |t| self[t]} ; end
  def vapers      ;   vaper ; end #Vaper.map{ |t| self[t]} ; end
  def max_temp ; temperatures.max ; end

  ("01".."24").each_with_index{ |h,idx| 
    define_method("tempvaper#{h}".to_sym){
      ("%2.1f<br>%2.1f"%[temp[idx],
                         vaper[idx]
                        ]).html_safe #.map{ |t| self[t]}).html_safe
    }
    define_method("temp_#{h}".to_sym){ temp[idx] }
    define_method("hour#{h}".to_sym){ temp[idx] }
  }
  def clm2serial
    self.temp  = Temperature.map{|tmp| self[tmp] }
    self.vaper = Vaper.map{|tmp| self[tmp] }
    self.humi  =  Humidity.map{|tmp| self[tmp] }
    self
  end

  def self.clm2serial_all
    self.all.each{|w| w.clm2serial.save }
  end
    
end
__END__
s = Time.local(2013,2,1).beginning_of_day
e = Time.local(2014,8,10).beginning_of_day
date = s
Weather.fetch("gifu",date)
while date <= e
  Weather.find_or_feach("gifu",date)
  date = date.tomorrow
  p date
end

wthr=Weather.all(:conditions => "date >= '2013-1-1' and date <= '2014-6-26'");wthr.size
tv = wthr.map{ |w| w.temperatures.zip(w.vapers)[7..19].map{ |t,v| "#{t} #{v}"} };tv.size
open("temp_vaper","w"){ |f| f.puts tv}
