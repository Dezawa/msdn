# -*- coding: utf-8 -*-
require 'pstore'
require 'pp'
require 'nkf'
require 'tempfile'
module Ubeboard::Function
  # 製造指示書を作成する
  # 
  # ロットは色分けする。色は Ubeboard::Product#color で定義する。
  # リリース時の色は  　西：暖色系  東：寒色系  とした。
  # 
  # 作成期間の指定有無で動作が変わる
  # [作業指示書]  期間が指定されている場合は、その期間の 抄造、養生、乾燥、加工の指示書がでる。
  #               1ロット１行で表示される。
  # [月度計画]  指定されていない場合は、立案期間全体に渡っての全工程が一覧できる
  #             1工程１行で表示される。Ubeboard::Skdのデータを元に割付の全体像を見る。
  # 後者は割付の状況をみて、立案条件を変えるための情報
  #
  # PS, PDF の日本語を表示させることができなかったので、gedit のPS、PDF化の仕掛けを利用させてもらった。
  # 1. geditは日本語フォントを使われる文字だけデータとして埋め込んでいる。
  #    全文字のフォント情報を得るのは量が多すぎるので、必要なものだけ抜き出しそれを全部埋めている。
  # 2. 新しい銘柄などが出てフォントが無いとき〓が表示される。
  #    そのときは、$RAILS_ROOT/lib/productListChars.txtを gedit で編集し file、印刷、ファイルに書き出すでPS化し、
  #    下記でDB化する
  #    　　$RAILS_ROOT/script/ps2ConvertTbl.rb -s PSfileName
  #    DBは/opt/MSDN/PStoreDB/PSuni2ps にPStore されている。
  # 3. productListChars.txtの最初の文字は 〓 でなければならない。この最初の文字を「無いフォント」のときに出す。
  #    ps2ConvertTbl.rbにて、文字がDBに無いときはこの最初の文字を割り当てるように定義されている。
  # 図はA3横長。一行に１製品ラウンド、横一週間＋α
  #    上から 西、東、原、新、加 を描く  
  #
  # 描画期間は、月度計画は skd_from～skd_to、作業指示書は指定日から指定日数。defaultは8日間。
  #
  # 月度計画、作業指示書はそれぞれ PSファイルが書き出される。それを /usr/bin/ps2pdf にてPDFとする。
  module SkdPdf
    Goth = "/GothicBBB-Medium-UniJIS-UTF8-H"
    #一日最低行数
    MinLine = 3

    # １時間当たりの長さ 単位 point。この数字はA3横に１週間が入る長さにした
    Hr = 15.5/4 #17.006/4.0
    # 1秒当たりの長さ
    Sec = Hr/3600.0
    # 一日あたりの長さ
    Day = Hr * 24.0
    # 1週間あたりの長さ
    Week = Day * 7.0
    # mm を pt にn変換する定数
    MM2pt = 1/0.3528

    ## A3 protrate
    ObjHight = 3*MM2pt      # 各予定を示す箱の高さ
    #ObjSkip  = 7.5*MM2pt   # 製品毎の間隔
    ObjSkip  = 4.5*MM2pt    # 製品毎の間隔 skdOut2 用
    WeekSpace = 8*MM2pt     # 1週ずつ折り返す時の週間のスペース

    X0 = 100                # 計画図の左上のX座標
    Y0 = -40*MM2pt          # 計画図の左上のY座標の@pdf.pageHightからのオフセット
    Xlabel = 20             # 製品名を書き出す位置、ページ左端からの長さ
    Ylabel = 9*MM2pt        # 項目名、日時表記の上の罫線位置の Y0からのオフセット

    Xtitle,Ytitle = [200*MM2pt,Y0+30]  # 図の左にくる表の左上座標
    Hanko  = [20*MM2pt,20*MM2pt,11,%w( 承認者 作成者)]  # 押印欄の 高さ、幅、タイトル欄の高さ、タイトル

    OpeScale = {[:shozoe,:shozow] => 0.85 , :yojo => 0.85 ,[:dryo,:dryn] => 0.65 , [:kakou] => 0.85 }

    # ウベボードの作業指示書に近いのを作る
    # 
    def skdOutByUbeSkd(title)#,paper="a3",orient="l")
      @Lefts = {
        :ope              => ["工,程"     , 1  ,0.4,:utf],
        :date             => ["日"        , 0.9,0.2],
        :lot_no           => ["製造番号"  , 2.5,0.2],
        :name             => ["型番"      ,14.5,4.0,:utf],
        :space            => ["空時,間/分", 1.7,0.3],
        :yojoko           => ["養生,庫"   , 1.5,0  ],
        :maeoki           => ["前置,/時間", 1.7,0  ],
        :atooki           => ["後置,/時間", 1.7,0  ],
        :mass             => ["製造数"    , 1.7,0  ],
        :plan_yojo_from   => ["養生,開始" , 2.7,0.8],
        :plan_yojo_to     => ["養生,終了" , 2.8,0.8],
        :plan_shozo_from  => ["開始"      , 1.8,0.7],
        :plan_shozo_to    => ["終了"      , 1.7,0  ],
        :plan_dry_from    => ["乾燥,開始" , 1.8,0.7],
        :plan_dry_to      => ["乾燥,終了" , 1.7,0  ],
        :plan_dry_end     => ["搬入,終了" , 1.8,0.7],
        :plan_dry_out     => ["搬出,開始" , 1.7,0  ],
        :plan_kakou_from  => ["開始"      , 1.8,0.7],
        :plan_kakou_to    => ["終了"      , 1.7,0  ],
        #     => [""],
        #     => [""]
      }
      
      @ItemHead = [:ope,:date]
      @YojoHead = [:ope,:yojoko]
      @Items = {
        :shozo => [:lot_no,:mass, :name, :space, :plan_shozo_from, :plan_shozo_to, :yojoko,:maeoki ] ,
        :yojo  => [:lot_no,:maeoki,:plan_yojo_from, :plan_yojo_to] ,
        :dry   => [:lot_no,:mass, :name, :space, :plan_dry_from, :plan_dry_to,:plan_dry_end, :plan_dry_out,
                   :yojoko,:maeoki,:plan_yojo_from, :plan_yojo_to,:atooki ] ,
        :kakou => [:lot_no,:mass, :name, :space, :plan_kakou_from, :plan_kakou_to ] 
      }
     #  :shozo =>
     #   %w(工,程 日 製造番号 型番 空時,間/分 開始 終了 養生,庫 前置 養生,開始).
     #   zip([1,0.9,2.5,14.5,1.7,1.8,1.7,1.5,1.7,1.7],[0.4,0.2,0.2,4,0.3,0.7,0,0,0,0],
     #       [nil,:date,:loy,:name,:space,),
     #   :dry =>
     #   %w(工,程 日 製造番号 型番 空時,間/分 開始 終了 搬入,終了 搬出,開始 養生,庫 前置 養生,開始 養生,終了).
     #   zip([1  ,0.9,2.5,14.5,1.7,1.8,1.7,1.7,1.75,1.5,1.7,1.7,1.7],
     #       [0.4,0.2,0.2,   4,0.3,0.7,0.8,  1,   1,0  ,  0,  0,  0] ),
     #   :kakou => 
     #   %w(工,程 日 製造番号 型番 空時,間/分 開始 終了).
     #   zip([1,0.9,2.5,14.5,1.7,1.8,1.7],[0.4,0.2,0.2,4,0.3,0.7,0.8] )
     # }
        
      # 出力期間
      range = "  #{@sdate.strftime('%Y/%m/%d')}-#{@edate.strftime('%Y/%m/%d')}"
      # 出力期間に当たるplanを抜き出す
      plans = ube_plans.select{|plan| 
        times = Ubeboard::Skd::PlanTimesSym.map{|sym| plan[sym]}.compact
        times.size>1 && times[0] <= @edate+32.hour && times[-1] >= @sdate
      }
      # 製品数
      @noOfPro = plans.size

      space_rate = 0.8
      @ObjSkip = ObjSkip * space_rate
      @X0 = X0+2.3*Day ;@Y0 = @pdf.pageHight+Y0

      pageNo = calc_page_const(@sdate,@edate,@noOfPro)

      # ####
      # <---- ここは固定 ------->|<-- ここは clip される。ときにtranslate される-->
      # 工程 日 製造 ・・・ 終了 | 日時 |     |     |     |     |     |     |     |     
      #    ここは                |
      #　　製品毎に書く　　　　  |  ここも製品毎だが、clip され、translate される
      #                          |
      #　　/Label 領域           | /Graph 領域
      #

      # 養生 
      docOutYojo range

      # 抄造
      #@Left=@Lefts[:shozo]
      docOutOpe("抄造運転計画"+range,[:shozoe,:shozow],range,@Items[:shozo],:shozo?)

      # 乾燥
      #@Left=@Lefts[:dry]
      docOutOpe("乾燥運転計画"+range,[:dryo,:dryn],range,@Items[:dry],:dry?)

      # 加工
      #@Left=@Lefts[:kakou]
      docOutOpe("加工運転計画"+range,[:kakou],range,@Items[:kakou],:kakou?)

    end

    def docOutYojo(range)
      #plan_from,plan_to = [:plan_yojo_from,:plan_yojo_to]
      #plans = ube_plans.select{|plan| plan[plan_from] && plan[plan_to] &&
      #  plan[plan_from] <= @edate+32.hour && @sdate <= plan[plan_to]
      #}.sort_by{|plan| plan[plan_from]}
      plans = plans_run_inthe_range_of_operation([:yojo],:yojo?,range)[0]

      # /Labelエリアの、表題と製品のデータを記述する
      plan_yojoko = Hash.new{|h,k| h[k]=[]}
      plans.each{|plan| plan_yojoko[plan.yojoko] << plan }

      makeLabelMacroYojo("養生運転計画"+range,plan_yojoko )
      # 予定表出力のマクロ定義 
      makeGraphMacroYojo(plan_yojoko)

      ### ページ分ループ
      @pdf.close_preamble
      all_days("",OpeScale[:yojo])
    end

    def docOutOpe(title,real_opes,range,items,ope_check)
      scale = OpeScale[real_opes]
      ope_names = real_opes.map{|real_ope| Ubeboard::Skd::Id2RealName[real_ope]}

      work = plans_run_inthe_range_of_operation(real_opes,ope_check,range)

      #一日最低５行
      real_ope_plan = spread_plans_more_than_MinLine(work)

      @noOfPro=real_ope_plan.map{|hash| hash.values}.flatten.size

      # /Labelエリアの、表題と製品のデータを記述する
      makeLabelMacroOpe(title,scale,real_ope_plan,real_opes,items)

      # 予定表出力のマクロ定義 
      makeGraphMacroOpe(real_ope_plan,Ubeboard::Skd::PlanTimes[real_opes.first][0..1],scale,ope_check)
      ### ページ分ループ
      all_days("")
    end
    ## 東西養生、新旧乾燥、加工 を一覧できる表を作る
    def skdAllOutByUbeSkd(title)#,paper="a3",orient="l")
      @scale=1.83
      plans = ube_plans
      @noOfPro = Ubeboard::Skd::RealOpe.size

      # 工程間の間隔は、製品の時の間隔の2倍にする
      #space_rate = 2
      space_rate =  @scale #1.5
      @ObjSkip = ObjSkip #* space_rate

      @X0 = X0 ;@Y0 = @pdf.pageHight+Y0

      pageNo = calc_page_const(skd_from,skd_to,@noOfPro)


      ### PSヘッダー、コメント、辞書出力
      ### 製品名記述のマクロ定義
      ### 予定表出力のマクロ定義
      ### ページ分ループ

      # PSヘッダー、コメント、辞書出力
      #psInit

      # 工程名
      #outTitle("月度割付概観 #{skd_from.strftime('%Y/%m/%d')}-#{skd_to.strftime('%Y/%m/%d')}")
      @pdf.add( "%%%% /Label %%%%\n").define(:Label){
        #outTitle("月度割付概観 #{skd_from.strftime('%Y/%m/%d')}-#{skd_to.strftime('%Y/%m/%d')}")
        names = Ubeboard::Skd::RealOpe.select{|ope| ope != :yojo}.map{|real_ope| Ubeboard::Skd::Id2RealName[real_ope]}
        @pdf.set_font( :font => Goth,:point => 8)
        @pdf.show_labels(names,[Xlabel,@Y0+2-@ObjSkip],[0,-@ObjSkip])
      }.add "\n%%%% end /Label\n"
      # 予定表出力のマクロ定義 
      label_yoffset=[0,-ObjHight]
      sw = 0
      @pdf.add("\n%%%% end Graph%%%%\n").define(:Graph){
        dateline(skd_from,skd_to,@noOfPro,@scale)
        [:shozow,:shozoe,:dryo,:dryn,:kakou].each_with_index{|real_ope,i|
          @pdf.add("\n%%% #{real_ope} %%%")
          stime,etime = Ubeboard::Skd::PlanTimes[real_ope][0..1]
          output_plans = plans.select{|plan| 
            plan.real_ope?(real_ope) &&
            plan[stime] && plan[stime] < skd_to + 5.day  &&
            plan[etime] && plan[etime] >  skd_from - 1.day }.
          sort_by{|plan| plan[stime]}
          #output_plans.each{|plan| operation(plan,stime,etime,i+1)}
          #output_plans.each{|plan| 
          #  operation_lot_no(plan,stime,etime,i+1,label_yoffset[sw])
          #  sw = 1 - sw if real_ope == :kakou
          #}
          output_plans.each{|plan| 
            operation_and_lot_no(plan,stime,etime,i+1,label_yoffset[sw])
            sw = 1 - sw if real_ope == :kakou
          }
          #}
        }
      }.add"\n%%%% end Graph%%%%\n"

    ### ページ分ループ
      @pdf.close_preamble
      all_days("月度割付概観 #{skd_from.strftime('%Y/%m/%d')}-#{skd_to.strftime('%Y/%m/%d')}",@scale)
    end

    def operation_and_lot_no(plan,stime,etime,no,lot_shift=0)
      operation(plan,stime,etime,no)
      #logger.debug("OPERATION_AND_LOT_NO:color=#{@color} #{@color[-2,1].upcase}")
      if @color[4,1].upcase > "A" && @color[2,1].upcase < "8"  && @color[0,1].upcase < "8" && lot_shift == 0
        @pdf.gsave_restore{
          @pdf.set_color_rgb "FFFF00"
          operation_lot_no(plan,stime,etime,no,lot_shift)
        }
      else
          operation_lot_no(plan,stime,etime,no,lot_shift)
      end
      return self
    end

    def operation(plan,stime,etime,no) #,lot_shift=0)
      @color = (plan.ube_product ? plan.ube_product.color : "c08080") #if color.blank?
      x0 = @X0+(plan[stime]-@sdate)*Sec*@scale
      y0 = @Y0-no*@ObjSkip #-@ObjSkip
      #x9 = @X0+(edate-@sdate)*Sec-3*Hr

      @pdf.add "% Lot No:#{plan.lot_no}\n"
      @pdf.box(x0,y0,(plan[etime]-plan[stime])*Sec*@scale,ObjHight).stroke_fill(@color)
      return self
    end

    def operation_lot_no(plan,stime,etime,no,lot_shift=0)
      x0 = @X0+(plan[stime]-@sdate)*Sec*@scale
      y0 = @Y0-no*@ObjSkip #-@ObjSkip
      @pdf.string(plan.lot_no.to_s,:x => x0,:y => y0+ObjHight*0.1 + lot_shift )
      return self
    end

    def docOutGraph(real_ope_plan,plan_from,plan_to,scale,dry=nil)
      idx = 0
      real_ope_plan.each{|plans|  # 工程毎に
        plans.keys.sort.each{|date|   # 日毎に
          #logger.debug("PDF OutGraph date=#{date} plans.size=#{plans.size}")
          plans[date].each{|plan|
            idx += 1
            next unless plan         # 行合わせの空だったら飛ばす
            unless dry
              ope_box(plan[plan_from],plan[plan_to],idx,scale,
                      plan.ube_product ? plan.ube_product.color : nil ) 
            else
              ope_box( plan[plan_from],(plan[:plan_dry_out]||plan[plan_from]),idx,scale,"808080")
              ope_box( (plan[:plan_dry_out]||plan[plan_from]),(plan[:plan_dry_end]||plan[plan_to]),
                       idx,scale,plan.ube_product ? plan.ube_product.color : nil)
              ope_box( (plan[:plan_dry_end]||plan[plan_from]),plan[plan_to],idx,scale,"c0c0c0")
            end
          }
        }
      }
    end

    def docOutGraphYojo(plans,scale)
      plans.each{|no,plansY|
        plansY.each{|plan|
          next unless plan # 一日5行のために追加された空行は飛ばす
          
          ope_yojo( plan.plan_shozo_to,plan.plan_yojo_from,
                    plan.plan_yojo_to,plan.plan_dry_end,
                    plan.yojoko*2-2.5,
                    plan.ube_product ? plan.ube_product.color : nil,
                    scale)
        }
      }
    end
    # <tt>plans</tt>;;抄造の時間があるUbeboard::Planを、西と東にわけ、各々時間順にソートしたもの
    #                 plans = { :shozow => [], :shozoe=>[]
    #                 乾燥、加工の場合も同じ
    def docOutLeft(real_ope_plans,real_opes,items,scale=1.0)

      yoff = 1
      # 日 製造番号 型番 空き,時間 開始 終了 を書く
      x00,y00  =  [Xlabel+2,@Y0-@ObjSkip+yoff] 
       x0_date = x00 + @Lefts[:ope][1]*@scale-2
      #横線
      docOutLines(real_ope_plans,x0_date)

      #ロット毎の名称他(itemから）
      docOutLotname(real_ope_plans,real_opes,items,yoff)
    end

  def docOutLotname(real_ope_plans,real_opes,items,yoff)
    x00,y00  =  [Xlabel+2,@Y0-@ObjSkip+yoff] 
    openames = real_opes.map{|real_ope| Ubeboard::Skd::Id2RealName[real_ope]}
    plan_from,plan_to = plan_times = Ubeboard::Skd::PlanTimes[real_opes.first][0..1]
    y0 = y00
    real_ope_plans.each{|plnsHash| # 東西、新旧毎に
      last_to = nil
        @pdf.set_font(:point => 10,:font => "/Helvetica")
        plnsHash.keys.sort.each{|date| plans=plnsHash[date] # 日ごとに
          @pdf.string("%3d" % date ,:x => x00+@Lefts[:ope][1]*@scale-3,:y => y0)
          #ロット毎の名称他(itemから）
          plans.each{|plan|
            if plan # 一日5行のために追加された空行ではない
              @space= last_to ? "%5.0f" % ((plan[plan_from]-last_to)/60) : " ----"
              last_to = (openames == %w(原乾燥 新乾燥)) ? plan[:plan_dry_end] : plan[plan_to]
            end
            outByItem(plan,items,x00+ (@Lefts[:ope][1]+ @Lefts[:date][1])*@scale,y0)
            y0 -= @ObjSkip ;
          }
        }
      # 工程名
      @pdf.set_font(:font => Goth,:point => 10)
      @pdf.show_labels(openames.shift.split(""),[x00+1,(y00+y0)/2],[0,-10])
    }
  end
    def docOutLines(real_ope_plans,x0_date)
      ## ロット間の線 y_top = y0-yoff+@ObjSki
      noOfPro=real_ope_plans.map{|hash| hash.values}.flatten.size
      @pdf.multi_lines(Xlabel+(@Lefts[:ope][1]+ @Lefts[:date][1])*@scale , @Y0,
                       @X0+@label_days*Day*@scale, @Y0,
                       [0,- @ObjSkip],noOfPro,0.1)
      ## 日の区切りの線
      @pdf.gsave_restore{
        @pdf.translate(0,@Y0)
        @pdf.line(Xlabel,0,@X0+@label_days*Day*@scale,0,1)
        real_ope_plans.each_with_index{|plnsHash,idx| # 東西、新旧毎に 
          plnsHash.keys.sort.each{|date| plans=plnsHash[date] # 日ごとに
            @pdf.line(x0_date,0, @X0+@label_days*Day*@scale,0).translate(0,-@ObjSkip*plans.size)
          }
          @pdf.line(Xlabel,0,@X0+@label_days*Day*@scale,0,1)
        }
      }
    end
    def outByItem(plan,items,x0,y0)
      items.each{|item|
        if plan
          if item == :space
            @pdf.string(@space,:x => x0,:y => y0,:point => 10,:font => "/Helvetica")
          elsif @Lefts[item][3]
            @pdf.string(plan.pdf_value[item],:x => x0,:y => y0,:point => 9,:font =>Goth)
          else
            @pdf.string(plan.pdf_value[item].to_s,:x => x0,:y => y0,:point => 10,:font => "/Helvetica")
          end
        end
        x0 += @Lefts[item][1]*@scale # @Left[2][1]*@scale 
      }
      x0
    end

    def docOutLeftYojo (scale,plan_yojoko)#(plans,openames,plan_from,plan_to,scale=1.0)
      _ObjSkip = @ObjSkip*2
      xline = Xlabel + @Lefts[:ope][1]*@scale
      yoff = 5
      x00,y00  =  [Xlabel+2,@Y0- _ObjSkip+yoff] 
      x0,y0 = [x00,y00]
      # 養生庫分の枠を作る
      ## タイトル
      @pdf.set_font(:font => Goth,:point => 12).
      show_labels(%w(養 生 庫),[Xlabel+2,@Y0 - Ubeboard::Yojo::Yojoko.size*@ObjSkip],[0,-24])
      ## 養生庫番号、線
      yojoko_Nos = Ubeboard::Yojo::Yojoko.keys.sort.map{|no| "%3d" % no }
      @pdf.set_font(:point => 10,:font => "/Helvetica")
      @pdf.show_labels( Ubeboard::Yojo::Yojoko.keys.sort.map{|no| "%3d" % no },
                        [xline+2,@Y0- _ObjSkip+yoff],[0,-_ObjSkip])
      @pdf.multi_lines(xline,@Y0- _ObjSkip,@X0+@label_days*Day*scale,@Y0- _ObjSkip,
                       [0,-_ObjSkip],Ubeboard::Yojo::Yojoko.size,0.3)


      x000 = Xlabel+2 + (@Lefts[:ope][1]+@Lefts[:yojoko][1])*@scale
      y0 = @Y0- _ObjSkip+yoff
      #plan_yojoko.each{|no,plansY|
      Ubeboard::Yojo::Yojoko.keys.sort.each{|no| plansY = plan_yojoko[no]
        x0 = x000
        plansY.each_with_index{|plan,idx|
          x0 = outByItem(plan,@Items[:yojo],x0,y0)
        }
        y0 -= _ObjSkip
      }
    end
    
    # <tt>x0,y0</tt>;; boxの左下の座標
    # <tt>w,h</tt>;; boxの幅と高さ
    def box_with_text(x0,y0,w,h,text=nil)
      @pdf.box(x0,y0,w,h).stroke 
      @pdf.string(text,:x => x0+2,:y => y0+2,:point => 10,:font =>Goth) if text 
    end

    def hanko(x0,y0)
      x00 = x0 - Hanko[3].size * Hanko[1]
      x0 = x00
      Hanko[3].each{ box_with_text(x0,y0,Hanko[1],Hanko[0]);x0 += Hanko[1] }
      x0 = x00;y0 += Hanko[1]
      Hanko[3].each{|txt| box_with_text(x0,y0,Hanko[1],Hanko[2],txt);x0 += Hanko[1] }

    end

    def outTitle(title)
      @pdf.string(title,:x => Xtitle,:y => @pdf.pageHight+Ytitle,:point => 15,:font =>Goth)
    end

    #<tt>scale</tt>;;横線を引くときに長さを求めるが、その縮尺率
    def outWaku(items,x0=nil,scale=1.0)#(left,x0=nil,scale=1.0)
      x0 = outWakuSub(items,x0,scale)#(left,x0,scale)
      hanko(@pdf.pageWidth-2.0*Day,@Y0+Ylabel)
      x0
    end

    # <tt>scale</tt>;; 時間軸の短縮率
    def outWakuYojo(scale)
      x0 = outWakuSub(@YojoHead,nil,scale)
      (0..2).each{|i| x0 = outWakuSub(@Items[:yojo],x0,scale) }
      hanko(@pdf.pageWidth-2.0*Day,@Y0+Ylabel)
      x0
    end

    def outWakuSub(items,x0=nil,scale=1.0)
      #左上位置
      x0 ||= Xlabel
      y0   = @Y0
      
      @scale = 4.0*Hr
      # 左枠：工程 日 製造番号 型番 空き時間 開始 終了
      #left.each{|lbl,size,xoff| off = xoff*@scale*0.5
      items.each{|item| lbl,size,xoff = @Lefts[item] ;off = xoff*@scale*0.5
        @pdf.line(x0,@Y0+Ylabel,x0,@Y0-@ObjSkip*@noOfPro,0.3)
        u,l = lbl.split(",")
        if l 
          @pdf.string(u,:x => x0+off,:y => y0+ObjHight*1.6,:point => 10,:font =>Goth).
           string(l,:x => x0+off,:y => y0+ObjHight*0.4)
        else
          @pdf.string(lbl,:x => x0+off,:y => y0+ObjHight,:point => 10,:font =>Goth)
        end
        x0 += size*@scale
      }
      @pdf.line(x0,@Y0+Ylabel    ,x0,@Y0-@ObjSkip*@noOfPro,0.3)
      @pdf.line(Xlabel,@Y0+Ylabel,x0+@label_days*Day*scale,@Y0+Ylabel,1)
      @pdf.line(Xlabel,@Y0       ,x0+@label_days*Day*scale,@Y0      )
      x0
    end

    def all_days(title,scale=1.0)
      (1..@pageNo).each{|page|
        @pdf.new_page
        # Title
        @pdf.string(title,:x => Xtitle,:y => @pdf.pageHight+Ytitle,:pos => 15,:font =>Goth,:point => 15)
        # 製品名
        linesOfThisPage = @lines*page > @totallines ?  
        @totallines - @lines*page+@lines : ( @lines > 0 ? @lines : 1)
        @pdf.gsave_restore{ @pdf.repeat(linesOfThisPage){@pdf.add("Label").translate(0,-@ObjSkip*(@noOfPro+3))}}
        @pdf.gsave_restore{
          @pdf.clip([@X0-1,@Y0+30,@pdf.pageWidth-@X0,-@Y0+10])
          # 2page目以降、画像を一頁分左にシフトし、窓に見える部分を変える
          #          移動ページ数  * 一日分のpix数 * 1ページの日数
          @pdf.translate( -(page-1)*Day*(@label_days-1)*scale, 0) if page>1 
          @pdf.repeat(linesOfThisPage){ @pdf.add("Graph").translate(-Day*@label_days*scale,-@ObjSkip*(@noOfPro+3))}
        }
      }
    end

    ### 計画最初の日と最後の日を知る
    ### 1行当りの日数
    ### 1組の高さと1頁当りの行数計算、ページ数計算
    # <tt>sdate</tt>;;出力最初の日
    # <tt>edate</tt>;;出力最後の日(その翌日の08:00までが対象)
    # <tt>noOfPro</tt>;;1組何行か。製品数、工程数など
    def calc_page_const(sdate,edate,noOfPro)
      ### 計画最初の日と最後の日, 1行当りの日数を知る
      @sday = sdate.yday  ;   @eday = edate.yday

      ### 1行当りの日数
      # 横幅/1日
     # logger.debug("CALC_PAGE_CONST:pageWidth=#{@pdf.pageWidth} @X0=#{@X0} Day=#{Day} @scale=#{@scale}")
      @label_days = ((@pdf.pageWidth - @X0)/(Day*@scale)).to_i.to_f

      ### 1組の高さと1頁当りの行数計算、ページ数計算
      # 製品数 * @ObjSkip + 行間スペース
      #  1組の高さ
      graph_hight = noOfPro * @ObjSkip + WeekSpace

      #  1頁当りの行数 == (1頁高さ-HeadSpace)/高さ
      @lines = ((@pdf.pageHight - 20*MM2pt)/graph_hight).to_i
      if @lines >0
        #pp [ @sday ,@eday,@days,@pdf.pageHight,20*MM2pt,noOfPro,graph_hight,@lines]
        # ページ数 = 総行数/1頁当りの行数　総行数= (日数/7)
        @totallines = ((@eday-@sday+1)/@label_days).ceil
        @pageNo = (@totallines/@lines.to_f).ceil 
      else #1回分が縦方向 1頁に収まらない：： とりあえずは縦方向１ページ、横方向複数日を考える
        # y横方向必要なページ数
        @totallines = @horizon_pages = ((@eday-@sday+1)/@label_days).ceil
        # 縦方向必要なページ数
        @vert_pages    =  (graph_hight/(@pdf.pageHight - 20*MM2pt)).ceil 
        @lines = -(graph_hight/(@pdf.pageHight - 20*MM2pt)).ceil 
        # とりあえずは縦方向１ページ、横方向複数日を考える
        @pageNo = @horizon_pages #1 # (graph_hight/(@pdf.pageHight - 20*MM2pt)).ceil 
        # 
      end
    end

    def dateline(sdate,edate,itemNo,scale=1.0,opt={})
      @days = (edate-sdate)/3600/24+1
      y9 = @Y0-itemNo * @ObjSkip
      # 罫線
      # |---+---+---| 4hr
      lines_of_dateline(itemNo,scale).nl
      # 日付
      y_off =  15 
      date_of_dateline(sdate,edate,y_off,scale).nl

      # 時刻
      hour_of_dateline(scale).nl

      #setline(0.3,0,0)
      @pdf.line_width 0.3
      [@Y0,@Y0-itemNo * @ObjSkip].each{|y| @pdf.line(@X0,y, @X0 + (@days+1) * Day*scale,y)}
      # line(x9,@Y0+40*Pt2mm,x9,40*Pt2mm)
    end

    def date_of_dateline(sdate,edate,y_off,scale)
      @pdf.set_font(:point => 10,:font => "/Helvetica")
      (0..@days).each{|d| x1 = @X0 + d *Day * scale
        day = (sdate + d*3600*24).strftime("%m/%d")
        @pdf.string(day,:x => @X0+(d+0.7) * Day * scale,:y => @Y0+y_off)
      }
      @pdf
    end
    def hour_of_dateline(scale)
      @pdf.set_font(:point => 8)
      @pdf.define(:hour){
        [" 0"," 4"," 8","12","16","20"].each{|hr| 
          @pdf.moveto(@X0+hr.to_i* Hr  * scale+2,@Y0).gsave_restore{ @pdf.rotate(90).string(hr)}
        }
      }
        @pdf.gsave_restore{
          @pdf.repeat((1+@days).to_i){ @pdf.add("hour").translate(Day * scale,0)}
        }
      @pdf
    end
    def lines_of_dateline(itemNo,scale)
      @pdf.define(:V){ @pdf.line(0,@Y0,0,@Y0-itemNo * @ObjSkip,0.3).translate(4* Hr  * scale, 0)}
      @pdf.define(:B){ @pdf.line(0,@Y0+Ylabel,0, @Y0-itemNo * @ObjSkip,0.8).translate(4* Hr * scale,0)}
      @pdf.gsave_restore{ @pdf.translate(@X0,0).
        repeat(@days.to_i+1){  @pdf.add("V V B V V V") }.add("B")}
      @pdf
    end

    def ope_box(sdate,edate,no,scale,color=0xf0f0f0,hi=1.0)
      color = 0xc08080 if color.blank?
      _Sec = Sec * scale
      x0 = @X0+(sdate-@sdate) * _Sec ;    y0 = @Y0-no*@ObjSkip+1 #-@ObjSkip
      length = (edate-sdate)* _Sec

      @pdf.box(x0,y0,length,ObjHight*hi).stroke_fill(color)
    end
    
    def ope_yojo(pre,sdate,edate,post,no,color=nil,scale=1,opt={})
      ope_box(pre,sdate,no,scale,"aaaaaa",0.5)
      ope_box(sdate,edate,no,scale,color)
      ope_box(edate,post,no,scale,"cccccc") if post
    end

    def ddoperation(lot,mass,sdate,edate,no,color=nil,lot_shift=0)
      color = 0xc08080 if color.blank?
      x0 = @X0+(sdate-@sdate)*Sec*@scale
      y0 = @Y0-no*@ObjSkip #-@ObjSkip
      #x9 = @X0+(edate-@sdate)*Sec-3*Hr

      @pdf.add "% Lot No:#{lot}\n"
      @pdf.box(x0,y0,(edate-sdate)*Sec*@scale,ObjHight).stroke_fill(color)
      #@pdf.string(sdate.strftime("%H:%M"),:x => x0,:y => y0+ObjHight+1,:point => 6,:font => "/Helvetica")
      @pdf.string(lot.to_s,:x => x0,:y => y0+ObjHight*0.1 + lot_shift )
      #@pdf.string(mass.to_s,:x => x0+2,:y => y0-5)
      return self
    end

    ################################################################################
    def doc_out(rep_from,rep_to,pdf_file = Rails.root+"public/tmp/doc_out.pdf",weekly=true)
      @scale = 1.0
      @pdf = Postscript.new(:paper => "A3l", :macros => :all ,:y0_is_up => false)
      #@pdf.add_macroMacro
      if weekly
        @sdate =  rep_from
        @edate =  rep_to  
        skdOutByUbeSkd(title)#,paper="a3",orient="l")    
      else
        @sdate =   skd_from 
        @edate =   skd_to
        skdAllOutByUbeSkd(title)#,paper="a3",orient="l") 
      end
      out = Tempfile.open("ps_file","/tmp")
      out.puts @pdf.to_s
      out.close
      pdf = `/usr/bin/ps2pdf #{out.path} -`
      pdffile =  pdf_file.class == String ? open(pdf_file,"w") : pdf_file
      pdffile.print pdf
      pdffile.close

      #[pdffile,rep_from == "" ? 0 : 1]
      [pdffile,rep_from  ?  1 : 0 ]
    end

    ###################################################################
    def spread_plans_more_than_MinLine(arrayarray_plan)
      min=MinLine #5
      sdate,edate=[@sdate,@edate].map{|t| t.day}
      real_ope_plan=[]
      arrayarray_plan.each{|plans|
        work2=Hash.new{|h,k| h[k]=[]}
        plans.each{|plan|  work2[plan.date] << plan}
        (sdate..edate).each{|d| s=work2[d].size ; (s..min-1).each{|f| work2[d]<< nil}}
        real_ope_plan << work2
      }
      real_ope_plan
    end

    def makeGraphMacroYojo(plan_yojoko)
      @pdf.define(:Graph) {
        dateline(@sdate,@edate,Ubeboard::Yojo::Yojoko.size*2,OpeScale[:yojo])
        docOutGraphYojo(plan_yojoko,OpeScale[:yojo])
      }
    end

    def makeGraphMacroOpe(real_ope_plan,plan_times,scale,ope_check)
      plan_from,plan_to = plan_times
      @pdf.define(:Graph) {
        dateline(@sdate,@edate,@noOfPro,scale)
        docOutGraph(real_ope_plan,plan_from,plan_to,scale,ope_check == :dry?)
      }
    end

    def makeLabelMacroOpe(title,scale,real_ope_plan, real_opes,items)
      @pdf.define(:Label){
        outTitle(title)
        # 枠
        @X0 = outWaku(@ItemHead+items,nil,scale)#@Left)
        pages=docOutLeft(real_ope_plan,real_opes,items)#plan_from,plan_to)
      }
    end

    def makeLabelMacroYojo(title,plan_yojoko)
      @pdf.define(:Label){
        outTitle(title)
        # 枠
        #left0 = %w(工,程 養生,庫).zip([1,1.3],[0.4,0.1])
        #left1 = %w(製造番号 経過 乾燥,開始 前置,時間 開始 終了).
        #  zip([2.3,1.3,2.5,1.3,2.5,2.5],[0.1,0.1,1,0.1,0.6,0.8])
        #yscale=OpeScale[:yojo]
        @X0 = outWakuYojo(OpeScale[:yojo]) #(left0,left1,yscale)
        docOutLeftYojo(OpeScale[:yojo],plan_yojoko) #(real_ope_plan,ope_names,plan_from,plan_to)
      }
    end
    def plans_run_inthe_range_of_operation(real_opes,ope_check,range)
      plan_from,plan_to = Ubeboard::Skd::PlanTimes[real_opes.first][0..1]

      plans =ube_plans.select{|plan| plan[plan_from] && plan[plan_to] &&
        plan[plan_from] <= @edate+32.hour && 
        @sdate <= plan[plan_to]
      }.sort_by{|plan| 
        plan.date(plan[plan_from]) #この工程の開始日を設定
        plan[plan_from]
      }
      real_opes.map{|real_ope| plans.select{|plan| plan.send(ope_check) == real_ope}}
    end
  end
end

__END__
