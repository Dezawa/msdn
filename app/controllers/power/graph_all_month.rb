# -*- coding: utf-8 -*-
module  Power::GraphAllMonth # controller
  GraphOpt =
    { "power" => {:method => :powers, :data_file_labels => "時刻 電力",
                  :title  => "消費電力",:with => "line",
      :set_key => "set key outside  autotitle columnheader samplen 1 width 0",
      #:by_date => "%02d"
    },
    "revise_temp" => { },
  }
  def monthly_graph
    month = @Model.find(params["id"].to_i)
    opt = GraphOpt[params[:option]]
    month.monthly_graph(opt.merge(:title => month.month.strftime(opt[:title]+" %Y/%m")))
    @graph_file = opt[:graph_file] || "graph"
    @url =  @Domain+"/show_jpeg"
    render :file => 'power/month/graph'
  end

  ScatterOpt =
    { "temp-power" => { :method => :powers , :title => "気温と消費電力",:pt => 6,
                        :xlabel => "xl '気温'",:ylabel => "yl '消費電力'" ,
                        :hour_range => (7..15) ,
                        :x_method => :temps,:xrange => "[-10:40]"
                        }
  }
  def monthly_scatter
    month = @Model.find(params["id"].to_i)
    opt = ScatterOpt[params[:option]]
    month.monthly_scatter(opt.merge(:title => month.month.strftime(opt[:title]+" %Y/%m")))
    @graph_file = opt[:graph_file] || "graph"
    @url =  @Domain+"/show_jpeg"
    render :file => 'power/month/graph'
  end

  def show_jpeg
    graph_file = (params[:graph_file].blank? ? "graph" : params[:graph_file])
    send_file RAILS_ROOT+"/tmp/graph/jpeg/#{graph_file}.gif", :type => 'image/jpeg', :disposition => 'inline'
  end
end

