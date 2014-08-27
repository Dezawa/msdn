# -*- coding: utf-8 -*-
module Power::Power
  Revs = ("rev01".."rev24").to_a
  Vapers = ("vaper01".."vaper24").to_a
  module ClassMethods
  end
  def self.included(base)
    base.extend ClassMethods
  end

  def update_by_day_data(day_data)
    ("01".."24").each{ |hr| self["power#{hr}"] = day_data.shift.to_f}
    self.save
  end

  def hours  ;("01".."24").to_a ;end

  def powers ; ("01".."24").map{ |hr| self["power#{hr}"] } ;end
  def temps 
    return @temps if @temps
    return nil unless weather
    @temps = ("01".."24").map{ |h| weather["hour#{h}"]}
    save
    @temps
  end

  def vapers 
    return @vapers if @vapers
    return nil unless weather2
    @vapers = Vapers.map{ |h| weather2[h]}
    save
    @vapers
  end

 def weather
    #logger.debug("WEATHER id=#{id} date=#{date} ")
    return @weather if @weather
    return @weather = db_weather if db_weather
    return nil unless date
    if db_weather = Weather.find_or_feach(self.class.weather_location, self.date)
      save
      @weather = db_weather  
    end
  end

 def weather2
    #logger.debug("WEATHER id=#{id} date=#{date} ")
    return @weather2 if @weather2
    return nil unless date
    if db_weather = Weather.find_or_feach(self.class.weather_location2, self.date)
      save
      @weather2 = db_weather  
    end
  end
 def month_of_day ;date.month ;end
 def day_of_year ;date.yday ;end

  def revise_by_vaper
    return @revise_by_vaper if @revise_by_vaper
    unless self.by_vaper01
      return [] unless weather

      x0,y0,p0,sll,slh = [:threshold,:y0,:power_0line, :slope_lower, :slope_higher ].
        map{ |sym| VaperParams[sym]}

      vapers0 = (0..23).map{ |h|
        revise = revise_by_temp[h]
        vaper  = weather[Vapers[h]]
        logger.debug("Vapers #{vaper},#{Vapers[h]}")
         if revise && vaper
           slp = vaper > VaperParams[:threshold]  ? slh : sll
           revise -  slp*(vaper-x0)*(revise-p0)/(slp*(vaper-x0)+y0-p0)
         else revise ? revise : 0
         end
      }
      ByVapers.each{ |r|  self[r] = vapers0.shift}
      save
    end
    @revise_by_vaper = ByVapers.map{ |r| self[r]}
  end

  def revise_by_temp
    return @revise_by_temp if @revise_by_temp
    unless self.rev01
      return [] unless weather
      revs = ("01".."24").map{ |h|
        power = self["power#{h}"]
        temp  = weather["hour#{h}"]
         if power && temp
           threshold,slope_lower,slope_high,y0,p0  = temp_vs_power_param
           slp = temp < threshold ? slope_lower : slope_high
           power -  slp*(temp-threshold)*(power-p0)/(slp*(temp-threshold)+y0-p0)
         else power ? power : 0
         end
      }
      Revs.each{ |r|  self[r] = revs.shift}
      save
    end
    @revise_by_temp = Revs.map{ |r| self[r]}
  end


end
