# -*- coding: utf-8 -*-
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

  class << self
    def fetch(location,day)
      day = day.to_date
      today = Time.now.to_date 
      return nil unless  day == today || day == today + 1

      announce,today,tomorrow,todays,tomorrows = forecast(location)

      today_forecast = self.find_or_create_by_location_and_date_and_announce_day(location.to_s,today,today )
      weather_temperature_humidity = to_hash(todays)
      #weather,temperature,humidity = todays
      #w = Hash[*Weather.zip(weather).flatten]
      #t = Hash[*Temp.zip(temperature).flatten]
      #h = Hash[*Humi.zip(humidity).flatten]
      args = { :announce => announce,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
      today_forecast.update_attributes( args )

      tomorrow_forecast = self.find_or_create_by_location_and_date_and_announce_day(location.to_s,tomorrow,today )
      weather_temperature_humidity = to_hash(tomorrows)
      args = { :announce => announce,:month => day.beginning_of_month }.merge(weather_temperature_humidity)
      tomorrow_forecast.update_attributes( args )

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

    def find_or_fetch(location,day,announce_day=nil)
      day = Time.parse(day).to_date if day === String
      announce_day = Time.parse(announce_day).to_date if announce_day === String
      announce_day ||= day
      day = day.to_date
      announce_day = announce_day.to_date
      forecast = find_by_location_and_month_and_date_and_announce_day(location.to_s,day.beginning_of_month,day,announce_day)
      return forecast if forecast
      return nil      if announce_day != Time.now.to_date # 本日のアナウンスしか採れない
       fetch(location,day)
    end

    def forecast_html(zp)
      zp = zp.to_sym
      url = URLForecast%ZP[zp]
      open("js.js","w"){ |fp| fp.write JS%url}
      content = `#{PhantomJS} js.js`.split("<")
    end

    def forecast(zp)
     lines=forecast_html(zp) #File.read("maebashi_forecast").split("\n")
  #    lines=File.read("maebashi_forecast").split("\n")
      while /id="pinpoint_weather_name"/ !~ lines.shift ;      end
      while /id="point_announce_datetime"/ !~ (line = lines.shift) ;      end
      date = Time.parse( line.sub(/^.*>/,"").gsub(/[年月日]/,"-"))
      while /今日/ !~ (line = lines.shift) ;      end
      today = Time.parse(line.sub(/^[^\d]/,"").gsub(/[^\d ]/,"")).to_date
      while /明日/ !~ (line = lines.shift) ;      end
      tomorrow =Time.parse(line.sub(/^[^\d]/,"").gsub(/[^\d ]/,"")).to_date
      while /class="hour/ !~ (line = lines.shift) ;      end
      while /雨のランクは5段階で表示されます/ !~ (line = lines.shift) ;      end
      weather = (0..15).map{ |i|
        while /^img/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"")
      }
      while /class="temperature"/ =~  (line = lines.shift) ;      end
      temperature = (0..15).map{ |k|
        while /^td>/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"").to_f
      }

      while / class="humidity/ =~  (line = lines.shift) ;      end
      humidity = (0..15).map{ |k|
        while /^td>/ !~ (line = lines.shift) ;      end
        lines.shift.sub(/^.*>/,"").to_f
      }
      [date,today,tomorrow,
       [weather[0,8],temperature[0,8],humidity[0,8]],
       [weather[8,8],temperature[8,8],humidity[8,8]]
      ]
    end
  end
end
