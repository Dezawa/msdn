# -*- coding: utf-8 -*-
module Shimada::GraphAllMonth
  def label_extension_by(method)
    case method
    when /by_temp/ ; ["温度補正","temp"]
    when /by_month/; ["季節変動補正","month"]
    end
  end

  # メイン画面での各月のリンクボタン
  def index_all_month_
    line,shape, @models = get_power_by_line_and_shape(params[@Domain][:index_all_month_])
    patern = [line,shape]
    @TYTLE_post = "(#{patern})"

    @TableEdit  =  
      [[:form,:index,"一覧に戻る",{ :method => :get}],[:form,:edit_on_table,"編集"],
       [:popup,:graph_patern,"補正後電力",{ :win_name => "graph",:patern => patern,:method => :revise_by_temp_3} ],
       [:popup,:graph_patern,"正規化"    ,{ :win_name => "graph",:patern => patern,:method => :normalized} ],
       [:popup,:graph_patern,"差分"      ,{ :win_name => "graph",:patern => patern,:method => :difference_3} ],
       [:popup,:graph_patern,"差分平均"  ,{ :win_name => "graph",:patern => patern,:method => :difference_ave} ]
      ]
    @labels = Shimada::MonthController::DaylyLabels
    @action_buttoms = nil
    show_sub
  end

  def graph_patern
    line,shape, @power = get_power_by_line_and_shape(params[@Domain][:patern])
    method =  params[@Domain][:method]

    @PowerModel.gnuplot(@factory_id,@power,method.to_sym,:by_date => "%m/%d" )
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def get_power_by_line_and_shape(patern)
    line,shape = patern.split("",2)
    [line,shape,if /\d/ =~ line
                  @PowerModel.where( ["line = ? and shape = n? and date < '2014-7-1'",line.to_i,shape]).
                    order( "date")
                else Shimada::Power::Un_sorted
                  @PowerModel.order("date").
                    where( ["shape = n?  and date < '2014-7-1'",shape] )
                end
    ]
  end

  def graph_all_month_lines_types;graph_all_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_ => :line_shape ) ;  end

  TITLE_ALLMONTH = { 
    :powers_3           => [ "消費電力推移 全月度",{ :by_date  => "%y/%m"} ],
    :revise_by_vaper_3  => [ "蒸気圧補正消費電力推移 全月度",{ :by_date  => "%y/%m"} ],
    :revise_by_month_3  => [ "月間差補正消費電力推移 全月度" ,{ :by_date  => "%y/%m"} ],
    :revise_by_temp_3   => [ "補正消費電力推移 全月度",{ :by_date  => "%y/%m"} ],
    :revise_by_temp_ave => [ "補正消費電力平均化推移 全月度",{ :by_date  => "%y/%m"} ],
    :normalized         => [ "正規化消費電力推移 全月度",{ :by_ => :shape} ],
    :difference_3       => [ "差分 全月度",{ :by_date => "%y/%m"} ],
    :difference_ave     => [ "差分平均 全月度",{ :by_date => "%y/%m"} ],
  }
  def graph_all_by_month #
    method = params[@Domain][:method].to_sym
    title,opt = ["蒸気補正電力 季節変動" , { }]
    opt.merge!(:graph_file => "by_month",:title => title)
    @power = @PowerModel.average_group_by_month_maybe3line
    @PowerModel.gnuplot_by_month(@factory_id,@power,method,opt)
    @graph_file =  opt[:graph_file]
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month #
    method = params[@Domain][:method].to_sym
    title,opt = TITLE_ALLMONTH[method]
    opt.merge!(:graph_file => "selected") if  params[@Domain][:powers] == :maybe3lines
    graph_all_month_sub(method,title,opt)
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

    @power = @PowerModel.where(["date in (?)",days.split(",")])
    @PowerModel.gnuplot(@factory_id,@power,method,:by_date=>"%y/%m/%d",:yitle =>title )
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
                        :graph_file => "_#{lines}#{shape}_#{@factory_id}".sub(/\+/,"p")) 
  end
  def graph_all_month_sub(method,title,opt={ })
    graph_file = opt[:graph_file] ? opt[:graph_file].sub(/\+/,"p") : ""
    opt.merge!(:graph_file => "all_month#{graph_file}_#{method}_#{@factory_id}" ) 
    @graph_file =  opt[:graph_file]
    unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{opt[:graph_file]}.gif") == true
      #months = @MonthModel.all
      if params[@Domain][:powers]
        @power=@PowerModel.send(params[@Domain][:powers].to_sym)
      else
        @power=@PowerModel.power_all(@factory_id)
        @power = select_by_( @power,opt[:find]) if  opt[:find] 
      end
      @PowerModel.gnuplot(@factory_id,@power,method,opt.merge(:title => title))
    end

    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_standerd
    line = params[@Domain][:lines].to_i
    @graph_file = "standerd_#{line}_#{@factory_id}"
    opt = { :graph_file => @graph_file }

    @TYTLE = "標準電力消費 #{line}稼働"
    unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
      @power = @PowerModel.where( ["line = ?",line])
      @PowerModel.gnuplot(@factory_id,@power,:standerd,opt.merge(:title => @TYTLE ))
    end

    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_patern(method,title,shapes,opt={ })
    @graph_file ||=  "all_month_patern_" + ( shapes || "unsorted")+"_#{@factory_id}"
    unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
      line_shape = ( if   shapes ; Shimada::Power::Paterns[shapes]
                     else Shimada::Power::Un_sorted
                     end ).map{ |ls| ls.split("",2)}
      months = @MonthModel.all
      @power=@PowerModel.by_patern(@factory_id,shapes)
      #months.map{ |m| m.powers}.flatten.
      #select{ |power| line_shape.any?{ |line,shape| power.lines == line.to_i && power.shape_is == shape }}
      opt.merge!({ :by_ => :line_shape,:title => (title ? title : params[@Domain][:shape]), :graph_file => @graph_file})
      @PowerModel.gnuplot(@factory_id,@power,method,opt)
    end
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_all_month_lines
    action = params[@Domain][:action]
    label  = params[@Domain][:label]
    shape  =  params[@Domain][:shape]
    shape  = nil if shape == "未分類"
    title = label + (action == "revise_by_vaper_3" ? "蒸気補正" : "")
    @graph_file =  "all_month_patern_#{action}" + ( shape || "unsorted")+"_#{@factory_id}"
    graph_all_month_patern(action,title,shape,{ :title => title,:mode =>action ,:fitting => :standerd })
  end
  def graph_deform
    action = params[@Domain][:action]
    label  = params[@Domain][:label]
    deform  =  params[@Domain][:deform]

    graph_all_month_deform(action,label,deform)

  end
  def graph_all_month_deform(method,title,deform_lbl)
    @graph_file =  "all_month_patern_" + deform_lbl +"_#{@factory_id}"
    unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
      deform = Shimada::Power::Deforms[deform_lbl]
      conditions = 
        case deform
        when "all" ;  "deform is not null and date < '2014-7-1' and shimada_factory_id = #{@factory_id}"
        when "null";  "deform is null and date is not null and date < '2014-7-1' and shimada_factory_id = #{@factory_id}"
        else       ; "deform like '%#{deform}%' and date < '2014-7-1' and shimada_factory_id = #{@factory_id}"
        end
      @power,by_ = 
        case deform
        when "all" ; [ @PowerModel.where(conditions),{ :by_ => :deform}]
        when "null"; [ @PowerModel.where(conditions),{ :by_date => "%y/%m"}]
        else       ; [ @PowerModel.where(conditions),{ :by_date => "%y/%m/%d" }]
        end
      opt = { :title => deform_lbl,:graph_file => @graph_file}.merge(by_)
      @PowerModel.gnuplot(@factory_id,@power,method,opt) 
    end
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_vaper
    line =  (params[@Domain] && params[@Domain][:line]) ? params[@Domain][:line] : nil 
    method =   (params[@Domain] && params[@Domain][:method]) ? params[@Domain][:method] : :revise_by_temp
    if params[@Domain] && params[@Domain][:each_month]
      @MonthModel.all.each{ |month| graph_temp_(month)}
    else
      @graph_file =  "all_month_vs_vaper_#{method}" + (line ? line : "")+"_#{@factory_id}"
      unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
        conditions = line ?  [" and line = ? ", line ] :  ["", [] ]
        @power = @PowerModel.power_all(@factory_id,conditions)
        @TYTLE = "蒸気量-#{method == 'powers' ? '未補正' : ''}消費電力 全月度 " + ( line ? line+"ライン稼働" : "")

        @PowerModel.gnuplot(@factory_id,@power,method,:by_date => "%y/%m",:title => @TYTLE,:vs_temp => :vaper,
                               :graph_file =>  @graph_file, :with_Approximation => true,
                               :range => (7..19))
      end
    end
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_temp
    line =  (params[@Domain] && params[@Domain][:line]) ? params[@Domain][:line] : nil 
    if params[@Domain] && params[@Domain][:each_month]
      @MonthModel.all.each{ |month| graph_temp_(month)}
    else
      @graph_file =  "all_month_vs_temp" + (line ? "_"+line : "")+"_#{@factory_id}"
      unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
        conditions = line ?  [" and line = ? ", line ] :  ["", [] ]
        @power = @PowerModel.power_all(@factory_id,conditions)
        @TYTLE = "温度-消費電力 全月度 " + ( line ? line+"ライン稼働" : "")

        @PowerModel.gnuplot(@factory_id,@power,:powers,:by_date => "%y/%m",:title => @TYTLE,:vs_temp => true,
                               :graph_file =>  @graph_file, :with_Approximation => true,
                               :range => (7..19))
      end
    end
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_bugs
    if params[@Domain] && params[@Domain][:each_month]
      @MonthModel.all.each{ |month| graph_bug_(month)}
    else
        method = params[@Domain][:method]
        label,ext = label_extension_by(method)
      @graph_file =  "all_month_vs_bugs_#{ext}"+"_#{@factory_id}"
      unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
        #conditions = line ?  [" and line = ? ", line ] :  ["", [] ]
        @power =  @PowerModel.where( "hukurosu is not null")
        logger.debug("GRAPH_ALL_MONTH_BUGS moethod=#{method}")
        @TYTLE = "袋数-消費電力(#{label}) "
        
        @PowerModel.gnuplot(@factory_id,@power,method,:by_date => "%y/%m",:title => @TYTLE,:vs_bugs => true,
                               :graph_file =>  @graph_file)# :with_Approximation => true,
        #:range => (7..19))
      end
    end
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_offset
    offset = params[@Domain][:offset]
    method = params[@Domain][:method].to_sym
    @graph_file =  "all_month_by_offset_#{offset}#{method}"+"_#{@factory_id}"
    unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
      @power = @PowerModel.by_offset(offset,method)
      @TYTLE = "消費電力 オフセット #{%w(低 中 高)[offset.to_i]} "
