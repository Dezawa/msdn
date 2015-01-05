require 'ondotori'
#pp ['ondotori',Convert]
require 'ondotori_current_reader'
class Ondotori::Status < ActiveRecord::Base

  #attri_reader :base_name, :group_name, :group_remote_name, :group_remote_rssi
  #attri_reader :group_remote_ch_name,:group_remote_ch_unix_time,:group_remote_ch_current_batt
  #attri_reader :group_remote_ch_record_type
  def self.load_xml(xml_file)
    ondotori = ondotori_status_load(xml_file)

    base_name = ondotori.base_name

    ondotori.groups.each{ |name,group|
      group_name = group.name

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
  
  def self.ondotori_status_load(xml_file); OndotoriCurrent.new(xml_file);end
    
  def self.select_each_one_from_every_group_by(columns,order,opt={ })
    self.all.order(order).
      group_by{|instans| columns.map{ |sym| instans[sym]}}.
      map{ |key,instanses| instanses.first }
  end

end
