# -*- coding: utf-8 -*-
require 'pp'

class Weather < ActiveRecord::Base
  Temperature = ("hour01".."hour24").to_a
  Vaper       = ("vaper01".."vaper24").to_a
  Humidity    = ("humidity01".."humidity24").to_a


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

    URLPast   = "http://www.data.jma.go.jp/obd/stats/etrn/view/hourly_s1.php?prec_no=%d&block_no=%d&year=%d&month=%02d&day=%d&view="

    Block= { :maebashi => [42,47624] }

    def hours_data_of(block,y,m,d)
      block = block.to_sym
      url = URLPast%[Block[block].first,Block[block].last,y,m,d]
      fp = Tempfile.open("js.js")
      fp.write JS%url
      jspath = fp.path
      fp.close
      content = `#{PhantomJS} #{jspath}`     

      lines = content.split(/[\n\r]+/)  
      while ( line = lines.shift) && /tablefix2/ !~ line ;end
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
        humi << clms[Humidity0].to_f
        vaper << clms[Vaper0].to_f
      }
      [temp,vaper,humi]
    end

  end

  def temperatures ;   Temperature.map{ |t| self[t]} ; end
  def max_temp ; temperatures.max ; end

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

