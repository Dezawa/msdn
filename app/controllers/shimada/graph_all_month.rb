# -*- coding: utf-8 -*-
module Shimada::GraphAllMonth

    AllMonthaction_buttoms = 
      [9 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :win_name => "graph"} ],
        #[:popup,:graph_all_month_lines_types,"全月度稼働変化別",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_linesS ,"稼働無",{ :win_name => "graph"}],
        [:popup,:graph_all_month_lines4F,"稼働4full",{ :win_name => "graph"}],
        [:popup,:graph_all_month_lines4D,"稼働4から3へ",{ :win_name => "graph"}],
        [:popup,:graph_all_month_lines3F,"稼働3full",{ :win_name => "graph"}],
        [:popup,:graph_all_month_lines3H,"稼働3一時低下",{ :win_name => "graph"}],
        [:popup,:graph_all_month_lines4H,"稼働4一時低下",{ :win_name => "graph"}],
        [:popup,:graph_all_month_linesOT ,"その他",{ :win_name => "graph"}],
        [:popup,:graph_all_month_linesE ,"未分類",{ :win_name => "graph"}],

        [:popup,:graph_all_month_reviced,"全月度温度補正",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_reviced_ave,"全月度温度補正平均化",{ :win_name => "graph"} ],
        [:popup,"graph_all_month_line3_mm","3line--",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_mp","3line-+",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_m0","3line-0",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_00","3line00",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_F" ,"3lineF" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_O" ,"3lineO" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_0p","3line0+",{ :win_name => "graph"}],


        [:popup,:graph_all_month_nomalized,"全月度正規化",{ :win_name => "graph"}  ] ,
        [:popup,"graph_all_month_line4_mm","4line--",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_m0","4line-0",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_mp","4line-+",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_00","4line00",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_F" ,"4lineF" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_O" ,"4lineO" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_H" ,"4lineH" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line4_OT","4line他",{ :win_name => "graph"}],

        [:popup,:graph_all_month_temp,"全月度対温度",{ :win_name => "graph"} ],
        [:popup,:graph_all_month_difference,"全月度差分",{ :win_name => "graph"} ],
        [:popup,"graph_all_month_line0_S" ,"0lineS" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line1_S" ,"1lineS" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line2_00","2line00",{ :win_name => "graph"}],
        [:popup,"graph_all_month_line2_O" ,"2lineO" ,{ :win_name => "graph"}],
        [:popup,"graph_all_month_line3_OT","3line他",{ :win_name => "graph"}],

        #[:popup,:graph_all_month_ave,"全月度平均化",{ :win_name => "graph"}  ] ,
        #[:popup,"graph_all_month_line5_mm","5line--",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_m0","5line-0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_mp","5line-+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_pm","3line+-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_pm","4line+-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_pm","5line+-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_p0","3line+0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_p0","4line+0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_p0","5line+0",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_pp","3line++",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_pp","4line++",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_pp","5line++",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_00","5line00",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_0p","4line0+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_0p","5line0+",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line3_pp","3line0-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line4_pp","4line0-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_pp","5line0-",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_F","4lineF",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_O","5lineO",{ :win_name => "graph"}],
        #[:popup,"graph_all_month_line5_OT","5line他",{ :win_name => "graph"}],

       #[:form,:graph_selected_months,"選択月度グラフ",{ :form_notclose => true,:win_name => "graph"}]
      ]]
  def graph_all_month_reviced ;    graph_all_month_sub(:revise_by_temp, "補正消費電力推移 全月度",:by_month => true) ;  end
  def graph_all_month_reviced_ave ; graph_all_month_sub(:revise_by_temp_ave,"補正消費電力平均化推移 全月度",:by_month => true);end
  def graph_all_month_ave ;    graph_all_month_sub(:move_ave,"平均消費電力推移 全月度",:by_month => true);  end
  def graph_all_month_nomalized ; graph_all_month_sub(:normalized, "正規化消費電力推移 全月度",:by_shape => true);  end
  def graph_all_month            ; graph_all_month_sub(:powers,"消費電力推移 全月度",:by_month => true) ;end
  def graph_all_month_difference           ; graph_all_month_sub(:difference,"差分 全月度",:by_month => true) ;end
  def graph_all_month_difference_ave           ; graph_all_month_sub(:difference_ave,"差分 全月度",:by_month => true) ;end
  def graph_all_month_lines_types;graph_all_month_sub(:revise_by_temp_ave,"月度稼働数・型",:by_line_shape => true ) ;  end



  def graph_all_month_line3_p0;graph_all_month_line_shape( 3,"+0") ;  end
  def graph_all_month_line4_p0;graph_all_month_line_shape( 4,"+0") ;  end
  def graph_all_month_line5_p0;graph_all_month_line_shape( 5,"+0") ;  end
  def graph_all_month_line3_pp;graph_all_month_line_shape( 3,"++") ;  end
  def graph_all_month_line4_pp;graph_all_month_line_shape( 4,"++") ;  end
  def graph_all_month_line5_pp;graph_all_month_line_shape( 5,"++") ;  end
  def graph_all_month_line3_pm;graph_all_month_line_shape( 3,"+-") ;  end
  def graph_all_month_line4_pm;graph_all_month_line_shape( 4,"+-") ;  end
  def graph_all_month_line5_pm;graph_all_month_line_shape( 5,"+-") ;  end
  def graph_all_month_line2_00;graph_all_month_line_shape( 2,"00") ;  end
  def graph_all_month_line3_00;graph_all_month_line_shape( 3,"00") ;  end
  def graph_all_month_line4_00;graph_all_month_line_shape( 4,"00") ;  end
  def graph_all_month_line5_00;graph_all_month_line_shape( 5,"00") ;  end
  def graph_all_month_line3_0m;graph_all_month_line_shape( 3,"0-") ;  end
  def graph_all_month_line4_0m;graph_all_month_line_shape( 4,"0-") ;  end
  def graph_all_month_line5_0m;graph_all_month_line_shape( 5,"0-") ;  end
  def graph_all_month_line3_0p;graph_all_month_line_shape( 3,"0+") ;  end
  def graph_all_month_line4_0p;graph_all_month_line_shape( 4,"0+") ;  end
  def graph_all_month_line5_0p;graph_all_month_line_shape( 5,"0+") ;  end
  def graph_all_month_line3_m0;graph_all_month_line_shape( 3,"-0") ;  end
  def graph_all_month_line4_m0;graph_all_month_line_shape( 4,"-0") ;  end
  def graph_all_month_line5_m0;graph_all_month_line_shape( 5,"-0") ;  end
  def graph_all_month_line3_mm;graph_all_month_line_shape( 3,"--") ;  end
  def graph_all_month_line4_mm;graph_all_month_line_shape( 4,"--") ;  end
  def graph_all_month_line5_mm;graph_all_month_line_shape( 5,"--") ;  end
  def graph_all_month_line3_mp;graph_all_month_line_shape( 3,"-+") ;  end
  def graph_all_month_line4_mp;graph_all_month_line_shape( 4,"-+") ;  end
  def graph_all_month_line5_mp;graph_all_month_line_shape( 5,"-+") ;  end
  def graph_all_month_line3_F;graph_all_month_line_shape( 3,"F") ;  end
  def graph_all_month_line4_F;graph_all_month_line_shape( 4,"F") ;  end
  def graph_all_month_line5_F;graph_all_month_line_shape( 5,"F") ;  end
  def graph_all_month_line2_O;graph_all_month_line_shape( 2,"O") ;  end
  def graph_all_month_line3_O;graph_all_month_line_shape( 3,"O") ;  end
  def graph_all_month_line4_O;graph_all_month_line_shape( 4,"O") ;  end
  def graph_all_month_line5_O;graph_all_month_line_shape( 5,"O") ;  end
  def graph_all_month_line0_S;graph_all_month_line_shape( 0,"S") ;  end
  def graph_all_month_line1_S;graph_all_month_line_shape( 1,"S") ;  end
  def graph_all_month_line4_H;graph_all_month_line_shape( 4,"H") ;  end
  def graph_all_month_line3_OT;graph_all_month_line_shape( 3,"他") ;  end
  def graph_all_month_line4_OT;graph_all_month_line_shape( 4,"他") ;  end
  def graph_all_month_line5_OT;graph_all_month_line_shape( 5,"他") ;  end

  def graph_all_month_line_shape(lines,shape)
    graph_all_month_sub(:revise_by_temp,"#{lines}line #{shape}",:find => {:lines => lines,:shape_is => shape}) 
  end
  def graph_all_month_sub(method,title,opt={ })
