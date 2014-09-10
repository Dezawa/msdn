# -*- coding: utf-8 -*-

module Ubr
  # 倉庫各フロアーの平面図定義
  # どのページに表示するかは 結合Table SoukoFlooSouko_plan にて
  #  ページ上のoffsetと共に指定する。
  class SoukoFloor < ActiveRecord::Base
    extend CsvIo
    include Ubr::Const
    set_table_name :ubr_souko_floors

    has_one    :souko_floor_souko_plan,:class_name => "Ubr::SoukoFloorSoukoPlan",:dependent => :destroy
    has_one    :souko_plan,:class_name => "Ubr::SoukoPlan", :through => :souko_floor_souko_plan
    has_many    :pillars,:class_name => "Ubr::Pillar"
    has_many    :walls,:class_name => "Ubr::Wall"

    has_many :waku_blocks,:class_name => "Ubr::WakuBlock"

    def outline ; [[outline_x0,outline_y0],[outline_x1,outline_y1]] ;end
    def floor_offset_x ;souko_floor_souko_plan.floor_offset_x || 0; end
    def floor_offset_y ;souko_floor_souko_plan.floor_offset_y || 0; end
    def floor_offset
      [souko_floor_souko_plan.floor_offset_x,souko_floor_souko_plan.floor_offset_y]
    end

    def contents    ;  waku_blocks.map(&:content)     ; end
    def sufix       ;  waku_blocks.map(&:sufix)       ; end
    def max         ;  waku_blocks.map(&:max)         ; end
    def label_pos   ;  waku_blocks.map(&:label_pos)   ; end
    def base_points ;  waku_blocks.map(&:base_point)  ; end

    # SoukoFloorController#showにて、倉庫の平面図をgifで表示するが
    # そのgifを作る
    def show
      Waku.waku(true)
      page = Ubr::Occupy.new({ :macros => [:rectangre,:centering,:right], 
                           :paper => "A3p",:y0_is_up => true,
                               :Shukushaku => 400.0})
      page.new_page. line_width(0.05).scale_unit(:m,page.shukushaku).nl
      page.souko_kouzou(self,[5,5])
      page.waku_kakidasi(self,[5,5],false)
      page.to_gif(RAILS_ROOT+"/tmp/ubr/Floor%d"%id)
    end
  
    def wall_dump
      walls.map{ |wall|
        p0=wall[0]
        name+(",%d"%id)+",%.2f,%.2f,"%wall[0]+
        wall[1..-1].map{ |p| q=[p[0]-p0[0],p[1]-p0[1]];p0=p;"%.2f,%.2f"%q}.join(",")
      }.join("\n")
    end
  end


end
