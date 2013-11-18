# -*- coding: utf-8 -*-
class UsersController < ApplicationController
  #before_filter :login_required 
  #before_filter {|ctrl| ctrl.require_permit_label "ユーザメンテ"}
  before_filter :set_instanse_variable
  # Be sure to include AuthenticationSystem in Application Controller instead
  #include AuthenticatedSystem
  
  #Viewにて表示すべき項目の定義。
  Labels0 = [
             HtmlText.new(:login         ,"ユーザ名",          :size => 30),
             HtmlText.new(:email         ,"メール",            :size => 30),
             HtmlPasswd.new(:password    ,"パスワード",        :size => 30),
             HtmlPasswd.new(:password_confirmation,"確認パスワード",:size => 30),
             HtmlRadio.new(:lipscsvio    ,"LiPS CSV IO option",
                            :correction => [["可",true],["不可",false]] ),
             HtmlRadio.new(:lipssizeoption    ,"size変更",
                            :correction => [["可",true],["不可",false]] ),
             HtmlText.new(:lipssizepro   ,"pro数最大",         :size => 30),
             HtmlText.new(:lipssizeope   ,"ope数最大",         :size => 30),
             HtmlText.new(:lipslabelcode ,"ラベル",            :size => 30),
             HtmlText.new(:lipsoptlink   ,"LiPS opt_link",     :size => 30)
            ]

 def set_instanse_variable
   @Model= User
    @options   = UserOption.all.sort{|a,b| (a.order <=> b.order)*1000 + (a.label <=> b.label)}
   @TYTLE = "ユーザ"
   @labels=Labels0
   @TableEdit = [[:form,:new,"新規登録"]]
   @tmplate  = true
   @Show = true
   @Edit = true
   @Delete=true
   @Domain= @Model.name.underscore
  end


  def change_password
    flash[:return_to] = request.env["HTTP_REFERER"]
    @labels = Labels0[2..3]
    @user = User.find(current_user.id)  
#render :action => :test  
  end

  def password_update
    @user = User.find(current_user.id)  

      if @user.update_attributes(params[:user])
        flash[:notice] = 'パスワード変更しました'
        redirect_to( flash[:return_to] || "/top")
      else
        flash[:notice] = 'User was failes updated.'
         render :action => "change_password" 
      end
  end

  # render new.rhtml

  def show
    @user = User.find(params[:id],:include=> :user_options)
    @arrowed_options = @user.user_options.map(&:id)
  end
  def edit
    @user = User.find(params[:id])
    @arrowed_options = @user.user_options.map(&:id)
  end
  def new
    flash[:return_to] = request.env["HTTP_REFERER"]
    @user = User.new
    @arrowed_options = @user.user_options.map(&:id)
  end
 
  def create
    #@user = User.new
    #logout_keeping_session!
    @user = User.new(params[:user])
    success = @user && @user.save
    logger.debug("UserCreate success? #{success}")
    logger.debug("UsetCreate #{@user.errors.on(:email)}")
    if success && @user.errors.empty?
            # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset session
      #self.current_user = @user # !! now logged in
      
        redirect_to :action => :index #( flash[:return_to] || "/top")#redirect_back_or_default('/top')
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
    else
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
    @arrowed_options = @user.user_options.map(&:id) || []
      render :action => 'new'
    end
  end #of create

  def update
    @params = params
    @user = User.find(params[:id],:include => :user_options)
    @user[:valtype] = @user[:lips_size_pro].class
    @user_option_ids = params[:user_options].map{|id,ok_ng| id if ok_ng == "1" }.compact
    @user.user_options = UserOption.find(@user_option_ids)
    #render :action => :test ; return
    respond_to do |format|
      if @user.update_attributes(params[:user])
        flash[:notice] = 'User was successfully updated.'
        format.html { redirect_to(@user) }
        format.xml  { head :ok }
      else
    @arrowed_options = @user.user_options.map(&:id) || []
        format.html { render :action => "edit" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end

  end

end # of class users_cont
