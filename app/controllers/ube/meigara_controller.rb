# -*- coding: utf-8 -*-
class Ube::MeigaraController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  #before_filter :authenticate_user!
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
  #include ApplicationHelper
  delegate :logger, :to=>"ActiveRecord::Base"

  Labels = [ 
            HtmlSelect.new(  :proname , "品種",:display => :proname,
                          :correction => Proc.new{Ube::Operation.names.map{|o| o[0]}}),
            HtmlText.new(  :meigara , "銘柄",:size => 30)
           ]
  CSVlabels =  ["品種","銘柄"]
  CSVatrs   =  [:proname,:meigara]

 def set_instanse_variable
    @Model= Ube::Meigara
    @TYTLE = "銘柄"
    @labels=Labels
    #@Links=BookKeepingController::Labels
   @FindOrder =  "proname,meigara"
    @TableEdit = true
   #@Show = true
    #@Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
    @Refresh = :meigaras
    #@SortBy    = :bunrui
   @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
   @CSVfile =  current_user.login + "_meigara.csv"
    @pageSession="UBmeiga_perpage"
    @Pagenation =  session[@PageSession] || (session[@PageSession] = 20)
    #maxNo = BookMain.maximum :no 
    #no = (maxNo ? maxNo : 0) + 1
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

end

