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
      ondotori = Ondotori::Recode.new(trz_file) # ondotori_load(trz_file)
      load_ondotori(ondotori)
    end

    def load_ondotori(ondotori)
      unless ondotori.base_name == "dezawa" && ondotori.channels["power01-電圧"] 
        #errors.add(:base_name,"dezawaのsolaの電力データではない" )
        return
      end
      logger.info("ONDOTORI:: slope #{ondotori.channels["power01-電圧"].slope} + graft #{ondotori.channels["power01-電圧"].graft}")
      times_values = times_values_group_by_day(ondotori.channels["power01-電圧"])
      times_values.each{ |day,time_values|
        find_or_create_and_save(day,time_values)
      }
    end
  end
  
  def self.included(base)
    base.extend(ClassMethod)
  end
end
