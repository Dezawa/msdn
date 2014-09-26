# -*- coding: utf-8 -*-
module Shimada::Analyze

  include Shimada::GraphDay
  include Shimada::GraphMonth
  include Shimada::GraphAllMonth

  ColumnNames = Shimada::Power.column_names

    AllMonthaction_buttoms = 
      [7 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph",:method => :powers_3} ],
        #[:popup,:graph_all_month_lines_types,"全月度稼働変化別",{ :win_name => "graph"} ],
        [:popup,:graph_all_month,"全月度温度補正",{ :win_name => "graph",:method => :revise_by_temp_3} ],
        [:popup,:graph_all_month,"全月度蒸気量補正",{ :win_name => "graph",:method => :revise_by_vaper_3} ],
        [:popup,:graph_all_month,"全月度 月補正",{ :win_name => "graph",:method => :revise_by_month_3} ],
        [:popup,:graph_all_month,"選抜グラフ",{:graph_file => "maybe3lines", :win_name => "graph",:method => :powers_3,:powers => :maybe3lines} ],
        #[:popup,:graph_all_month_lines_types,"全月度稼働変化別",{ :win_name => "graph"} ],
        [:popup,:graph_all_month,"選抜温度補正",{ :win_name => "graph",:method => :revise_by_temp_3,:powers => :maybe3lines} ],
        [:popup,:graph_all_month,"選抜蒸気量補正",{ :win_name => "graph",:method => :revise_by_vaper_3,:powers => :maybe3lines} ],
        [:popup,:graph_all_by_month,"選抜補正後季節変動",{ :win_name => "graph",:method => :revise_by_vaper_3} ],
        [:popup,:graph_all_month,"全月度温度補正平均化",{ :win_name => "graph",:method => :revise_by_temp_ave} ],
        [:popup,:graph_all_month,"全月度正規化",{ :win_name => "graph",:method => :normalized}  ] ,
        [:popup,:graph_all_month_vaper,"未補正対蒸気量",{ :win_name => "graph",:method => :powers} ],
        [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_vaper,"全月度対蒸気量",{ :win_name => "graph"} ],

        [:popup,:graph_all_month_temp,"全月度月別対温度",{ :win_name => "graph",:each_month => true} ],
        [:popup,:graph_all_month_bugs,"全月度対袋数",{ :win_name => "graph",:method => :revise_by_temp_sum} ],
        [:popup,:graph_all_month_bugs,"全月度対袋数:季節変動",{ :win_name => "graph",:method => :revise_by_month_sum} ],
        [:popup,:graph_all_month_offset,"月度補正 offset低",{ :win_name => "graph",:offset => 0,:method => :revise_by_month } ],
        [:popup,:graph_all_month_offset,"月度補正 offset中",{ :win_name => "graph",:offset => 1,:method => :revise_by_month } ],
        [:popup,:graph_all_month_offset,"月度補正 offset高",{ :win_name => "graph",:offset => 2,:method => :revise_by_month } ],
        [:popup,:graph_all_month_offset,"温度補正 offset低",{ :win_name => "graph",:offset => 0,:method => :revise_by_temp } ],
        [:popup,:graph_all_month_offset,"温度補正 offset中",{ :win_name => "graph",:offset => 1,:method => :revise_by_temp } ],
        [:popup,:graph_all_month_offset,"温度補正 offset高",{ :win_name => "graph",:offset => 2,:method => :revise_by_temp } ],
        [:popup,:graph_all_month_bugs_offset,"全月度対袋数offset",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_bugs,"全月度月別対袋数",{ :win_name => "graph",:method => :revise_by_temp_sum,:each_month => true} ],
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
            :label => lbl,:shape => lbl, :fitting => :standerd}]
       } 
      ]
    AllMonthaction_buttomsPaternsByVaper = 
      [10,   Shimada::Power::PaternsKey.map{ |lbl| 
         [:popup,:graph_all_month_lines,lbl+"蒸気補正",
          {:win_name => "graph_patarn_all_month",:action=> :revise_by_vaper_3,
            :label => lbl,:shape => lbl, :fitting => :standerd}]
       } 
      ]
    AllMonthaction_buttomsPaternsByMonth = 
      [10,   Shimada::Power::PaternsKey.map{ |lbl| 
         [:popup,:graph_all_month_lines,lbl+"月間差補正",
          {:win_name => "graph_patarn_all_month",:action=> :revise_by_month_3,
            :label => lbl,:shape => lbl, :fitting => :standerd}]
       } 
      ]
       #%w( #3-- 3-+ 3-0 3F 3O 30+ 4-- 4-0 400 4F 4H 3他 4他 0S 1S 200  2O
       #  ). map{ |patern| line,shape = patern.split("",2); 
       #  [:popup,"graph_all_month_pat","#{line}line#{shape}",
       #   { :win_name => "graph",:patern => patern}
       #  ]
       #}+

    AllMonthaction_buttoms2 = 
    [ 1,
      [[:input_and_action,"graph_simyartion","気象データによる推定:Y-M-D,Y-M-D",{:size=>40 ,:popup => "graph_almighty",:scroll => true}],
       [:input_and_action,"graph_almighty","line,shape,deform,month,method",{:size=>40 ,:popup => "graph_almighty",:scroll => true}],
       [:input_and_action,"graph_superman","title:検索条件：グルーピング:filename:method",{:size=>80 ,:popup => "graph_superman",:scroll => true}],
       [:input_and_action,"graph_superman2","title:検索条件：グルーピング:filename",{:size=>80 ,:popup => "graph_superman",:scroll => true,:method => :by_temp}],

      ]
    ]
      
    AllMonthaction_buttoms3 = 
    [ 4,
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

  def analyze
    @action_buttoms_analize =[# Action_buttoms,
                               AllMonthaction_buttoms,         # 全月度グラフ ....
                               AllMonthaction_buttomsPaterns,  # パターン分析結果
                               AllMonthaction_buttomsPaternsByVaper,  # パターン分析結果
                               AllMonthaction_buttomsPaternsByMonth,  # パターン分析結果
                               AllMonthaction_buttomsDeform,   # 異常パターン
                               AllMonthaction_buttoms3,        # 数、型指定しての、グラフなど
                               AllMonthaction_buttoms2         # 
                               
                             ]

    @labels =   AllMonthLabels 
    @factory_id  = session[:shimada_factory] = params[:id] if  params[:id]
     @page = params[:page] || 1 
   @FindOption = { :conditions => ["shimada_factory_id = ?",@factory_id],:order => "month desc" }
    find_and

    @TableEdit  =
      [ :csv_up_buttom ,
        [:form,:reset_reevice_and_ave,"再補正・再平均",{ method: :get}],
        [:form,:reculc_all,"再計算",{ method: :get}],
        [:form,:reculc_shapes,"再分類",{ method: :get}],
        [:form,:rm_gif,"グラフ再作成",{ method: :get}],
        [:form,:standerd,"標準線計算",{ method: :get}]
      ]
    @action_buttoms =  @action_buttoms_analize
    render  :file => 'application/index',:layout => 'application'
  end

  def show_analyze ;
    @model = @Model.find(params[:id])
    @page = params[:id]
    @models = @model.powers
    @TYTLE_post = @models.first.date.strftime("(#{@factory.name}工場 %Y年%m月)")

    @TableEdit  =  
      [[:form,:analyze,"一覧に戻る",{ :method => :get}],
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
    @PowerModel.reset_reevice_and_ave
    redirect_to :action => :index
  end

  def rm_gif 
    @PowerModel.rm_gif
    redirect_to :action => :analyze
  end

  def reculc_all
    @PowerModel.reculc_all
    redirect_to :action => :analyze
    #render  :file => 'application/index',:layout => 'application'
  end

  def reculc_shapes
    @PowerModel.reculc_shapes
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
    errors= @Model.csv_upload(params[@Domain][:csvfile],Shimada::Factory.find(@factory_id))
    redirect_to :action => :index,:layout => "hospital_error_disp"
  end

  def standerd
    @labels = 
      [ HtmlNum.new(:line,"稼働数")] +
       ("a0".."a4").map{|n| HtmlNum.new(n.to_sym,n,:tform => "%.3f") }+
       ("a_low0".."a_low4").map{|n| HtmlNum.new(n.to_sym,n,:tform => "%.3f") }+
       ("a_high0".."a_high4").map{|n| HtmlNum.new(n.to_sym,n,:tform => "%.3f") }
      
    #@models = %w(稼働1 稼働2 稼働3 稼働4).map{ |patern|
    @models = [1,2,3,4].map{ |patern|
      @PowerModel.average_line(@factory_id,patern)
    }
    @AfterIndexHtml = to_html(@models)
    render  :file => 'application/index',:layout => 'application'
    
  end
  A = [:a0,:a1,:a2,:a3,:a4]
  AL = [:a_low0,:a_low1,:a_low2,:a_low3,:a_low4]
  AH = [:a_high0,:a_high1,:a_high2,:a_high3,:a_high4]
  def to_html(models)
    models.map{ |pw|
      "#{pw.line} => { <br>" +
      "  :ave => [ " +  A.map{ |s| pw.send(s) ? "%.3f"%pw.send(s) : "0"}.join(" ,") + "],<br>"+
      "  :max => [ " + AH.map{ |s| pw.send(s) ? "%.3f"%pw.send(s) : "0"}.join(" ,") + "],<br>"+
      "  :min => [ " + AL.map{ |s| pw.send(s) ? "%.3f"%pw.send(s) : "0"}.join(" ,") + "]<br>"
    }.join("},<br>")+"}"
  end

  def graph_superman
    title,quely,by,graph_file,method = params[@Domain][:graph_superman].split(":")
    method ||= :revise_by_temp_3 ; method = method.to_sym
    opt = case by
          when nil ; { }
          when /date\s*,\s*(.*)/ ; { :by_date => $1 }
          when /by\s*,\s*(.*)/   ; { :by_ => $1}  
          end
    @power = @PowerModel.all(:conditions => quely)
    @PowerModel.gnuplot(@factory_id,@power,method,opt.merge(:title => title))    
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_superman2
    title,quely,by,graph_file,method = params[@Domain][:graph_superman2].split(":")
    opt = case by
          when nil ; { }
          when /date\s*,\s*(.*)/ ; { :by_date => $1 }
          when /by\s*,\s*(.*)/   ; { :by_ => $1}  
          end
    @power = @PowerModel.all(:conditions => quely)
    @PowerModel.gnuplot(@factory_id,@power,method,opt.merge(:title => title,:vs_temp => true,:range => (7..19)))    
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_simyartion
    from,to = params[@Domain]["graph_simyartion"].split(/[\s,]+/)
    from = from ? Time.parse(from).to_date : Time.now.last_month.beginning_of_month.to_date
    to  =  to   ? Time.parse(to).to_date  : Time.now.last_month.end_of_month.to_date

    @PowerModel.simulation(@factory_id,14,3,from,to)
  end
  
  def graph_almighty
    patern = params[@Domain][:graph_almighty]
    list = patern.sub!(/,?list/,"")
    args = patern.split(/\s*,\s*|\s*and\s*|\s*&&\s*/).map{ |arg| a=arg.split(/\s*([<=>]+)\s*/);[a.first,a[1..-1]]}
logger.debug("GRAPH_ALMIGHTY:args=#{args.flatten.join(',')}")
    args = Hash[*args.flatten(1)] ;args.delete(nil) # =>"line=4,shpe=-0,month=2013/4
    method = args.delete("method") || params[@Domain][:method] || "revise_by_temp_3"
    method = case method
             when /^dif.*dif/ ; "diffdiff_3"
             when /^dif.*ave/ ; "difference_ave"
             when /^dif/ ; "difference_3"
             when /^norm/ ; "normalized"
             when /^rev.*ave/  ; "revise_by_temp_ave"
             when /^rev/  ; "revise_by_temp_3"
             when /^devi/  ; "deviation_of_difference"
             when /^pow/  ; "powers_3"
             end
    #logger.debug("GRAPH_ALMIGHTY:args[deform]=>[#{args["deform"][0]},#{args["deform"][1]}]")
    cnd_dform= 
      case deform = args.delete("deform")
      when nil   ;  nil
      when ["=","all"] ;  " deform is not null"
      when ["=","null"];  " deform is  null"
      else       ;  " (" + deform[1].split("").map{ |d| "deform like '%#{d}%'"}.join(" or ")  +")"
      end

    month_query = 
      if month=args.delete("month")
        the_month = Time.local(*month[1].split(/[-\/]/)).beginning_of_month
        if month[0] == "=" 
          args["month_id"] = ["=",@MonthModel.find_by(month: the_month).id]
          "month_id = #{@MonthModel.find_by(month: the_month).id}"
        else
          month_id = @MonthModel.all(:conditions => [ "month #{month[0]} ? ",the_month ] ).map(&:id)
          "month_id in (#{month_id.join(',')})"
        end
      end
    
    date_query =
      if date = args.delete("date") ;  "date #{date[0]} '#{date[1]}'" ;end
    date_query = "date < '2014-7-1'" unless date_query || month_query
    args_query = 
      if (args.keys & ColumnNames).size > 0 
        values = []
        ColumnNames.map{ |clm|
        if arg = args.delete(clm)
          values << arg[1]
          " #{clm} #{arg[0]} ? " 
        end
      }.compact.join("and")
        #args.keys.map{ |clm| " #{clm} #{args[clm][0]} ? " if ColumnNames.include?(clm)}.compact.join("and")
      end
    method_keys =  args.keys - ColumnNames 

    query = ["date is not null",cnd_dform,month_query,date_query,args_query].compact.join(" and ")
    #logger.debug("GRAPH_ALMIGHTY: query = #{query},args.values=#{values.join(',')}")
    @models = @PowerModel.all( :order => "date", 
                                  :conditions => [query,*values] )
    if args.size > 0
      @models = @models.select{ |pw|  
        args.keys.all?{ |m| 
          comp,value = args[m] ; 
          eval("pw.send(m.to_sym) #{comp} value.to_f") 
        }
      }
    end

    by_date = 
      if    month_query ; "%y/%m"
      elsif date_query || args_query ; "%m/%d"
      else
        by_date = "%y/%m"
      end

    if list
      patern.delete("method")
      winoption = {:win_name => "list", :graph_almighty => patern }
      @TableEdit  =  
        [[:form,:index,"一覧に戻る",{ :method => :get}],[:form,:edit_on_table,"編集"],
         [:popup,:graph_almighty,"補正後電力",winoption.merge({:method => :revise_by_temp_3}) ],
         [:popup,:graph_almighty,"正規化"    ,winoption.merge({:method => :normalized      }) ],
         [:popup,:graph_almighty,"差分"      ,winoption.merge({ :method => :difference_3   }) ],
         [:popup,:graph_almighty,"差分平均"  ,winoption.merge({:method => :difference_ave  }) ]
        ]
      @labels = Shimada::MonthController::DaylyLabels
      @action_buttoms = nil
      show_sub

    else
      @PowerModel.gnuplot(@factory_id,@models,method.to_sym,:by_date => by_date,
                             :title => patern )
      render :action => :graph,:layout => "hospital_error_disp"
    end
  end
end
