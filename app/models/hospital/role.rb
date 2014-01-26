class Hospital::Role < ActiveRecord::Base
  extend CsvIo
  has_and_belongs_to_many :nurces
  self.table_name = 'hospital_roles'
  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

  def self.roles
    @@roles ||= self.pluck(:id,:name)
  end

  def self.role_ids   ; @@role_ids ||= roles.map{ |r| r[0]};end
  def self.roles_by_id
    @@rolls_by_id ||= Hash[*roles.flatten]
  end

end
