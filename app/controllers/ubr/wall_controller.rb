# -*- coding: utf-8 -*-
class Ubr::WallController <  Ubr::Controller
  include ExcelToCsv
  before_filter :authenticate_user! 

   Labels = [HtmlText.new(:name,"壁群名",:size =>7),
             HtmlSelect.new(:souko_floor_id,"倉庫",:size=> 5,
                            :correction => Ubr::SoukoFloor.all.map{ |f| [f.name,f.id]}
                            ),
             HtmlText.new(:x0,"X",:align=>:right,:size => 3),
             HtmlText.new(:y0,"Y",:align=>:right,:size => 3),
             HtmlText.new(:dx1,"dX1",:align=>:right,:size => 3),
             HtmlText.new(:dy1,"dY1",:align=>:right,:size => 3),
             HtmlText.new(:dx2,"dX2",:align=>:right,:size => 3),
             HtmlText.new(:dy2,"dY2",:align=>:right,:size => 3),
             HtmlText.new(:dx3,"dX3",:align=>:right,:size => 3),
             HtmlText.new(:dy3,"dY3",:align=>:right,:size => 3),
             HtmlText.new(:dx4,"dX4",:align=>:right,:size => 3),
             HtmlText.new(:dy4,"dY4",:align=>:right,:size => 3)
            ]

  def set_instanse_variable
    @labels= Labels
    #@AssosiationLabels= FloorLabels
    @TableHeaderDouble = [2,[2,"始点"],[2,"角1への移動量"],[2,"角2"],[2,"角3"],[2,"角4"]]
    @Model = Ubr::Wall
    #@ThroughTable = Ubr::SoukoFloorSoukoPlan
    #@assosiation = :souko_floor_souko_plans
    @TYTLE = "UBR：倉庫壁管理"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :souko_floor_id
    @FindOption = { :order => "souko_floor_id"}
    @FindOrder = "souko_floor_id"
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
