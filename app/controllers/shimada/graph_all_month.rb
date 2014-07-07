# -*- coding: utf-8 -*-
module Shimada::GraphAllMonth
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  # メイン画面での各月のリンクボタン
  Labels = 
    [#HtmlCeckForSelect.new(:id,""),
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month", :link_label => "グラフ", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_nomalized",:link_label => "正規化", :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced", :link_label => "温度補正",  :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_reviced_ave",:link_label => "温度補正平均",:htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_temp", :link_label => "対温度", :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働数"   , :url => "/shimada/month/graph_line_all"   , :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働変化別",:url => "/shimada/month/graph_month_lines_types",:htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働F",:url => "/shimada/month/graph_shape_all_F"  , :htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働D",:url => "/shimada/month/graph_shape_all_D"  , :htmloption => Popup}), 
     #HtmlLink.new(:id,"",:link => { :link_label => "稼働O",:url => "/shimada/month/graph_shape_all_O"  , :htmloption => Popup}), 
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference", :link_label => "差分",  :htmloption => Popup}),
     HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference_ave", :link_label => "差分平均",:htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_diffdiff", :link_label => "二階差", :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_ave", :link_label => "平均化",  :htmloption => Popup}),
    ]

    AllMonthaction_buttoms = 
      [6 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph"} ],
        #[:popup,:graph_all_month_lines_types,"全月度稼働変化別",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_reviced,"全月度温度補正",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_reviced_ave,"全月度温度補正平均化",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_nomalized,"全月度正規化",{ :win_name => "graph"}  ] ,
        [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_difference,"全月度差分",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_difference_ave,"全月度差分平均",{ :win_name => "graph"} ]
      ] +
       Shimada::Power::PaternsKey.map{ |lbl| 
         [:popup,:graph_all_month_lines,lbl,
          {:win_name => "graph_patarn_all_month",:action=> :revise_by_temp,:label => lbl,:shape => lbl}]
       } +

       #%w( #3-- 3-+ 3-0 3F 3O 30+ 4-- 4-0 400 4F 4H 3他 4他 0S 1S 200  2O
       #  ). map{ |patern| line,shape = patern.split("",2); 
       #  [:popup,"graph_all_month_pat","#{line}line#{shape}",
       #   { :win_name => "graph",:patern => patern}
       #  ]
       #}+
        [[:input_and_action,"graph_all_month_","数型グラフ",{:size=>7 ,:popup => "graph_all_month"}],
         [:input_and_action,"index_all_month_","数型の一覧",{:size=>7 ,:popup => "index_all_month",:scroll => true}]
        ]

      ]


  def index_all_month_
    line,shape = patern = params[@Domain][:index_all_month_].split("",2)
    #@models = Shimada::Power.all(:conditions => ["line=? and shape = ?",line,shape])
    @models = Shimada::Power.all( :order => "date",
                                  :conditions => ["line = ? and shape = n? ",line.to_i,shape]
                                )
    @TYTLE_post = "(#{patern})"

    @TableEdit  =  [[:form,:index,"一覧に戻る"],[:form,:edit_on_table,"編集"],
                    [:popup,:graph_patern,"補正後電力",{ :win_name => "graph",:patern => patern,:method => :revise_by_temp} ],
                    [:popup,:graph_patern,"正規化",{ :win_name => "graph",:patern => patern,:method => :normalized} ],
                    [:popup,:graph_patern,"差分",{ :win_name => "graph",:patern => patern,:method => :difference} ],
                    [:popup,:graph_patern,"差分平均",{ :win_name => "graph",:patern => patern,:method => :difference_ave} ]
                   ]
    @action_buttoms = nil
    show_sub
  end

  def graph_patern
    line,shape = patern = params[@Domain][:patern].split("",2)
    method =  params[@Domain][:method]

    @power=Shimada::Power.all(   :conditions => ["line = ? and shape = n? ",line.to_i,shape]  )
    Shimada::Power.gnuplot(@power,method.to_sym,:by_monthday => true)
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_reviced ;    graph_all_month_sub(:revise_by_temp, "補正消費電力推移 全月度",:by_month => true) 
  end

  def graph_all_month_reviced_ave ; graph_all_month_sub(:revise_by_temp_ave,"補正消費電力平均化推移 全月度",:by_month => true);end
  def graph_all_month_ave ;    graph_all_month_sub(:move_ave,"平均消費電力推移 全月度",:by_month => true);  end
  def graph_all_month_nomalized ; graph_all_month_sub(:normalized, "正規化消費電力推移 全月度",:by_shape => true);  end
  def graph_all_month            ; graph_all_month_sub(:powers,"消費電力推移 全月度",:by_month => true) ;end
  def graph_all_month_difference           ; graph_all_month_sub(:difference,"差分 全月度",:by_month => true) ;end
  def graph_all_month_difference_ave           ; graph_all_month_sub(:difference_ave,"差分平均 全月度",:by_month => true) ;end
  def graph_all_month_lines_types;graph_all_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_line_shape => true ) ;  end

  def graph_all_month_pat
    graph_all_month_line_shape(params[@Domain][:patern])
  end
  
  def graph_all_month_
    graph_all_month_line_shape(params[@Domain][:graph_all_month_])
  end

  def graph_all_month_line_shape(lines,shape=nil)
    lines,shape = lines.split("",2) unless shape
    logger.debug("\n** GRAPH_ALL_MONTH_LINE_SHAPE: line=#{lines} shape=#{shape} **")
    graph_all_month_sub(:revise_by_temp,"#{lines}line #{shape}",
                        :find => {:lines => lines.to_i,:shape_is => shape},:by_month => true,
                        :graph_file => "_#{lines}#{shape}".sub(/\+/,"p")) 
  end
  def graph_all_month_sub(method,title,opt={ })
    graph_file = opt[:graph_file] ? opt[:graph_file].sub(/\+/,"p") : ""
    opt.merge!(:graph_file => "giffiles/all_month#{graph_file}_#{method}" ) 
    @graph_file =  opt[:graph_file]
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{opt[:graph_file]}.gif") == true
      months = Shimada::Month.all
      @power=months.map{ |m| m.powers}.flatten
      @power = select_by_( @power,opt[:find]) if  opt[:find] 
      Shimada::Power.gnuplot(@power,method,opt)
    end

    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_all_month_patern(method,title,shapes)
    @graph_file =  "giffiles/all_month_patern_" + ( shapes || "unsorted")
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{@graph_file}.gif") == true
      line_shape = ( if   shapes ; Shimada::Power::Paterns[shapes]
                     else Shimada::Power::Un_sorted
                     end ).map{ |ls| ls.split("",2)}
      months = Shimada::Month.all
      @power=months.map{ |m| m.powers}.flatten.
        select{ |power| line_shape.any?{ |line,shape| power.lines == line.to_i && power.shape_is == shape }}
 logger.debug("GRAPH_ALL_MONTH_PATERN: @power.size=#{@power.size}")
     Shimada::Power.gnuplot(@power,method,:by_line_shape => true,
                             :graph_file => @graph_file
                             )
    end
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_all_month_lines
    action = params[@Domain][:action]
    label  = params[@Domain][:label]
    shape  =  params[@Domain][:shape]
    shape  = nil if shape == "未分類"
    graph_all_month_patern(action,label,shape)
  end

  def graph_all_month_temp
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot_by_temp(@power,:by_month => true,:with_Approximation => true)
    @TYTLE = "温度-消費電力 全月度"
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
