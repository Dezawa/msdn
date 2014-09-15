# -*- coding: utf-8 -*-
class Ube::OperationController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  #before_filter :authenticate_user!
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
  #include ApplicationHelper
  Labels = [
            HtmlText.new( :ope_name,"品種",:size => 10),
            HtmlText.new( :west    ,"西抄造" ,:align => :right,:size => 7),
            HtmlText.new( :east    ,"東抄造" ,:align => :right,:size => 7),
            HtmlText.new( :old     ,"原乾燥" ,:align => :right,:size => 7),
            HtmlText.new( :new     ,"新乾燥" ,:align => :right,:size => 7),
            HtmlText.new( :kakou   ,"加工"   ,:align => :right,:size => 7)
          ]
  CSVlabels =  %w(id 品種 西抄造時産 東抄造時産 原乾燥滞留時間 新乾燥滞留時間 加工時産)
  CSVatrs   =  [:id ,:ope_name ,:west ,:east ,:old ,:new ,:kakou ]

  def before_save
    Labels.each{|sym,lbl,type| self[sym]=nil if self[sym] == 0.0 }
  end

  def set_instanse_variable
    @Model= Ube::Operation
    @TYTLE = "工程速度"
    #@TYTLEpost = 
    @labels=Labels
    #@Links=BookKeepingController::Labels
    #@FindOption = {}
    @errors=Proc.new{@Model.error_check.join("<br>")}
    @TableEdit = [:add_edit_buttoms,
                  "</tr><tr><td colspan=2>　　A01～A13 は保守、切り替えの所要時間(分)<br>\n"+
                  "　　製品は時産(枚/時間)"
                 ]
    @Edit = true
    @Delete=true
    #@conditions = { :order => "bunrui,kamoku" }
    @Domain= @Model.name.underscore
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    @CSVatrs = CSVatrs; @CSVlabels = CSVlabels
    #@Pagenation = 10
    #maxNo = BookMain.maximum :no 
    #no = (maxNo ? maxNo : 0) + 1
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

end

__END__
$Id: ube_operation_controller.rb,v 2.19 2012-10-24 05:27:11 dezawa Exp $
