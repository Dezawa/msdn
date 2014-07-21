# -*- coding: utf-8 -*-
module Shimada::Analyze

  include Shimada::GraphDay
  include Shimada::GraphMonth
  include Shimada::GraphAllMonth

    AllMonthaction_buttoms = 
      [7 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph",:method => :powers_3} ],
        #[:popup,:graph_all_month_lines_types,"全月度稼働変化別",{ :win_name => "graph"} ],
        [:popup,:graph_all_month,"全月度温度補正",{ :win_name => "graph",:method => :revise_by_temp_3} ],
        [:popup,:graph_all_month,"全月度温度補正平均化",{ :win_name => "graph",:method => :revise_by_temp_ave} ],
        [:popup,:graph_all_month,"全月度正規化",{ :win_name => "graph",:method => :normalized}  ] ,
        [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_temp,"全月度月別対温度",{ :win_name => "graph",:each_month => true} ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働無",{ :win_name => "graph",:line => 0 } ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働2",{ :win_name => "graph",:line => 2 } ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働3",{ :win_name => "graph",:line => 3 } ],
        [:popup,:graph_all_month_temp,"全月度対温度 稼働4",{ :win_name => "graph",:line => 4 } ],
        [:popup,:graph_all_month,"全月度差分",{ :win_name => "graph",:method => :difference_3} ],
        [:popup,:graph_all_month,"全月度差分平均",{ :win_name => "graph",:method => :difference_ave} ],
        [:popup,:graph_all_month_deviation_vs_temp,"全月度差分分散対気温",
         { :win_name => "graph_temp",:method => :deviation_of_difference,:by_ => :lines}],
        #[:popup,:graph_all_month_deviation_vs_temp,"全月度差分分散対気温by_shape",
        # { :win_name => "graph_temp",:method => :deviation_of_difference, :by_ => :shape}],
        [:popup,:graph_all_month_deviation_vs_temp,"全月度電力分散対気温",
         { :win_name => "graph_temp",:method => :deviation_of_revice,:by_ => :lines}],
        #[:popup,:graph_all_month_deviation_vs_temp,"全月度電力分散対気温by_shape",
        # { :win_name => "graph_temp",:method => :deviation_of_revice, :by_ => :shape}]
       ] 
      ]
    AllMonthaction_buttomsPaterns = 
      [10,   Shimada::Power::PaternsKey.map{ |lbl| 
         [:popup,:graph_all_month_lines,lbl,
          {:win_name => "graph_patarn_all_month",:action=> :revise_by_temp_3,
            :label => lbl,:shape => lbl, :fitting => :std_temp}]
       } 
      ]
       #%w( #3-- 3-+ 3-0 3F 3O 30+ 4-- 4-0 400 4F 4H 3他 4他 0S 1S 200  2O
       #  ). map{ |patern| line,shape = patern.split("",2); 
       #  [:popup,"graph_all_month_pat","#{line}line#{shape}",
       #   { :win_name => "graph",:patern => patern}
       #  ]
       #}+

    AllMonthaction_buttoms2 = 
    [ 2,
      [[:input_and_action,"graph_almighty","line,shape,deform,month,method",{:size=>40 ,:popup => "graph_almighty",:scroll => true}]
      ]
    ]
      
    AllMonthaction_buttoms3 = 
    [ 3,
        [[:input_and_action,"graph_all_month_","数型グラフ",{:size=>7 ,:popup => "graph_all_month"}],
         [:input_and_action,"index_all_month_","数型の一覧",{:size=>7 ,:popup => "index_all_month",:scroll => true}],
         [:input_and_action,"graph_the_day","日付指定グラフ",{:size=>14 ,:popup => "graph_all_month"}],
        ]
      ]
  AllMonthaction_buttomsDeform = 
    [8,Shimada::Power::DeformKey.map{ |lbl| 
         [:popup,:graph_deform,lbl,
          {:win_name => "graph_patarn_all_month",:action=> :revise_by_temp_3,:label => lbl,:deform => lbl}]
       } 
    ]

  SGRPH="/shimada/month/graph_month?method="
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  # メイン画面での各月のリンクボタン
  POPUP = {:htmloption => Popup}

  AllMonthLabels = 
    [#HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}powers_3", :link_label => "グラフ"}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}normalized",:link_label => "正規化"}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}revise_by_temp_3", :link_label => "温度補正"}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}revise_by_temp_ave",:link_label => "温度補正平均"}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_temp", :link_label => "対温度"}.merge(POPUP)),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働数"   , :url => "#{SGRPH}_line_all"   }.merge(POPUP)),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働変化別",:url => "#{SGRPH}_month_lines_types" }.merge(POPUP)), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働F",:url => "#{SGRPH}_shape_all_F"  }.merge(POPUP)), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働D",:url => "#{SGRPH}_shape_all_D"  }.merge(POPUP)), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働O",:url => "#{SGRPH}_shape_all_O"  }.merge(POPUP)), 
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}difference_3", :link_label => "差分"}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}difference_ave", :link_label => "差分平均"}.merge(POPUP)),
     #HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}_month_diffdiff", :link_label => "二階差"}.merge(POPUP)),
     #HtmlLink.new(:id,"",:link => { :url => "#{SGRPH}_month_ave", :link_label => "平均化"}.merge(POPUP)),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/show_analyze",:link_label => "月度一覧表示" })
    ]

  def analyze
    @action_buttoms_analize =[# Action_buttoms,
                               AllMonthaction_buttoms,         # 全月度グラフ ....
                               AllMonthaction_buttomsPaterns,  # パターン分析結果
                               AllMonthaction_buttomsDeform,   # 異常パターン
                               AllMonthaction_buttoms3,        # 数、型指定しての、グラフなど
                               AllMonthaction_buttoms2         # 
                               
                             ]

    @labels =   AllMonthLabels 
      #factory = Shimada::Factory.find(params[:id])
     @page = params[:page] || 1 
    find_and

    @TableEdit  =
      [ :csv_up_buttom ,
        [:form,:reset_reevice_and_ave,"再補正・再平均"],
        [:form,:reculc_all,"再計算"],
        [:form,:reculc_shapes,"再分類"],
        [:form,:rm_gif,"グラフ再作成"],
        [:form,:standerd,"標準線計算"]
      ]
    
    @action_buttoms =  @action_buttoms_analize
    render  :file => 'application/index',:layout => 'application'
  end

  def show_analyze ;
    @model = @Model.find(params[:id])
    @page = params[:id]
    @models = @model.powers
    @TYTLE_post = @models.first.date.strftime("(%Y年%m月)")

    @TableEdit  =  
      [[:form,:analyze,"一覧に戻る"],
        [:popup,:graph_month,"月度グラフ",{ :win_name => "graph",:method => :powers_3} ],
        [:popup,:graph_month,"月度温度補正",{ :win_name => "graph",:method => :revise_by_temp_3} ],
        [:popup,:graph_month,"月度温度補正平均",{ :win_name => "graph",:method =>:revise_by_temp_ave } ],
        [:popup,:graph_month_temp,"月度対温度",{ :win_name => "graph" } ],
        [:popup,:graph_month_lines_types,"月度稼働・型",{ :win_name => "graph" } ],
        #:popup,:graph_month_difference_ave,"月度差分平均",{ :win_name => "graph"} ],
        [:popup,:graph_month,"月度差分",{ :win_name => "graph",:method => :difference_3} ]
      ]
      
    @action_buttoms = Month_action_buttoms
    @TableHeaderDouble = [10,[16,"係数"],1,[24,"時刻"]]
    @labels = PowerLabels
    show_sub
  end


  def reset_reevice_and_ave
    Shimada::Power.reset_reevice_and_ave
    redirect_to :action => :index
  end

  def rm_gif 
    Shimada::Power.rm_gif
    redirect_to :action => :analyze
  end

  def reculc_all
    Shimada::Power.reculc_all
    redirect_to :action => :analyze
    #render  :file => 'application/index',:layout => 'application'
  end

  def reculc_shapes
    Shimada::Power.reculc_shapes
    redirect_to :action => :analyze
    #render  :file => 'application/index',:layout => 'application'
  end


  def select_by_(powers,find_conditions)
    find_conditions.to_a.inject(powers){ |p,sym_v| 
      sym,v = sym_v
      p.select{ |pw| pw.send(sym) == v }
    }
  end

  def csv_upload
    errors= @Model.csv_upload(params[@Domain][:csvfile])
    redirect_to :action => :index,:layout => "hospital_error_disp"
  end

  def standerd
    @labels = 
      [ HtmlNum.new(:line,"稼働数")] +
       ("a0".."a4").map{|n| HtmlNum.new(n.to_sym,n,:tform => "%.3f") }+
       ("a_low0".."a_low4").map{|n| HtmlNum.new(n.to_sym,n,:tform => "%.3f") }+
       ("a_high0".."a_high4").map{|n| HtmlNum.new(n.to_sym,n,:tform => "%.3f") }
      
    #@models = %w(稼働1 稼働2 稼働3 稼働4).map{ |patern|
    @models = (1..4).map{ |patern|
      Shimada::Power.average_line(patern)
    }
logger.debug("Shimada::Power:models #{@models[0].a_low.join(',')}")
    render  :file => 'application/index',:layout => 'application'
    
  end
end
