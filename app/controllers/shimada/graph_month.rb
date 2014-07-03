# -*- coding: utf-8 -*-
module  Shimada::GraphMonth
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 

  # メイン画面での各月のリンクボタン
  Labels = 
    [#HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month", :link_label => "グラフ", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_nomalized",:link_label => "正規化", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced", :link_label => "温度補正",  :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced_ave",:link_label => "温度補正平均",:htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_temp", :link_label => "対温度", :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働数"   , :url => "/shimada/month/graph_line_all"   , :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働変化別",:url => "/shimada/month/graph_month_lines_types",:htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働F",:url => "/shimada/month/graph_shape_all_F"  , :htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働D",:url => "/shimada/month/graph_shape_all_D"  , :htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働O",:url => "/shimada/month/graph_shape_all_O"  , :htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference", :link_label => "差分",  :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference_ave", :link_label => "差分平均",:htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_diffdiff", :link_label => "二階差", :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_ave", :link_label => "平均化",  :htmloption => Popup}),
    ]

    Month_action_buttoms =
      [12,
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
    graph_month_sub(:revise_by_temp,"#{lines}line #{shape}",:by_month => true,
                    :find => {:lines => lines,:shape_is => shape}) 
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
  def graph_month_temp
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    @power = @Model.find(id).powers
    Shimada::Power.gnuplot_by_temp(@power)
    @TYTLE = "温度-消費電力" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
