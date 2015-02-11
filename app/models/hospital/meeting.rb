# -*- coding: utf-8 -*-
class Hospital::Meeting < ActiveRecord::Base
  extend CsvIo

  attr_writer :startday

    # t.integer  "busho_id"
    # t.date     "month"
    # t.integer  "number"
    # t.string   "name"
    # t.datetime "start"
    # t.float    "length",   limit: 24
    # t.boolean  "kaigi",  default: true

  def startday   #; logger.debug("### MEETING startday=#{startday}")
    start.strftime("%d");end
  def day_column ; start.strftime("day%02d").to_sym;end
  def day        ; start.day ;end

  Selection =
    { ["日勤",true,1.0] => [["会1",32]],
    ["日勤",true,1.5] => [["会□",31]],
    ["日勤",true,nil] => [["会1",32]],
    ["三交代",true,nil] => [["会1",7]],
    ["三交代",true,1.0] => [["会1",7]],
    ["三交代",true,1.5] => [["会",6]],
    ["日勤",false,nil] => %w(出 出/1□ 1/出 出/G Z/出).zip([41,42,43,44,45]),
    ["三交代",false,nil] => %w(出 出/1 1/出 出/G Z/出).zip([25,26,27,28,29])
  }
  def assign_correction(nurce)
    @assign_correction ||= { }
    kinmukubun = nurce.kinmukubun.name
    return @assign_correction[kinmukubun] if @assign_correction[kinmukubun]
    
    @assign_correction[kinmukubun] = 
      if kaigi
        case length
        when 1.5     ; Selection[[kinmukubun,true,1.5]]
        else         ; Selection[[kinmukubun,true,1.0]]
        end
      else           ; Selection[[kinmukubun,false,nil]]
      end 
  end
end
