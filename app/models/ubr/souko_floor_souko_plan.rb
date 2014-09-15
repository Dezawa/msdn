# -*- coding: utf-8 -*-
# 
# SoukoPlan  １ページに記載する倉庫の定義
#   SoukoFloor  倉庫   
#     WakuBlock  枠の塊  1A2 とか 3F2 とか
#       Waku       枠
# 
# 
module Ubr

  # １ページに記載する倉庫の定義
  #   SoukoPlanとSoukoFloorをつなぐ 結合Tableである
  #
  #   name          : 単にID
  #   offset        : 紙原点からの印刷原点の相対位置 単位はこれのみ mm
  #   floor_offset  : ofsetからの倉庫平面図の相対位置 単位 m。
  #   floor         : このページに出力する SoukoFloorの配列
  class SoukoFloorSoukoPlan  < ActiveRecord::Base
    extend CsvIo
    #self.table_name = "ubr_souko_floor_souko_plans"

    belongs_to :souko_floor,:class_name => "Ubr::SoukoFloor"
    belongs_to :souko_plan,:class_name => "Ubr::SoukoPlan"

    delegate :logger, :to=>"ActiveRecord::Base"

    def offset; [offset_x,offset_y] ;end
  end
end
