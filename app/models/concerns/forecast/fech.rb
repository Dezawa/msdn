# -*- coding: utf-8 -*-
module Forecast::Fech
  module ClassMethod
  Def =
"#ause -1
set term jpeg  size 1000,600 enhanced font '/usr/share/fonts/truetype/takao/TakaoPGothic.ttf,10'
set output '%s/%s.jpeg'  
 
set title '%s地方 %s～%s の気温・水蒸気量と予報の誤差'
set key outside autotitle columnheader samplen 2 width -10

#unset key
set x2range [0:%f]
#set xtics 1,1 
set x2tics 1
set xtics  rotate by -90
set  grid noxtics x2tics ytics

plot '%s/tmp/shimada/forecast-real'  using 3:xticlabel(2)  with line lc 1, \
     '' using 4   with line lc 1 lw 2,\
     '' using 5  with line lc 4,\
      '' using 6   with line lc 3, \
      '' using 7   with line lc 3 lw 2,\
      '' using 8  with line lc 2 

"
    ZP   = { "maebashi" => %w(3/13/4210/10201 前橋), 
             "minamiashigara" => %w(3/17/4620/14217 南足柄) }

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


  #StrArg   = %w(location)
  #DateArg  = %w(date month announce_day)
  #TimeArg  = %w(announce)

      def fetch(location,day)
      day = day.to_date
      today = Time.now
#      h = today.hour
      day_hour = today.beginning_of_hour
      today = today.to_date

      return nil unless  day == today || day == today + 1

      announce,today,tomorrow,todays,tomorrows = forecast(location)
      today_forecast = self.
        find_or_create_by(location: location.to_s,date: today, announce: announce )
      weather_temperature_humidity = to_hash(todays)
      #weather,temperature,humidity = todays
      #w = Hash[*Weathers.zip(weather).flatten]
      #t = Hash[*Temp.zip(temperature).flatten]
      #h = Hash[*Humi.zip(humidity).flatten]
      args = { :announce_day => announce.to_date,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
      today_forecast.update_attributes( args )
      today_forecast.vaper
      today_forecast.save

      tomorrow_forecast = self.
        find_or_create_by(location: location.to_s,date: tomorrow, announce: announce )
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
    def find_or_fetch(location,day=nil,announce_day = nil)
      day = Time.parse(day).to_date if day.is_a? String
      day ||= Time.now.to_date
      announce_day = Time.parse(announce_day).to_date if announce_day.is_a? String
      announce ||= day
      day = day.to_date
      announce = Time.now.beginning_of_hour
      forecast = find_by(location: location.to_s, 
                         month: day.beginning_of_month,  date: day)
                                                                  
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
      while / class="humidity/ =~  (line = lines.shift) 
      end
      humidity = humidities(lines) 

      [date,today,tomorrow,
       [weather[0,8],temperature[0,8],humidity[0,8]],
       [weather[8,8],temperature[8,8],humidity[8,8]]
      ]
    end
  
    def forecast_html(zp)
      zp = zp.to_s
      #url = URLForecast%ZP[zp].first
      url = URLForecast%WeatherLocation.find_by(location: zp).forecast_code
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
      (0..15).map{
        while /^img/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"")
      }
    end

    def temperaures(lines)
      while /class="temperature"/ =~  (line = lines.shift) ;      end
      temperature = (0..15).map{ 
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


  end # end of class method

  def included(klass)
    klass.extend ClassMethod
  end
end

  
