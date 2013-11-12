# -*- coding: utf-8 -*-
module ExcelToCsv
  def csv_files(file)
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
             when String
               open(file,"r")
             else
               logger.info("ERROR: UPDATE_RESULT 未定義IOstreamClass。= #{file.class}")
               raise
             end
    csv_files = ssconvert_if_excel(infile)
  end
        
    # input file を調べ、xls,xlsx のときはCSVに直す。
    # そうでないときは CSVであるとみなす。
    # CSV fileのファイルpathの配列を返す
    # 判定はマジックナンバーで調べる
    def ssconvert_if_excel(infile)
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
    def ssconvert(path)
      pid = fork{
        exec("#{SSCONVERT} -S #{SJIS} #{EXPORT_CSV} #{path} 2>/dev/null")
      }   
      if pid
        Process.waitall
      end
      basename = File.basename(path,".*")
      files = Dir.glob(path.sub(/\.[^.]*/,".")+"csv*").sort_by{|f| /(\d+)$/ =~ f;$1.to_i}
    end 
end
