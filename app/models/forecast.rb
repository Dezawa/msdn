# -*- coding: utf-8 -*-
require 'pp'
class Forecast < ActiveRecord::Base
 extend Shimada::ForecastReal

    ZP   = { :maebashi => %w(3/13/4210/10201 前橋), 
             :minamiashigara => %w(3/17/4620/14217 南足柄) }

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
    URLForecast =  "http://www.tenki.jp/forecast/%s.html"


  StrArg   = %w(location)
  DateArg  = %w(date month announce_day)
  TimeArg  = %w(announce)
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weathers     = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
  Humi     = %w(humi03 humi06 humi09 humi12 humi15 humi18 humi21 humi24)
  Vaper    = %w(vaper03 vaper06 vaper09 vaper12 vaper15 vaper18 vaper21 vaper24)
  class << self
    def fetch(location,day)
      day = day.to_date
      today = Time.now
#      h = today.hour
      day_hour = today.beginning_of_hour
      today = today.to_date

      return nil unless  day == today || day == today + 1

      announce,today,tomorrow,todays,tomorrows = forecast(location)
      today_forecast = self.find_or_create_by_location_and_date_and_announce(location.to_s,today,announce )
      weather_temperature_humidity = to_hash(todays)
      #weather,temperature,humidity = todays
      #w = Hash[*Weathers.zip(weather).flatten]
      #t = Hash[*Temp.zip(temperature).flatten]
      #h = Hash[*Humi.zip(humidity).flatten]
      args = { :announce_day => announce.to_date,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
      today_forecast.update_attributes( args )
      today_forecast.vaper
      today_forecast.save

      tomorrow_forecast = self.find_or_create_by_location_and_date_and_announce(location.to_s,tomorrow,announce )
      weather_temperature_humidity = to_hash(tomorrows)
      args = { :announce_day => announce.to_date,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
      tomorrow_forecast.update_attributes( args )
      tomorrow_forecast.vaper
      tomorrow_forecast.save

      return case day
             when today ; today_forecast 
             when tomorrow ;  tomorrow_forecast
             end
    end
    def to_hash(weathers)
      weather,temperature,humidity = weathers
      w = Hash[*Weathers.zip(weather).flatten]
      t = Hash[*Temp.zip(temperature).flatten]
      h = Hash[*Humi.zip(humidity).flatten]
      w.merge(t).merge(h)
    end

    def find_or_fetch(location,day=nil,announce_day = nil)
      day = Time.parse(day).to_date if day === String
      day ||= Time.now.to_date
      announce_day = Time.parse(announce_day).to_date if announce_day === String
      announce ||= day
      day = day.to_date
      announce = Time.now.beginning_of_hour
      forecast = find_by_location_and_month_and_date(location.to_s,
                                                                  day.beginning_of_month,
                                                                  day)
      forecast.vaper if forecast && !forecast.vaper03
      return forecast if forecast
#      return nil      if announce_day != Time.now.to_date # 本日のアナウンスしか採れない
       fetch(location,day)
    end


    def forecast(zp)
     lines=forecast_html(zp) #File.read("maebashi_forecast").split("\n")
  #    lines=File.read("maebashi_forecast").split("\n")
      date = announce_datetime(lines)
      today = today_is(lines)
      tomorrow =tomorrow_is(lines)
      hour_lines(lines)
      weather = rain_rank(lines)
      temperature = temperaures(lines)
      while / class="humidity/ =~  (line = lines.shift) ;      end
      humidity = humidities(lines) 

      [date,today,tomorrow,
       [weather[0,8],temperature[0,8],humidity[0,8]],
       [weather[8,8],temperature[8,8],humidity[8,8]]
      ]
    end
  
    def forecast_html(zp)
      zp = zp.to_sym
      url = URLForecast%ZP[zp].first
      open("js.js","w"){ |fp| fp.write JS%url}
      content = `#{PhantomJS} js.js`.split("<")
    end

    def announce_datetime_excite(lines)      
      while /<div class="spot_ref_time">/ !~ (line = lines.shift) ;      end
#puts line
      match=/(\d+)月(\d+)日[^\d]*(\d+)時(\d+)分/.match(line)
      Time.local(Time.now.year,*match[1,4])
    end

    def today_is_excite(lines)
      while /今日の天気/ !~ (line = lines.shift) ;      end
      match=/(\d+)月(\d+)日/.match(line)
      Date.new(Time.now.year,*match[1,2].map(&:to_i))
    end

    def announce_datetime(lines)      
      while /id="pinpoint_weather_name"/ !~ lines.shift ;      end
      while /id="point_announce_datetime"/ !~ (line = lines.shift) ;      end
      Time.parse( line.sub(/^.*?>/,"").gsub(/[年月日時分]/,"-"))
    end

    def today_is(lines)
      while /今日/ !~ (line = lines.shift) ;      end
      Time.parse(line.sub(/^[^\d]/,"").gsub(/[^\d ]/,"")).to_date
    end

    def tomorrow_is(lines)
      while /明日/ !~ (line = lines.shift) ;      end
      Time.parse(line.sub(/^[^\d]/,"").gsub(/[^\d ]/,"")).to_date
    end

    def hour_lines(lines)
      while /class="hour/ !~ (line = lines.shift) ;      end
    end

    def rain_rank(lines)
      while /雨のランクは5段階で表示されます/ !~ (line = lines.shift) ;      end
      (0..15).map{ |i|
        while /^img/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"")
      }
    end

    def temperaures(lines)
      while /class="temperature"/ =~  (line = lines.shift) ;      end
      temperature = (0..15).map{ |k|
        while /^td>/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"").to_f
      }
    end

    def humidities(lines) 
      while / class="humidity/ =~  (line = lines.shift) ;      end
      (0..15).map{ |k|
        while /^td>/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"").to_f
      }
    end

  def temperature24(location,date)
    date=date.to_date
    fore = self.find_or_fetch(location,date)# || self.find_or_fetch(location,date,date-1)
    expand(fore.temperature)
  end
  def vaper24(location,date)
    date=date.to_date
    fore = self.find_or_fetch(location,date) || self.find_or_fetch(location,date,date-1)
    expand(fore.vaper)
  end

  def expand(ary)
    ret = ary.map{ |t| [0,0,t]}.flatten
    # 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4
    # 0 0 t 0 0 t 0 0 t 0 0 t 0 0 t 0 0 t 0 0 t 0 0 t
    (2..20).step(3).each{ |h| 
      ret[h+1] = (ret[h]*2 + ret[h+3])/3.0 
      ret[h+2] = (ret[h]   + ret[h+3] * 2)/3.0 
    }
    slope = (ret[5]-ret[2])/3.0
    ret[0] = ret[2] - 2*slope
    ret[1] = ret[2] - slope
    ret
  end

  def differrence_via_real(location = :maebashi )
    dates = Forecast.all(:conditions => ["location = ?",location]).
    map(&:date).uniq
    weathers = dates.map{ |date|
      today    = Forecast.find_by_date_and_announce_day(date,date)
      tomorrow = Forecast.find_by_date_and_announce_day(date,date-1)
      real     = Weather.find_or_feach(:maebashi,date)
      [today,tomorrow,real]
    }

    differ = []
    weathers.map{ |k,a,r|
      next unless r
      [3,6,9,12,15,18,21,24].each_with_index{ |h,idx|
        diff = []
        diff << ( r.date.to_time + h.hour)
        diff << (r ? r.temperatures[h-1] : nil )
        diff << (k ? (k.temperature[idx]-r.temperatures[h-1])  : nil)
        diff << (a ? (a.temperature[idx]-r.temperatures[h-1])  : nil)

        diff << (r ? r.vapers[h-1] :  nil)
        diff << (k ? (k.vaper[idx]-r.vapers[h-1])  : nil )
        diff << (a ? (a.vaper[idx]-r.vapers[h-1])  : nil)
        differ << diff
      }
    }
    differ
  end

  def differrence_via_real_graph(location = :maebashi)
    differ = differrence_via_real(location)
    deffile = RAILS_ROOT+"/tmp/shimada/forecast-real.def"
    open(RAILS_ROOT+"/tmp/shimada/forecast-real","w"){ |f|
      f.puts "No 日時 気温 当日予報誤差 前日予報誤差 蒸気圧 当日予報誤差 前日予報誤差" 
      i=0.0
      differ.each{ |h,t,dt0,dt1,v,dv0,dv1|
          f.print  i 
          i += 1/8.0

        f.print h.hour == 3 ?  h.strftime(" \"%Y-%m-%d %H:00\"") : " \"\""
        f.print t   ? " %.1f "%t    : " -- "
        f.print dt0 ? " %.1f "%dt0  : " -- "
        f.print dt1 ? " %.1f "%dt1  : " -- "
        f.print v   ? " %.1f "%v    : " -- "
        f.print dv0 ? " %.1f "%dv0  : " -- "
        f.print dv1 ? " %.1f "%dv1  : " -- "
        f.puts
      }
    }

    open(deffile,"w"){ |f|
      f.puts Def%[RAILS_ROOT,ZP[location.to_sym][1],differ.first.first.strftime("%Y/%m/%d"),
                  differ.last.first.strftime("%Y/%m/%d"),differ.size/8-0.125,
                  RAILS_ROOT,RAILS_ROOT
                 ]
    }
    @graph_file = "forecast-real.gif"
    `(cd #{RAILS_ROOT};/usr/local/bin/gnuplot #{deffile})`
  end

  end # of class method

  def temperature ;    Temp.map{ |sym| self[sym]} ;  end

  def humidity ;    Humi.map{ |sym| self[sym]} ;  end

  def vaper    
    unless self[:vaper03]
    (0..Vaper.size-1).each{ |idx| self[Vaper[idx]] = vaper_presser(self[Temp[idx]],self[Humi[idx]]) } 
    save
    end
    Vaper.map{ |sym| self[sym]}  
  end

  def to_s
    "#{date} #{announce}: temp:#{temperature.join(',')}  Humi:#{humidity.join(',')}  Vaper:#{ vaper.join(',')}"
  end

  def vaper_presser(temp,humi) ;    saturate_p(temp)*humi*0.01 ;  end
    # 飽和水蒸気圧（hPa)
  # Wagner（ワグナー）の式　･･･　より近似度が高い
  #
  #　e(t) = Pc・exp[ (A・x + B・x^1.5 + C・x^3 + D・x^6) / (1 - x) ]
  #　ここで、
  Pc = 221200   #[hPa]：　臨界圧
  Tc = 647.3    # [K]：　臨界温度
  InvTc = 1/Tc
  #x = 1 - (t + 273.15) / Tc
  A = -7.76451
  B = 1.45838
  C = -2.7758
  D = -1.23303
  
  def saturate_p(temp) #hPa  ℃
    x = xx(temp)
    Pc*Math.exp((A*x + B*x**1.5 + C*x**3 + D*x**6) / (1 - x))
  end
  def xx(temp) ; 1 - (temp + 273.15) * InvTc ; end
