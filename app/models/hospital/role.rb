# -*- coding: utf-8 -*-
module Hospital
class Role < ActiveRecord::Base
  extend CsvIo
#  include Hospital::Const

  has_and_belongs_to_many :nurces

  Bunrui = [ ["職位", 1], ["職種", 2], ["資格", 3], ["勤務区分", 4] ]
  Bunrui2Id = Bunrui.to_h
 
  @@kinmukubun = nil
  def self.kinmukubun
    @@kinmukubun ||= self.where(bunrui: 4).pluck(:id,:name)
  end

  def self.names
    all.map{|obj| [obj.name,obj.id]}
  end

  @@name2id =nil
  def self.name2id
   @@name2id ||=  Hash[*all.map{|obj| [obj.name,obj.id]}.flatten]
  end

  @@id2name = nil 
  def self.id2name
    @@id2name ||= Hash[*all.map{|obj| [obj.id,obj.name]}.flatten]
  end

  def self.shokui
    where("bunrui = #{Bunrui2Id['職位']}").map{ |obj| [obj.name,obj.id]}
   end
   def self.shokushu
    where("bunrui =  #{Bunrui2Id['職種']}").map{ |obj| [obj.name,obj.id]}
   end
   def self.kinmukubun
    where("bunrui =  #{Bunrui2Id['勤務区分']}").map{ |obj| [obj.name,obj.id]}
  end
  def self.shikaku
    where("bunrui =  #{Bunrui2Id['資格']}").map{ |obj| [obj.name,obj.id]}
  end
 


  #  include Hospital::Const
  #logger.debug " [ Kangoshi,Leader ] = [#{ Kangoshi},#{Leader} #{MarginLimit}]"
  #Defined = nil

end
end
