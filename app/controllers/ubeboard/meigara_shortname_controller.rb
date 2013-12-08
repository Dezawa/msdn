# -*- coding: utf-8 -*-
class UbeMeigaraShortnameController < ApplicationController
  before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
  #include ApplicationHelper
  delegate :logger, :to=>"ActiveRecord::Base"

  Labels = [ HtmlSelect.new( :ube_meigara_id , "銘柄",:display => :meigara,
                          :correction => Proc.new{UbeMeigara.all_meigara}),
            HtmlText.new(  :short_name  , "略称",:size => 30)
           ]
  CSVlabels =  ["ID","略称","銘柄"]
  CSVatrs   =  [:id,:short_name,:ube_meigara_id]

 def set_instanse_variable
    @Model= UbeMeigaraShortname
    @TYTLE = "銘柄略称"
    @labels=Labels
    @TableEdit = true
    @Delete=true
   @Domain= @Model.name.underscore
   @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
   @CSVfile =  current_user.login + "_meigara_shortname.csv"
    @Pagenation = 20
    #maxNo = BookMain.maximum :no 
    #no = (maxNo ? maxNo : 0) + 1
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

end

