# -*- coding: utf-8 -*-
class UbeMeigaraController < ApplicationController
  before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
  #include ApplicationHelper
  delegate :logger, :to=>"ActiveRecord::Base"

  Labels = [ 
            HtmlSelect.new(  :proname , "品種",:display => :proname,
                          :correction => Proc.new{UbeOperation.names.map{|o| o[0]}}),
            HtmlText.new(  :meigara , "銘柄",:size => 30)
           ]
  CSVlabels =  ["品種","銘柄"]
  CSVatrs   =  [:proname,:meigara]

 def set_instanse_variable
    @Model= UbeMeigara
    @TYTLE = "銘柄"
    @labels=Labels
    #@Links=BookKeepingController::Labels
   @FindOption = {:order => "proname,meigara"}
    @TableEdit = true
   #@Show = true
    #@Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
    @Refresh = :meigaras
    #@SortBy    = :bunrui
   @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
   @CSVfile =  current_user.login + "_meigara.csv"
    @Pagenation = 20
    #maxNo = BookMain.maximum :no 
    #no = (maxNo ? maxNo : 0) + 1
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

end

