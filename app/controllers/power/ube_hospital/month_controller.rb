# -*- coding: utf-8 -*-
require 'extentions'
class Power::UbeHospital::MonthController  <   Power::MonthController
  include Power::GraphLinks
  before_filter :set_instanse_variable
  def set_instanse_variable
    super
    @Model = Power::UbeHospital::Month
    @Domain= @Model.name.underscore
   end

  def index
    @Show = true
    @labels =   eval( Labels_for_month_index) <<
      HtmlLink.new(:id,"",
                   :link => {:url => "month/monthly_scatter", :link_label => "温度補正対蒸気",
                     :option => "vaper-power" }.merge(POPUP))
    @action_buttoms = 
      #[
       [ 4,
         [
          [:popup,:graph_all_month,"全年度グラフ",{ :option => :power} ],
          [:popup,:graph_all_month,"24年度グラフ",{ :option => :power,:year => 2012} ],
          [:popup,:graph_all_month,"25年度グラフ",{ :option => :power,:year => 2013} ],
          [:popup,:graph_all_month,"26年度グラフ",{ :option => :power,:year => 2014} ],
          
          [:popup,:graph_all_month,"全年度対温度",{ :option => "temp-power"} ],
          [:popup,:graph_all_month,"24年度対温度",{ :option => "temp-power",:year => 2012} ],
          [:popup,:graph_all_month,"25年度対温度",{ :option => "temp-power",:year => 2013} ],
          [:popup,:graph_all_month,"26年度対温度",{ :option => "temp-power",:year => 2014} ],

          [:popup,:graph_all_month,"全年度対温度夜間",{:option => "temp-power",:night =>'夜間'} ],
          [:popup,:graph_all_month,"24年度対温度夜間",{:option => "temp-power",:night =>'夜間',:year => 2012} ],
          [:popup,:graph_all_month,"25年度対温度夜間",{:option => "temp-power",:night =>'夜間',:year => 2013} ],
          [:popup,:graph_all_month,"26年度対温度夜間",{:option => "temp-power",:night =>'夜間',:year => 2014} ],

          [:popup,:graph_all_month,"全年度対温度平日",{:option => "temp-power",:select => 'pw.line==2'} ],
          [:popup,:graph_all_month,"24年度対温度平日",{:option => "temp-power",:select => 'pw.line==2',:year => 2012} ],
          [:popup,:graph_all_month,"25年度対温度平日",{:option => "temp-power",:select => 'pw.line==2',:year => 2013} ],
          [:popup,:graph_all_month,"26年度対温度平日",{:option => "temp-power",:select => 'pw.line==2',:year => 2014} ],

          [:popup,:graph_all_month,"全年度温度補償",{ :option => "revise_temp"} ],
          [:popup,:graph_all_month,"24年度温度補償",{ :option => "revise_temp",:year => 2012} ],
          [:popup,:graph_all_month,"25年度温度補償",{ :option => "revise_temp",:year => 2013} ],
          [:popup,:graph_all_month,"26年度温度補償",{ :option => "revise_temp",:year => 2014} ],
          
          [:popup,:graph_all_month,"全年度対蒸気圧",{ :option => "vaper-power"} ],
          [:popup,:graph_all_month,"24年度対蒸気圧",{ :option => "vaper-power",:year => 2012} ],
          [:popup,:graph_all_month,"25年度対蒸気圧",{ :option => "vaper-power",:year => 2013} ],
          [:popup,:graph_all_month,"26年度対蒸気圧",{ :option => "vaper-power",:year => 2014} ],

          [:popup,:graph_all_month,"日中平均温度補償電力 年間",{ :option => "hour10","method" => :ave_daytime} ],
          [:popup,:graph_all_month,"10時の温度補償電力 年間",{ :option => "hour10"} ],
          [:popup,:graph_all_month,"10時の電力 年間",{ :option => "hour10","method" => :powers} ],
          [:popup,:graph_all_month,"25年度4月～7月の補正電力" ,
           { :option => "by_days_hour",:select => "pw.date.month >=4 && pw.date.month <= 7",:year => 2013} ],
          [:popup,:graph_all_month,"26年度4月～7月の補正電力" ,
           { :option => "by_days_hour",:select => "pw.date.month >=4 && pw.date.month <= 7",:year => 2014} ],
          [:popup,:graph_all_month,"25年度4月～7月の未補正電力" ,
           { :option => "by_days_hour",:select => "pw.date.month >=4 && pw.date.month <= 7",:method => :powers, :year => 2013} ],
          [:popup,:graph_all_month,"26年度4月～7月の未補正電力" ,
           { :option => "by_days_hour",:select => "pw.date.month >=4 && pw.date.month <= 7",:method => :powers, :year => 2014} ],
         ].re_order_by_line(8)
      ]
    [
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
    ]
    super
  end

  def title(opt)
    super
    opt[:title] += "（平日）" if opt["select"] == "line==2"
  end
end
