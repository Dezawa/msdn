# -*- coding: utf-8 -*-
module Tand
  module ClassMethod
    def load_xml(xml_file)
      ondotori = Ondotori::Current.new(xml_file)#ondotori_status_load(xml_file)

      base_name = ondotori.base_name

      ondotori.groups.each{ |name,group|
        group_name = group.name
        logger.debug("###Ondotori::Status load_xml #{ondotori}")
        group.remotes.each{ |name,remote|
          group_remote_name = remote.name
          group_remote_rssi = remote.rssi
          group_remote_serial  = remote.serial

            remote.channels.each{ |name,ch|
            next if ch.record.type == ""
            group_remote_ch_record_type  = ch.record.type
            group_remote_ch_name = ch.name
            group_remote_ch_unix_time = ch.current.unix_time
            group_remote_ch_current_batt = ch.current.batt
            status = self.
              find_or_create_by(:base_name  => base_name  ,
                                :group_name => group_name ,
                                :group_remote_name => group_remote_name,
                                :group_remote_ch_name => group_remote_ch_name,
                                :group_remote_ch_unix_time =>group_remote_ch_unix_time
                               )
            status.group_remote_rssi = group_remote_rssi
            status.group_remote_ch_current_batt = group_remote_ch_current_batt
            status.group_remote_ch_record_type  = group_remote_ch_record_type
            status.serial  = group_remote_serial
            status.save
          }
        }
      }
    end
    def load_trz(trz_file)
      ondotori = Ondotori::Recode.new(trz_file)
      @base_name = ondotori.base_name
      load_ondotori(ondotori)
    end

    def load_ondotori(ondotori)
      return  unless valid_trz(ondotori)
      #channel_and_attr.each{|channel_name,attr|
      ondotori.channels.each{|channel_name,channel|
        next unless instrument.all.pluck(:serial).include?(channel.serial)
        times_values = times_values_group_by_day(channel)
        times_values.each{ |day,time_values|
          find_or_create_and_save(day,channel,time_values)
        }
      }
    end

    def times_values_group_by_day(channel)
      channel.times.zip(channel.values). #.map{ |v| scale(v)}).
      group_by{ |time,value| time.to_date }
    end

    def find_or_create_and_save(day,channel,time_values )
      conditions = {date: day, serial:  channel.serial, measurement_type: channel.type  }
      dayly = self.find_by(conditions ) || self.new(conditions )
      
      dayly[:measurement_value] ||= []
      time_values.each{ |time,value| 
        min = (time.seconds_since_midnight/channel.interval).to_i
        dayly[:measurement_value][min] = value 
      }
      dayly.month = day.to_time.beginning_of_month.to_date
      dayly.interval = channel.interval
      dayly.ch_name_type = channel.name_type
      dayly.instrument =
        dayly.class.instrument.find_by(serial: channel.serial,
                                      measurement_type: channel.type
                                     )
      dayly.save
      dayly
    end
  end # of ClassModule
  
  def self.included(base)
    base.extend(ClassMethod)
  end

end
