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
    extend Function::CsvIo
    set_table_name :ubr_souko_floor_souko_plans

    belongs_to :souko_floor,:class_name => "Ubr::SoukoFloor"
    belongs_to :souko_plan,:class_name => "Ubr::SoukoPlan"

  delegate :logger, :to=>"ActiveRecord::Base"
  #attr_reader :name, :floor_offset, :offset,:floor,:stat_names,:stat_reg , :stat_offset, :stat_font

    def offset; [offset_x,offset_y] ;end
    def stat_offset; [stat_offset_x,stat_offset_y] ;end
    def stat_names ; stat_name_list.split ;end
    def stat_reg   ; stat_reg_list.split.map{ |r| %r(#{r})} ;end
    @@SoukoPlan = [] # ]Hash.new{ |h,k| h[k]=[]}

    def self.plans
      return @@SoukoPlan if @@SoukoPlan.size >0 
      #SP.each{ |souko_group| @@SoukoPlan [souko_group[:name]] = self.new(souko_group) }
      Ubr::Const::SP.each{ |souko_group| 
        @@SoukoPlan << [souko_group[:name], self.new(souko_group),souko_group[:landscape]] 
      }
      @@SoukoPlan
    end


    def dinitialize(args={ })
      [:name ,:sufix,:floor,:floor_offset    , :offset,
       :stat_names,:stat_reg , :stat_offset , :stat_font
      ].each{| attr_name| 
        instance_variable_set  "@#{attr_name}",args.delete(attr_name) 
      }
    end
  end
end
