# -*- coding: utf-8 -*-
class Ubeboard::PlanController < CommonController #ApplicationController
  include Actions
  before_action :authenticate_user! 
  #before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
  #           sym,             lbl,   hlpnsg,type,width
  #          column            label   memo  type size action   
  Labels = [#HtmlText.new(:ube_skd_id          ,"立案No",:ro],
            HtmlText.new(      :id                ,"ID",:align=>:right, :ro=>true,:size => 2),
            HtmlText.new(      :jun               ,"優先順",:align=>:right,:size => 2),
            HtmlText.new(      :lot_no            ,"製造番号",:size => 5),
            HtmlText.new(      :mass              ,"製造数",:align=>:right,:size => 3),
            HtmlProname.new ,
            HtmlMeigara.new(   :include_blank=>true),
            HtmlText.new(      :yojoko            ,"養生庫",:align=>:right,:ro=>true), 
            HtmlPlanTime.new(  :plan_shozo_from   ,"予定抄造開始"),
            HtmlPlanTime.new(  :plan_shozo_to     ,"予定抄造終了"),
            HtmlPlanTime.new(  :plan_yojo_from    ,"予定養生開始"),
            HtmlPlanTime.new(  :plan_yojo_to      ,"予定養生終了"),
            HtmlPlanTime.new(  :plan_dry_from     ,"予定乾燥開始"),
            HtmlPlanTime.new(  :plan_dry_to       ,"予定乾燥終了"),
            HtmlPlanTime.new(  :plan_kakou_from   ,"予定加工開始"),
            HtmlPlanTime.new(  :plan_kakou_to     ,"予定加工終了"),
            HtmlText.new(      :lot_no            ,"製造番号",:size => 5),
            HtmlResultTime.new(:result_shozo_from ,"実績抄造開始"),
            HtmlResultTime.new(:result_shozo_to   ,"実績抄造終了"),
            HtmlResultTime.new(:result_yojo_from  ,"実績養生開始"),
            HtmlResultTime.new(:result_yojo_to    ,"実績養生終了"),
            HtmlResultTime.new(:result_dry_from   ,"実績乾燥開始"),
            HtmlResultTime.new(:result_dry_to     ,"実績乾燥終了"),
            HtmlResultTime.new(:result_kakou_from ,"実績加工開始"),
            HtmlResultTime.new(:result_kakou_to   ,"実績加工終了")
           ]
                       
  DLabels = [[:id               ,"ID","",:ro],
            [:jun               ,"優先順","",:text],
            [:lot_no            ,"ロット","",:text],
            [:mass              ,"製造数","",:text],
            [:ube_product_id    ,"製品名","",:proname],
            [:meigara           ,"銘柄","",:text],
            [:plan_shozo_from   ,"予定抄造開始","",:datetimero,],
            [:plan_shozo_to     ,"予定抄造終了","",:datetimero,],
            [:plan_yojo_from    ,"予定養生開始","",:datetimero,],
            [:plan_yojo_to      ,"予定養生終了","",:datetimero,],
            [:plan_dry_from     ,"予定乾燥開始","",:datetimero,],
            [:plan_dry_to       ,"予定乾燥終了","",:datetimero,],
            [:plan_kakou_from   ,"予定加工開始","",:datetimero,],
            [:plan_kakou_to     ,"予定加工終了","",:datetimero,],
            [:result_shozo_from ,"実績抄造開始","",:datetime,],
            [:result_shozo_to   ,"実績抄造終了","",:datetime,],
            [:result_yojo_from  ,"実績養生開始","",:datetime,],
            [:result_yojo_to    ,"実績養生終了","",:datetime,],
            [:result_dry_from   ,"実績乾燥開始","",:datetime,],
            [:result_dry_to     ,"実績乾燥終了","",:datetime,],
            [:result_kakou_from ,"実績加工開始","",:datetime,],
            [:result_kakou_to   ,"実績加工終了","",:datetime,]
           ]

  def set_instanse_variable
    @Model= Ubeboard::Plan
    @TYTLE = "製造計画"
    #@TYTLEpost = "#{@year}年度"
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption = {}
    #@errors=Proc.new{@Model.error_check.join("<br>")}
    @TableEdit = true
    #@Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    @CSVatrs   =[:id,:jun,:lot_no,:mass,:ube_product_id,:meigara,:yojoko,
                 :plan_shozo_from,:plan_shozo_to,:plan_yojo_from,:plan_yojo_to,
                 :plan_dry_from,:plan_dry_to,:plan_kakou_from,:plan_kakou_to,
                 :result_shozo_from,:result_shozo_to,:result_yojo_from,:result_yojo_to,
                 :result_dry_from,:result_dry_to,:result_kakou_from,:result_kakou_to]

    @CSVlabels = ["ID","優先順","製造番号","製造数" ,"製品名","銘柄","養生庫",
                  "予定抄造開始","予定抄造終了", "予定養生開始","予定養生終了",
                  "予定乾燥開始","予定乾燥終了","予定加工開始", "予定加工終了",
                  "実績抄造開始","実績抄造終了","実績養生開始","実績養生終了",
                  "実績乾燥開始","実績乾燥終了","実績加工開始","実績加工終了"]
    @pageSession="UBplan_perpage"
    @Pagenation =  session[@PageSession] || (session[@PageSession] = 20)
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

  def ddindex
    @labels = Labels
    @models = Ubeboard::Plan.all(:include => :ube_product,:order => :jun)
    #render :action => "test"
  end

  def ddedit_on_table
    @title = "製造計画 編集"
    @labels    = Labels
    @models   =  Ubeboard::Plan.all(:include => :ube_product,:order => :jun)
    #render :action => :test
  end
end

__END__
$Id: ube_plan_controller.rb,v 2.8 2013-04-01 22:25:27 dezawa Exp $
$Log: ube_plan_controller.rb,v $
Revision 2.8  2013-04-01 22:25:27  dezawa
*** empty log message ***

Revision 2.7  2012-11-01 13:59:59  dezawa
Ubeboard::PlanのCSV IOをconfigureにつけた

Revision 2.6  2012-10-07 00:21:23  dezawa
set_permitをlabel -> authoneicat

Revision 2.5  2012-10-05 05:46:10  dezawa
HtmlCell　子class作成

Revision 1.1.1.1  2012-09-24 03:03:24  dezawa


Revision 1.2  2012-09-20 12:27:44  dezawa
rout.rb変更にともなう修正

Revision 1.1  2012-09-17 00:23:55  dezawa
app/controllers/ube_plan_controller.rb

Revision 2.3  2012-04-23 23:40:33  dezawa
無効機能も見せるようにした
ユーザオプションの表示順変更

Revision 2.2  2012-04-17 00:43:17  dezawa
UserOptionのlabel間違い

Revision 2.1  2012-04-12 11:56:32  dezawa
ウベボードにユーザの権限チェック入れた

Revision 2.0  2012-01-29 23:31:34  dezawa
リリース版：最適化一旦ここまで。
BUG出しに移る

Revision 1.5  2011-12-16 00:44:55  dezawa
ADD Id,Log

