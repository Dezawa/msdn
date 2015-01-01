# -*- coding: utf-8 -*-
class Sola::MonthlyController < Sola::Controller #ApplicationController
=begin
index     1 2 3 4 5.... 30 31 peak
   2014/1                          表示 削除
   2014/2

show      power 日照時間
    1
    2
    .....
    31
=end

  include Actions
  include GraphController
  before_action :authenticate_user! 
  before_filter :set_instanse_variable

  Labels = [HtmlDate.new(:month,"年月",:tform =>"%Y-%m",:size => 5)]+
    ("01".."31").map{ |kwh| HtmlNum.new("kwh#{kwh}".to_sym,kwh,:size => 2,tform: "%4.1f")}
  def set_instanse_variable
    super
    @Model= Sola::Monthly
    @Domain= @Model.name.underscore
    @TYTLE = "太陽光発電"
    #@TYTLEpost = "#{@year}年度"
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption = {}
    @TableEdit =  [ :add_edit_buttoms,
                   [:popup,:peak_graph,"ピークグラフ",{:win_name => "default" }]
                 ]
    #@Edit = true
    @Delete=true
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    #@CSVatrs = Ube::Product::CSVatrs; @CSVlabels = Ube::Product::CSVlabels
    #@pageSession="UBpro_perpage"
    @Pagenation =  session[@PageSession] || (session[@PageSession] = 20)
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

  def update_on_table
    params[@Domain].each{ |id,monthly|
      monthly["month"] = monthly["month"] + "-1" if monthly["month"]
    }
    super
  end

end
