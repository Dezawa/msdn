# -*- coding: utf-8 -*-
class Shimada::MonthController <  Shimada::Controller
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"!

  # メイン画面での各月のリンクボタン
  Labels = 
    [#HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month", :link_label => "グラフ",
                    :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_nomalized", :link_label => "正規化", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :link_label => "稼働数"   , :url => "/shimada/month/graph_line_all"   ,:htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :link_label => "稼働変化別",:url => "/shimada/month/graph_month_lines_types"  ,:htmloption => Popup}), 
     HtmlLink.new(:id,"",:link => { :link_label => "稼働F",:url => "/shimada/month/graph_shape_all_F"  ,:htmloption => Popup}), 
     HtmlLink.new(:id,"",:link => { :link_label => "稼働D",:url => "/shimada/month/graph_shape_all_D"  ,:htmloption => Popup}), 
     HtmlLink.new(:id,"",:link => { :link_label => "稼働O",:url => "/shimada/month/graph_shape_all_O"  ,:htmloption => Popup}), 
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference", :link_label => "差分", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference_ave", :link_label => "差分平均", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_diffdiff", :link_label => "二階差", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced", :link_label => "温度補正", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced_ave", :link_label => "温度補正平均", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_temp", :link_label => "対温度", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_ave", :link_label => "平均化", :htmloption => Popup}),
     
    ]
  PowerLabels =
    [ HtmlLink.new(:id,"",:link => { :link_label => "グラフ"   , :url => "/shimada/month/graph"            ,:htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "温度補正"  ,:url => "/shimada/month/graph_reviced"    ,:htmloption => Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "補正後平均",:url => "/shimada/month/graph_reviced_ave",:htmloption => Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "対温度"   , :url => "/shimada/month/graph_temp"    ,  :htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "正規化"   , :url => "/shimada/month/graph_nomalize" , :htmloption =>Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "差分"     , :url => "/shimada/month/graph_difference",:htmloption =>Popup}),
      #HtmlCeckForSelect.new(:id,""),
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2),
      HtmlText.new(:shape_calc,"形<br>状",:ro => true,:size =>2,:ro => true),
      HtmlText.new(:shape,"形<br>状",:ro => true,:size =>2)
      
    ] + 
    (1..4).map{ |i| HtmlNum.new("na#{i}".to_sym,"na#{i}",:tform => "%.3f")}+
    [HtmlNum.new(:discriminant,"判別式",:size =>2,:tform => "%.6f"),
     HtmlNum.new(:x1,"x1",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:x2,"x2",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:y1,"f2(左)",:size =>2,:tform => "%.3f"),
     HtmlNum.new(:y2,"f2(右)",:size =>2,:tform => "%.3f")]+
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3)
      }
  EditOnTable = 
    [ 
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2),
      HtmlText.new(:shape_calc,"形<br>状",:ro => true,:size =>2,:ro => true),
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
      [:csv_up_buttom ,[:form,:reset_reevice_and_ave,"再補正・再平均"]]
    @action_buttoms = 
      [8 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_lines_types,"全月度稼働変化別",{ :win_name => "graph"} ],
        [:popup,"graph_all_month_line3_mm","3line--",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_mp","3line-+",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_m0","3line-0",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_00","3line00",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_F" ,"3lineF" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_O" ,"3lineO" ,{ :win_name => "graph"}],

        [:popup,:graph_all_month_reviced,"全月度温度補正",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_reviced_ave,"全月度温度補正平均化",{ :win_name => "graph"} ],
        [:popup,"graph_all_month_line4_mm","4line--",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_m0","4line-0",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_mp","4line-+",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_00","4line00",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_F" ,"4lineF" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_O" ,"4lineO" ,{ :win_name => "graph"}],

        [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_nomalized,"全月度正規化",{ :win_name => "graph"}  ] ,
        [:popup,"graph_all_month_line0_S" ,"0lineS" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line1_S" ,"1lineS" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line2_00","2line00",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_OT","3line他",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_OT","4line他",{ :win_name => "graph"}],

       #[:popup,:graph_all_month_ave,"全月度平均化",{ :win_name => "graph"}  ] ,
       #[:popup,:graph_all_month_difference_ave,"全月度差分",{ :win_name => "graph"} ],
         #[:popup,"graph_all_month_line5_mm","5line--",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_m0","5line-0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_mp","5line-+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_pm","3line+-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_pm","4line+-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_pm","5line+-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_p0","3line+0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_p0","4line+0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_p0","5line+0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_pp","3line++",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_pp","4line++",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_pp","5line++",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_00","5line00",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_0p","3line0+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_0p","4line0+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_0p","5line0+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_pp","3line0-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_pp","4line0-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_pp","5line0-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_F","4lineF",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_O","5lineO",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_OT","5line他",{ :win_name => "graph"}],

       #[:form,:graph_selected_months,"選択月度グラフ",{ :form_notclose => true,:win_name => "graph"}]
      ]]

    @Show = true
    @Delete = true
    @Domain= @Model.name.underscore
    # @Refresh = :kamokus
    @SortBy    = :month
    #@CSVatrs = CSVatrs; @CSVlabels = CSVlabels
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

  def index
        @FindOption = { :order => "month" }
    super
  end

  def show ;
    @model = @Model.find(params[:id])
    @page = params[:id]
    @models = @model.powers
    @Show = @Edit = @Delete = nil
    @Graph = true
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")
    @TableEdit  =  [[:form,:index,"一覧に戻る"],[:form,:edit_on_table,"編集"],
                    [:popup,:graph_month,"月度グラフ",{ :win_name => "graph"} ],
                    [:popup,:graph_month_reviced,"月度温度補正",{ :win_name => "graph"} ],
                    [:popup,:graph_month_reviced_ave,"月度温度補正平均",{ :win_name => "graph"} ],
                    [:popup,:graph_month_temp,"月度対温度",{ :win_name => "graph"} ],
                    [:popup,:graph_month_lines_types,"月度稼働・型",{ :win_name => "graph"} ],
                    #:popup,:graph_month_difference_ave,"月度差分平均",{ :win_name => "graph"} ],
                    #:popup,:graph_month_difference,"月度差分",{ :win_name => "graph"} ]
                   ]

    @action_buttoms =
      [9,
       [
        [:popup,"graph_line3_mm","3line--",{ :win_name => "graph"}],
        [:popup,"graph_line4_mm","4line--",{ :win_name => "graph"}],
        #[:popup,"graph_line5_mm","5line--",{ :win_name => "graph"}],
        [:popup,"graph_line3_m0","3line-0",{ :win_name => "graph"}],
        [:popup,"graph_line4_m0","4line-0",{ :win_name => "graph"}],
        #[:popup,"graph_line5_m0","5line-0",{ :win_name => "graph"}],
        [:popup,"graph_line3_mp","3line-+",{ :win_name => "graph"}],
        [:popup,"graph_line4_mp","4line-+",{ :win_name => "graph"}],
        #[:popup,"graph_line5_mp","5line-+",{ :win_name => "graph"}],
        #[:popup,"graph_line3_pm","3line+-",{ :win_name => "graph"}],
        #[:popup,"graph_line4_pm","4line+-",{ :win_name => "graph"}],
        #[:popup,"graph_line5_pm","5line+-",{ :win_name => "graph"}],
        #[:popup,"graph_line3_p0","3line+0",{ :win_name => "graph"}],
        #[:popup,"graph_line4_p0","4line+0",{ :win_name => "graph"}],
        #[:popup,"graph_line5_p0","5line+0",{ :win_name => "graph"}],
        #[:popup,"graph_line3_pp","3line++",{ :win_name => "graph"}],
        #[:popup,"graph_line4_pp","4line++",{ :win_name => "graph"}],
        #[:popup,"graph_line5_pp","5line++",{ :win_name => "graph"}],
        [:popup,"graph_line2_00","2line00",{ :win_name => "graph"}],
        [:popup,"graph_line3_00","3line00",{ :win_name => "graph"}],
        [:popup,"graph_line4_00","4line00",{ :win_name => "graph"}],
        #[:popup,"graph_line5_00","5line00",{ :win_name => "graph"}],
        #[:popup,"graph_line3_0p","3line0+",{ :win_name => "graph"}],
        #[:popup,"graph_line4_0p","4line0+",{ :win_name => "graph"}],
        #[:popup,"graph_line5_0p","5line0+",{ :win_name => "graph"}],
        #[:popup,"graph_line3_pp","3line0-",{ :win_name => "graph"}],
        #[:popup,"graph_line4_pp","4line0-",{ :win_name => "graph"}],
        #[:popup,"graph_line5_pp","5line0-",{ :win_name => "graph"}],
        [:popup,"graph_line3_F","3lineF",{ :win_name => "graph"}],
        [:popup,"graph_line4_F","5lineF",{ :win_name => "graph"}],
        #[:popup,"graph_line5_F","4lineF",{ :win_name => "graph"}],
        [:popup,"graph_line3_O","3lineO",{ :win_name => "graph"}],
        [:popup,"graph_line4_O","4lineO",{ :win_name => "graph"}],
        #[:popup,"graph_line5_O","5lineO",{ :win_name => "graph"}],
        [:popup,"graph_line3_OT","3line他",{ :win_name => "graph"}],
        [:popup,"graph_line4_OT","4line他",{ :win_name => "graph"}],
        #[:popup,"graph_line5_OT","5line他",{ :win_name => "graph"}]
       ]
      ]
      #[7,
      # (0..5).map{ |run| [:popup,"graph_line#{run}","#{run}ライン稼働",{ :win_name => "graph"}] } +
      # [[:popup,"graph_line_all","ライン稼働数別",{ :win_name => "graph"}],
      #  [:popup,"graph_shape_all_F","稼働フラット",{ :win_name => "graph"}],
      #  [:popup,"graph_shape_all_D","稼働ダウン",{ :win_name => "graph"}],
      #  [:popup,"graph_shape_all_O","稼働その他",{ :win_name => "graph"}],
      #  [:popup,"graph_shape_all","稼働変化別",{ :win_name => "graph"}]
      # ]
      #]
    @labels = PowerLabels
    @TableHeaderDouble = [7,[9,"係数"],[24,"時刻"]]
  end

  def reset_reevice_and_ave
    Shimada::Power.reset_reevice_and_ave
    redirect_to :action => :index
    #render  :file => 'application/index',:layout => 'application'
  end

  def graph_sub(method,title,opt={ })
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot([@power],method,opt)
    @TYTLE = title + @power.date.strftime("(%Y年%m月%d日)")
    render  :action => :graph,:layout => "hospital_error_disp"
  end
  def graph         ;    graph_sub(:powers,"消費電力推移") ;  end
  def graph_reviced ;    graph_sub(:revise_by_temp,"温度補正後 消費電力推移",:fitting => true) ;  end
  def graph_reviced_ave; graph_sub(:revise_by_temp_ave,"補正後平均 消費電力推移") ;  end
  def graph_nomalize   ; graph_sub(:normalized,"正規化消費電力推移",:fitting => true) ;  end
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
 
  def graph_all_month_reviced ;    graph_all_month_sub(:revise_by_temp, "補正消費電力推移 全月度",:by_month => true) ;  end
  def graph_all_month_reviced_ave ; graph_all_month_sub(:revise_by_temp_ave,"補正消費電力平均化推移 全月度",:by_month => true);end
  def graph_all_month_ave ;    graph_all_month_sub(:move_ave,"平均消費電力推移 全月度",:by_month => true);  end
  def graph_all_month_nomalized ; graph_all_month_sub(:normalized, "正規化消費電力推移 全月度",:by_shape => true);  end
  def graph_all_month            ; graph_all_month_sub(:powers,"消費電力推移 全月度",:by_month => true) ;end
  def graph_all_month_difference_ave           ; graph_all_month_sub(:difference_ave,"差分 全月度",:by_month => true) ;end
  def graph_all_month_lines_types;graph_all_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_line_shape => true ) ;  end


  def graph_line_shape(lines,shape)
    graph_month_sub(:revise_by_temp,"#{lines}line #{shape}",:find => {:lines => lines,:shape_calc => shape}) 
  end

  def graph_all_month_line3_p0;graph_all_month_line_shape( 3,"+0") ;  end
  def graph_all_month_line4_p0;graph_all_month_line_shape( 4,"+0") ;  end
  def graph_all_month_line5_p0;graph_all_month_line_shape( 5,"+0") ;  end
  def graph_all_month_line3_pp;graph_all_month_line_shape( 3,"++") ;  end
  def graph_all_month_line4_pp;graph_all_month_line_shape( 4,"++") ;  end
  def graph_all_month_line5_pp;graph_all_month_line_shape( 5,"++") ;  end
  def graph_all_month_line3_pm;graph_all_month_line_shape( 3,"+-") ;  end
  def graph_all_month_line4_pm;graph_all_month_line_shape( 4,"+-") ;  end
  def graph_all_month_line5_pm;graph_all_month_line_shape( 5,"+-") ;  end
  def graph_all_month_line2_00;graph_all_month_line_shape( 2,"00") ;  end
  def graph_all_month_line3_00;graph_all_month_line_shape( 3,"00") ;  end
  def graph_all_month_line4_00;graph_all_month_line_shape( 4,"00") ;  end
  def graph_all_month_line5_00;graph_all_month_line_shape( 5,"00") ;  end
  def graph_all_month_line3_0m;graph_all_month_line_shape( 3,"0-") ;  end
  def graph_all_month_line4_0m;graph_all_month_line_shape( 4,"0-") ;  end
  def graph_all_month_line5_0m;graph_all_month_line_shape( 5,"0-") ;  end
  def graph_all_month_line3_0p;graph_all_month_line_shape( 3,"0+") ;  end
  def graph_all_month_line4_0p;graph_all_month_line_shape( 4,"0+") ;  end
  def graph_all_month_line5_0p;graph_all_month_line_shape( 5,"0+") ;  end
  def graph_all_month_line3_m0;graph_all_month_line_shape( 3,"-0") ;  end
  def graph_all_month_line4_m0;graph_all_month_line_shape( 4,"-0") ;  end
  def graph_all_month_line5_m0;graph_all_month_line_shape( 5,"-0") ;  end
  def graph_all_month_line3_mm;graph_all_month_line_shape( 3,"--") ;  end
  def graph_all_month_line4_mm;graph_all_month_line_shape( 4,"--") ;  end
  def graph_all_month_line5_mm;graph_all_month_line_shape( 5,"--") ;  end
  def graph_all_month_line3_mp;graph_all_month_line_shape( 3,"-+") ;  end
  def graph_all_month_line4_mp;graph_all_month_line_shape( 4,"-+") ;  end
  def graph_all_month_line5_mp;graph_all_month_line_shape( 5,"-+") ;  end
  def graph_all_month_line3_F;graph_all_month_line_shape( 3,"F") ;  end
  def graph_all_month_line4_F;graph_all_month_line_shape( 4,"F") ;  end
  def graph_all_month_line5_F;graph_all_month_line_shape( 5,"F") ;  end
  def graph_all_month_line3_O;graph_all_month_line_shape( 3,"O") ;  end
  def graph_all_month_line4_O;graph_all_month_line_shape( 4,"O") ;  end
  def graph_all_month_line5_O;graph_all_month_line_shape( 5,"O") ;  end
  def graph_all_month_line0_S;graph_all_month_line_shape( 0,"S") ;  end
  def graph_all_month_line1_S;graph_all_month_line_shape( 1,"S") ;  end
  def graph_all_month_line3_OT;graph_all_month_line_shape( 3,"他") ;  end
  def graph_all_month_line4_OT;graph_all_month_line_shape( 4,"他") ;  end
  def graph_all_month_line5_OT;graph_all_month_line_shape( 5,"他") ;  end

  def graph_all_month_line_shape(lines,shape)
    graph_all_month_sub(:revise_by_temp,"#{lines}line #{shape}",:find => {:lines => lines,:shape_calc => shape}) 
  end
  def graph_all_month_sub(method,title,opt={ })
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    @power = select_by_( @power,opt[:find]) if  opt[:find] 
Shimada::Power.gnuplot(@power,method,opt)
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  ###
  def graph_month_sub(method,title,opt={ })
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    month =  @Model.find(id)
    #@power = opt[:find] ? send(opt[:find].first,month, opt[:find].last)  : month.powers
    @power = opt[:find] ? select_by_(month.powers,opt[:find])  : month.powers
    @TYTLE = title + month.month.strftime("(%Y年%m月)")
    Shimada::Power.gnuplot(@power,method,opt)
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_line_shape(lines,shape)
    graph_month_sub(:revise_by_temp,"#{lines}line #{shape}",:find => {:lines => lines,:shape_calc => shape}) 
  end
  def graph_line3_p0;graph_line_shape( 3,"+0") ;  end
  def graph_line4_p0;graph_line_shape( 4,"+0") ;  end
  def graph_line5_p0;graph_line_shape( 5,"+0") ;  end
  def graph_line3_pp;graph_line_shape( 3,"++") ;  end
  def graph_line4_pp;graph_line_shape( 4,"++") ;  end
  def graph_line5_pp;graph_line_shape( 5,"++") ;  end
  def graph_line3_pm;graph_line_shape( 3,"+-") ;  end
  def graph_line4_pm;graph_line_shape( 4,"+-") ;  end
  def graph_line5_pm;graph_line_shape( 5,"+-") ;  end
  def graph_line2_00;graph_line_shape( 2,"00") ;  end
  def graph_line3_00;graph_line_shape( 3,"00") ;  end
  def graph_line4_00;graph_line_shape( 4,"00") ;  end
  def graph_line5_00;graph_line_shape( 5,"00") ;  end
  def graph_line3_0m;graph_line_shape( 3,"0-") ;  end
  def graph_line4_0m;graph_line_shape( 4,"0-") ;  end
  def graph_line5_0m;graph_line_shape( 5,"0-") ;  end
  def graph_line3_0p;graph_line_shape( 3,"0+") ;  end
  def graph_line4_0p;graph_line_shape( 4,"0+") ;  end
  def graph_line5_0p;graph_line_shape( 5,"0+") ;  end
  def graph_line3_m0;graph_line_shape( 3,"-0") ;  end
  def graph_line4_m0;graph_line_shape( 4,"-0") ;  end
  def graph_line5_m0;graph_line_shape( 5,"-0") ;  end
  def graph_line3_mm;graph_line_shape( 3,"--") ;  end
  def graph_line4_mm;graph_line_shape( 4,"--") ;  end
  def graph_line5_mm;graph_line_shape( 5,"--") ;  end
  def graph_line3_mp;graph_line_shape( 3,"-+") ;  end
  def graph_line4_mp;graph_line_shape( 4,"-+") ;  end
  def graph_line5_mp;graph_line_shape( 5,"-+") ;  end
  def graph_line3_F;graph_line_shape( 3,"F") ;  end
  def graph_line4_F;graph_line_shape( 4,"F") ;  end
  def graph_line5_F;graph_line_shape( 5,"F") ;  end
  def graph_line3_O;graph_line_shape( 3,"O") ;  end
  def graph_line4_O;graph_line_shape( 4,"O") ;  end
  def graph_line5_O;graph_line_shape( 5,"O") ;  end
  def graph_line3_OT;graph_line_shape( 3,"他") ;  end
  def graph_line4_OT;graph_line_shape( 4,"他") ;  end
  def graph_line5_OT;graph_line_shape( 5,"他") ;  end


  def graph_month         ;graph_month_sub(:powers,"消費電力推移") ; end
  def graph_month_reviced ;graph_month_sub(:revise_by_temp,"補正消費電力推移") ; end
  def graph_month_reviced_ave ;graph_month_sub(:revise_by_temp_ave,"補正平均消費電力推移") ; end
  def graph_month_nomalized ;graph_month_sub(:normalized,"正規化消費電力推移",:by_shape => true) ; end
  def graph_month_ave   ;graph_month_sub(:move_ave,"平均消費電力推移") ; end
  def graph_month_difference   ;graph_month_sub(:difference,"月度差分",:by_shape => true) ; end
  def graph_month_difference_ave   ;graph_month_sub(:difference_ave,"月度差分平均",:by_shape => true) ; end
  def graph_month_diffdiff   ;graph_month_sub(:diffdiff,"月度二階差",:by_shape => true) ; end
  def graph_line0       ; graph_month_sub(:revise_by_temp_ave,"稼働０ライン",:find => {:lines => 0}) ;  end
  def graph_line1       ; graph_month_sub(:revise_by_temp_ave,"稼働１ライン",:find => {:lines => 1}) ;  end
  def graph_line2       ; graph_month_sub(:revise_by_temp_ave,"稼働２ライン",:find => {:lines => 2}) ;  end
  def graph_line3       ; graph_month_sub(:revise_by_temp_ave,"稼働３ライン",:find => {:lines => 3}) ;  end
  def graph_line4       ; graph_month_sub(:revise_by_temp_ave,"稼働４ライン",:find => {:lines => 4}) ;  end
  def graph_line5       ; graph_month_sub(:revise_by_temp_ave,"稼働５ライン",:find => {:lines => 5}) ;  end
  def graph_line_all    ; graph_month_sub(:revise_by_temp_ave,"稼働５ライン",:by_line => true ) ;  end
  def graph_month_lines_types;graph_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_line_shape => true ) ;  end
  def graph_shape_all_F ; graph_month_sub(:revise_by_temp_ave,"稼働F",:find => {:shape => "Flat"} ) ;  end
  def graph_shape_all_D ; graph_month_sub(:revise_by_temp_ave,"稼働D"  ,:find => {:shape => "Reduce"});end
  def graph_shape_all_O ; graph_month_sub(:revise_by_temp_ave,"稼働O"  ,:find => {:shape => "Other"} ) ;  end
  def graph_shape_all   ; graph_month_sub(:revise_by_temp_ave,"稼働変化別",:by_shape => true ) ;  end

  def select_by_(powers,find_conditions)
    find_conditions.to_a.inject(powers){ |p,sym_v| 
      sym,v = sym_v
      p.select{ |pw| pw.send(sym) == v }
    }
  end

  def line_num(month, run) ;  month.powers.select{ |p| p.lines == run } ;  end
  def shape(month, run)    ;  month.powers.select{ |p| p.shape == run } ;  end

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
