# -*- coding: utf-8 -*-
class Ubeboard::ConstantController < ApplicationController
  include Actions
  #before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter(:except => [:index,:csv_out,:edit_on_table,:update_on_table]){|ctrl| ctrl.require_configure} 
  before_filter :set_instanse_variable
  #include ApplicationHelper
  delegate :logger, :to=>"ActiveRecord::Base"

  Labels = [ HtmlText.new(:name   ,"項目名",:size =>15,:ro => :not_configure ),
             HtmlText.new(:keyword,"Key",:size =>20,:ro => :not_configure  ,
                            :field_disable => :not_configure ),
             HtmlText.new(:value  ,"値"   ,:align => :right,:size =>5),
             HtmlText.new(:comment,"備考"  ,:size =>30),
             HtmlSelect.new(:admin ,"管理者項目",:align => :center,
                            :correction =>[["",false],["○",true]] ,
                            :field_disable => :not_configure 
                            )
           ]
  CSVlabels =  %w(name value keyword  comment admin)
  CSVvars   =  [:name ,:value,:keyword  ,:comment,:admin]

 def set_instanse_variable
   @Model= Ubeboard::Constant
   @TYTLE = "工程管理項目"
   @labels=Labels
   @TableEdit = true # @configure ?  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table_all_column,"編集"]] :
 #    [[:form,:edit_on_table,"編集"]] #true
   #@Edit = true
   @Delete= :configure
   @Domain= @Model.name.underscore
   #@Refresh = :meigaras
   #@SortBy    = :bunrui
   @CSVatrs = CSVvars; @CSVlabels = CSVlabels
   @CSVfile =  current_user.login + "_constant.csv"
    @pageSession="UBcnst_perpage"
    @Pagenation =  session[@PageSession] || (session[@PageSession] = 20)
   #maxNo = BookMain.maximum :no 
   #no = (maxNo ? maxNo : 0) + 1
   #@New = {:no => no, :date => Time.now}
   @FindOption = configure ? {} :  "admin is not true"
 end
end

