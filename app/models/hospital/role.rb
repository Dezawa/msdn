class Hospital::Role < ActiveRecord::Base
  extend CsvIo
  has_and_belongs_to_many :nurces
  self.table_name = 'hospital_roles'

  has_and_belongs_to_many :nurces

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

# <<<<<<< HEAD
#   def self.roles
#     @@roles ||= self.pluck(:id,:name)
#   end

#   def self.role_ids   ; @@role_ids ||= roles.map{ |r| r[0]};end
#   def self.roles_by_id
#     @@rolls_by_id ||= Hash[*roles.flatten]
#   end

# =======
  @@name2id =nil
  def self.name2id
   @@name2id ||=  Hash[*all.map{|obj| [obj.name,obj.id]}.flatten]
  end

  @@id2name = nil 
  def self.id2name
    @@id2name ||= Hash[*all.map{|obj| [obj.id,obj.name]}.flatten]
  end

  def self.shokui
    all(:conditions => "bunrui = 1").map{ |obj| [obj.name,obj.id]}
  end
  def self.shokushu
    all(:conditions => "bunrui = 2").map{ |obj| [obj.name,obj.id]}
  end
  def self.kinmukubun
    all(:conditions => "bunrui = 3").map{ |obj| [obj.name,obj.id]}
  end


 #  include Hospital::Const
  #logger.debug " [ Kangoshi,Leader ] = [#{ Kangoshi},#{Leader} #{MarginLimit}]"
  #Defined = nil

end

