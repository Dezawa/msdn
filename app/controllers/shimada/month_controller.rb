# -*- coding: utf-8 -*-
class Shimada::MonthController <  Shimada::Controller
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 

  include Shimada::Analyze

  URL_GRAPH0 = "/shimada/month/graph?fitting=standerd&method="
  URL_GRAPH1 = "/shimada/month/graph?fitting=std_temp&method="
  Labels_for_month_results = 
    [
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}powers_3", :link_label => "グラフ",:fitting => :standerd}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}revise_by_temp_3", :link_label => "温度補正",:fitting => :standerd}.merge(POPUP)),
    ]

   Action_buttoms_for_month_results = 
      [5 ,
       AllMonthaction_buttomsPaterns[1] +
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph",:method => :powers_3} ],
        [:popup,:graph_all_month,"全月度温度補正",{ :win_name => "graph",:method => :revise_by_temp_3} ],
       ]
      ]
  DaylyLabels =
    [
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
     HtmlLink.new(:id,"",:link => { :link_label => "グラフ"   , :url => URL_GRAPH1+"powers_3"   , :htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "温度補正"  ,:url => URL_GRAPH0+"revise_by_temp_3",:htmloption => Popup }),
      #HtmlCeckForSelect.new(:id,""),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2),
      HtmlText.new(:shape_is,"形<br>状",:ro => true,:size =>2,:ro => true),
      HtmlText.new(:deform,"変形",:ro => true,:size =>4)
      
    ] + 
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3)
      }

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
    @TYTLE = "シマダヤ:月度データ"
    @labels = Labels_for_month_results
    @AssosiationLabels = PowerLabels
    @TableEdit  = 
      [
       [:form,:factory,"戻る"] # ,{ :controller => "shimada"}]
      ]
    @action_buttoms = Action_buttoms_for_month_results
    @action_buttoms_analize =[# Action_buttoms,
                               AllMonthaction_buttoms,         # 全月度グラフ ....
                               AllMonthaction_buttomsPaterns,  # パターン分析結果
                               AllMonthaction_buttomsDeform,   # 異常パターン
                               AllMonthaction_buttoms3,        # 数、型指定しての、グラフなど
                               AllMonthaction_buttoms2         # 
                               
                             ]

        @FindOption = { :order => "month desc" }

    #@Delete = true
    @Domain= @Model.name.underscore
    # @Refresh = :kamokus
    @SortBy    = :month
    #@CSVatrs = CSVatrs; @CSVlabels = CSVlabels
  end
  def factory
    redirect_to :controller => "shimada/factory",:action => :index
  end


  def index
    #factory = Shimada::Factory.find(params[:id])
     @Show = true
     @page = params[:page] || 1 
    find_and
    render  :file => 'application/index',:layout => 'application'
  end


  def show ;
    @model = @Model.find(params[:id])
    @page = params[:id]
    @models = @model.powers
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")

    @TableEdit  =  [[:form,:index,"一覧に戻る"],[:form,:edit_on_table,"編集"],
                    [:popup,:graph_month,"月度グラフ",{ :win_name => "graph",:method => :powers_3} ],
                    [:popup,:graph_month,"月度温度補正",{ :win_name => "graph",:method => :revise_by_temp_3} ],
                   ]

    @action_buttoms = nil; #Month_action_buttoms
    @labels = DaylyLabels
    @TableHeaderDouble = [6,[24,"時刻"]]
    show_sub
  end
    def show_sub
    @Show = @Edit = @Delete = nil
    @Graph = true
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


  def line_num(month, run) ;  month.powers.select{ |p| p.lines == run } ;  end
  def shape(month, run)    ;  month.powers.select{ |p| p.shape == run } ;  end

  def show_gif
    graph_file = params[:graph_file].blank? ? "power" : params[:graph_file]
    send_file RAILS_ROOT+"/tmp/shimada/giffiles/#{graph_file}.gif", :type => 'image/gif', :disposition => 'inline'
  end

end
