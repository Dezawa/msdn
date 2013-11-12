# -*- coding: utf-8 -*-

module Ubr

  # １ページに記載する倉庫の定義
  #   name          : 単にID
  #   offset        : 紙原点からの印刷原点の相対位置 単位はこれのみ mm
  #   floor_offset  : ofsetからの倉庫平面図の相対位置 単位 m。
  #   floor         : このページに出力する SoukoFloorの配列
  class SoukoPlan 
    attr_reader :name, :floor_offset, :offset,:floor,:stat_names,:stat_reg , :stat_offset, :stat_font
    @@SoukoPlan = [] # ]Hash.new{ |h,k| h[k]=[]}

    def self.plans
      return @@SoukoPlan if @@SoukoPlan.size >0 
      #SP.each{ |souko_group| @@SoukoPlan [souko_group[:name]] = self.new(souko_group) }
      Ubr::Const::SP.each{ |souko_group| 
        @@SoukoPlan << [souko_group[:name], self.new(souko_group),souko_group[:landscape]] 
      }
      @@SoukoPlan
    end


    def initialize(args={ })
      [:name ,:sufix,:floor,:floor_offset    , :offset,
       :stat_names,:stat_reg , :stat_offset , :stat_font
      ].each{| attr_name| 
        instance_variable_set  "@#{attr_name}",args.delete(attr_name) 
      }
    end
  end
end
