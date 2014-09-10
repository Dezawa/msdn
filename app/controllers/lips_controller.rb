# -*- coding: utf-8 -*-
class LipsController < CommonController #ApplicationController
  include Actions
  include LipsHelper
  include CsvIo
  #before_filter :login_required , :except => [:free,:calc,:error]
  before_action :authenticate_user! ,except: [:msdn,:free,:calc]
  before_filter {|ctrl| ctrl.set_permit %w(LiPS会員 LiPS会員 LiPS会員)}
  before_filter(:only => [:csv_upload,:csv_download,:change_form]){|ctrl|
    ctrl.require_permit "/msg_lips_login"
  } 
  #skip_before_filter :verify_authenticity_token
  max= "3"
  Permit = ["promax", "opemax", "vertical", "minmax", 
            "opename"=>("1"..max).to_a ,
            "time"   =>("1"..max).to_a ,
            "gele"   => ("1"..max).to_a ,
            "proname"=> ("1"..max).to_a ,
            "gain"   => ("1"..max).to_a ,
            "min"    =>("1"..max).to_a ,
            "max"    =>("1"..max).to_a ,
            "rate"   =>[ "1" => ("1"..max).to_a ,"2" => ("1"..max).to_a ]
#Hash[*("1"..max).map{|i| [i,("1"..max).to_a]}.flatten(1)]
           ]

  def is_member?
    @user  = current_user ? current_user : User.find_by(username: "guest")
    if @permit
      I18n.locale = :default
    else
      I18n.locale = :guest
    end
  end

  def ube_hospital
    @title = "線形計画法"
    I18n.locale = :hospital
   @user  = current_user ? current_user : User.find_by(username: "guest")
   redirect_to :action => :calc
  end


  def calc
    @title = "線形計画法"
    is_member?
    #@user  = current_user ? current_user : User.find_by(username: "guest")
    @login = @user ? @user.username : "guest"
    set_filename
    if params[:lips]
      @lips=Lips.new(params.require(:lips).permit!)#(Permit))#!)
    else
      @lips=Lips.new
    end
    @lips.calc(@prefix,@filebase,@csvfile)
  end



  def csv_download
    filename = current_user.username + "_LiPS.csv"
    send_file(params[:file_name], :filename => filename)    
  end

  def csv_upload
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
    @login = @user ? @user.username : "guest" 
    @lips=Lips.new(params[:lips])
    set_filename
    render :action => :calc
  end

protected
  def set_filename
    user = @user ? @user.username : "guest" 
    @filebase ="#{user}-#{Time.now.to_i.to_s(16)}"
    @csvfile = "lips/tmp/#{@filebase}.csv"
    @prefix = Rails.root+"public"
  end
end
