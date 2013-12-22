# -*- coding: utf-8 -*-
class Ubr::MainController < ApplicationController
  include ExcelToCsv
  before_action :authenticate_user! 
  before_filter :set_instanse_variable

   dmy=Menu
   Labels = [MenuCsv.new("SCM在庫更新" ,"ubr/main"   ,:enable_csv_upload=> true,:size => 40,:buttonlabel=>"CSV/Excelで登録") ,
             Menu.new(   "在庫表示"    ,:main   ,:action => :occupy_pdf) ,
             Menu.new(   "再計算"      ,:main   ,:action => :reculc) ,
            ]
  #]+
  #(0..Ubr::Waku::Aria.size-2).map{ |idx|
  #   Menu.new( Ubr::Waku::Aria[idx].first ,:ubr_main ,:action => "list_#{idx}" )
  #}

  Links = Labels
  def set_instanse_variable
    @Links=Labels

    @filename = "枠詰まり具合"
    @pdffile  =File.join(Rails.root,"tmp","ubr",@filename)
  end

  # メニューを出す
  def index
    @labels = Labels 
    @lastday = /201\d{3,5}/.match(File.read(Ubr::Lot::SCMFILEBASE))
  end
  def occupy_pdf
    #pdf_file = Tempfile.new("pdffile","#{Rails.root}/public/tmp")
    #pdffile,mode = @model.doc_out(from,to,pdf_file,weekly)
    send_file(@pdffile+".pdf", :filename =>@filename+".pdf")
  end

  def method_missing(id,*args,&block)
    case id.to_s
    when /^list_(\d+)/
      @idx = $1.to_i
      @aria_name = Ubr::Waku.idx_or_name2name(@idx)
      @waku_empty    = Ubr::Waku.empty(@idx)
     # @waku_by_volume_occupied  = Ubr::Waku.by_volume_occupied(@idx,true)
      @html = File.read( File.join(Ubr::Souko::Dirname,id.to_s+".html"))
      render  :action => :list
    when /^detail_(\d+)_([^_]+)_(\d+)_(\d+)_(\d+)_(\d+)$/
      @aria_no,@vol,@dan3,@dan2,@dan1,@masu = $1,$2.to_i,$3,$4,$5,$6
      @aria_name = Ubr::Waku.idx_or_name2name(@aria_no)
      @html =  File.read(File.join(Ubr::Souko::Dirname,id.to_s+".html"))
      render  :action => :detail
    else
      super
    end    
  end

  def csv_upload
pp params[:csvfile].class
    @filename = case infile = params[:csvfile]
                when ActionDispatch::Http::UploadedFile; infile.original_filename
                end
    @basename = @filename.sub(/\....$/,"")
    csvfiles = csv_files(params[:csvfile])
    open(Ubr::Lot::SCMFILE,"w"){ |fp| fp.write(File.read(csvfiles[0]))}
    open(Ubr::Lot::SCMFILEBASE,"w"){ |fp| fp.puts(@filename) }
    open(File.join(Rails.root,"tmp","ubr","save",@basename+".csv"),"w"){
      |fp| fp.write(File.read(csvfiles[0]))}
    logger.debug("在庫更新 Lotlist数 #{Ubr::LotList.lotlist.list.size}")
    
    Ubr::Occupy.main(@pdffile)
    
    save_ps

    File.join(Rails.root,"tmp","ubr","pssave",@basename+".csv")

    flash[:message] = "更新成功:" + @filename
    redirect_to :action => :reculc 
  end

  def save_ps
    date = /\d{8}/.match(@basename)
    psgz = File.join(Rails.root,"tmp","ubr","pssave","plan")+"-#{date}.ps.gz"
    `/bin/gzip -c #{@pdffile+".ps"} > #{psgz}`
  end

  def reculc
    #Ubr::LotList.lotlist
    Ubr::Occupy.main(@pdffile)
    flash[:message] = "再計算終了:" 
    send_file(@pdffile+".pdf", :filename =>@filename+".pdf")
  end

  def show_pdf
    send_file Rails.root+"tmp/ubr/SoukoInfo.gif", :type => 'image/gif', :disposition => 'inline'
  end
end
