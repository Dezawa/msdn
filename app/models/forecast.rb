# -*- coding: utf-8 -*-
require 'pp'
class Forecast < ActiveRecord::Base


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
    ZP   = { :maebashi => "3/13/4210/10201", :minamiashigara => "3/17/4620/14217" }
    URLForecast =  "http://www.tenki.jp/forecast/%s.html"


  StrArg   = %w(location)
  DateArg  = %w(date month announce_day)
  TimeArg  = %w(announce)
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weather     = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
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
pp announce
      today_forecast = self.find_or_create_by_location_and_date_and_announce(location.to_s,today,announce )
      weather_temperature_humidity = to_hash(todays)
      #weather,temperature,humidity = todays
      #w = Hash[*Weather.zip(weather).flatten]
      #t = Hash[*Temp.zip(temperature).flatten]
      #h = Hash[*Humi.zip(humidity).flatten]
      args = { :announce_day => announce.to_date,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
pp args[:announce]
      today_forecast.update_attributes( args )
      today_forecast.announce = announce
      today_forecast.save
pp args[:announce]

      tomorrow_forecast = self.find_or_create_by_location_and_date_and_announce(location.to_s,tomorrow,announce )
      weather_temperature_humidity = to_hash(tomorrows)
      args = { :announce_day => announce.to_date,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
      tomorrow_forecast.update_attributes( args )
      today_forecast.announce = announce
      today_forecast.save

      return case day
             when today ; today_forecast 
             when tomorrow ;  tomorrow_forecast
             end
    end
    def to_hash(weathers)
      weather,temperature,humidity = weathers
      w = Hash[*Weather.zip(weather).flatten]
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
      forecast = find_by_location_and_month_and_date_and_announce(location.to_s,
                                                                  day.beginning_of_month,
                                                                  day,
                                                                  announce)
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
      url = URLForecast%ZP[zp]
      open("js.js","w"){ |fp| fp.write JS%url}
      content = `#{PhantomJS} js.js`.split("<")
    end

    def announce_datetime(lines)      
      while /id="pinpoint_weather_name"/ !~ lines.shift ;      end
      while /id="point_announce_datetime"/ !~ (line = lines.shift) ;      end
      Time.parse( line.sub(/^.*>/,"").gsub(/[年月日]/,"-"))
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


  end

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
