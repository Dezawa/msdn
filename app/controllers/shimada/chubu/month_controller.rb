# -*- coding: utf-8 -*-
class Shimada::Chubu::MonthController <   Shimada::MonthController
  include Shimada::Chubu::Analyze

  AllMonthOpt ={ "power" =>  { :by_date => "%Y",:data_file_labels => nil,:x_method => :hours},
    
    "temp-power" => { :by_date => "%Y",
      :set_key => "set key outside  autotitle columnheader samplen 1 width 0",
      :fitting => :temp_vs_power
    },
    "revise_temp" => {:by_date => "%Y"},
    "vaper-power" => { :by_date => "%Y"},
  }

  GraphOpt =
    {
    "hour10" =>  { "method" => :powers, :x_method => :day_of_year,:by_date => "%Y",
      :hour_range => [0,1],:xrange => "[0:367]", :tics => "set xtics 1,30,365 ",
      :xlabel => "xl '年初からの経過日数'",:grid => "set grid ytics"
      # :data_file_labels => ""
    },
  }


  def action_buttoms_analize
    [# Action_buttoms,
     #AllMonthaction_buttomss,         # 全月度グラフ ....
     #AllMonthaction_buttomsPaterns,  # パターン分析結果
     #AllMonthaction_buttomsPaternsByVaper,  # パターン分析結果
     #AllMonthaction_buttomsPaternsByMonth,  # パターン分析結果
     #AllMonthaction_buttomsDeform,   # 異常パターン
     #AllMonthaction_buttoms3,        # 数、型指定しての、グラフなど
     #AllMonthaction_buttoms2         # 
    ]
  end

  def graph_all_days
    para = params[@Domain]
    option = "hour10" #para.delete(:option) || para.delete("option") 
    para.keys.each{ |k| para[k.to_sym] = para[k] if k.class == String}
    logger.debug("GRAPH_ALL_MONTH: para = #{para.to_a.flatten.join(', ')}")
    opt = GraphOpt[option].merge(AllMonthOpt[option]||{ }).merge(para)
    logger.debug("GRAPH_ALL_MONTH: opt = #{opt.to_a.flatten.join(', ')}:year #{ opt[:year]},year#{opt["year"]}")
    title(opt)    
    opt[:graph_file] = opt[:title] unless  opt[:graph_file]
    @graph_file = opt[:graph_file] || "graph"
    opt[:factory_id] = @factory_id
    if option == "by_days_hour"
      @Model.monthly_by_days_hour(opt)
    else
      @Model.monthly_graph(opt)
    end
    @url =  @Domain+"/show_jpeg"
    render :file => 'power/month/graph'
 # @TYTLE = title
 # render :action => :graph,:layout => "hospital_error_disp"   
  end

  def title(opt)
    opt[:title] ||= params["commit"]
    opt[:title] += "-#{opt["year"]}年" if opt["year"]
    opt[:title] += "-#{opt["night"]}" if opt["night"]
    opt[:title] += "（平日）" if opt["select"] == "line==2"
    opt[:title] += "（#{@factory.name}工場)"
    
  end

  def monthly_graph(opt = { } )
    objects = target_powers(opt)
    opt[:set_key] ||= "set key outside  autotitle columnheader samplen 1 width 0"
    graph_scatter(objects,opt)
  end
  def monthly_scatter(opt = { } )
    objects = self.powers
    graph_scatter(objects,opt)
  end

end
