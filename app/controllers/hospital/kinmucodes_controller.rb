# -*- coding: utf-8 -*-
class Hospital::KinmucodesController < Hospital::Controller
  before_filter :set_instanse_variable

  Labels= [HtmlText.new(:id,"ID",:ro => true),
           HtmlSelect.new(:kinmukubun_id ,"勤務"      ,
                          :correction =>  Hospital::Const::Kinmukubun),
           HtmlText.new(:code            ,"Code"      ,:size =>3),
           HtmlText.new(:name            ,"名称"                 ),
           HtmlText.new(:color           ,"色"        ,:size =>3),
           HtmlText.new(:start           ,"開始"          ,:size =>3),
           HtmlText.new(:finish          ,"終了"          ,:size =>3),
           HtmlCheck.new(:with_mousiokuri,"申送り"                  ),
           HtmlText.new(:nenkyuu         ,"年休"          ,:size =>3),
           HtmlText.new(:am              ,"午前"          ,:size =>3),
           HtmlText.new(:pm              ,"午後"          ,:size =>3),
           HtmlText.new(:night           ,"準夜"          ,:size =>3),
           HtmlText.new(:midnight        ,"深夜"          ,:size =>3),
           HtmlText.new(:am              ,"前応"      ,:size =>3),
           HtmlText.new(:pm              ,"後応"      ,:size =>3),
           HtmlText.new(:night2          ,"準応"      ,:size =>3),
           HtmlText.new(:midnight2       ,"深応"      ,:size =>3),
           HtmlText.new(:main_daytime    ,"日勤"  ,:size =>3),
           HtmlText.new(:main_nignt      ,"夜勤"  ,:size =>3),
           HtmlText.new(:main_next       ,"翌夜",:size =>3),
           HtmlText.new(:sub_daytime     ,"日勤"  ,:size =>3),
           HtmlText.new(:sub_night       ,"夜勤"  ,:size =>3),
           HtmlText.new(:sub_next        ,"翌夜",:size =>3)
]

  def set_instanse_variable
    @Model= Hospital::Kinmucode
    @TYTLE = "記号一覧"
    @Domain= @Model.name.underscore
    @TableEdit = true
    @TableHeader = :kinmucode_header
    @Edit = true
    #@Delete=true
    @labels= Labels
    super
  end
end
