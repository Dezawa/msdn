# -*- coding: utf-8 -*-
module  Power::GraphMonthly # controller
  AllMonthOpt ={ "power" =>  { :by_date => "%Y",:data_file_labels => nil,:x_method => :hours},
                       
    "temp-power" => { :by_date => "%Y",
      :set_key => "set key outside  autotitle columnheader samplen 1 width 0",
      :fitting => :temp_vs_power
    },
    "revise_temp" => {:by_date => "%Y"},
    "vaper-power" => { :by_date => "%Y"},
  }
                     
  GraphOpt =
    { "power" => {"method" => :powers, #:data_file_labels => "時刻 電力",
                  :title  => "消費電力",:with => "line",
      :set_key => "set key outside  autotitle columnheader samplen 1 width 0",
      :by_date => "%a", 
    },
    "revise_temp" => { "method" => :revise_by_temp , :x_method => :hours,
      :by_date => "%a", 
      :title  => "温度補正電力",:with => "line",
      :set_key => "set key outside  autotitle columnheader samplen 1 width 0",
    }, 
    "temp-power" => { "method" => :powers , :title => "気温と消費電力",:pt => 6,
      :xlabel => "xl '気温'",:ylabel => "yl '消費電力'" ,
      :hour_range => [0,1,2,3,4,5,8,9,10,11,12,13,14,15],
      :by_date => "%a", 
      :tics => "set xtics -10,10",
      :x_method => :temps,:xrange => "[-10:40]"
    }, 
    "vaper-power" => { "method" => :revise_by_temp , :title => "蒸気圧と温度補正電力",:pt => 6,
      :xlabel => "xl '蒸気圧/hPa'",:ylabel => "yl '温度補正電力'" ,
      :hour_range => (7..15) ,:by_date => "%a", 
      :tics => "set xtics 0,10",
      :x_method => :vapers,:xrange => "[0:40]"
    },
    "vaper-temp-revs" => { "method" => :revise_by_temp , :title => "蒸気圧と温度補正電力",:pt => 6,
      :xlabel => "xl '蒸気圧/hPa'",:ylabel => "yl '温度補正電力'" ,
      :hour_range => (7..15) ,:by_date => "%a", 
      :tics => "set xtics 0,10",
      :x_method => :vapers,:xrange => "[0:40]"
    },
    "hour10" => { "method" => :revise_by_temp, :x_method => :day_of_year,:by_date => "%Y",
      :hour_range => [9],:xrange => "[0:367]", :tics => "set xtics 1,30,365 ",
      :xlabel => "xl '年初からの経過日数'",
      # :data_file_labels => ""
    }, 
    "temp-power" => { "method" => :powers , :title => "気温と消費電力",:pt => 6,
      :xlabel => "xl '気温'",:ylabel => "yl '消費電力'" ,
      :hour_range => [0,1,2,3,4,5,8,9,10,11,12,13,14,15],
      :by_date => "%a", 
      :tics => "set xtics -10,10",
      :x_method => :temps,:xrange => "[-10:40]"
    },
    "by_days_hour" => { "method" => :revise_by_temp, #:x_method => :by_hour,
     #:xrange => "[90:212]", ][
     :yrange => "[100:800]",
      #:xlabel => "xl '年初からの経過日数'",
      # :data_file_labels => ""
    }, 
  }
  def title(opt)
    opt[:title] ||= params["commit"]
    opt[:title] += "-#{opt["year"]}年" if opt["year"]
    opt[:title] += "-#{opt["night"]}" if opt["night"]
  end
  def graph_all_month
    para = params[@Domain]
    option = para.delete(:option) || para.delete("option") 
    para.keys.each{ |k| para[k.to_sym] = para[k] if k.class == String}
logger.debug("GRAPH_ALL_MONTH: para = #{para.to_a.flatten.join(', ')}")
    opt = GraphOpt[option].merge(AllMonthOpt[option]||{ }).merge(para)
logger.debug("GRAPH_ALL_MONTH: opt = #{opt.to_a.flatten.join(', ')}:year #{ opt[:year]},year#{opt["year"]}")
    title(opt)    
    opt[:graph_file] = opt[:title] unless  opt[:graph_file]
    @graph_file = opt[:graph_file] || "graph"

    if option == "by_days_hour"
      @Model.monthly_by_days_hour(opt)
    else
      @Model.monthly_graph(opt)
    end
    @url =  @Domain+"/show_jpeg"
    render :file => 'power/month/graph'
  end

  def monthly_graph
    month = @Model.find(params["id"].to_i)
    opt = GraphOpt[params[:option]]
    opt[:title] = month.month.strftime(opt[:title]+"-%Y-%m")
    opt[:graph_file] = opt[:title] unless  opt[:graph_file]
    @graph_file = opt[:graph_file] || "graph"
    month.monthly_graph(opt)
    @url =  @Domain+"/show_jpeg"
    render :file => 'power/month/graph'
  end

  ScatterOpt =
    { "temp-power" => { "method" => :powers , :title => "気温と消費電力",:pt => 6,
                        :xlabel => "xl '気温'",:ylabel => "yl '消費電力'" ,
                        :hour_range => [0,1,2,3,4,5,8,9,10,11,12,13,14,15],
      :by_date => "%a", 
      :set_key => "set key outside  autotitle columnheader samplen 1 width 0",
                        :x_method => :temps,:xrange => "[-10:40]",
      :tics => "set xtics -10,10",
                        }
  }
  def monthly_scatter
    month = @Model.find(params["id"].to_i)
    opt = ScatterOpt[params[:option]] || GraphOpt[params[:option]]

    opt[:title] = month.month.strftime(opt[:title]+"-%Y-%m")
    opt[:graph_file] = opt[:title] unless  opt[:graph_file]
    month.monthly_scatter(opt)
    @graph_file = opt[:graph_file] || "graph"
    @url =  @Domain+"/show_jpeg"
    render :file => 'power/month/graph'
  end

  def show_jpeg
    graph_file = (params[:graph_file].blank? ? "graph" : params[:graph_file])
    send_file RAILS_ROOT+"/tmp/graph/jpeg/#{graph_file}.gif", :type => 'image/jpeg', :disposition => 'inline'
  end
end

