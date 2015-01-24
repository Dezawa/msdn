# -*- coding: utf-8 -*-

# 複式簿記

class Book::KeepingController <  Book::Controller
  #include BookPermit
  #before_filter :authenticate_user! 
  before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  before_filter(:except => [:error]) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
 
   Labels = [Menu.new(   "新規伝票作成",:main   ,:action => :new,
                         :disable => :editable) ,
             MenuCsv.new("振替伝票一覧"    ,:main   ,:enable_csv_upload=> :editable),
             MenuCsv.new("勘定科目"        ,:kamoku ,:enable_csv_upload=> :editable),
             Menu.new(   "貸借対照表"      ,:keeping,:action => :taishaku  ,
                      :csv_download_url=> :csv_taishaku),
             Menu.new(   "清算表",:keeping,:action => :motocho ),
             Menu.new(   "共有ユーザー"    ,:permission,:disable => :owner?,:help => "Book#permission")
            ] 
  Links = [Menu.new("簿記Top",:keeping)] + Labels + [Menu.new("ヘルプ",:keeping,:action => :help)]

  # メニューを出す
  def index
    @owner_choices = @arrowed.map{|a| ["#{a.owner} #{a.permission_string}",a.owner]}
    # @year_owner= {"param_owner" => @owner[1]}
    @labels = Labels 
    logger.debug "BookKeeping:INDEX @owner = #{@owner.login}/#{@owner.owner} session['BK_year']=#{session['BK_year']}"
  end


  def year_change
    unless params["year"].blank?
      @year = Time.parse(params["year"]+"/1/1 JST")
      session["BK_year"] =  @year
      logger.debug "BOOKKEEPING:YEAR_CHANGED  SESSION params[:year]=#{ params[:year]},#{ params["year"]},@year =#{@year},['BK_year']=#{session['BK_year']}"
    end
    @owner_choices = @arrowed.map{|a| ["#{a.owner} #{a.permission_string}",a.owner]}
    @labels = Labels 

    logger.debug "BookKeeping:year_change  @year = #{ @year}session['BK_year']=#{session['BK_year']}"
    #render :partial => "this_year" 
    render  :action => :index
    # redirect_to :action => :index
  end

 def error
  end


  def ddowner_change_win
    @labels = OwnerChangeLabels
  end

  def ddowner_change
    unless params[:owner].blank?
      if owner = @arrowed.find{|arrw| arrw.owner == params[:owner]}
        @owner = owner; session[:BK_owner] = owner.id
        #@labels = Labels
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
