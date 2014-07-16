# -*- coding: utf-8 -*-
module Shimada::GraphAllMonth
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  # メイン画面での各月のリンクボタン
  SGRPH="/shimada/month/graph_month?method="
  POPUP = {:htmloption => Popup}
  ColumnNames = Shimada::Power.column_names
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
    ]

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
          {:win_name => "graph_patarn_all_month",:action=> :revise_by_temp_3,:label => lbl,:shape => lbl}]
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
  def graph_almighty
    patern = params[@Domain][:graph_almighty]
    list = patern.sub!(/,?list/,"")
    args = patern.split(",").map{ |arg| a=arg.split(/([<=>]+)/);[a.first,a[1..-1]]}
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
          args["month_id"] = ["=",Shimada::Month.find_by_month(the_month).id]
          "month_id = #{Shimada::Month.find_by_month(the_month).id}"
        else
          month_id = Shimada::Month.all(:conditions => [ "month #{month[0]} ? ",the_month ] ).map(&:id)
          "month_id in (#{month_id.join(',')})"
        end
      end
    
    date_query =
      if date = args.delete("date") ;  "date #{date[0]} '#{date[1]}'" ;end
    
    args_query = 
      if (args.keys & ColumnNames).size > 0 
        args.keys.map{ |clm| " #{clm} #{args[clm][0]} ? " if ColumnNames.include?(clm)}.compact.join("and")
      end
    method_keys =  args.keys - ColumnNames 

    query = ["date is not null",cnd_dform,month_query,date_query,args_query].compact.join(" and ")
