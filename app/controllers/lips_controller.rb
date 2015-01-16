# -*- coding: utf-8 -*-
class LipsController < CommonController #ApplicationController
  include LipsHelper
  include CsvIo
  #before_filter :login_required , :except => [:free,:calc,:error]
  before_filter {|ctrl| ctrl.set_permit %w(LiPS会員)}
  before_filter(:only => [:csv_upload,:csv_download,:change_form]){|ctrl| ctrl.require_permit "/msg_lips_login"} 
  skip_before_filter :verify_authenticity_token

  def free
    @title = "線形計画法"
    I18n.locale = :guest
    #self.current_user = User.find_by_login("guest")
    redirect_to :action => :calc
  end


  def member
    @title = "線形計画法"
    @user  = current_user ? current_user : User.find_by(username: "guest")
    #I18n.locale = (@login == "guest") ? :guest : :default #user.lipslabelcode
    I18n.locale = @permit ? :default : :guest   #user.lipslabelcode
    redirect_to :action => :calc
  end

  def ube_hospital
    @title = "線形計画法"
    I18n.locale = :hospital
   @user  = current_user ? current_user : User.find_by(username: "guest")
   redirect_to :action => :calc
  end


  def calc
    @title = "線形計画法"
    I18n.locale = @permit ? :default : :guest 
   # begin
      @user  = current_user ? current_user : User.find_by(username: "guest")
    @login = @user ? @user.login : "guest"
    set_filename
      @lips=Lips.new(params[:lips])
      @lips.calc(@prefix,@filebase,@csvfile) if params[:lips]
  end



  def csv_download
    filename = current_user.login + "_LiPS.csv"
    send_file(params[:file_name], :filename => filename)    
  end

  def csv_upload
   I18n.locale = @permit ? :default : :guest 
     @title = "線形計画法"
    param =HashWithIndifferentAccess.new
    @user  = current_user ? current_user : User.find_by(username: "guest")
    param[:promax]=current_user.lipssizepro
    param[:opemax]=current_user.lipssizeope	
    @lips = Lips.new(param)
    @lips.csv_upload(params[:csvfile])
    @title = "線形計画法"
    render :action => :calc
  end

  def test
  end

  def test2
  end

  def change_form
    @title = "線形計画法"
      @user  = current_user ? current_user : User.find_by(username: "guest")
    @login = @user ? @user.login : "guest" 
    @lips=Lips.new(params[:lips])
    set_filename
    I18n.locale = @permit ? :default : :guest 
    render :action => :calc
  end

protected
  def set_filename
    user = @user ? @user.login : "guest" 
    @filebase ="#{user}-#{Time.now.to_i.to_s(16)}"
    @csvfile = "lips/tmp/#{@filebase}.csv"
    @prefix = Rails.root+"public"
  end
end
