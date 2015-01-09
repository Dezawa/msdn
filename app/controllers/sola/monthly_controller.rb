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

  Labels = [HtmlDate.new(:month,"年月",:tform =>"%Y-%m",:size => 5),
            HtmlNum.new(:sum_kwh,"総発電量",tform: "%4.1f",:ro => true),
           ]+
    ("01".."31").map{ |kwh| HtmlNum.new("kwh#{kwh}".to_sym,kwh,:size => 2,tform: "%4.1f")}
  def set_instanse_variable
    super
    @Model= Sola::Monthly
    @Domain= @Model.name.underscore
    @TYTLE = "太陽光発電"
    @labels=Labels
    @FindOrder = "month"
    @TableEdit =  [ :add_edit_buttoms,
                    [:popup,:peak_graph,"ピークグラフ",{:win_name => "default" }],
                    [:csv_out,      "CSVダウンロード"],
                    [:csv_up_buttom]
                 ]
    @Delete=true
    #@CSVatrs = Ube::Product::CSVatrs; @CSVlabels = Ube::Product::CSVlabels
    @Pagenation = 12
  end

  def update_on_table
    params[@Domain].each{ |id,monthly|
      monthly["month"] = monthly["month"] + "-1" if monthly["month"]
    }
    super
  end

  def monthly_graph
    @graph_file = "sola_monthly"
    @graph_file_dir = Rails.root+"tmp" + "img"
    Sola::Monthly.monthly_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end


  def dayly_graph
    @graph_file = "sola_dayly"
    @graph_file_dir = Rails.root+"tmp" + "img"
    Sola::Monthly.dayly_graph(@graph_file,@graph_file_dir)
    render   :file => 'application/graph', :layout => "simple"
  end

  def csv_upload
    @CSVatrs  = @CSVlabels = @Model.column_names unless @CSVatrs && @CSVlabels
    errors= @Model.csv_update(params[:csvfile]||params[@Domain][:csvfile], @CSVlabels,@CSVatrs)
    unless errors[0]
      flash[:message] = errors[1]
      redirect_to :action => :index
    else
      @Model.send(@Refresh,true) if @Refresh
      flash[:message] = errors[1] if  errors[1]>""
      redirect_to :action => :index
    end
  end


end
