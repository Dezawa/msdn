# -*- coding: utf-8 -*-

module Ubr
  class SoukoFloor < ActiveRecord::Base
    extend Function::CsvIo
    include Ubr::Const
    set_table_name :ubr_souko_floors

    belongs_to :ubr_souko_plan,:class_name => "Ubr::SoukoPlan"
    has_one    :souko_floor_souko_plan,:class_name => "Ubr::SoukoFloorSoukoPlan"
    has_one    :souko_plan,:class_name => "Ubr::SoukoPlan", :through => :souko_floor_souko_plan

    has_many :souko_plan_waku_blocks,:class_name => "Ubr::SoukoFloorWakuBlock"
    has_many :waku_blocks,:class_name => "Ubr::WakuBlock"
    #attr_reader :walls,:pillars:name #,  :outline , :walls,:pillars

    def outline ; [[outline_x0,outline_y0],[outline_x1,outline_y1]] ;end
    def floor_offset
      [souko_floor_souko_plan.floor_offset_x,souko_floor_souko_plan.floor_offset_y]
    end

    def walls   ;  @walls   ||=  Floors[name] ? Floors[name].walls : []    ; end
    def pillars ;  @pillars ||=  Floors[name] ? Floors[name].pillars : []  ; end

    def blocks ;@blocks ||= Ubr::WakuBlock[name]  ;end
    def contents    ;  blocks.map(&:content)     ; end
    def sufix       ;  blocks.map(&:sufix)       ; end
    def max         ;  blocks.map(&:max)         ; end
    def label_pos   ;  blocks.map(&:label_pos)   ; end
    def base_points ;  blocks.map(&:base_point)  ; end
  
  end
end