end

class Time
  def beginning_of_hour
    beginning_of_day+self.hour.hour
  end
end

__END__

dates = Forecast.all.map(&:date).uniq
weathers = dates.map{ |date|
  today    = Forecast.find_by_date_and_announce_day(date,date)
  tomorrow = Forecast.find_by_date_and_announce_day(date,date-1)
  real     = Weather.find_by_date(date)
  [today,tomorrow,real]
};1
i=1
open("forecast-realT","w"){ |f|
f.puts "日時 気温 本日予報 前日予報" 
  weathers.each{ |k,a,r|
    [3,6,9,12,15,18,21,24].each_with_index{ |h,idx|
      f.print k.date.day+h/24.0
      f.print h
      f.print r ? " %.1f "%r.temperatures[h-1] : " -- "
      f.print k ? " %.1f "%k.temperature[idx]  : " -- "
      f.print a ? " %.1f "%a.temperature[idx]  : " -- "
     f.puts
    }
  }
}
open("forecast-realV","w"){ |f|
f.puts "日時 蒸気圧 本日予報 前日予報"
  weathers.each{ |k,a,r|
    [3,6,9,12,15,18,21,24].each_with_index{ |h,idx|
      f.print k.date.day+h/24.0
      f.print h
      f.print r ? " %.1f "%r.vapers[h-1] : " -- "
      f.print k ? " %.1f "%k.vaper[idx]  : " -- "
      f.print a ? " %.1f "%a.vaper[idx]  : " -- "
         f.puts
    }
  }
}
open("forecast-real","w"){ |f|
f.puts "日時 気温 本日予報 前日予報" 
  weathers.each{ |k,a,r|
    [3,6,9,12,15,18,21,24].each_with_index{ |h,idx|
      f.print k.date.day+h/24.0
      f.print h
      f.print r ? " %.1f "%r.temperatures[h-1] : " -- "
      f.print k ? " %.1f "%(k.temperature[idx]-r.temperatures[h-1])  : " -- "
      f.print a ? " %.1f "%(a.temperature[idx]-r.temperatures[h-1])  : " -- "

      f.print r ? " %.1f "%r.vapers[h-1] : " -- "
      f.print k ? " %.1f "%(k.vaper[idx]-r.vapers[h-1])  : " -- "
      f.print a ? " %.1f "%(a.vaper[idx]-r.vapers[h-1])  : " -- "
      f.puts
    }
  }
}

open("forecast-real","w"){ |f|
f.puts "日時 本日予報気温 本日予報蒸気 前日予報気温  前日予報蒸気 実測気温 実測蒸気"
  weathers.each{ |k,a,r|
    [3,6,9,12,15,18,21,24].each_with_index{ |h,idx|
      f.print k.date.day+h/24.0
      f.print h
      f.print k ? " %.1f %1.f"%[k.temperature[idx]  ,k.vaper[idx]]  : " -- --"
      f.print a ? " %.1f %1.f"%[a.temperature[idx]  ,a.vaper[idx]]  : " -- --"
      f.print r ? " %.1f %1.f "%[r.temperatures[h-1] ,r.vapers[h-1]] : " -- -- "
      f.puts i
      i += 1
    }
  }
}

;1
weathers.first
