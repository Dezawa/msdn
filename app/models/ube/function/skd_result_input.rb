# -*- coding: utf-8 -*-
module Ube::Function
  # 
  # Excelデータをもらいそれから実績を入力する。
  # 
  # 1. Excelデータは、ssconvert で csv になおし、それを読む
  #      ssconvert -S --import-encoding=shift-jis  --export-type Gnumeric_stf:stf_csv 各運転日報.xls gomi
  #      シート毎に、gomi.0, gomi.1 ,,, ができる。
  # 2. params としては、File, ActionController::UploadedStringIO のいずれかとなる。
  module SkdResultInput
    include ExcelToCsv
    # 入力されたデータの実績開始、実績終了の時刻が どのフィールドに
    # 書かれているかを定義する。
    #
    # [データ行数]
    #   excelのヘッダー内の各cellに改行が含まれている。ペーストした文字データとしては
    #   そこで行が変わってしまう。このため、行数でdデータ開始行を決めるのがなかな厄介である。
    #   そのため、開始行は /\d?[wWmM]\d{4}/ が最初に出てくる行とし、そこを先頭とする行数
    #   を定義する。
    # ラインにより微妙に欄構成が異なる。
    # [抄造・加工]
    #   ロット番号、開始時刻、終了時刻、数量 が１行にある。
    #   抄造はこの他に、 ロット番号と養生開始時刻の行がある。
    #   班をまたぐ抄造の場合、両方の班で同じロットについて書かれ、
    #   前の班の終了と後の班の開始が同じとなっている。
    #   この場合は後の班の開始時刻で上書きされないようにする必要がある。
    #   その実装は既入力の終了時刻と同じかどうかで判断しているので、
    #   開始終了を製品毎に入れていく必要がある。
    #   構成：ロット、開始時刻、終了時刻、数量、養生開始時刻
    # [乾燥]
    #   １行に、裁断開始・終了時刻と投入開始情報が書かれており、そのロット番号が異なる。
    #   すなわち、開始と終了は別の行に分かれて書かれているので,１行から２ロットの情報を取り出す必要がある。
    #   構成：［データ行数、［ロット、開始時刻、終了時刻、銘柄、養生庫],]
    # [製造数量]
    #   
    ColumnList = { 
      :shozoe =>  [18,[ 1, 6, 7,3,17]] , :shozow => [18,[ 1, 6, 7,3,17]] ,
      #               S   T H  L
      :dryn   => [18,[18,19,7,11]]     , :dryo   => [18,[19,21,7,12]],
      :kakou  => [50,[ 1,16,17],32 ]   ,
      :masse  => [200,[3,15]], :massw => [200,[3,15]] #:kakou  => [33,[ 1,16,17] ]
    }.merge(
            eval "{"+Ube::Constant.all.select{|c| c.name =~ /実績コピー/}.map(&:comment).join(",")+"}"
            )

    # params :: Hash, keyは "0",,,,,"19"。
    #        :: 要素は File, ActionController::UploadedTempfile,ActionController::UploadedStringIO のいずれか
    # ファイル形式 :: ファイルのマジックナンバーで判断する。xls,xlsx以外はCSVとして扱う
    # 対象日 :: 形式１ /\d{4}年\d{1,2}月\d{1,2}日/ 。年月日の文字の前後に空白文字が有ってもよい
    # 　　　 :: 　　　1cellで書く場合も年月日別のcellで書く場合もサポートするため
    #        :: 形式２ /,\d{4}/\d{1,2}/\d{1,2},/  
    #        :: 形式３ /運転日報.*抄造.*,(4\d{4}),/ Excel 日付データを ssconvertが1900年からの日数にすることが有る
    # データ行 :: ロット番号の有る行
    # データフィールド :: ロット番号より右で、ColumnList に定義されカラム
    # 開始・終了時刻   :: 24時間制表記。00:00～ は暦日は翌日のデータと解釈する
    # 　　　 :: 班をまたぐロットの場合、一つのロットが二つ書かれる。
    # 　　　 :: この様な場合、前の班の終了と後の班の開始が同じ時刻となる。
    # 　　　 :: これを見つけたら、一つにまとめる。
    # ライン :: "運転日報","運　転　日　報" という行があれば、そこに(ライン名) がある
    #        :: "生 産 受 払 日 報" という行があれば 加工
    def result_update(params)
      (0..params.size-1).each{|k| file = params[k.to_s]
        next if file.blank?
        
        # Excel(mgic no 208 207 17 224 -> xsl,80 75 3 -> xlsx) のときは、CSVへの変換を行う
        # 物理ファイルでないとできないので、書き出す。
        infile = case file
                 when ActionController::UploadedStringIO
                   # Temp ファイルに書き出す
                   tempfile = Tempfile.new("result_update")
                   while result=file.read;tempfile.write result;end
                   tempfile.rewind
                   tempfile
                 when File,ActionController::UploadedTempfile
                   file
                 else
                   logger.info("ERROR: UPDATE_RESULT 未定義IOstreamClass。= #{file.class}")
                   raise
                 end
        csv_files = ssconvert_if_excel(infile)
        
        csv_files.each_with_index{|csv_file,idx|
          lines = File.read(csv_file)
          real_ope = extruct_real_ope lines
          unless real_ope
            errors.add(:nil,"実績コピペ : 添付番号 #{k+1}、シート#{idx+1}:工程が判定できません");

          end

          # 日付チェック
          case real_ope
          when :shozoe,:shozow,:dryo,:dryn,:kakou
            y,m,d = date = extract_ymd(lines)
            unless date
              errors.add(:nil,"実績コピペ : 添付番号 #{k+1}、シート#{idx+1}:#{Ube::Skd::Id2RealName[real_ope]} のデータに日付が有りません")
              next
            end
            set_result(real_ope,date,lines)
          when :masse,:massw
            set_mass(real_ope,lines)
          end
          }
      }
      ube_plans.each{|plan| plan.save}
    end
    
    # input file を調べ、xls,xlsx のときはCSVに直す。
    # そうでないときは CSVであるとみなす。
    # CSV fileのファイルpathの配列を返す
    # 判定はマジックナンバーで調べる
    def dddssconvert_if_excel(infile)
      magic = [infile.getc,infile.getc]
      case magic
        #   xsl       xslx
      when [208,207],[80,75] ; ssconvert infile.path
      else                   ;[infile.path]
      end
    end

    # 拡張子の有無、単一シートか,複数かによって、作成されるCSVファイルの拡張子が変わる
    # [拡張子有、単一シート] foge.xsl → foge.csv
    # [拡張子有、複数シート] foge.xsl → foge.csv.{0,1,2,3,,,}
    # [拡張子無、単一シート] foge     → fogecsv
    # [拡張子無、複数シート] foge     → fogecsv.{0,1,2,3,,,}
    SSCONVERT= "/usr/bin/ssconvert"
    SJIS       = "--import-encoding=shift-jis"
    EXPORT_CSV = "--export-type Gnumeric_stf:stf_csv"
    def dddssconvert(path)
      pid = fork{
        exec("#{SSCONVERT} -S #{SJIS} #{EXPORT_CSV} #{path} 2>/dev/null")
      }   
      if pid
        Process.waitall
      end
      basename = File.basename(path,".*")
      files = Dir.glob(path.sub(/\.[^.]*/,".")+"csv*").sort_by{|f| /(\d+)$/ =~ f;$1.to_i}
    end 
    
  # CSVのデータからラインを抜き出す
  def extruct_real_ope( lines)
    case lines
    when /生.*産.*受.*払.*日.*報/ ; :kakou
    when /運.*転.*日.*報.*新乾燥/ ; :dryn
    when /運.*転.*日.*報.*原乾燥/ ; :dryo
    when /運.*転.*日.*報.*東抄造/ ; :shozoe
    when /運.*転.*日.*報.*西抄造/ ; :shozow
    when /集計.*東抄造/ ; :masse
    when /集計.*西抄造/ ; :massw
    end
  end

  #
  def search_plan(lot)
    return nil unless /^\d[MW]\d{4}$/ =~ lot
    plan = ube_plans.select{|p| p.lot_no == lot }[0]
    logger.info("＊＊==ERROR: #search_plan: #{lot}がube_plansにない。")
    errors.add(:nil,"ロット #{lot} が一覧にありません") unless plan
    plan
  end

  # データを抽出し、ロットごとに製造数量を集計し、設定する
  def set_mass(real_ope,lines)
    extract = extract_mass(real_ope,lines)
      logout real_ope,extract
    sum_mass = Hash.new{|h,k| h[k]=0 }
    extract.each{|lot_no,mass| sum_mass[lot_no] += mass }
    sum_mass.each{|lot_no,mass|
      plan = search_plan(lot_no)
      plan.mass = mass if plan
    }
    
  end

  # データを抽出し、結果をログに出し、値を設定する
  def set_result(real_ope,date,lines)
      extract = extract_data(real_ope,date,lines)
      logout real_ope,extract
    case real_ope
    when :shozow,:shozoe,  :kakou 
      set_result_sub(real_ope,extract)
    when :dryo,:dryn    
      set_result_dry(real_ope,extract)
    end
  end
  
  def logout( real_ope,extract )
    return unless extract
    logger.info("### 実績コピー update_result ### skd #{id} ###\n"+
                "   #{real_ope}\n     " + 
                extract.map{|ext| ext.map{|item|
                    case item 
                    when Time ; item.strftime("%m/%d-%H:%M")
                    else ;item.to_s
                    end 
                  }.join(",")}.join("\n     ")
                )
  end

  # 抄造と加工の結果設定
  # 1. 該当するUbe::Planを探し,無ければ次のデータに移る
  # 2. from,to のデータがあれば入れる
  #    ただし、既に終了時刻が入っていてそれが開始時刻と同じ場合は
  #    班の切り替えだと思われるので、開始時刻は直さない
  # 3. 抄造の場合、massを入れたいのだが、解決できない問題があり今回パス
  # 4. 抄造の場合、yojoがあれば入れる。終了時酷は40時間追加してこれも入れる。
  def set_result_sub(real_ope,results)
    id_f,id_t = Ube::Skd::PlanTimes[real_ope][2..3]
    results.each{|lot,from,to,meigara,yojo,yojoko|
  

      # 該当するUbe::Planを探し
      plan =search_plan(lot) # ube_plans.select{|p| p.lot_no == lot }[0]
      next unless plan
      # from のデータがあれば入れる
      # ただし、終了時刻が入っていてそれが開始時刻と同じ場合は
      # 班の切り替えだと思われるので、開始時刻は直さない
      if !from.blank? && plan[id_t] != from
        plan[id_f] = from
      end
      plan[id_t] = to if to

      plan.meigara = Ube::MeigaraShortname::meigara(meigara) if meigara
      
      #yojoがあれば入れる yojo
      if yojo
        plan.result_yojo_from = yojo  
        plan.result_yojo_to   = yojo + 40.hour
      end
      if yojoko
        plan.yojoko = yojoko if yojoko
      end
    }
  end

  # 乾燥の結果設定
  #
  # 1行に開始と終了の二つのデータがあるが、これは異なるロットのものなので
  # 開始と終了と２回に分けて以下を行う。
  # 1. 該当するUbe::Planを探し,無ければ次のデータに移る
  # 2. from |to のデータがあれば入れる
  #    fromの場合は、
  #    既に終了時刻が入っていてそれが開始時刻と同じ場合は
  #    班の切り替えだと思われるので、開始時刻は直さない
  # 4. 養生の時刻がi入れて無かったら、抄造で入れ損なったと思われるので
  #    予定時刻をs入れてしまう。
  # 
  def set_result_dry(real_ope,results)
    id_f,id_t = Ube::Skd::PlanTimes[real_ope][2..3]
    results.each{|lot,from,lot_e,to|
      # 開始時刻について
      # 該当するUbe::Planを探し
      if plan = search_plan(lot) # ube_plans.select{|p| p.lot_no == lot }[0]
        # from のデータがあれば入れる
        # ただし、終了時刻が入っていてそれが開始時刻と同じ場合は
        # 班の切り替えだと思われるので、開始時刻は直さない
        if !from.blank? && plan[id_t] != from
          plan[id_f] = from
        end
        #yojoが入ってないときは、予定を入れちゃう
        if [:dryo,:dryn].include?(real_ope) && !plan[:result_yojo_from]
          plan[:result_yojo_from] = plan[:plan_yojo_from]
          plan[:result_yojo_to]   = plan[:plan_yojo_to]
          
        end        
      end
      # 終了時刻について
      # 該当するUbe::Planを探し
      if plan = ube_plans.select{|p| p.lot_no == lot_e }[0]
        plan[id_t] = to if to
        #yojoが入ってないときは、予定を入れちゃう
        if [:dryo,:dryn].include?(real_ope) && !plan[:result_yojo_from]
          plan[:result_yojo_from] = plan[:plan_yojo_from]
          plan[:result_yojo_to]   = plan[:plan_yojo_to]
          
        end        
      end
    }
  end

  # データを抜き出す
  def extract_data(real_ope,date,lines) 
    case real_ope
    when :shozow,:shozoe,:kakou;  extract_data_nomal(real_ope,date,lines)
    when :dryo,:dryn    ;  extract_data_dry(real_ope,date,lines)
    #when :kakou         ;  extract_data_kakou(real_ope,date,lines)
    end
  end

  # 年月日を抜き出す
  def extract_ymd(lines)
    if /(\d\d\d\d)[,\s]*年[,\s]*(\d+)[,\s]*月[,\s]*(\d+)[,\s]*日/ =~ lines
      [$1,$2,$3].map{|s| s.to_i}
    elsif /,(\d{4})\/(\d{1,2})\/(\d{1,2}),/ =~ lines
      date=Date.new(* [$1,$2,$3].map{|s| s.to_i})-1
      [date.year,date.month,date.day]
    elsif /運転日報.*抄造.*,(4\d{4}),/  =~ lines
      date = Date.new(1899,12,31)+$1.to_i
      [date.year,date.month,date.day]
    end
  end
  
    # 乾燥のデータを抜き出す
    #
    # 1. 裁断開始時刻、裁断終了時刻、投入開始時刻 の3つの時刻がある。
    # 2. 投入開始が製造開始、裁断終了が製造終了とする。
    # 3. これは同じ行にはこない。
    # 4. つまり、１行に二つのロット番号と時刻がある
    # 5. 0時から6:59の時刻の場合は、暦日は翌日とする。
    # 6. 7:00 は本日の開始時刻であり、翌歴日の終了時刻でもある。
    #    終了時刻が07:00であった場合は、暦日は翌日とする。
    def extract_data_dry(real_ope,date,lines)
      #puts "############### #{real_ope} ### #{lines.size} ####"
      rows = extruct_rows(real_ope,lines)

      s_lot_idx,start_idx,e_lot_idx,end_idx  = ColumnList[real_ope][1]
      rows.map{|row|
        lot_no         =  normalize_lotno(row[s_lot_idx])
        lot_no_e       =  normalize_lotno(row[e_lot_idx])
        (row[start_idx] = modify_time(row[start_idx],date)) || lot_no = nil
        row[end_idx]   = modify_time(row[end_idx],date)
        row[end_idx] += 24.hour if row[end_idx]  && row[end_idx].strftime("%H%M") == "0700" 
        row[end_idx] || lot_no_e = nil
        if lot_no || lot_no_e 
          [lot_no,row[start_idx],lot_no_e,row[end_idx]]
        end
      }.compact
    end

    # 製造数量のデータを抜き出す
    def extract_mass(real_ope,lines)
      rows = extruct_rows(real_ope,lines)
      s_lot_idx,mass_idx = ColumnList[real_ope][1]
      rows.map{|row|
        lot_no         =  normalize_lotno(row[s_lot_idx]  )
        row[mass_idx] =  row[mass_idx] ? row[mass_idx].sub(/,/,"").to_i : 0
        [lot_no  ,row[mass_idx]]
      }

    end

    # 抄造,加工のデータを抜き出す
    # [時刻の補正について]
    #    5. 0時から6:59の時刻の場合は、暦日は翌日とする。
    #    6. 7:00 は本日の開始時刻であり、翌歴日の終了時刻でもある。
    #    終了時刻が07:00であった場合は、暦日は翌日とする。
    #    ただし、extract_dataには開始なのか終了なのか分からないので、呼び出し元で行う
    # [製造数量について]
    #    今回製造数量は扱えなかった
    #    日報の製造数量は各班の数量で班をまたぐロットの場合は二つに分かれる
    #    総計が別の行に書かれているが、この数量は本日のもので日をまたぐ場合の集計はない。
    #    集計数で置き換えを行うと、日をまたぐ製造の製造数が正しく出ない。
    #    入力済みの製造数に加えていくということを行うと、予定数量への上積みになってしまう。
    #    「07:00から始まる製造の場合のみ加える」という方法もあるが、この場合翌日の日報の
    #    処理が終わるまでの間少なめの製造数となってしまう。
    #    この時に 再立案を行うと少ない数量での立案となり、後工程の時間が短めになってしまう。
    def extract_data_nomal(real_ope,date,lines)
      rows = extruct_rows(real_ope,lines)
      s_lot_idx,start_idx,end_idx,meigara_idx,yojo_idx = ColumnList[real_ope][1]

      rows.map{|row|
        lot_no         =  normalize_lotno(row[s_lot_idx]  )
        #puts lot_no
        start_time = modify_time(row[start_idx],date)
        end_time   = modify_time(row[end_idx],date)
        end_time  += 24.hour if  end_time  && end_time.strftime("%H%M") == "0700"
        if meigara_idx
          row[meigara_idx] =  row[meigara_idx] ? row[meigara_idx] : ""
        end
        if yojo_idx
          yojoko = /(\d\d?)/ =~ row[yojo_idx-1]  ?  $1.to_i : nil 
          logger.info("extract_data_noma:lot #{lot_no} yojoko #{yojoko}。") if lot_no

          row[yojo_idx] =  if row[yojo_idx] =~ /20\d{2}/ 
                             begin
                               Time.parse row[yojo_idx]
                             rescue
                               msg = $!.message + ": #{lot_no} 養生開始時刻[#{row[yojo_idx]}]"
                               errors.add(:nil,"＊＊＊ #{lot_no} の養生開始時刻がありえない日時に思われるので無視します[#{row[yojo_idx]}]")
                               logger.info("== ERROR == extract_data_nomal:"+msg +"\n"+$!.backtrace.join("\n"))
                               nil
                             end
                           else
                             nil
                           end
        end
        if real_ope == :kakou 
          if lot_no && (row[start_idx]||row[end_idx])
            [lot_no,start_time,end_time]
          end
        else
          if lot_no #&& (row[start_idx]||row[end_idx]||row[yojo_idx] || yojoko)
            [lot_no,start_time,end_time,row[meigara_idx],row[yojo_idx],yojoko]
          end
        end
      }.compact
    end

    # データのある行を抜きだし、\n と \t で分ける。
    # 1. /\d[MmWw]\d{4}/のある行がその行
    def extruct_rows(real_ope,lines)
      rows = lines.split("\n").select{|line| /\d[ＭｍＷｗMmWw]\d{4}/ =~ line}
      rows.map{|l| l.split(",") }
    end

    # lot_noを正規化
    def normalize_lotno(lotno)
       lotno =~ /(\d?[ＭｍＷｗMmWw]\d{4})/ ? $1.sub(/[ＭｍMm]/,"M").sub(/[ＷｗWw]/,"W") : nil
    end

    
    #ロット番号のある行だけ抜き出された文字列（の配列）から、
    #ロット番号、開始日時、終了日時の配列（の配列）にする
    #00:00 ～ 06:59は翌日の時刻にする
    def modify_time(timestr,date)
      y,m,d = date
      if /(\d{1,2}):(\d{1,2})/ =~ timestr
        fh = $1 ;fm = $2 #].map{|s| s.to_i  }
        
        # 0～7時は歴日は翌日
        #fd = fh < 7 ? d+1 : d
        time=Time.parse("#{y}-#{m}-#{d} #{fh}:#{fm}")
        #puts "#{y}-#{m}-#{d} #{fh}:#{fm} #{time.strftime('%Y-%m-%d %H:%M')}"
        if time.hour < 7
         time=time.tomorrow
        end
        time
      else
        nil
      end
    end

   end
end
__END__

$:Id$
