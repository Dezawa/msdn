# -*- coding: utf-8 -*-
module  Power::GraphLinks
  Popup = %Q!onClick="window.open('/power/month/graph','graph','width=300,height=300,scrollbars=yes');" target="graph"! 
  POPUP = {:htmloption => Popup}
  SGRPH="/shimada/month/graph_month?method="
  LinkKye_Popup = {:htmloption => Popup,:key => :id,:key_val => :id}
  Labels_for_month_index = #%q!
    [
     HtmlDate.new(:month,"年月",:align=>:right,:ro=>true,:size =>7,:tform => "%y/%m"),
     HtmlLink.new(:id,"",:link => LinkKye_Popup.merge( :url => "month/monthly_graph", :link_label => "グラフ",:option => :power )),
     HtmlLink.new(:id,"",:link => LinkKye_Popup.merge( :url => "month/monthly_scatter", :link_label => "対温度",:option => "temp-power" )),
     HtmlLink.new(:id,"",:link => LinkKye_Popup.merge( :url => "month/monthly_graph", :link_label => "温度補正",:option => :revise_temp)),
    ] #!


  Actions_for_month_index = %q!
      [7 ,
       [
        [:popup,:graph_all_month,"全月度グラフ",{ :option => :power} ],
        [:popup,:graph_all_month,"全月度対温度",{ :option => "temp-power"} ],
       ]
      ]
!
  
end

