# -*- coding: utf-8 -*-
require "pp"

class Hospital::Define < ActiveRecord::Base
  include Hospital::Const
  class Define
    include Hospital::Const
    attr_reader *Hospital::Define.all.map{ |define| define.attri.to_sym}
    #attr_reader :koutai3,:shifts_int,:shifts ,:shifts123,:shiftsmx , :night , :shifts_night 
    attr_reader :koutai3,:shifts_int,:shifts ,:shifts123 , :night , :shifts_night 
    attr_accessor :kangoshi,:leader

    def initialize
      defines = Hospital::Define.all
      defines.each{ |define|
        instance_variable_set "@#{define.attri}",define.value
      }
      set_attr
    end
    def set_attr
      @koutai3  = (@hospital_Koutai == "三交代") 
      @kangoshi = Hospital::Role.find_by(name: "看護師").id
      @leader    = Hospital::Role.find_by(name: "リーダー").id
      @shifts_int= @koutai3 ? Shift0123 : Shift0123[0..-2]
      @shifts = @koutai3    ? Sshift0123 : Sshift0123[0..-2]
      @shifts123 = @koutai3 ? Sshift123  : Sshift123[0..-2]
      # @shiftsmx = @shifts123[-1] #  Sshift2 or Sshift3
      @night  = @shifts123[1..-1] # [Sshift2] or [Sshift2,Sshift3]
      @shifts_night = { true =>  @night, false => [Sshift1], nil => [Sshift1]}
    end
  end


  attr_reader *Hospital::Define.all.map{ |define| define.attri.to_sym}
  #attr_reader :koutai3,:shifts_int,:shifts ,:shifts123,:shiftsmx , :night , :shifts_night 
  attr_reader :koutai3,:shifts_int,:shifts ,:shifts123 , :night , :shifts_night 
  attr_accessor :kangoshi,:leader

  @@define = nil
  def self.define ;    @@define ||= Define.new ;  end

  def self.koutai3?
    #define=Hospital::Define.find_by_attribute("hospital_Koutai")
    define=Hospital::Define.where(["attri = ?","hospital_Koutai"])[0]
    !!(define && define.value == "三交代")      
  end
  def nil ;"" ; end

  def self.find_or_create_all
    ItemsDefineAll.map{ |item|
      self.find_or_create_by( name: item.label, attri: item.symbol)
    }
  end

  def self.create(args)
    define = self.new(args)
    define.set_attr
    define.save
  end

  def self.ddcreate
    define = self.new
    define.set_attr
  end

  def set_attr
    self.class.all.each{ |df| instance_variable_set("@#{df.attri}",df.value)}
    @koutai3  = (@hospital_Koutai == "三交代") 
    @kangoshi = Hospital::Role.find_by(name: "看護師").id
    @leader   = Hospital::Role.find_by(name: "リーダー").id
    @shifts_int= @koutai3 ? Shift0123 : Shift0123[0..-2]
    @shifts = @koutai3    ? Sshift0123 : Sshift0123[0..-2]
    @shifts123 = @koutai3 ? Sshift123  : Sshift123[0..-2]
    # @shiftsmx = @shifts123[-1] #  Sshift2 or Sshift3
    @night  = @shifts123[1..-1] # [Sshift2] or [Sshift2,Sshift3]
    @shifts_night = { true =>  @night, false => [Sshift1], nil => [Sshift1]}
    
    self
  end


end
