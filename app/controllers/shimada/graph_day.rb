# -*- coding: utf-8 -*-
module Shimada::GraphDay
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  def graph_sub(method,title,opt={ })
logger.debug("GRAPH_SUB:opt -#{opt}")
    @power = Shimada::PowerModels[@factory.power_model_id].find(params[:id])
    opt[:title] = @TYTLE = title + @power.date.strftime("(%Y年%m月%d日)")
    @PowerModel.gnuplot(@factory_id,[@power],method,opt)

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
    method = params.delete(:method).to_sym
    id     = params[:id].to_i
    
    opt = case method
          when /^revise|^normal/ ; { :fitting => :std_temp }
          else                  ; { }
          end
    opt[:fitting] = params.delete(:fitting).to_sym if params[:fitting]
    opt.merge! params
    graph_sub(method,TITLE_DAY[method],opt)
  end
  def graph_temp    
    @power = @PowerModel.find(params[:id])
    @PowerModel.gnuplot(@factory_id,[@power])
    @TYTLE = "温度-消費電力" + @power.date.strftime("(%Y年%m月%d日)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
