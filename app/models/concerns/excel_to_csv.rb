# -*- coding: utf-8 -*-
module ExcelToCsv
  def csv_files(file)
    # Excel(mgic no 208 207 17 224 -> xsl,80 75 3 -> xlsx) のときは、CSVへの変換を行う
    # 物理ファイルでないとできないので、書き出す。
    infile = case file
             when File,ActionDispatch::Http::UploadedFile #
               logger.debug("ExcelToCsv:original_filename #{file.original_filename}")
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
    XSL = "\xD0\xCF".force_encoding("US-ASCII")
    XSLX = "\x50\x4B".force_encoding("US-ASCII")
    def ssconvert_if_excel(infile)
      magic = infile.read(2).force_encoding("US-ASCII")

      #magic = [infile.getc,infile.getc]
      case magic
        #   xsl       xslx
      when XSL, XSLX,[208,207],[80,75] 
        ssconvert(infile.path)
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
      tmpfile = Tempfile.new("xls2csv","/tmp")
      pid = fork{
        exec("#{SSCONVERT} -S #{SJIS} #{EXPORT_CSV} #{path} #{tmpfile.path} 2>/dev/null")
      }   
      if pid
        Process.waitall
      end
      
      files = Dir.glob("#{tmpfile.path}*").sort_by{|f| /(\d+)$/ =~ f;$1.to_i}
    end 
end
