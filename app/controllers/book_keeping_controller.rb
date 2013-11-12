# -*- coding: utf-8 -*-
# 複式簿記

class BookKeepingController <  BookController
  #include BookPermit
  #before_filter :login_required 
  before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  before_filter(:except => [:error]) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
 
   Labels = [Menu.new(   "新規伝票作成",:book_main   ,:action => :new,
                         :disable => :editable) ,
             MenuCsv.new("振替伝票一覧"    ,:book_main   ,:enable_csv_upload=> :editable),
             MenuCsv.new("勘定科目"        ,:book_kamoku ,:enable_csv_upload=> :editable),
             Menu.new(   "貸借対照表"      ,:book_keeping,:action => :taishaku  ,
                      :csv_download_url=> :csv_taishaku),
             Menu.new(   "清算表",:book_keeping,:action => :motocho ),
             Menu.new(   "共有ユーザー"    ,:book_permission,:disable => :owner?,:help => "Book#permission")
            ] 
  Links = [Menu.new("簿記Top",:book_keeping)] + Labels + [Menu.new("ヘルプ",:book_keeping,:action => :help)]
  OwnerChangeLabels =
    [
      HtmlText.new(:owner     ,"簿記ユーザlogin名",:ro=>true),
      HtmlText.new(:owner_name,"簿記ユーザ 氏名"  ,:ro=>true),
      HtmlText.new(:permission_string,"権限"      ,:ro=>true)
    ]
  # メニューを出す
  def index
    session[:book_keeping_year]  ||= @year
    session[:book_keeping_owner] ||= @owner
    @owner_choices = @arrowed.map{|a| ["#{a.owner} #{a.permission_string}",a.owner]}
    #@year_owner= {"param_owner" => @owner[1]}
    @labels = Labels 
    logger.debug "BookKeeping:INDEX @owner = #{@owner.inspect}"
  end

 def error
  end

  # 年度をメニューにて対象年度を変更した時のaction

  def owner_change_win
    @labels = OwnerChangeLabels
  end

  def owner_change
    unless params[:owner].blank?
      if owner = @arrowed.find{|arrw| arrw.owner == params[:owner]}
        @owner = session[:book_keeping_owner] = owner
        @labels = Labels
        logger.debug("CHANGE_OWNER new owner = #{@owner}, @year=#{@year}")
        redirect_to  :action => :index
      else
        flash[:error] = "許可の無いユーザです"
        redirect_to :action => "owner_change_win"
      end
    else
        redirect_to  :action => :index     
    end
    #nder :partial => "menu_list" 
  end

  def year_change
    unless params[:value].blank?
      @year = session[:book_keeping_year] = Time.parse(params[:value]+"/1/1 JST") 
    end
    redirect_to :action => :index
  end

  # 科目一覧を表示し、そこから元帳を選ぶ
  def motocho
    @sum  = Book::Main.sum(@owner.owner,@year)
  end

  # 貸借対照表
  def taishaku
    @data = Book::Main.taishaku(@owner.owner,@year)
  end

  def help
  end

  # 貸借対照表をCSV出力
  def csv_taishaku
    models = Book::Main.taishaku(@owner.owner,@year)
    tmpfile = Book::Main.csv_out(models)
    send_file(tmpfile,:filename => (@owner.owner + "_貸借対照表.csv"))
  end

  # 総勘定元帳をCSV出力
  def csv_motocho
    models = Book::Main.motocho(@owner.owner,@year)
    tmpfile = Book::Main.csv_out(models)
    send_file(tmpfile,:filename => (@owner.owner + "_総元帳.csv"))
  end

  def editable ; @owner.permission == Book::Permission::EDIT ; end
    
end