logger.debug("##### GRAPH_ALL_MONTH_OFFSET:method=#{method},offset=#{offset},@power.eize=#{@power.size}")
      @PowerModel.gnuplot(@factory_id,@power,method,:title => @TYTLE,:graph_file => @graph_file,:by_date => "%y/%m")#:line_shape)
    end
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_bugs_offset
    @graph_file =  "all_month_vs_bugs_offset"+"_#{@factory_id}"
    unless File.exist?(Rails.root+"tmp/shimada/giffiles/#{@graph_file}.gif") == true
      #conditions = line ?  [" and line = ? ", line ] :  ["", [] ]
      @power = @PowerModel.where( "hukurosu > 0.0  and date < '2014-7-1'")
      @TYTLE = "袋数-消費電力 オフセット 全月度 "
      
      @PowerModel.gnuplot_histgram(@factory_id,@power,:offset_of_hukurosu_vs_pw,:title => @TYTLE,
                                      :graph_file =>  @graph_file,
                                      :min => -500,:max => -500+250*21,:steps => 21
                                      )
    end
    render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_all_month_deviation_vs_temp
    @power=@PowerModel.power_all(@factory_id)
    by_ = params[@Domain][:by_]
    method = params[@Domain][:method].to_sym
    title = { :deviation_of_revice => "電力", :deviation_of_difference => "差分"}[method]
    @TYTLE = "最高温度-#{title}分散 全月度"
    @PowerModel.gnuplot(@factory_id,@power,method,:by_ => by_ , :title => @TYTLE,:vste_mp => true)
    render :action => :graph,:layout => "hospital_error_disp"
  end
end
