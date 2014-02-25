# -*- coding: utf-8 -*-
class Ubr::SoukoPlanController <  Ubr::Controller
  include ExcelToCsv
  before_filter :login_required 


   Labels = [HtmlText.new(:name,"ページタイトル",:size =>7),
             HtmlText.new(:stat_name_list,"統計出力枠名",:size => 20),
             HtmlText.new(:stat_reg_list,"統計出力枠抽出",:size => 20),
             HtmlText.new(:offset_x,"位置X",:align=>:right,:size => 3),
             HtmlText.new(:offset_y,"位置Y",:align=>:right,:size => 3),
             HtmlText.new(:stat_offset_x,"位置X",:align=>:right,:size => 3),
             HtmlText.new(:stat_offset_y,"位置Y",:align=>:right,:size => 3),
             HtmlText.new(:stat_font,"font code",:align=>:right,:size => 1),
             HtmlText.new(:stat_point,"font_point code",:align=>:right,:size => 1),
             HtmlSelect.new(:landscape,"用紙方向"    ,:correction =>[["縦",false],["横",true]])
            ]

   FloorLabels =
    [HtmlSelect.new(:souko_floor_id,"倉庫",
                    :correction => Ubr::SoukoFloor.all.map{ |floor| [floor.name,floor.id]}),
     HtmlText.new(:floor_offset_x,"位置X",:align=>:right,:size => 3),
     HtmlText.new(:floor_offset_y,"位置Y",:align=>:right,:size => 3)
    ]

  def set_instanse_variable
    @labels= Labels
    @AssosiationLabels= FloorLabels
    @TableHeaderMulti = [3,[2,"倉庫書き出し"],[4,"集計書き出し"],1]
    @Model = Ubr::SoukoPlan
    @ThroughTable = Ubr::SoukoFloorSoukoPlan
    @assosiation = :souko_floor_souko_plans
    @TYTLE = "UBR：PDFページ管理"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :name
   @Show = true
    @Delete = @editor
    #@Edit =   @editor
    @TableEdit  =  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table,"編集"],
                    [:form,:csv_out,"CSVダウンロード"],
                    [:csv_up_buttom,:dmy,:dmy]] 
  end

  def index
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
