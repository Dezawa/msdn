# -*- coding: utf-8 -*-
class Shimada::MonthController <  Shimada::Controller
  Labels = 
    [HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
      HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month", :link_label => "グラフ",
                     :htmloption => %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"!})
    ]
  PowerLabels =
    [ HtmlLink.new(:id,"",:link => { :link_label => "グラフ", :url => "/shimada/month/graph",
                     :htmloption => %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"!}),
      HtmlLink.new(:id,"",:link => { :link_label => "正規化", :url => "/shimada/month/graph_nomalize",
                     :htmloption => %Q!onClick="window.open('error_disp','graph','width=300,height=300,scrollbars=yes');" target="graph"!}),
      HtmlCeckForSelect.new(:id,""),
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d")
    ] + 
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3)
      }
  def set_instanse_variable
    super
    @Model= Shimada::Month
    @TYTLE = "シマダ:月度データ"
    @labels=Labels
    @AssosiationLabels = PowerLabels
    @TableEdit  = 
      [:csv_up_buttom,
       [:popup,:graph_all_month_nomalized,"全月度正規化",{ :win_name => "graph"}  ] ,
       [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph"} ],
       [:form,:graph_selected_months,"選択月度グラフ",{ :form_notclose => true,:win_name => "graph"}]
      ]
    @Show = true
    @Delete = true
    @FindOption = { :order => "month" }
    @Domain= @Model.name.underscore
    # @Refresh = :kamokus
    @SortBy    = :month
    #@CSVatrs = CSVatrs; @CSVlabels = CSVlabels
  end

  def show ;
    @model = @Model.find(params[:id])
    @models = @model.powers
    @Show = @Edit = @Delete = nil
    @Graph = true
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")
    @TableEdit  =  [[:form,:index,"一覧に戻る"],
                    [:popup,:graph_month_nomalized,"月度正規化",{ :win_name => "graph"} ] ,
                    [:popup,:graph_month,"月度グラフ",{ :win_name => "graph"} ],
                    [:form,:graph_selected,"選択日グラフ",{:win_name => "graph", :form_notclose => true}]
                   ]
    @labels = PowerLabels
    @TableHeaderDouble = [4,[24,"時刻"]]
  end

  def graph
    @power = [Shimada::Power.find(params[:id])]
    Shimada::Power.gnuplot(@power)
    @TYTLE = "消費電力推移" + @power.first.date.strftime("(%Y年%m月%d日)")
    render :layout => "hospital_error_disp"
  end

  def graph_nomalize
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot([@power.normalized(5)],true)
    @TYTLE = "正規化消費電力推移" + @power.date.strftime("(%Y年%m月%d日)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_month_nomalized
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    @power = @Model.find(id).powers
    power = @power.map{ |p| p.normalized(5)}
    Shimada::Power.gnuplot(power,true)
    @TYTLE = "消費電力推移" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph, :layout => "hospital_error_disp"
  end

  def show_gif
    send_file RAILS_ROOT+"/tmp/shimada/power.gif", :type => 'image/gif', :disposition => 'inline'
  end

  def graph_month
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    @power = @Model.find(id).powers
    Shimada::Power.gnuplot(@power)
    @TYTLE = "消費電力推移" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_selected
    ids = params[:check_id].
      delete_if {|key, value| value == "0" }.keys.map(&:to_i)
    @power=Shimada::Power.find(ids)  
    Shimada::Power.gnuplot(@power)
    @TYTLE = "消費電力推移" + 
      @power.first.date.strftime("(%Y年%m月 ") +
      @power.map{ |p| p.date.strftime("%d")}.join(",") + "日)"
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_nomalized
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    power = @power.map{ |p| p.normalized(5)}
    Shimada::Power.gnuplot(power,true)
    @TYTLE = "正規化消費電力推移 全月度" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot(@power)
    @TYTLE = "消費電力推移 全月度" 
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_selected_months
    month_ids = params[:check_id].
      delete_if {|key, value| value == "0" }.keys.map(&:to_i)
    months = Shimada::Month.find(month_ids)
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot(@power)
    @TYTLE = "消費電力推移" + 
      @power.first.date.strftime("(%Y年 ") +
      months.map{ |m| m.powers.first.date.strftime("%m")}.join(",") + "月)"
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_mult(power)
    Shimada::Power.gnuplot(power)
    @TYTLE = "消費電力推移" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def csv_upload
    errors= @Model.csv_upload(params[@Domain][:csvfile])
    redirect_to :action => :index,:layout => "hospital_error_disp"
  end


end
