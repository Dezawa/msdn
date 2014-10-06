# -*- coding: utf-8 -*-
module Shimada::Chubu::Analyze

  include Shimada::GraphDay
  include Shimada::GraphMonth
  include Shimada::GraphAllMonth

  ColumnNames = Shimada::Power.column_names

    AllMonthaction_buttoms = 
      [5 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph",:method => :powers_3} ],
        [:popup,:graph_all_month,"全月度温度補正",{ :win_name => "graph",:method => :revise_by_temp_3} ],
        [:popup,:graph_all_month,"全月度蒸気量補正",{ :win_name => "graph",:method => :revise_by_vaper_3} ],
       # [:popup,:graph_all_month,"選抜グラフ",{:graph_file => "maybe3lines", :win_name => "graph",:method => :powers_3,:powers => :maybe3lines} ],
        [:popup,:graph_all_days,"年間変化",{:graph_file => "alldays", :win_name => "graph",:method => :min_max_power} ], [:popup,:graph_all_days,"年間変化:補正後",{:graph_file => "alldays", :win_name => "graph",:method => :min_max_revs} ],
        [:popup,:graph_all_month_vaper,"未補正対蒸気量",{ :win_name => "graph",:method => :powers} ],
        [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_vaper,"全月度対蒸気量",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_temp,"全月度月別対温度",{ :win_name => "graph",:each_month => true} ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働無",{ :win_name => "graph",:line => 0 } ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働不安定",{ :win_name => "graph",:line => 1 } ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働安定",{ :win_name => "graph",:line => 2 } ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働無・安定",{ :win_name => "graph",:line => -1 } ],
        [:popup,:graph_all_month_vaper,"全月度対蒸気 稼働無",{ :win_name => "graph",:line => 0 ,:method => :powers} ],
        [:popup,:graph_all_month_vaper,"全月度対蒸気 稼働不安定",{ :win_name => "graph",:line => 1 ,:method => :powers} ],
        [:popup,:graph_all_month_vaper,"全月度対蒸気 稼働安定",{ :win_name => "graph",:line => 2 ,:method => :powers} ],
        [:popup,:graph_all_month_vaper,"全月度対蒸気 稼働無・安定",{ :win_name => "graph",:line => -1 ,:method => :powers} ],
       ] 
      ]

  SGRPH="/shimada/month/graph_month"
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  # メイン画面での各月のリンクボタン
  POPUP = {:htmloption => Popup}
  AllMLink = { :url => SGRPH ,:key => :id, :key_val => :id, :htmloption => Popup}
  AllMonthLabels = 
    [#HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => {method: "powers_3", :link_label => "グラフ"}.merge(AllMLink)),
     HtmlLink.new(:id,"",:link => {method: "normalized",:link_label => "正規化"}.merge(AllMLink)),
     HtmlLink.new(:id,"",:link => {method: "revise_by_temp_3", :link_label => "温度補正"}.merge(AllMLink)),
     HtmlLink.new(:id,"",:link => {method: "revise_by_vaper_3",:link_label => "蒸気補正"}.merge(AllMLink)),
     HtmlLink.new(:id,"",:link => AllMLink.merge({:method=> "revise_by_month_3",:link_label => "月度補正"})),
     HtmlLink.new(:id,"",:link => AllMLink.merge({ :url => "/shimada/month/graph_month_temp", :link_label => "対温度"})),
     HtmlLink.new(:id,"",:link => AllMLink.merge({ :url => "/shimada/month/graph_month_bugs", :link_label => "対袋数"})),
     HtmlLink.new(:id,"",:link => AllMLink.merge({ :url => "/shimada/month/graph_month_bugs",method: :revise_by_month_sum, :link_label => "対袋数月度補正"})),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働数"   , :url => "#{SGRPH}_line_all"   }.merge(AllMLink)),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働変化別",:url => "#{SGRPH}_month_lines_types" }.merge(AllMLink)), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働F",:url => "#{SGRPH}_shape_all_F"  }.merge(AllMLink)), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働D",:url => "#{SGRPH}_shape_all_D"  }.merge(AllMLink)), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働O",:url => "#{SGRPH}_shape_all_O"  }.merge(AllMLink)), 
     HtmlLink.new(:id,"",:link => { method: "difference_3", :link_label => "差分"}.merge(AllMLink)),
     HtmlLink.new(:id,"",:link => { method: "difference_ave", :link_label => "差分平均"}.merge(AllMLink)),
     #HtmlLink.new(:id,"",:link => { month_diffdiff", :link_label => "二階差"}.merge(AllMLink)),
     #HtmlLink.new(:id,"",:link => { month_ave", :link_label => "平均化"}.merge(AllMLink)),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/show_analyze" ,:key => :id, :key_val => :id,:link_label => "月度一覧表示" })
    ]

  def action_buttoms_analize
    [# Action_buttoms,
     AllMonthaction_buttoms,         # 全月度グラフ ....
     #AllMonthaction_buttomsPaterns,  # パターン分析結果
     #AllMonthaction_buttomsPaternsByVaper,  # パターン分析結果
     #AllMonthaction_buttomsPaternsByMonth,  # パターン分析結果
     #AllMonthaction_buttomsDeform,   # 異常パターン
     #AllMonthaction_buttoms3,        # 数、型指定しての、グラフなど
     #AllMonthaction_buttoms2         # 
    ]
  end

  def analyze
    @action_buttoms_analize = [AllMonthaction_buttoms] #action_buttoms_analize
    #@action_buttoms_analize = action_buttoms_analize
    @labels =   AllMonthLabels 
    analyze_sub
  end

  def poststr(line) case line.to_i
              when 0; "稼働無"
              when 1; "稼働不安定"
              when 2 ; "稼働安定"
              when -1 ; "稼働安定,稼働無"
                else    ; ""
              end
  end

  def graph_all_month_temp
    line =  (params[@Domain] && params[@Domain][:line]) ? params[@Domain][:line] : nil 
    @TYTLE = "温度-消費電力 全月度 " + poststr(line)
    super
  end
  def graph_all_month_vaper
    line =  (params[@Domain] && params[@Domain][:line]) ? params[@Domain][:line] : nil 
    @TYTLE = "蒸気圧-消費電力 全月度 " + poststr(line)
    super
  end
end
