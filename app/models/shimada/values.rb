# -*- coding: utf-8 -*-

# Shimada::Daylyから 一つの工場の全測定値を測定日毎に一まとめにし
# Arrayにして返す。Array内の順は、Shimada::Instrumentの順
#
# 使い方
#  simada_values =  Shimada::Values.new(工場IDor工場名,日付)
#  daylies = simada_values.daylies
#
#  一月分simada_values =  Shimada::Values.month(factory_id_or_name,month)
#     
class Shimada::Values
  include ActiveModel::Model
  include ActionView::Helpers::UrlHelper
  attr_reader :date,:factory_id,:id
  #attr_reader :channels
  def initialize(factory_id_or_name,date=Time.now)
    @factory_id =
      case factory_id_or_name
      when Integer ; factory_id_or_name
      when String ;
        if /^\d/  ; factory_id_or_name.to_i
        else
          Shimada::Factory.find_by(name: factory_id_or_name).id
        end
      end
    @date = case date
            when Date,Time ; date.to_date
            when String    ; Date.parse(date)
            else           ; Time.now
            end
    @id =@factory_id*100+@date.day
  end

  def self.month(factory_id_or_name,month)
    (month..month.end_of_month).map{|date| self.new(factory_id_or_name,date) }
  end
  
  def instruments
    @channels ||= Shimada::Instrument.where(factory_id: @factory_id).order(:id)
  end

  def daylies
    return @daylies if @daylies
    daylies = Shimada::Dayly.by_factory_id_order_instrument(@factory_id).where(date: @date)
    @daylies = Shimada::Dayly.instruments.map{|instrument|
      daylies.find_by(instrument_id: instrument.id,
                      measurement_type: instrument.measurement_type)
      }    
  end

  def self.by_factory_id(factory_id,date)
    new(Shimada::Dayly.by_factory_id(@factory_id).where(date: date))
  end
  def self.by_factory_name(factory_name,date)
    new(Shimada::Factory.where(name: factory_name))
  end
  
  def hours
      daylies.map{|dayly| dayly ? dayly.converted_value_hourly : [nil]*24}.transpose
  end

  def item_labels
    instruments.map.with_index{|instrument,idx|
      lbl = instrument.ch_name + "-" + instrument.measurement
      daylies[idx] ? link_to(lbl, 
                             "/shimada/daylies/graph_dayly/?id=#{daylies[idx].id}" +
                               "&type=#{graph_type(instrument.measurement)}"
                            ) : lbl
    }.join("<br>".html_safe).html_safe
  end

  def graph_type(measurement)
    {"温度" => :temp, "電力" => :power, "蒸気圧" => :hyum}[measurement]
  end
  
  ("00".."23").each{|h|
    define_method("hour_html#{h}") do 
      hours[h.to_i].map{|v| v ? "%.2f"%v : "ー　"}.join("<br>".html_safe).html_safe
    end
  }
end
