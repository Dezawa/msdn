#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'
require 'postscript'

module Ubr
  @dir= File.dirname(__FILE__)
    $LOAD_PATH << @dir

  # 通路置きも表示する
  # 
  # 
  # 
  # 
  # 
  # 枠ごとの総重量も枠に記載する
  #  ← は+2枡から二桁、 0度ローテーション 但し2枡枠の時は+1枡から
  #  → は+1枡から二桁、 0度ローテーション
  #  ↑ は+1枡から二桁  90度ローテーション
  #  ↓ は+2枡から二桁、90度ローテーション 但し2枡枠の時は+1枡から
  # 


  # 縮尺  1/500 は 10mが20mm
  Shukushaku = 500.0 

  # 枡の大きさ。単位 m。 
  #   H:横向きに置く。並べる方向は縦。  V:縦向きに置き横方向に並べる
  #   14:標準のパレット用               11:正方形なパレット用   
  #   N: ネステナー用
  Masu =  { 
    :HN => Pos[1.8,1.33], :VN => Pos[1.33,1.8],
    :UN => Pos[1.8,1.33], :LN => Pos[1.33,1.8],
    :DN => Pos[1.8,1.33], :RN => Pos[1.33,1.8],
    :H14 => Pos[1.6,1.2], :V14 => Pos[1.2,1.6],
    :U14 => Pos[1.6,1.2], :L14 => Pos[1.2,1.6],
    :D14 => Pos[1.6,1.2], :R14 => Pos[1.2,1.6],
    :H11 => Pos[1.2,1.2], :V11 => Pos[1.2,1.2],
    :U11 => Pos[1.2,1.2], :L11 => Pos[1.2,1.2],
    :D11 => Pos[1.2,1.2], :R11 => Pos[1.2,1.2],
    :HS => Pos[93,93],:VS => Pos[93,93]}

  # 枡の色分け  白黒でも４色分かるように気をつける
  #          空：白        引当：青っぽい  埋まり：灰   オーバー：赤っぽい
  #Color = [[255,255,255], [130,240,240],[180,180,180],[250,40,70]]#[250,90,150]]
  #Color = [[255,255,255], [140,245,245],[165,165,165],[250,40,70]]#[250,90,150]]
  #          空：白        出荷：青っぽい 引合:青濃い  埋まり：灰   オーバー：赤っぽい
  Color = [[255,255,255], [140,245,245], [100,180,180],[165,165,165],[250,40,70]]#[250,90,150]]


  class Occupy < Postscript
    delegate :logger, :to=>"ActiveRecord::Base"
    attr_accessor :waku_waku, :shukushaku, :date

    def self.main(pdfpath = nil)
      pdfpath ||= ARGV[0] || "./Ubr_occupy"
      Waku.waku(true)
      LotList.lotlist(true)
      @page = Occupy.new({ :macros => [:rectangre,:centering,:right], 
                           :paper => "A4p",:y0_is_up => true,
                           :pdfpath => pdfpath })
      @page.pages_out
      open(pdfpath+".ps","w"){ |fp| fp.puts @page.to_s}
      `/usr/bin/ps2pdf #{pdfpath+'.ps'} #{pdfpath+'.pdf'}`

      date_of_file = /201\d{5}/.match(@page.date)[0]
      Ubr::Point.new(@waku_waku ,date_of_file ).save
      `(cd #{Rails.root};/usr/local/bin/gnuplot app/models/ubr/point_to_gif.def)`
    end

    def initialize(args={ :macros => [:rectangre,:centering,:right], 
                           :paper => "A4p",:y0_is_up => true})
      super

      @shukushaku = 1.0/( args[:Shukushaku] || Shukushaku)
      @waku_waku     = Waku.waku#(true) #load_from_master
      #LotList.lotlist(true)
      @filename = open(Ubr::Lot::SCMFILEBASE).gets.chop rescue nil
      @date = @filename #||  LotList.lotlist.list.map{ |id,lot| lot.packed_date}.max
    end

    def to_gif(filepath)
      open(filepath.to_s + ".ps","w"){ |fp| fp.puts self.to_s}
      `/usr/bin/convert #{filepath}.ps #{filepath}.gif`
    end

    def pages_out
      SoukoPlan.plans.each{ |souko_plan| # |souko_group_name,souko_group,landscape|
        souko_group_name,souko_group,landscape = souko_plan.name,souko_plan,souko_plan.landscape
        new_page
        gsave_restore{ 
          rotate(90).translate(0,-pageWidth)  if landscape
          #scale_unit(:m,shukushaku).nl
          page_header souko_plan #souko_group_name,souko_group

          souko_plan.souko_floors.each{ |floor|
            comment("倉庫 #{floor.name}")
            souko_kouzou(floor)
            waku_kakidasi(floor)
            
          }
          statistics(souko_plan)
        }
        
      }#plans
    end

    ###
    def page_header souko_plan #souko_group_name,souko_group
      set_font(:point => 1.0,:font => "(GothicBBB-Medium-UniJIS-UTF8-H)").
        line_width(0.05).scale_unit(:m,shukushaku).nl
      string(souko_plan.name,:x => 10,:y => 10, :point => 2)
      string("  "+date,:x => 20,:y => 10,  :point => 1.5)
      
      add "\n%% 倉庫グループ #{souko_plan.name}\n"
      comment("paper_offset").paper_offset(souko_plan.offset,:mm) 
    end

    def souko_kouzou(floor,offset=nil)
      #outline(floor,offset)
      comment("wall").wall(floor,offset)
      comment("pillar").pillar(floor,offset)
    end

    def waku_kakidasi(souko,offset=nil,used_map=true)
      gsave_restore{ 
        souko.contents.each_with_index{ |_1A1,idx|
           #logger.debug("  UBR  枠#{_1A1} idx #{ idx}  souko.sufix[idx]..souko.max => #{souko.sufix[idx]}..#{souko.max[idx]}")
          add "\n%% 枠#{_1A1}\n"
          #sfx = souko.sufix[idx].dup
          base_point = Pos.new(offset || souko.floor_offset||[0,0]) +  Pos.new(souko.base_points[idx]|| [0,0])

          (souko.sufix[idx]..souko.max[idx]).each{ |sfx|  #|i|
            waku = waku_waku[_1A1 + sfx]
            waku_out(sfx,waku,base_point,used_map) # [詰、引、過]
            #sfx.succ!
          } # end of 枠書き出し
          waku_name(_1A1,base_point+souko.label_pos[idx] ) if souko.label_pos[idx]

        } # end of ブロック書き出し
      } # grestore

    end


    ###### sub of souko_kouzou ####
    def outline(souko,offset=nil)
      gsave_restore{ 
        translate(offset || souko.floor_offset) 
        box_diagonal(souko.outline,:size => 0.002)}
    end

    def wall(souko,offset=nil)
      gsave_restore{ translate(offset || souko.floor_offset).line_width(0.2)
        souko.walls.each{ |wall| 
          moveto wall.x0,wall.y0
          [[:dx1,:dy1],[:dx2,:dy2],[:dx3,:dy3],[:dx4,:dy4] ].
          each{ |dx,dy| rlineto wall[dx],wall[dy] if wall[dx] && !(wall[dx] == 0.0 && wall[dy] == 0.0) }
          stroke
        }
      }
    end

    def pillar(souko,offset=nil)
      return unless souko.pillars
      gsave_restore{ translate(offset || souko.floor_offset)
      souko.pillars.each{|pillers|
        xs,ys = pillers.size#.map{ |xy| xy }
        dx,dy = pillers.kankaku#.map{ |xy| xy }
        x   = pillers.start[0]-xs*0.5
        y   = pillers.start[1]-ys*0.5
        #x   = pillers.start[0]+souko.floor_offset_x-xs*0.5
        #y   = pillers.start[1]+souko.floor_offset_y-ys*0.5
        (0..pillers.kazu[0]-1).to_a.product( (0..pillers.kazu[1]-1).to_a ).each{ |ix,iy|
          next if (pillers.missing || []).include?([ix,iy])
          box_fill(x+dx*ix, y+dy*iy,xs,ys)
        }
        nl
      }
      }
    end

    ##### sub of waku_kakidasi #####


    def waku_out(sfx,waku,base_point,used_map=true)
      return unless waku && waku.direction
      waku.enable = true 
      
      masu_xy  = waku.masu_xy  #"Masu[waku.kata]
      delta_xy = waku.delta_xy # masu_xy*waku.direction
      waku_xy  = waku.waku_xy base_point # waku.pos_xy + base_point+[-masu_xy.x,0]
      # masu     = waku.kawa_suu

      waku_out_sub(waku,base_point,used_map) #,waku_xy,masu_xy,delta_xy)
      waku_weight(waku,base_point) if used_map
      waku_label(sfx,waku,base_point )#_xy,masu_xy)

    end

    def waku_out_sub(waku,base_point,used_map=true)
      aary = used_map ? waku.used_map : [[waku.kawa_suu ,0,0,0]]*waku.retusu
      gsave_restore{
        aary.each{ |ary|
          gsave_restore{ 
            (waku.tuuro? ? [4,3,2,1,0] : [0,1,2,3,4]).each{ |idx|
              next unless ary[idx] && ary[idx]>0
              repeat(ary[idx]){ 
                box_fill(waku.waku_xy(base_point),waku.masu_xy,Color[idx])
                translate(waku.delta_xy.x,waku.delta_xy.y)
              }
            }
          } #grestore 
          translate( waku.masu_xy*waku.drift_by_mult_retu)        
        }
      }
    end

    def waku_name(name,base_point)
      #pp base_point
      centering(name,base_point.merge(:point => 1.6,:font => Bold))
    end

    def waku_label(sfx,waku,base_point)#_xy,masu_xy)
      #moveto(waku_xy.x-masu_xy.x*0.5,waku_xy.y+0.8*masu_xy.y)
      moveto(waku.waku_xy(base_point) + waku.masu_xy*[0.5,0.87])
      #gsave_restore{ scale(1,-1).
      centering(sfx,:point => 1.3,:font => Bold)
      #}
      nl
      self
    end


    # 枠ごとの総重量も枠に記載する
    #  ← は+3枡から二桁、 0度ローテーション 但し2枡枠の時は+1枡から
    #  → は+1枡から二桁、 0度ローテーション
    #  ↑ は+1枡から二桁  90度ローテーション
    #  ↓ は+2枡から二桁、90度ローテーション 但し2枡枠の時は+1枡から
    def waku_weight(waku,base_point) #,waku_xy,masu_xy,delta_xy)
      #logger.debug("UBR::OCUPY#waku_weight 1A4D =#{waku.weight}") if waku.name == "1A4D"
      case waku.kawa_suu
      when 1  ; return
      when 2  ; weight = "%d"%((waku.weight(false)*0.001).ceil) 
      else    ; weight = "%2d"%((waku.weight(false)*0.001).ceil)
      end
      return if waku.kawa_suu == 1
      case waku.kata
      when :LN,:RN,:L14,:R14 ,:L11,:R11;  #  ← →
        offset = if [:LN,:L14,:L11].include?(waku.kata) && waku.weight > 99
                   [waku.delta_xy.x*3.1,waku.masu_xy.y*0.9]
                 else
                   waku.kawa_suu > 2 ? [waku.delta_xy.x*2,waku.masu_xy.y*0.99] :
                     [waku.delta_xy.x,waku.masu_xy.y*0.99]
                 end 
      when :D14,:DN,:D11
        offset = waku.kawa_suu > 2 ? [waku.masu_xy.x*0.9,waku.delta_xy.y*3.1]:
          [waku.masu_xy.x*0.9,waku.delta_xy.y*3.1] 
      when :UN ,:U14,:U11; 
        offset = waku.kawa_suu > 2 ? [waku.masu_xy.x*0.9,waku.delta_xy.y]: [waku.masu_xy.x*0.9,0]
      else ;offset = [0,0]
      end
      
      moveto(waku.waku_xy(base_point) + offset).
        gsave_restore{ rotate(waku.angle).string(weight,:point => 1.6,:font => "/Courier-Bold")}
      nl
      self
    end


    # SoukoPlanの:stat_names,:stat_reg , :stat_offsetに従って
    # 倉庫毎の 総重量 穴数 を書き出す
    def statistics(souko_group)
      comment("統計")
      translate(souko_group.stat_offset)
      stat_label
      souko_group.stat_names.each_with_index{ |label,idx|
        ### 要修正。 アクティブな枠だけカウントするか全枠かを決めること
        wakulist_of_this_souko = Ubr::Waku.aria(souko_group.stat_reg[idx])
        weight = Ubr::Waku.weight_of_aria(souko_group.stat_reg[idx])*0.001
        weight = wakulist_of_this_souko.inject(0){|wt,waku|  wt + waku.weight(WithPull)}/1000.to_i

        #logger.debug  "枠一覧 #{souko_group.stat_reg[idx]} "+wakulist_of_this_souko.map(&:name).join(" ") if idx >3
        vacants = [0]+ Ubr::Waku.empty_number_by_masusuu(souko_group.stat_reg[idx],[10,5,1])
        rmoveto(0,1.6)
        gsave_restore{
          stat_eria_label(label)
          stat_total_weight(weight)
          stat_vacants(souko_group,vacants)
        }
      }
    end

    def stat_total_weight(weight)
      rmoveto(9,0).gsave_restore{right("#{weight.to_i}")}
    end

    def stat_eria_label(label)
          gsave_restore{string(label)}
    end

    def  stat_vacants(souko_group,vacants)
      (0..2).each{ |i| 
        rmoveto(7,0).gsave_restore{
          right("%3d"%(vacants[i+1]-vacants[i]),
                :font => StatFont[souko_group.stat_font][0],
                :point   => StatFont[souko_group.stat_point][1]
                #:fontset => StatFont[souko_group.stat_font[i]]
                )
        }
        gsave_restore{rmoveto(0.2,0).string("本",:fontset => StatFont[2])
        }
      }
    end

    def stat_label
      moveto(0,0).string("　　　総量と穴数")
      moveto(0,1.8)
      gsave_restore{ 
        rmoveto(6,0).gsave_restore{string("総量")}
        rmoveto(5.5,0).gsave_restore{string("10桝以上")}
        rmoveto(8,0).gsave_restore{string("5-9桝")}
        rmoveto(8,0).gsave_restore{string("1-4桝")}
      }
    end

    def past(waku)
      
    end

  end
end


Ubr::Occupy.main(ARGV[0]) unless /www/ =~ __FILE__

__END__

%%%
  %%%255 G      色指定。255は白(RGBでなくグレーのG)
%%%%  上が正
%%%% 始点のXY  右offset 変形 高    幅         塗りつぶし
%%%  5307 2521 -37      0 0   93   73 0 ^ -36 0 f*
  %%%26 G
%%%5307 2421 -37 0 0 93 73 0 ^ -36 0 H
%%%S
