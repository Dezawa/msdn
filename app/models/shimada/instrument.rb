class Shimada::Instrument < ActiveRecord::Base
  extend CsvIo
  has_many :shimada_dayly
  belongs_to :simada_factory

  scope :by_factory_id, -> (factory_id) { where factory_id: factory_id }
  
  scope :by_factory_name, -> (factory_name) { by_factory_id(Shimada::Factory.where(name: factory_name))}
  
  def buttely
    tand_d = Status::TandD.where(serial: serial).order("group_remote_ch_unix_time desc").first
    return tand_d.group_remote_ch_current_batt  if tand_d
  end
  def denpa
    tand_d =Status::TandD.where(serial: serial).order("group_remote_ch_unix_time desc").first
    return tand_d.group_remote_rssi  if tand_d
  end
  def status_date
    tand_d =Status::TandD.where(serial: serial).order("group_remote_ch_unix_time desc").first
    return tand_d.group_remote_ch_unix_time  if tand_d
  end
end
