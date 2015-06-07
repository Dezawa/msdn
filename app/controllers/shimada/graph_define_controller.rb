# -*- coding: utf-8 -*-
class Shimada::GraphDefineController <  Shimada::Controller
  Labels =
    [HtmlSelect.new(:factory_id ,"工場"      ,correction: Shimada::Factory.all.pluck(:name,:id )),
     HtmlText.new(:name      ,"グラフ名"      ),
     HtmlText.new(:title     ,"グラフタイトル"),
     HtmlText.new(:graph_type,"型"),
     HtmlText.new(:serials   ,"計測器シリアル",display: :serials_to_s),
    ]
  def set_instanse_variable
    super
    model  Shimada::GraphDefine
    @labels = Labels
    @TableEdit  = [:add_edit_buttoms,:csv_out, :csv_up_buttom]
    
  end
end
