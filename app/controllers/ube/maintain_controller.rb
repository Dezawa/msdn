# -*- coding: utf-8 -*-
class Ube::MaintainController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  #before_filter :authenticate_user!
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable

  Select = %w(西抄造 東抄造 原乾燥 新乾燥 加工)+(2..24).map{|n| "養生庫-#{n}"}
  #          column            label   memo  type size action                          
 Labels =  [#[:ope_name            ,"工程","",:ope_select],
            HtmlSelect.new( :ope_name      ,"工程"   ,:correction => Select),
            HtmlText.new( :maintain_no     ,"No"    ,:align => :right,:size=>6),
            HtmlText.new( :maintain        ,"作業内容"                          ),
            HtmlDate.new( :plan_time_start ,"開始予定",:tform=>"%Y-%m-%d %H:%M",:size => 13),
            HtmlDate.new( :plan_time_end   ,"終了予定",:tform=>"%Y-%m-%d %H:%M",:size => 13),
            HtmlText.new( :memo            ,"メモ"    ,:size => 30)
          ]

  def set_instanse_variable
    @Model= Ube::Maintain
    @TYTLE = "休転計画"
    #@TYTLEpost = 
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOrder= "plan_time_start"
    #@errors=Proc.new{@Model.error_check.join("<br>")}
    @TableEdit = true
    #@Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    @CSVatrs   = Labels.map{|html| html.symbol}
    @CSVlabels = Labels.map{|html| html.label}
    #@Pagenation = 20
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

end
__END__
$Id: ube_maintain_controller.rb,v 2.13 2012-10-28 08:02:53 dezawa Exp $
