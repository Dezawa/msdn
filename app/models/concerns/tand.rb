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

          remote.channels.each{ |name,ch|
            group_remote_ch_name = ch.name
            group_remote_ch_unix_time = ch.current.unix_time
            group_remote_ch_current_batt = ch.current.batt
            group_remote_ch_record_type  = ch.record.type
            status = self.find_or_create_by(:base_name  => base_name  ,
                                            :group_name => group_name ,
                                            :group_remote_name => group_remote_name,
                                            :group_remote_ch_name => group_remote_ch_name,
                                            :group_remote_ch_unix_time =>group_remote_ch_unix_time
                                           )
            status.group_remote_rssi = group_remote_rssi
            status.group_remote_ch_current_batt = group_remote_ch_current_batt
            status.group_remote_ch_record_type  = group_remote_ch_record_type
            status.save
          }
        }
      }
    end
    def load_trz(trz_file)
      ondotori = Ondotori::Recode.new(trz_file) 
      load_ondotori(ondotori)
    end

    def load_ondotori(ondotori)
      return  unless valid_trz(ondotori)
      channel_and_attr.each{|channel_name,attr|
        channel = ondotori.channels[channel_name]
        times_values = times_values_group_by_day(channel)
        times_values.each{ |day,time_values|
          find_or_create_and_save(day,attr,channel.interval.to_f,time_values)
      }
      }
    end

    def times_values_group_by_day(channel)
      channel.times.zip(channel.values). #.map{ |v| scale(v)}).
      group_by{ |time,value| time.to_date }
    end

    def find_or_create_and_save(day,attr,interval,time_values)
      dayly = self.find_by(:date => day) || self.new(:date => day)
      dayly[attr] ||= []
      time_values.each{ |time,value| 
        min = (time.seconds_since_midnight/interval).to_i
        dayly[attr][min] = value 
      }
      dayly.save
      dayly
    end

  end
  
  def self.included(base)
    base.extend(ClassMethod)
  end
end
