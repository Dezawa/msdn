# -*- coding: utf-8 -*-
class Ubr::WallController <  Ubr::Controller
  include ExcelToCsv
  before_filter :login_required 

   Labels = [HtmlText.new(:name,"壁群名",:size =>7),
             HtmlSelect.new(:souko_floor_id,"倉庫",:size=> 5,
                            :correction => Ubr::SoukoFloor.all.map{ |f| [f.name,f.id]}
                            ),
             HtmlText.new(:x0,"始点X",:align=>:right,:size => 3),
             HtmlText.new(:y0,"始点Y",:align=>:right,:size => 3),
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
    #@TableHeaderMulti = [3,[2,"描画原点"],[4,"集計書き出し"],1]
    @Model = Ubr::Wall
    #@ThroughTable = Ubr::SoukoFloorSoukoPlan
    #@assosiation = :souko_floor_souko_plans
    @TYTLE = "UBR：倉庫柱管理"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :souko_floor_id
    @FindOption = { :order => "souko_floor_id"}
    @Show = true
    @Delete = @editor
    #@Edit =   @editor
    @TableEdit  =  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table,"編集"],
                    [:form,:csv_out,"CSVダウンロード"],
                    [:csv_up_buttom,:dmy,:dmy]]  
    @CSVatrs = Labels.map{|lbl| lbl.symbol}
    @CSVlabels= Labels.map{|lbl| lbl.label}
    super
  end

  def ddindex
    if params[:prefix]
      @FindOption = {:conditions => "name like '#{params[:prefix]}%'" } #,params[:prefix] ]    }
    end
    super
  end

  def show ;
    @model = @Model.find(params[:id])
    @assosiations = @model.souko_floor_souko_plans #send(@association)
    #@AssosiationLabels = AssosiationLabels
    super
  end

end
