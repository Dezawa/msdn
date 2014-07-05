# -*- coding: utf-8 -*-
module  Shimada::GraphMonth
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
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_difference_ave", :link_label => "差分平均",:htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_diffdiff", :link_label => "二階差", :htmloption => Popup}),
     #HtmlLink.new(:id,"",:link => { :url => "/shimada/month/graph_month_ave", :link_label => "平均化",  :htmloption => Popup}),
    ]

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