#    opt = { :by_month => true,:graph_file => @graph_file }.merge(opt)
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    @power = select_by_( @power,opt[:find]) if  opt[:find] 
    Shimada::Power.gnuplot(@power,method,opt)
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end
  def graph_all_month_patern(method,title,shapes)
    line_shape = shapes.map{ |ls| ls.split("",2)}
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten.
      select{ |power| line_shape.any?{ |line,shape| power.lines == line.to_i && power.shape_is == shape }}
    Shimada::Power.gnuplot(@power,method,:by_line_shape => true )
    @TYTLE = title
    render :action => :graph,:layout => "hospital_error_disp"
  end

  Paterns = {
    "S" => %w(0S 1S)          ,"4H" => %w(4H)    ,"4F" => %w(400 4F),"4D" => %w(4-- 4-+ 4-0),
    "3F" => %w(3-- 30- 3F 300),"3H" => %w(3H)    ,"OT" => %w(1他 2他 3他 4他)   }
  AllPatern = %w(0 1 2 3 4 5).product(Shimada::Power::Shapes).map{ |l,s| l+s } 
  Un_sorted = AllPatern - Paterns.values.flatten

  def graph_all_month_linesS;  graph_all_month_patern(:revise_by_temp,"稼働無"       ,Paterns["S" ] ) ;  end
  def graph_all_month_lines4F; graph_all_month_patern(:revise_by_temp,"稼働4"        ,Paterns["4F"] ) ;  end
  def graph_all_month_lines4D; graph_all_month_patern(:revise_by_temp,"稼働4→3"     ,Paterns["4D"] ) ;  end
  
  def graph_all_month_lines3F; graph_all_month_patern(:revise_by_temp,"稼働3"        ,Paterns["3F"] ) ;  end
  def graph_all_month_lines3H; graph_all_month_patern(:revise_by_temp,"稼働3一時低下",Paterns["3H"] ) ;  end
  def graph_all_month_lines4H; graph_all_month_patern(:revise_by_temp,"稼働4一時低下",Paterns["4H"] ) ;  end
  def graph_all_month_linesOT; graph_all_month_patern(:revise_by_temp,"その他"       ,Paterns["OT"] ) ;  end
  def graph_all_month_linesE;  graph_all_month_patern(:revise_by_temp,"未分類"       ,Un_sorted     ) ;  end


  def graph_all_month_temp
    months = Shimada::Month.all
    @power=months.map{ |m| m.powers}.flatten
    Shimada::Power.gnuplot_by_temp(@power,:by_month => true,:with_Approximation => true)
    @TYTLE = "温度-消費電力 全月度"
    render :action => :graph,:layout => "hospital_error_disp"
  end

end
