# -*- coding: utf-8 -*-
module Shimada::GraphDay
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 

  # 月別画面でのリンクボタン
  PowerLabels =
    [ HtmlLink.new(:id,"",:link => { :link_label => "グラフ"   , :url => "/shimada/month/graph"            , :htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "温度補正"  ,:url => "/shimada/month/graph_reviced"    , :htmloption => Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "補正後平均",:url => "/shimada/month/graph_reviced_ave", tmloption => Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "対温度"   , :url => "/shimada/month/graph_temp"    , htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "正規化"   , :url => "/shimada/month/graph_nomalize" , :htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "差分"     , :url => "/shimada/month/graph_difference",:htmloption =>Popup}),
      #HtmlCeckForSelect.new(:id,""),
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2),
      HtmlText.new(:shape_is,"形<br>状",:ro => true,:size =>2,:ro => true),
      HtmlText.new(:shape,"形<br>状",:ro => true,:size =>2)
      
    ] + 
    (1..4).map{ |i| HtmlNum.new("na#{i}".to_sym,"na#{i}",:tform => "%.3f")}+
    [HtmlNum.new(:discriminant,"判別式",:size =>2,:tform => "%.6f"),
     HtmlNum.new(:x1,"x1",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:x2,"x2",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:y1,"f3(左)",:size =>2,:tform => "%.3f"),
     HtmlNum.new(:y2,"f3(右)",:size =>2,:tform => "%.3f"),
     HtmlNum.new(:f3x1,"f3x1",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:f3x2,"f3x2",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:f3x3,"f3x3",:size =>2,:tform => "%.1f"),
     
    ]+
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3)
      }
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

  def graph_temp    
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot_by_temp([@power])
    @TYTLE = "温度-消費電力" + @power.date.strftime("(%Y年%m月%d日)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
