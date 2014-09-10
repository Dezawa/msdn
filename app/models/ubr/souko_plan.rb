# -*- coding: utf-8 -*-
# 
# SoukoPlan  １ページに記載する倉庫の定義
#      1:多 
#   SoukoFloor  倉庫各フロアーの定義
#       1:多
#     WakuBlock  枠の塊  1A2 とか 3F2 とか
#         関連は用いない。
#       Waku       枠
# 
# 
module Ubr

  # １ページに記載する倉庫の定義
  #   name              : 紙に表示されるタイトルになる
  #   offset_x,_y       : 紙原点からの印刷原点の相対位置の相対位置 単位 mm。
  #   このアプリで用いる長さの単位は、この二組以外はすべて 実寸での m(メートル）
  # このページに表示する倉庫群は 結合Table SoukoFloorSoukoPlan で定義する
  class SoukoPlan  < ActiveRecord::Base
    extend CsvIo
    set_table_name :ubr_souko_plans

    has_many :souko_floor_souko_plans,:class_name => "Ubr::SoukoFloorSoukoPlan",:dependent => :destroy
    has_many :souko_floors,:class_name => "Ubr::SoukoFloor", :through => :souko_floor_souko_plans

  delegate :logger, :to=>"ActiveRecord::Base"
  #attr_reader :name, :floor_offset, :offset,:floor,:stat_names,:stat_reg , :stat_offset, :stat_font

    def offset; [offset_x,offset_y] ;end
    def floor_offset 
      Hash[*souko_floors.map{ |floor| [floor.name,floor.floor_offset] }.flatten(1)]
    end

    def stat_offset; [stat_offset_x,stat_offset_y] ;end
    def stat_names ; stat_name_list.split ;end
    def stat_reg   ; stat_reg_list.split.map{ |r| %r(#{r})} ;end
    @@SoukoPlan = [] # ]Hash.new{ |h,k| h[k]=[]}

    def self.plans
      @@SoukoPlan = self.all
    end

    def show
      page = Ubr::Occupy.new({ :macros => [:rectangre,:centering,:right], 
                           :paper => "A4p",:y0_is_up => true,
                               :Shukushaku => 600.0})
      page.new_page.line_width(0.05).scale_unit(:m,page.shukushaku).nl
      page.gsave_restore{ 
        souko_floors.each{ |floor|
          page.souko_kouzou(floor)            
        }
      }
      page.to_gif(Rails.root+"tmp/ubr/Plan%d"%id)
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