logger.debug("GRAPH_ALMIGHTY: query = #{query}")
    @models = Shimada::Power.all( :order => "date", 
                                   :conditions => [query,*args.values.map{ |a| a[1]}] )
    if method_keys.size > 0
      @models = @models.select{ |pw|  method_keys.
        all?{ |method| comp,value = args[method] ; eval("pw.send(method.to_sym) #{comp} value.to_f") }
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
    [[:form,:index,"一覧に戻る"],[:form,:edit_on_table,"編集"],
     [:popup,:graph_almighty,"補正後電力",winoption.merge({:method => :revise_by_temp_3}) ],
     [:popup,:graph_almighty,"正規化"    ,winoption.merge({:method => :normalized      }) ],
     [:popup,:graph_almighty,"差分"      ,winoption.merge({ :method => :difference_3   }) ],
     [:popup,:graph_almighty,"差分平均"  ,winoption.merge({:method => :difference_ave  }) ]
    ]
    @action_buttoms = nil
    show_sub

    else
    Shimada::Power.gnuplot(@models,method.to_sym,:by_date => by_date,
                           :title => patern )
      render :action => :graph,:layout => "hospital_error_disp"
    end
  end


  def index_all_month_
    line,shape, @models = get_power_by_line_and_shape(params[@Domain][:index_all_month_])
    patern = [line,shape]
    @TYTLE_post = "(#{patern})"

    @TableEdit  =  
    [[:form,:index,"一覧に戻る"],[:form,:edit_on_table,"編集"],
     [:popup,:graph_patern,"補正後電力",{ :win_name => "graph",:patern => patern,:method => :revise_by_temp_3} ],
     [:popup,:graph_patern,"正規化"    ,{ :win_name => "graph",:patern => patern,:method => :normalized} ],
     [:popup,:graph_patern,"差分"      ,{ :win_name => "graph",:patern => patern,:method => :difference_3} ],
     [:popup,:graph_patern,"差分平均"  ,{ :win_name => "graph",:patern => patern,:method => :difference_ave} ]
    ]
    @action_buttoms = nil
    show_sub
  end

  def graph_patern
    line,shape, @power = get_power_by_line_and_shape(params[@Domain][:patern])
    method =  params[@Domain][:method]

    Shimada::Power.gnuplot(@power,method.to_sym,:by_date => "%m/%d" )
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def get_power_by_line_and_shape(patern)
    line,shape = patern.split("",2)
    [line,shape,if /\d/ =~ line
                  Shimada::Power.all( :order => "date",
                                     :conditions => ["line = ? and shape = n? ",line.to_i,shape]
                                     )
                else Shimada::Power::Un_sorted
                 Shimada::Power.all( :order => "date",
                                     :conditions => ["shape = n? ",shape]
                                     )
                end
    ]
  end

  def graph_all_month_lines_types;graph_all_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_ => :line_shape ) ;  end

  TITLE_ALLMONTH = { 
    :powers_3           => [ "消費電力推移 全月度",{ :by_date  => "%y/%m"} ],
    :revise_by_temp_3   => [ "補正消費電力推移 全月度",{ :by_date  => "%y/%m"} ],
    :revise_by_temp_ave => [ "補正消費電力平均化推移 全月度",{ :by_date  => "%y/%m"} ],
    :normalized         => [ "正規化消費電力推移 全月度",{ :by_ => :shape} ],
    :difference_3       => [ "差分 全月度",{ :by_date => "%y/%m"} ],
    :difference_ave     => [ "差分平均 全月度",{ :by_date => "%y/%m"} ],
  }
  def graph_all_month   
    method = params[@Domain][:method].to_sym
    graph_all_month_sub(method,*TITLE_ALLMONTH[method])
  end 
  def graph_all_month_pat
    graph_all_month_line_shape(params[@Domain][:patern])
  end

    Graph_the_day = [ [/^rev(ise)?/,"補正電力",:revise_by_temp_3],
               [/^diffdiff/,"二階差分"         ,:difference_3],
               [/^dif.*ave/,"差分平均",:difference_ave],
               [/^dif/,"差分"         ,:difference_3],
               [/./,"消費電力",:powers_3],
             ]
  def graph_the_day
    days,method = params[@Domain][:graph_the_day].split
    _,title,method = Graph_the_day[ method ? Graph_the_day.find_index{ |a| a.first =~ method} : -1]

    @power = Shimada::Power.all(:conditions => ["date in (?)",days.split(",")])
    Shimada::Power.gnuplot(@power,method,:by_date=>"%y/%m/%d",:yitle =>title )
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_all_month_
    graph_all_month_line_shape(params[@Domain][:graph_all_month_])
  end

  def graph_all_month_line_shape(lines,shape=nil)
    lines,shape = lines.split("",2) unless shape
    find = /\d/ =~ lines ? {:lines => lines.to_i,:shape_is => shape} : {:shape_is => shape}

    logger.debug("\n** GRAPH_ALL_MONTH_LINE_SHAPE: line=#{lines} shape=#{shape} **")
    graph_all_month_sub(:revise_by_temp_3,"#{lines}line #{shape}",
                        :find => find,:by_date => "%y/%m",
                        :graph_file => "_#{lines}#{shape}".sub(/\+/,"p")) 
  end
  def graph_all_month_sub(method,title,opt={ })
    graph_file = opt[:graph_file] ? opt[:graph_file].sub(/\+/,"p") : ""
    opt.merge!(:graph_file => "all_month#{graph_file}_#{method}" ) 
    @graph_file =  opt[:graph_file]
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{opt[:graph_file]}.gif") == true
      months = Shimada::Month.all
      @power=months.map{ |m| m.powers}.flatten
      @power = select_by_( @power,opt[:find]) if  opt[:find] 
      Shimada::Power.gnuplot(@power,method,opt.merge(:title => title))
    end

    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_standerd
    line = params[@Domain][:lines].to_i
    @graph_file = "standerd_#{line}"
    opt = { :graph_file => @graph_file }

    @TYTLE = "標準電力消費 #{line}稼働"
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{@graph_file}.gif") == true
      @power = Shimada::Power.all(:conditions => ["line = ?",line])
      Shimada::Power.gnuplot(@power,:standerd,opt.merge(:title => @TYTLE ))
    end

    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_patern(method,title,shapes,opt={ })
    @graph_file =  "all_month_patern_" + ( shapes || "unsorted")
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{@graph_file}.gif") == true
      line_shape = ( if   shapes ; Shimada::Power::Paterns[shapes]
                     else Shimada::Power::Un_sorted
                     end ).map{ |ls| ls.split("",2)}
      months = Shimada::Month.all
      @power=months.map{ |m| m.powers}.flatten.
        select{ |power| line_shape.any?{ |line,shape| power.lines == line.to_i && power.shape_is == shape }}
      opt.merge!({ :by_ => :line_shape,:title => params[@Domain][:shape], :graph_file => @graph_file})
     Shimada::Power.gnuplot(@power,method,opt)
    end
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_all_month_lines
    action = params[@Domain][:action]
    label  = params[@Domain][:label]
    shape  =  params[@Domain][:shape]
    shape  = nil if shape == "未分類"
    graph_all_month_patern(:standerd,label,shape,{ :mode =>:revise_by_temp_3 })
  end
  def graph_deform
    action = params[@Domain][:action]
    label  = params[@Domain][:label]
    deform  =  params[@Domain][:deform]

    graph_all_month_deform(action,label,deform)

  end
  def graph_all_month_deform(method,title,deform_lbl)
    @graph_file =  "all_month_patern_" + deform_lbl
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{@graph_file}.gif") == true
      deform = Shimada::Power::Deforms[deform_lbl]
      @power,by_ = 
        case deform
        when "all" ; [ Shimada::Power.all(:conditions => "deform is not null"),{ :by_ => :deform}]
        when "null"; [ Shimada::Power.all(:conditions => "deform is null and date is not null"),{ :by_date => "%y/%m"}]
        else       ; [ Shimada::Power.all(:conditions => "deform like '%#{deform}%'"),{:by_date => "%y/%m/%d" }]
        end
      opt = { :title => deform_lbl,:graph_file => @graph_file}.merge(by_)
      Shimada::Power.gnuplot(@power,method,opt) 
   end
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_temp
    line =  (params[@Domain] && params[@Domain][:line]) ? params[@Domain][:line] : nil 
    if params[@Domain] && params[@Domain][:each_month]
      Shimada::Month.all.each{ |month| graph_temp_(month)}
    else
    @graph_file =  "all_month_vs_temp_" + (line ? line : "")
    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{@graph_file}.gif") == true
      conditions = line ?  [" and line = ? ", line ] :  ["", [] ]
      @power = Shimada::Power.power_all(conditions)
      @TYTLE = "温度-消費電力 全月度 " + ( line ? line+"ライン稼働" : "")

      Shimada::Power.gnuplot(@power,:powers,:by_date => "%y/%m",:title => @TYTLE,:vs_temp => true,
                                     :graph_file =>  @graph_file, :with_Approximation => true,
                                     :range => (7..19))
    end
    end
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_deviation_vs_temp
    @power=Shimada::Power.power_all
    by_ = params[@Domain][:by_]
    method = params[@Domain][:method].to_sym
    title = { :deviation_of_revice => "電力", :deviation_of_difference => "差分"}[method]
    @TYTLE = "最高温度-#{title}分散 全月度"
    Shimada::Power.gnuplot(@power,method,:by_ => by_ , :title => @TYTLE,:vs_temp => true)
    render :action => :graph,:layout => "hospital_error_disp"
  end
end
