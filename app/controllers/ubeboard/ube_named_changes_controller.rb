# -*- coding: utf-8 -*-
class UbeNamedChangesController < ApplicationController
  before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter {|ctrl| ctrl.require_configure }
  before_filter :set_instanse_variable
  delegate :logger, :to=>"ActiveRecord::Base"

  SELF = UbeNamedChange
  ORDER = "jun"
  SORT  = :jun
  TYTLE_BASE = "記名切り替え"
  NameBase   = :class_name
  PostUpdate = Proc.new{true}
  CSVlabels =  ["順","前品種","後品種","工程名","表示"]
  CSVatrs   =  [:jun,:pre_condition_id,:post_condition_id,:ope_name,:display]

  Labels = 
    [# colmn,ラベル,help,type,size or choice
     HtmlText.new(:jun           , "決定順" ,:size=>3),
     HtmlSelect.new(:pre_condition_id , "前品種" ,:include_blank=>true,
                    :correction => Proc.new{UbeOperation.names},:display =>:pre_con_name),
     HtmlSelect.new(:post_condition_id, "後品種" ,:include_blank=>true,
                    :correction => Proc.new{UbeOperation.names},:display =>:post_con_name),
     HtmlSelect.new(:ope_name      , "工程名" , :correction =>UbeSkd::OpeName),
     HtmlText.new(:display       , "表示"   ,:size=>4)
    ]

  def set_instanse_variable
    @Model= UbeNamedChange
    @TYTLE = "記名切り替え"
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption = {:order => ORDER}
    @TableEdit = true
    @Edit = true
    @Delete=true
    @Domain= :ube_named_change
    #@Refresh = :kamokus
    #@SortBy    = :bunrui
    @CSVatrs = CSVatrs; @CSVlabels = CSVlabels;
    #@Pagenation = 20
    #maxNo = BookMain.maximum :no 
    #no = (maxNo ? maxNo : 0) + 1
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

end

