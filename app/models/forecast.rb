# -*- coding: utf-8 -*-
require 'pp'
class Forecast < ActiveRecord::Base
  include Fech
  extend  Fech::ClassMethod
  Temp     = %w(temp03 temp06 temp09 temp12 temp15 temp18 temp21 temp24) 
  Weathers     = %w(weather03 weather06 weather09 weather12 weather15 weather18 weather21 weather24)
  Humi     = %w(humi03 humi06 humi09 humi12 humi15 humi18 humi21 humi24)
  Vaper    = %w(vaper03 vaper06 vaper09 vaper12 vaper15 vaper18 vaper21 vaper24)
 #extend Shimada::ForecastReal
  class << self
    def daylies_of_month(weather_location,month)
      where(:month  => month,:location =>  weather_location).order("date").
      group_by{ |d| d.date }.
      map{|date,daylies| daylies.sort_by{|d| d.announce}.last}
    end
    def dayly_of_a_day(weather_location,date)
      daylies_of_a_day(weather_location,date)[-1,1]
    end
    
    def daylies_of_a_day(weather_location,date)
      where(:date  =>date,:location =>  weather_location).order("announce")
    end

    def to_hash(weathers)
      weather,temperature,humidity = weathers
      w = Hash[*Weathers.zip(weather).flatten]
      t = Hash[*Temp.zip(temperature).flatten]
      h = Hash[*Humi.zip(humidity).flatten]
      w.merge(t).merge(h)
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

    def differrence_via_real(location = "maebashi" )
      weather_location = WeatherLocation.find_by(location: location)
      dates = Forecast.where(  ["location = ?",location]).
        pluck(:date).uniq
      weathers = dates.map{ |date|
        today    = Forecast.find_by(date: date ,announce_day: date)
        tomorrow = Forecast.find_by(date: date ,announce_day: date-1)
        real     = Weather.find_or_feach(location,date)
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
          if /^47/ =~ weather_location.weather_block
            diff << (r ? r.vapers[h-1] :  nil)
            diff << (k  ? (k.vaper[idx]-r.vapers[h-1])  : nil )
            diff << (a  ? (a.vaper[idx]-r.vapers[h-1])  : nil)
          end
          differ << diff
        }
      }
      differ
    end

    def differrence_via_real_graph(location = :maebashi,graph_file = "graph")
      weather_location = WeatherLocation.find_by(location: location)
      differ = differrence_via_real(location)
      deffile = Rails.root+"tmp/shimada/forecast-real.def"
      open(Rails.root+"tmp/shimada/forecast-real","w"){ |f|
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
      logger.debug("DIFFERRENCE_VIA_REAL_GRAPH: location=#{location} zp =#{WeatherLocation.find_by(location: location).forecast_code}")
      open(deffile,"w"){ |f|
        f.puts Def%[Rails.root+"tmp/img",graph_file,
                    WeatherLocation.find_by(location: location).name,
                    differ.first.first.strftime("%Y/%m/%d"),
                    differ.last.first.strftime("%Y/%m/%d"),differ.size/8-0.125,
                    Rails.root,Rails.root,Rails.root
                   ]
      }
      `(cd #{Rails.root};/usr/local/bin/gnuplot #{deffile})`
      [graph_file,"jpeg"]
    end


    def plot(forecasts,option=Gnuplot::OptionST.new)
      Graph::TempHumidity.create(forecasts,option).plot     
    end
  end # of class method

  def times       ; d=self.date.to_time;[3,6,9,12,15,18,21,24].map{|h| d+h.hour} ; end
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
  today    = Forecast.find_by(date: date,announce_day: date)
  tomorrow = Forecast.find_by(date: date,announce_day: date-1)
  real     = Weather.find_by(date: date)
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
