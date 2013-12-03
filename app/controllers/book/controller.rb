# -*- coding: utf-8 -*-
# 複式簿記

class Book::Controller <  ApplicationController
  include Actions
  #include BookPermit
  #before_filter :login_required 
  before_filter {|ctrl| ctrl.set_permit %w(複式簿記試用 複式簿記利用 複式簿記メンテ)}
  before_filter :set_instanse_variable
  before_filter(:except => :error) {|ctrl|  ctrl.require_allowed "/book_keeping/error" }
 
  def set_instanse_variable
    @year = session[:book_keeping_year] || Time.now.beginning_of_year
    @arrowed = []
    if current_user
      myself = Book::Permission.create_myself(current_user)      if @editor
      @arrowed << Book::Permission.create_myself(User.find_by(username: "guest"))  if  @permit
      @arrowed += (@aaa=Book::Permission.arrowed_owner(current_user.username) )
    end
    @arrowed.sort!{|a,b|  (b.permission <=> a.permission)*2 + (a.username <=> b.username)}
    @arrowed.unshift(myself) if myself
    logger.debug "BookCtrl SET_INSTANSE_VARIABLE : @arrowed.first=#{@arrowed.first.inspect},session[:book_keeping_owner] =#{session[:book_keeping_owner].inspect}"
    @owner = (session[:book_keeping_owner] ? session[:book_keeping_owner] : @arrowed.first) ||
      Book::Permission.create_nobody #owner
    @Links=Book::KeepingController::Links
    #@optionDisplay = "誰の簿記か #{@owner[1]}"
  end

  def require_allowed(url="/404.html") 
    redirect_to url unless @permit || @arrowed.size>0
    @permit || @arrowed.size>0
  end

  def require_book_editor(url="/404.html") 
    redirect_to url unless book_editor?
    book_editor?
  end

  def book_editor? ; @owner.permission == 2 ; end

  def owner? 
    @owner && current_user && @owner.owner == current_user.username
  end

  def editable ; 
#pp @owner.permission
    @owner.permission == Book::Permission::EDIT ; 
  end

  def readable ; @owner.permission >= Book::Permission::SHOW ; end


  def show
    unless @Model.find(params[:id]).readable?(current_user.username)
      redirect_to "/msg_book_permit.html"
    else
      super
    end
  end

  def new
#pp [current_user.username,@owner,"editabl=",editable]
    unless editable
      redirect_to "/msg_book_permit.html"
    else
      super
    end
  end

  def create
#pp [current_user.username,@owner,"editabl=",editable]
    unless editable
      redirect_to "/msg_book_permit.html"
    else
      super
    end
  end

  def edit
    unless @Model.find(params[:id]).editable?(current_user.username)
      redirect_to "/msg_book_permit.html"
    else
      super
    end
  end

 def update_on_table
    unless editable
      redirect_to "/msg_book_permit.html"
    else
      super
    end
 end

 def edit_on_table
    unless editable
      redirect_to "/msg_book_permit.html"
    else
      @page = params[:page] || lastpage if @Pagenation
      find_and
      render  :file => 'application/edit_on_table',:layout => 'application'
    end
  end

end
