# -*- coding: utf-8 -*-
module Shimada::GraphDay
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  def graph_sub(method,title,opt={ })
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot([@power],method,opt)
    @TYTLE = title + @power.date.strftime("(%Y年%m月%d日)")
    render  :action => :graph,:layout => "hospital_error_disp"
  end

  TITLE_DAY = 
    { 
    :powers_3 => "消費電力推移 " ,
    :revise_by_temp_3 => "温度補正後 消費電力推移 " ,
    :revise_by_vaper_3 => "蒸気圧補正後 消費電力推移 " ,
    :revise_by_temp_ave => "補正後平均 消費電力推移 " ,
    :normalized => "正規化消費電力推移 " ,
    :difference_3 => "差分 " ,
    :difference_ave => "差分平均 " ,
    :diffdiff_3 => "差分差分 " ,

  }
  def graph  
    method,id = params[:method].split("/")
    
    opt = case method
          when /^revise|^normal/ ; { :fitting => :std_temp }
          else                  ; { }
          end
    opt[:fitting] = params[:fitting].to_sym if params[:fitting]
    method = method.to_sym
     params[:id] = id.to_i
    graph_sub(method,TITLE_DAY[method],opt)
  end
  def graph_temp    
    @power = Shimada::Power.find(params[:id])
    Shimada::Power.gnuplot([@power])
    @TYTLE = "温度-消費電力" + @power.date.strftime("(%Y年%m月%d日)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
