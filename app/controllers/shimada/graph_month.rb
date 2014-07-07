# -*- coding: utf-8 -*-
module  Shimada::GraphMonth
  Popup = %Q!onClick="window.open('/shimada/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 


  # 月別画面でのリンクボタン
  PowerLabels =
    [ HtmlLink.new(:id,"",:link => { :link_label => "グラフ"   , :url => "/shimada/month/graph"            , :htmloption => Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "温度補正"  ,:url => "/shimada/month/graph_reviced"    , :htmloption => Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "補正後平均",:url => "/shimada/month/graph_reviced_ave", tmloption => Popup}),
      #HtmlLink.new(:id,"",:link => { :link_label => "対温度"   , :url => "/shimada/month/graph_temp"    , htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "正規化"   , :url => "/shimada/month/graph_nomalize" , :htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "差分"     , :url => "/shimada/month/graph_difference",:htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "差分平均" , :url => "/shimada/month/graph_difference_ave",:htmloption =>Popup}),
      HtmlLink.new(:id,"",:link => { :link_label => "差分差分" , :url => "/shimada/month/graph_diffdiff",:htmloption =>Popup}),
      #HtmlCeckForSelect.new(:id,""),
      HtmlDate.new(:date,"月日",:ro=>true,:size =>4,:tform => "%m/%d"),
      HtmlNum.new(:lines,"稼<br>働<br>数",:ro => true,:size =>2),
      HtmlText.new(:shape_is,"形<br>状",:ro => true,:size =>2,:ro => true),
      HtmlText.new(:shape,"形<br>状",:ro => true,:size =>2)
      
    ] + 
    (1..4).map{ |i| HtmlNum.new("na#{i}".to_sym,"na#{i}",:tform => "%.3f")}+
    [HtmlNum.new(:discriminant,"判別式",:size =>2,:tform => "%.6f"),
     HtmlNum.new(:x1,"x1",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:x2,"x2",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:y1,"f3(左)",:size =>2,:tform => "%.3f"),
     HtmlNum.new(:y2,"f3(右)",:size =>2,:tform => "%.3f"),
     HtmlNum.new(:f3x1,"f3x1",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:f3x2,"f3x2",:size =>2,:tform => "%.1f"),
     HtmlNum.new(:f3x3,"f3x3",:size =>2,:tform => "%.1f"),
     
    ]+
      Shimada::Power::Hours.map{ |h| 
        HtmlNum.new( h.to_sym,h.sub(/hour0?/,""),:tform => "%.0f",:size => 3)
      }

    Month_action_buttoms =
      [12,
       [[:input_and_action,"graph_month_line_shape_","数型",{:size=>2 ,:popup => "graph_month"}]] +
       %w(3-- 4-- 3-0 4-0 3-+ 4-+ 200 300 400 3F 4F 3O 4O 3他 4他).
       map{ |patern| line,shape = patern.split("",2); 
         [:popup,"graph_line","#{line}line#{shape}",{ :win_name => "graph",:shape => patern}]
       }
      ]

  def graph_month_sub(method,title,opt={ })
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    month =  @Model.find(id)
    
    opt.merge!(:graph_file => "giffiles/month_#{ month.month.strftime('%Y%m')}#{opt[:graph_file]}_#{method}" ) 
    @graph_file =  opt[:graph_file]

    unless File.exist?(RAILS_ROOT+"/tmp/shimada/#{opt[:graph_file]}.gif") == true
      #@power = opt[:find] ? send(opt[:find].first,month, opt[:find].last)  : month.powers
      @power = opt[:find] ? select_by_(month.powers,opt[:find])  : month.powers
      Shimada::Power.gnuplot(@power,method,opt)
   end
      @TYTLE = title + month.month.strftime("(%Y年%m月)")
      render :action => :graph,:layout => "hospital_error_disp"
  end

  def graph_month_line_shape_
    graph_line_shape(params[@Domain][:graph_month_line_shape_])
  end

  def graph_line_shape(lines,shape=nil)
logger.debug("GRAPH_LINE_SHAPE: #{lines}  #{shape.nil?}")
    lines,shape = lines.split("",2) unless shape
    graph_month_sub(:revise_by_temp,"#{lines}line #{shape}",:by_day => true,
                    :find => {:lines => lines.to_i,:shape_is => shape},
                    :graph_file => "_#{lines}#{shape}".sub(/\+/,"p")) 
  end

  def graph_line ;   graph_line_shape( params[@Domain][:shape] ) ;  end

  def graph_month         ;graph_month_sub(:powers,"消費電力推移") ; end
  def graph_month_reviced ;graph_month_sub(:revise_by_temp,"補正消費電力推移") ; end
  def graph_month_reviced_ave ;graph_month_sub(:revise_by_temp_ave,"補正平均消費電力推移") ; end
  def graph_month_nomalized ;graph_month_sub(:normalized,"正規化消費電力推移",:by_shape => true) ; end
  def graph_month_ave   ;graph_month_sub(:move_ave,"平均消費電力推移") ; end
  def graph_month_difference   ;graph_month_sub(:difference,"月度差分",:by_shape => true) ; end
  def graph_month_difference_ave   ;graph_month_sub(:difference_ave,"月度差分平均",:by_shape => true) ; end
  def graph_month_diffdiff   ;graph_month_sub(:diffdiff,"月度二階差",:by_shape => true) ; end
  def graph_line0       ; graph_month_sub(:revise_by_temp_ave,"稼働０ライン",:find => {:lines => 0}) ;  end
  def graph_line1       ; graph_month_sub(:revise_by_temp_ave,"稼働１ライン",:find => {:lines => 1}) ;  end
  def graph_line2       ; graph_month_sub(:revise_by_temp_ave,"稼働２ライン",:find => {:lines => 2}) ;  end
  def graph_line3       ; graph_month_sub(:revise_by_temp_ave,"稼働３ライン",:find => {:lines => 3}) ;  end
  def graph_line4       ; graph_month_sub(:revise_by_temp_ave,"稼働４ライン",:find => {:lines => 4}) ;  end
  def graph_line5       ; graph_month_sub(:revise_by_temp_ave,"稼働５ライン",:find => {:lines => 5}) ;  end
  def graph_line_all    ; graph_month_sub(:revise_by_temp_ave,"稼働５ライン",:by_line => true ) ;  end
  def graph_month_lines_types
    graph_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_line_shape => true,:graph_file => " lines_types") 
  end
  def graph_shape_all_F ; graph_month_sub(:revise_by_temp_ave,"稼働F",:find => {:shape => "Flat"} ) ;  end
  def graph_shape_all_D ; graph_month_sub(:revise_by_temp_ave,"稼働D"  ,:find => {:shape => "Reduce"});end
  def graph_shape_all_O ; graph_month_sub(:revise_by_temp_ave,"稼働O"  ,:find => {:shape => "Other"} ) ;  end
  def graph_shape_all   ; graph_month_sub(:revise_by_temp_ave,"稼働変化別",:by_shape => true ) ;  end

  def graph_month_temp(opt={ })
    id = params[@Domain] ? params[@Domain][:id] : params[:id] 
    month = @Model.find(id)
    @power = month.powers
 
    opt.merge!(:graph_file => "giffiles/month_temp#{ month.month.strftime('%Y%m')}#{opt[:graph_file]}" ) 
    @graph_file =  opt[:graph_file]
   Shimada::Power.gnuplot_by_temp(@power,opt)
    @TYTLE = "温度-消費電力" + @power.first.date.strftime("(%Y年%m月)")
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
