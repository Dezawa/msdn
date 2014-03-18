# -*- coding: utf-8 -*-

module Ubr
  class SoukoFloor < ActiveRecord::Base
    extend Function::CsvIo
    include Ubr::Const
    set_table_name :ubr_souko_floors

    #belongs_to :ubr_souko_plan,:class_name => "Ubr::SoukoPlan"
    has_one    :souko_floor_souko_plan,:class_name => "Ubr::SoukoFloorSoukoPlan",:dependent => :destroy
    has_one    :souko_plan,:class_name => "Ubr::SoukoPlan", :through => :souko_floor_souko_plan
    has_many    :pillars,:class_name => "Ubr::Pillar"
    has_many    :walls,:class_name => "Ubr::Wall"

   # has_many :souko_plan_waku_blocks,:class_name => "Ubr::SoukoFloorWakuBlock"
    has_many :waku_blocks,:class_name => "Ubr::WakuBlock"
    #attr_reader :walls,:pillars:name #,  :outline , :walls,:pillars

    def outline ; [[outline_x0,outline_y0],[outline_x1,outline_y1]] ;end
    def floor_offset_x ;souko_floor_souko_plan.floor_offset_x || 0; end
    def floor_offset_y ;souko_floor_souko_plan.floor_offset_y || 0; end
    def floor_offset
      [souko_floor_souko_plan.floor_offset_x,souko_floor_souko_plan.floor_offset_y]
    end

    def blocks ;@blocks ||= Ubr::WakuBlock[name]  ;end
    def contents    ;  waku_blocks.map(&:content)     ; end
    def sufix       ;  waku_blocks.map(&:sufix)       ; end
    def max         ;  waku_blocks.map(&:max)         ; end
    def label_pos   ;  waku_blocks.map(&:label_pos)   ; end
    def base_points ;  waku_blocks.map(&:base_point)  ; end
  
  
    def wall_dump
      walls.map{ |wall|
        p0=wall[0]
        name+(",%d"%id)+",%.2f,%.2f,"%wall[0]+
        wall[1..-1].map{ |p| q=[p[0]-p0[0],p[1]-p0[1]];p0=p;"%.2f,%.2f"%q}.join(",")
      }.join("\n")
    end
  end


end
