#!/usr/bin/ruby
# -*- coding: utf-8 -*-
require 'pp'
require 'postscript'

module Ubr
  @dir= File.dirname(__FILE__)
  if Rails
    $LOAD_PATH << @dir
    #  $MasterDir =  @dir
  else
    $LOAD_PATH << File.join(File.dirname(__FILE__),"../System") << "~/lib/ruby"
    #  $MasterDir =  File.join(@dir,"../System/Master")

  #require 'souko_plan'
  #require 'const'
  require 'souko'
  require 'lot'
  require 'lot_list'

  end

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
    :H11 => Pos[1.2,1.1], :V11 => Pos[1.1,1.2],
    :U11 => Pos[1.2,1.1], :L11 => Pos[1.1,1.2],
    :D11 => Pos[1.2,1.1], :R11 => Pos[1.1,1.2],
    :HS => Pos[93,93],:VS => Pos[93,93]}

  # 枡の色分け  白黒でも４色分かるように気をつける
  #          空：白        引当：青っぽい  埋まり：灰   オーバー：赤っぽい
  #Color = [[255,255,255], [130,240,240],[180,180,180],[250,40,70]]#[250,90,150]]
  Color = [[255,255,255], [140,245,245],[165,165,165],[250,40,70]]#[250,90,150]]


  class Occupy < Postscript
    delegate :logger, :to=>"ActiveRecord::Base"
    attr_accessor :waku_waku, :shukushaku, :date

    def self.main(pdfpath = nil)
      pdfpath ||= ARGV[0] || "./Ubr_occupy"
      @page = Occupy.new({ :macros => [:rectangre,:centering,:right], 
                           :paper => "A4p",:y0_is_up => true,
                           :pdfpath => pdfpath })
      @page.pages_out
      open(pdfpath+".ps","w"){ |fp| fp.puts @page.to_s}
      `/usr/bin/ps2pdf #{pdfpath+'.ps'} #{pdfpath+'.pdf'}`
    end

    def initialize(args={})
      super

      @shukushaku = 1.0/Shukushaku
      @waku_waku     = Waku.waku(true) #load_from_master
      LotList.lotlist(true)

      @filename = open(Ubr::Lot::SCMFILEBASE).gets.chop rescue nil
      @date = @filename || LotList.lotlist.list.map{ |id,lot| lot.packed_date}.max
      date_of_file = /201\d{5}/.match(@filename)[0]
      Ubr::Point.new(@waku_waku ,date_of_file ).save
      `(cd #{Rails.root};/usr/bin/gnuplot app/models/ubr/point_to_gif.def)`
    end

    def pages_out
      SoukoPlan.plans.each{ |souko_group_name,souko_group,landscape|
        new_page
        gsave_restore{ 
          rotate(90).translate(0,-pageWidth)  if landscape

          page_header souko_group_name,souko_group
          
          souko_group.floor_offset.each{|name,floor_offset|
            souko = $SoukoFloors[name]
            comment("倉庫 #{name}")
            souko_kouzou(souko,floor_offset)
            waku_kakidasi(souko,floor_offset)
          } # floa書き出し
          
          statistics(souko_group)
        }# grestore
        #open(pdfpath+".ps","w"){ |fp| fp.puts to_s}
        #`/usr/bin/ps2pdf #{pdfpath+'.ps'} #{pdfpath+'.pdf'}`
        
        
      }#plans
    end

    ###
    def page_header souko_group_name,souko_group
      set_font(:point => 1.0,:font => "(GothicBBB-Medium-UniJIS-UTF8-H)").
        line_width(0.05).scale_unit(:m,shukushaku).nl
      string(souko_group_name,:x => 10,:y => 10, :point => 2)
      string("  "+date,:x => 20,:y => 10,  :point => 1.5)
      
      add "\n%% 倉庫グループ #{souko_group_name}\n"
      comment("paper_offset").paper_offset(souko_group.offset,:mm) 
    end

    def souko_kouzou(souko,floor_offset)
      outline(souko,floor_offset)
      comment("wall").wall(souko,floor_offset)
      comment("pillar").pillar(souko,floor_offset)
    end


    def waku_kakidasi(souko,floor_offset)
      gsave_restore{ 
        souko.contents.each_with_index{ |_1A1,idx|
          add "\n%% 枠#{_1A1}\n"
          #sfx = souko.sufix[idx].dup
          base_point = Pos.new(floor_offset||[0,0]) +  Pos.new(souko.base_points[idx]|| [0,0])

          # logger.debug("  UBR #{souko_group_name} 枠#{_1A1} idx #{ idx}  souko.sufix[idx]..souko.max => #{souko.sufix[idx]}..#{souko.max[idx]}")

          (souko.sufix[idx]..souko.max[idx]).each{ |sfx|  #|i|
            waku = waku_waku[_1A1 + sfx]
            waku_out(sfx,waku,base_point) # [詰、引、過]
            #sfx.succ!
          } # end of 枠書き出し
          waku_name(_1A1,base_point+souko.label_pos[idx] ) if souko.label_pos[idx]

        } # end of ブロック書き出し
      } # grestore

    end

    ###### sub of souko_kouzou ####
    def outline(souko,floor_offset)
      gsave_restore{ translate(floor_offset).
        box_diagonal(souko.outline,:size => 0.002)}
    end

    def wall(souko,floor_offset)
      gsave_restore{ translate(floor_offset).line_width(0.2)
        souko.walls.each{ |wall| lines wall }
      }
    end

    def pillar(souko,floor_offset)
      return unless souko.pillars
      souko.pillars.each{|pillers|
        xs,ys = pillers.size#.map{ |xy| xy }
        dx,dy = pillers.kankaku#.map{ |xy| xy }
        x   = pillers.start[0]+floor_offset[0]-xs*0.5
        y   = pillers.start[1]+floor_offset[1]-ys*0.5
        (0..pillers.kazu[0]-1).to_a.product( (0..pillers.kazu[1]-1).to_a ).each{ |ix,iy|
          next if (pillers.missing || []).include?([ix,iy])
          box_fill(x+dx*ix, y+dy*iy,xs,ys)
        }
        nl
      }
    end

    ##### sub of waku_kakidasi #####
    def waku_out(sfx,waku,base_point)
      return unless waku && waku.direction
      waku.enable = true 

      if waku.tuuro?
        tuuro_out(sfx,waku,base_point)   
      else
        masu_xy = Masu[waku.kata]
        delta_xy =  masu_xy*waku.direction
        waku_xy =  waku.pos_xy + base_point+[-masu_xy.x,0]
        # masu     = waku.kawa_suu

        ary = waku.used_map
        gsave
        (0..3).each{ |idx|
          next unless ary[idx] && ary[idx]>0
          repeat(ary[idx]){ 
            box_fill(waku_xy,masu_xy,Color[idx]).translate(delta_xy.x,delta_xy.y)}
        }
        grestore
        waku_weight(waku,waku_xy,masu_xy,delta_xy)
        waku_label(sfx,waku_xy,masu_xy)
      end
    end

    def waku_name(name,base_point)
      #pp base_point
      centering(name,base_point.merge(:point => 1.6,:font => Bold))
    end

    ########## sub of waku_out ######
    def tuuro_out(sfx,waku,base_point)
      pulles   = waku.occupied(false)
      occupied = waku.occupied(true)
      return if pulles==0

      masu_xy = Masu[waku.kata]
      delta_xy =  masu_xy*waku.direction
      waku_xy =  waku.pos_xy + base_point+[-masu_xy.x,0]
      masu     = waku.kawa_suu
      if Const::Suuro2Retu.include?(waku.name)
        occupied0=occupied/2        ; occupied1=occupied-occupied0
        pulles1=(pulles-occupied)/2 ; pulles0  =(pulles-occupied)-pulles1 
        gsave
        repeat(occupied0){ box_fill(waku_xy,masu_xy,Color[2]).translate(delta_xy.x,delta_xy.y)}
        repeat(pulles0){ box_fill(waku_xy,masu_xy,Color[1]).translate(delta_xy.x,delta_xy.y)}
        grestore
        gsave
        repeat(occupied1){ box_fill(waku_xy+[0,-masu_xy.y],masu_xy,Color[2]).translate(delta_xy.x,delta_xy.y)}
        repeat(pulles1){ box_fill(waku_xy+[0,-masu_xy.y],masu_xy,Color[1]).translate(delta_xy.x,delta_xy.y)}
        grestore
      else
        gsave
        [[occupied,2],[pulles-occupied,1]].each{ |val,color|
          repeat(val){ box_fill(waku_xy,masu_xy,Color[color]).translate(delta_xy.x,delta_xy.y)}
        }
        grestore
      end
      waku_weight(waku,waku_xy,masu_xy,delta_xy)
      waku_label(sfx,waku_xy,masu_xy)
    end


    def waku_label(sfx,waku_xy,masu_xy)
      #moveto(waku_xy.x-masu_xy.x*0.5,waku_xy.y+0.8*masu_xy.y)
      moveto(waku_xy + masu_xy*[0.5,0.87])
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
    def waku_weight(waku,waku_xy,masu_xy,delta_xy)
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
                   [delta_xy.x*3.1,masu_xy.y*0.9]
                 else
                   waku.kawa_suu > 2 ? [delta_xy.x*2,masu_xy.y*0.99] :[delta_xy.x,masu_xy.y*0.99]
                 end 
        angle = 0
      when :D14,:DN,:D11
        offset = waku.kawa_suu > 2 ? [masu_xy.x*0.9,delta_xy.y*3.1]: [masu_xy.x*0.9,delta_xy.y*3.1] 
        angle = 270
      when :UN ,:U14,:U11; 
        offset = waku.kawa_suu > 2 ? [masu_xy.x*0.9,delta_xy.y]: [masu_xy.x*0.9,0]
        angle = 270
      else ;offset = [0,0];angle = 0
      end
      
      moveto(waku_xy + offset).gsave_restore{ rotate(angle).string(weight,:point => 1.6,:font => "/Courier-Bold")}
      nl
      self
    end


    # SoukoPlanの:stat_names,:stat_reg , :stat_offsetに従って
    # 倉庫毎の 総重量 穴数 を書き出す
    def statistics(souko_group)
      comment("統計")
      translate(souko_group.stat_offset)
      moveto(0,0).string("　　　総量と穴数")
      moveto(0,1.8)
      gsave_restore{ 
        rmoveto(6,0).gsave_restore{string("総量")}
        rmoveto(5.5,0).gsave_restore{string("10桝以上")}
        rmoveto(8,0).gsave_restore{string("5-9桝")}
        rmoveto(8,0).gsave_restore{string("1-4桝")}
      }
      souko_group.stat_names.each_with_index{ |label,idx|
        wakulist_of_this_souko = Ubr::Waku.aria(souko_group.stat_reg[idx])
        weight = wakulist_of_this_souko.inject(0){|wt,waku|  wt + waku.weight}/1000.to_i
        vacants = [0]+ Ubr::Waku.empty_number_by_masusuu(souko_group.stat_reg[idx],[10,5,1])
        rmoveto(0,1.6)
        gsave_restore{
          gsave_restore{string(label)}
          rmoveto(9,0).gsave_restore{right("#{weight.to_i}")}
          (0..2).each{ |i| 
            rmoveto(7,0).gsave_restore{
              right("%3d"%(vacants[i+1]-vacants[i]),
                    :font => StatFont[souko_group.stat_font[i]][0],
                    :point   => StatFont[souko_group.stat_font[i]][1]
                    #:fontset => StatFont[souko_group.stat_font[i]]
                    )
            }
            gsave_restore{rmoveto(0.2,0).string("本",:fontset => StatFont[2])
            }
          }
        }
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
