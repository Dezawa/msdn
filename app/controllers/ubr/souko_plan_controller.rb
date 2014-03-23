# -*- coding: utf-8 -*-
class Ubr::SoukoPlanController <  Ubr::Controller
  include ExcelToCsv
  before_filter :login_required 


   Labels = [HtmlText.new(:name,"ページタイトル",:size =>7),
             HtmlText.new(:stat_name_list,"統計出力枠名",:size => 20),
             HtmlText.new(:stat_reg_list,"統計出力枠抽出",:size => 20),
             HtmlText.new(:offset_x,"X",:align=>:right,:size => 3),
             HtmlText.new(:offset_y,"Y",:align=>:right,:size => 3),
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
    @TableHeaderMulti = [3,[2,"描画原点"],[4,"集計書き出し"],1]
    @Model = Ubr::SoukoPlan
    @ThroughTable = Ubr::SoukoFloorSoukoPlan
    @assosiation = :souko_floor_souko_plans
    @TYTLE = "UBR：PDFページ管理"
    @AfterIndexHtml = "<p>描画原点：X,Y： 紙の左上からの mm
    <br>
    集計書き出し　：描画原点からの mm
    <br>
    <br>統計出力枠名：総量などを出力する倉庫名を\" \"(空白)で区切って並べる
    <br>統計出力枠抽出：その倉庫名に出力する枠を選択するための正規表現式をを\" \"(空白)で区切って並べる
    <br>　　　　　　例：^5[JIK]　   ^5：枠名の先頭文字は5。[JIK]：次の文字は JIKのどれか
"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :name
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

  def index
    if params[:prefix]
      @FindOption = {:conditions => "name like '#{params[:prefix]}%'" } #,params[:prefix] ]    }
    end
    super
  end

  def show ;
    @model = @Model.find(params[:id])
    @assosiations = @model.souko_floor_souko_plans #send(@association)
    @image_source = "/ubr/souko_plan/show_plan/#{params[:id]}"
    super
  end

  def show_plan
    plan = @Model.find(params[:id])
    plan.show
    send_file RAILS_ROOT+"/tmp/ubr/Plan%d.gif"%params[:id],
    :type => 'image/pdf', :disposition => 'inline'
  end
end
