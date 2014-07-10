# -*- coding: utf-8 -*-
class Shimada::MonthController <  Shimada::Controller
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 

  include Shimada::GraphDay
  include Shimada::GraphMonth
  include Shimada::GraphAllMonth



  EditOnTable = 
    [ 
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2),
      HtmlText.new(:shape_is,"形<br>状",:ro => true,:size =>2,:ro => true),
      HtmlText.new(:shape,"形<br>状",:size =>2)
      
    ] + 
    (0..6).map{ |i| HtmlNum.new("na#{i}".to_sym,"na#{i}",:tform => "%.3f",:ro => true)}+
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3,:ro => true)
      }
  def set_instanse_variable
    super
    @Model= Shimada::Month
    @TYTLE = "シマダ:月度データ"
    @labels=Labels
    @AssosiationLabels = PowerLabels
    @TableEdit  = 
      [:csv_up_buttom ,[:form,:reset_reevice_and_ave,"再補正・再平均"],
       [:form,:reculc_all,"再計算"],
       [:form,:reculc_shapes,"再分類"],
       [:form,:rm_gif,"グラフ再作成"]
      ]
    @action_buttoms = AllMonthaction_buttoms
    @action_buttoms3 = AllMonthaction_buttoms3
    @action_buttoms2 = AllMonthaction_buttoms2

    @Show = true
    @Delete = true
    @Domain= @Model.name.underscore
    # @Refresh = :kamokus
    @SortBy    = :month
    #@CSVatrs = CSVatrs; @CSVlabels = CSVlabels
  end

  def index
        @FindOption = { :order => "month" }
    super
  end

  def show ;
    @model = @Model.find(params[:id])
    @page = params[:id]
    @models = @model.powers
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")

    @TableEdit  =  [[:form,:index,"一覧に戻る"],[:form,:edit_on_table,"編集"],
                    [:popup,:graph_month,"月度グラフ",{ :win_name => "graph"} ],
                    [:popup,:graph_month_reviced,"月度温度補正",{ :win_name => "graph"} ],
                    [:popup,:graph_month_reviced_ave,"月度温度補正平均",{ :win_name => "graph"} ],
                    [:popup,:graph_month_temp,"月度対温度",{ :win_name => "graph"} ],
                    [:popup,:graph_month_lines_types,"月度稼働・型",{ :win_name => "graph"} ],
                    #:popup,:graph_month_difference_ave,"月度差分平均",{ :win_name => "graph"} ],
                    [:popup,:graph_month_difference,"月度差分",{ :win_name => "graph"} ]
                   ]

    @action_buttoms = Month_action_buttoms
    show_sub
  end
 
  def show_sub
    @Show = @Edit = @Delete = nil
    @Graph = true
    @labels = PowerLabels
    @TableHeaderDouble = [10,[13,"係数"],[24,"時刻"]]
    render :action => :show
  end

  def edit_on_table
    @labels = EditOnTable
    @model = @Model.find(params[:page])
    @models = @model.powers
    render  :file => 'application/edit_on_table',:layout => 'application'
  end

  def update_on_table
    @Model = Shimada::Power
    super
  end

  def reset_reevice_and_ave
    Shimada::Power.reset_reevice_and_ave
    redirect_to :action => :index
  end

  def rm_gif 
    Shimada::Power.rm_gif
    redirect_to :action => :index
  end


  def reculc_all
    Shimada::Power.reculc_all
    redirect_to :action => :index
    #render  :file => 'application/index',:layout => 'application'
  end

  def reculc_shapes
    Shimada::Power.reculc_shapes
    redirect_to :action => :index
    #render  :file => 'application/index',:layout => 'application'
  end

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

  def select_by_(powers,find_conditions)
    find_conditions.to_a.inject(powers){ |p,sym_v| 
      sym,v = sym_v
      p.select{ |pw| pw.send(sym) == v }
    }
  end

  def line_num(month, run) ;  month.powers.select{ |p| p.lines == run } ;  end
  def shape(month, run)    ;  month.powers.select{ |p| p.shape == run } ;  end


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
    graph_file = params[:graph_file].blank? ? "power" : params[:graph_file]
    send_file RAILS_ROOT+"/tmp/shimada/#{graph_file}.gif", :type => 'image/gif', :disposition => 'inline'
  end

  def csv_upload
    errors= @Model.csv_upload(params[@Domain][:csvfile])
    redirect_to :action => :index,:layout => "hospital_error_disp"
  end


end
