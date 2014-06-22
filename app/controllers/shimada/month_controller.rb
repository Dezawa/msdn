# -*- coding: utf-8 -*-
class Shimada::MonthController <  Shimada::Controller
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"!

  Labels = 
    [HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month", :link_label => "グラフ",
                    :htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "稼働数"   , :url => "/shimada/month/graph_line_all"   ,:htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced", :link_label => "温度補正",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced_ave", :link_label => "温度補正平均",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_temp", :link_label => "対温度",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_ave", :link_label => "平均化",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_nomalized", :link_label => "正規化",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference", :link_label => "差分",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference_ave", :link_label => "差分平均",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_diffdiff", :link_label => "二階差",
                    :htmloption => Popup})
     
    ]
  PowerLabels =
    [ HtmlLink.new(:id,"",:link => { :link_label => "グラフ"   , :url => "/shimada/month/graph"            ,:htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "温度補正"  ,:url => "/shimada/month/graph_reviced"    ,:htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "補正後平均",:url => "/shimada/month/graph_reviced_ave",:htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "対温度"   , :url => "/shimada/month/graph_temp"    ,  :htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "正規化"   , :url => "/shimada/month/graph_nomalize" , :htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "差分"     , :url => "/shimada/month/graph_difference",:htmloption =>Popup}),
      HtmlCeckForSelect.new(:id,""),
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2)
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
      [:csv_up_buttom ,[:form,:reset_reevice_and_ave,"再補正・再平均"]]
    @action_buttoms = [4,[
       [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph"} ],
       [:popup,:graph_all_month_nomalized,"全月度正規化",{ :win_name => "graph"}  ] ,
       [:popup,:graph_all_month_ave,"全月度平均化",{ :win_name => "graph"}  ] ,
       [:popup,:graph_all_month_reviced,"全月度温度補正",{ :win_name => "graph"} ],
       [:popup,:graph_all_month_reviced_ave,"全月度温度補正平均化",{ :win_name => "graph"} ],
       [:popup,:graph_all_month_difference,"全月度差分",{ :win_name => "graph"} ],
       [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
       [:form,:graph_selected_months,"選択月度グラフ",{ :form_notclose => true,:win_name => "graph"}]
      ]]

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
                    [:popup,:graph_month,"月度グラフ",{ :win_name => "graph"} ],
                    [:popup,:graph_month_reviced,"月度温度補正",{ :win_name => "graph"} ],
                    [:popup,:graph_month_reviced_ave,"月度温度補正平均",{ :win_name => "graph"} ],
                    [:popup,:graph_month_temp,"月度対温度",{ :win_name => "graph"} ],
                    [:popup,:graph_month_difference,"月度差分",{ :win_name => "graph"} ]
                   ]

    @action_buttoms =
      [7,
       (0..5).map{ |run| [:popup,"graph_line#{run}","#{run}ライン稼働",{ :win_name => "graph"}] }<<
       [:popup,"graph_line_all","ライン稼働別",{ :win_name => "graph"}]
      ]
    @labels = PowerLabels
    @TableHeaderDouble = [9,[24,"時刻"]]
  end

  def reset_reevice_and_ave
    Shimada::Power.reset_reevice_and_ave
    redirect_to :action => :index
    #render  :file => 'application/index',:layout => 'application'
  end

  def graph_sub(method,title)
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot([@power],method)
    @TYTLE = title + @power.date.strftime("(%Y年%m月%d日)")
    render  :action => :graph,:layout => "hospital_error_disp"
  end
  def graph         ;    graph_sub(:powers,"消費電力推移") ;  end
  def graph_reviced ;    graph_sub(:revise_by_temp,"温度補正後 消費電力推移") ;  end
  def graph_reviced_ave; graph_sub(:revise_by_temp_ave,"補正後平均 消費電力推移") ;  end
  def graph_nomalize   ; graph_sub(:normalized,"正規化消費電力推移") ;  end
  def graph_nomalize   ; graph_sub(:normalized,"正規化消費電力推移") ;  end
  def graph_difference ; graph_sub(:difference,"差分") ;  end

  def graph_selected
    ids = params[:check_id].
      delete_if {|key, value| value == "0" }.keys.map(&:to_i)
    @power=Shimada::Power.find(ids)  
    Shimada::Power.gnuplot(@power,:powers)
    @TYTLE = "消費電力推移" + 
      @power.first.date.strftime("(%Y年%m月 ") +
      @power.map{ |p| p.date.strftime("%d")}.join(",") + "日)"
    render :action => :graph,:layout => "hospital_error_disp"
  end

 
  def graph_all_month_reviced ;    graph_all_month_sub(:revise_by_temp, "補正消費電力推移 全月度") ;  end
  def graph_all_month_reviced_ave ; graph_all_month_sub(:revise_by_temp_ave,"補正消費電力平均化推移 全月度");end
  def graph_all_month_ave ;    graph_all_month_sub(:move_ave,"平均消費電力推移 全月度");  end
  def graph_all_month_nomalized ; graph_all_month_sub(:normalized, "正規化消費電力推移 全月度");  end
  def graph_all_month            ; graph_all_month_sub(:powers,"消費電力推移 全月度") ;end
  def graph_all_month_difference           ; graph_all_month_sub(:difference,"差分 全月度") ;end
  def graph_all_month_sub(method,title)
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot(@power,method,:by_month => true)
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  ###
  def graph_month_sub(method,title,opt={ })
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    month =  @Model.find(id)
    @power = opt[:find] ? send(opt[:find].first,month, opt[:find].last)  : month.powers
    @TYTLE = title + month.month.strftime("(%Y年%m月)")
    Shimada::Power.gnuplot(@power,method,opt)
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_month         ;graph_month_sub(:powers,"消費電力推移") ; end
  def graph_month_reviced ;graph_month_sub(:revise_by_temp,"補正消費電力推移") ; end
  def graph_month_reviced_ave ;graph_month_sub(:revise_by_temp_ave,"補正平均消費電力推移") ; end
  def graph_month_nomalized ;graph_month_sub(:normalized,"正規化消費電力推移") ; end
  def graph_month_ave   ;graph_month_sub(:move_ave,"平均消費電力推移") ; end
  def graph_month_difference   ;graph_month_sub(:difference,"月度差分") ; end
  def graph_month_difference_ave   ;graph_month_sub(:difference_ave,"月度差分") ; end
  def graph_month_diffdiff   ;graph_month_sub(:diffdiff,"月度二階差") ; end
  def graph_line0       ; graph_month_sub(:revise_by_temp_ave,"稼働０ライン",:find => [:line_num,0]) ;  end
  def graph_line1       ; graph_month_sub(:revise_by_temp_ave,"稼働１ライン",:find => [:line_num,1]) ;  end
  def graph_line2       ; graph_month_sub(:revise_by_temp_ave,"稼働２ライン",:find => [:line_num,2]) ;  end
  def graph_line3       ; graph_month_sub(:revise_by_temp_ave,"稼働３ライン",:find => [:line_num,3]) ;  end
  def graph_line4       ; graph_month_sub(:revise_by_temp_ave,"稼働４ライン",:find => [:line_num,4]) ;  end
  def graph_line5       ; graph_month_sub(:revise_by_temp_ave,"稼働５ライン",:find => [:line_num,5]) ;  end
  def graph_line_all    ; graph_month_sub(:revise_by_temp_ave,"稼働５ライン",:by_line => true ) ;  end

  def line_num(month, run)
    month.powers.select{ |p| p.lines == run }
  end

  def graph_temp    
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot_by_temp([@power])
    @TYTLE = "温度-消費電力" + @power.date.strftime("(%Y年%m月%d日)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_month_temp
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    @power = @Model.find(id).powers
    Shimada::Power.gnuplot_by_temp(@power)
    @TYTLE = "温度-消費電力" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_temp
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot_by_temp(@power,:by_month => true,:with_Approximation => true)
    @TYTLE = "温度-消費電力 全月度"
    render :action => :graph,:layout => "hospital_error_disp"
  end


  def graph_selected_months
    month_ids = params[:check_id].
      delete_if {|key, value| value == "0" }.keys.map(&:to_i)
    months = Shimada::Month.find(month_ids)
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot(@power.map(&:powers))
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


  def show_gif
    send_file RAILS_ROOT+"/tmp/shimada/power.gif", :type => 'image/gif', :disposition => 'inline'
  end

  def csv_upload
    errors= @Model.csv_upload(params[@Domain][:csvfile])
    redirect_to :action => :index,:layout => "hospital_error_disp"
  end


end
