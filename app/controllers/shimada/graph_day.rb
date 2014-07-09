# -*- coding: utf-8 -*-
module Shimada::GraphDay
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  def graph_sub(method,title,opt={ })
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot([@power],method,opt)
    @TYTLE = title + @power.date.strftime("(%Y年%m月%d日)")
    render  :action => :graph,:layout => "hospital_error_disp"
  end

  def graph         ;    graph_sub(:powers,"消費電力推移") ;  end
  def graph_reviced ;    graph_sub(:revise_by_temp,"温度補正後 消費電力推移",:fitting => true ) ;  end
  def graph_reviced_ave; graph_sub(:revise_by_temp_ave,"補正後平均 消費電力推移") ;  end
  def graph_nomalize   ; graph_sub(:normalized,"正規化消費電力推移",:fitting => true) ;  end
  def graph_difference ; graph_sub(:difference,"差分") ;  end
  def graph_difference_ave ; graph_sub(:difference_ave,"差分平均") ;  end
  def graph_diffdiff ; graph_sub(:diffdiff,"差分差分") ;  end

  def graph_temp    
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot_by_temp([@power])
    @TYTLE = "温度-消費電力" + @power.date.strftime("(%Y年%m月%d日)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
