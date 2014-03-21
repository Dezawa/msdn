# -*- coding: utf-8 -*-
class Ubr::PillarController <  Ubr::Controller
  include ExcelToCsv
  before_filter :login_required 

   Labels = [HtmlText.new(:name,"柱群名",:size =>7),
             HtmlSelect.new(:souko_floor_id,"倉庫",:size=> 5,
                            :correction => Ubr::SoukoFloor.all.map{ |f| [f.name,f.id]}
                            ),
             HtmlText.new(:kazu_x,"横本数",:align=>:right,:size => 3),
             HtmlText.new(:kazu_y,"縦本数",:align=>:right,:size => 3),
             HtmlText.new(:start_x,"X",:size => 3),
             HtmlText.new(:start_y,"Y",:align=>:right,:size => 3),
             HtmlText.new(:kankaku_x,"横",:align=>:right,:size => 3),
             HtmlText.new(:kankaku_y,"縦",:align=>:right,:size => 3),
             HtmlText.new(:size_x,"横",:align=>:right,:size => 3),
             HtmlText.new(:size_y,"縦",:align=>:right,:size => 3)
            ]

  def set_instanse_variable
    @labels= Labels
    #@AssosiationLabels= FloorLabels
    @TableHeaderMulti = [4,[2,"開始位置"],[2,"間隔"],[2,"柱幅"]]
    @Model = Ubr::Pillar
    #@ThroughTable = Ubr::SoukoFloorSoukoPlan
    #@assosiation = :souko_floor_souko_plans
    @TYTLE = "UBR：倉庫柱管理"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :souko_floor_id
    @FindOption = { :order => "souko_floor_id"}
    #@Show = true
    @Delete = @editor
    @Edit =   @editor
    @TableEdit  =  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table,"編集"],
                    [:form,:csv_out,"CSVダウンロード"],
                    [:csv_up_buttom,:dmy,:dmy]]  
    @CSVatrs = Labels.map{|lbl| lbl.symbol}
    @CSVlabels= Labels.map{|lbl| lbl.symbol}
    super
  end

end
