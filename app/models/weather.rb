# -*- coding: utf-8 -*-
require 'pp'

class Weather < ActiveRecord::Base
  Temperature = ("hour01".."hour24").to_a
  Vaper       = ("vaper01".."vaper24").to_a
  Humidity    = ("humidity01".."humidity24").to_a


    Block= { "maebashi" => [42,47624],
             "minamiashigara" => [46,1008]
  }


  class << self
    def fetch(location,day)
      y,m,d = [day.year, day.month, day.day]
      #emp_vaper_humidity = `/usr/local/bin/weather_past.rb #{location} #{y} #{m} #{d}`
      temp,vaper,humidity = hours_data_of(location,y,m,d) #mp_vaper_humidity.split(/[\n\r]+/)
      logger.info("WEATHER:: #{temp.class}")
      return unless temp
      weather = self.create( { :location => location.to_s,:date => day,
                               :month => day.beginning_of_month}.
                             merge(Hash[*Temperature.zip(temp).flatten]).
                             merge(Hash[*Vaper.zip(vaper).flatten]).
                             merge(Hash[*Humidity.zip(humidity).flatten])

                             )
    end

    def find_or_feach(location,day)
      weather = find_by_location_and_month_and_date(location.to_s,day.beginning_of_month,day)
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

    def hours_data_of(block,y,m,d)
      location = WeatherLocation.find_by_location(block)
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
        temp << clms[Temperature0].to_f
        if /47\d{3}/ =~ location.weather_block
          humi << clms[Humidity0].to_f
          vaper << clms[Vaper0].to_f
        end
      }
      [temp,vaper,humi]
    end

  end

  def temperatures ;   Temperature.map{ |t| self[t]} ; end
  def vapers      ;   Vaper.map{ |t| self[t]} ; end
  def max_temp ; temperatures.max ; end
  ("01".."24").each_with_index{ |h,idx| define_method("tempvaper#{h}".to_sym){
      "%2.1f<br>%2.1f"%[Temperature[idx],Vaper[idx]].map{ |t| self[t]}
    }}
end
__END__
s = Time.local(2013,1,1).beginning_of_day
e = Time.local(2014,6,26).beginning_of_day
date = s
Weather.fetch("maebashi",date)
while date <= e
  Weather.find_or_feach("maebashi",date)
  date = date.tomorrow
  p date
end

wthr=Weather.all(:conditions => "date >= '2013-1-1' and date <= '2014-6-26'");wthr.size
tv = wthr.map{ |w| w.temperatures.zip(w.vapers)[7..19].map{ |t,v| "#{t} #{v}"} };tv.size
open("temp_vaper","w"){ |f| f.puts tv}
