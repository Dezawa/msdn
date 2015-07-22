require 'ondotori'
require 'ondotori/converter'
require 'ondotori/current'
class Status::TandD < ActiveRecord::Base
  include Tand
  extend Tand::ClassMethod
  def self.oldload_xml(xml_file)
    ondotori = Ondotori::Current.new(xml_file)#ondotori_status_load(xml_file)

    base_name = ondotori.base_name

    ondotori.groups.each{ |_name,group|
      group_name = group.name
logger.debug("###Ondotori::Status load_xml #{ondotori}")
      group.remotes.each{ |name,remote|
        group_remote_name = remote.name
        group_remote_rssi = remote.rssi

        remote.channels.each{ |_name,ch|
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
  
  def self.ondotori_status_load(xml_file); Ondotori::CurrentReader.new(xml_file);end
    
  def self.select_each_one_from_every_group_by(columns,order,opt={ })
    self.all.order(order).
      group_by{|instans| columns.map{ |sym| instans[sym]}}.
      map{ |key,instanses| instanses.first }
  end

end
