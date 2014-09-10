# -*- coding: utf-8 -*-
class Ubr::SoukoFloorController <  Ubr::Controller
  include ExcelToCsv
  before_filter :login_required 


   Labels = [HtmlText.new(:name,"倉庫名",:size =>7),
             HtmlText.new(:outline_x0,"外枠左上X",:align=>:right,:size => 5),
             HtmlText.new(:outline_y0,"外枠左上Y",:align=>:right,:size => 5),
             HtmlText.new(:outline_x1,"外枠右下X",:align=>:right,:size => 5),
             HtmlText.new(:outline_y1,"外枠右下Y",:align=>:right,:size => 5)
            ]
  
  AssosiationLabels =
    [HtmlText.new(:content  ,"枠名前半",:size =>3),
     HtmlText.new(:sufix,"開始文字",:size => 3),
     HtmlText.new(:max,"最終文字",:size => 3)
    ]
    
  def set_instanse_variable
    @labels= Labels
    #@TableHeaderDouble = [2,[2,"枠名後半"],[2,"対倉庫相対位置"],[2,"ブロック名相対位置対ブロック"] ]
    @Model = Ubr::SoukoFloor
    @AssociationTable = Ubr::WakuBlock
    @AssosiationLabels = AssosiationLabels
    @assosiation = :waku_blocks
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :name
    @Delete = @editor
    @Show =   @editor
    @TableEdit  =  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table,"編集"],
                    [:form,:csv_out,"CSVダウンロード"],
                    [:csv_up_buttom,:dmy,:dmy]] 
    @CSVatrs = Labels.map{|lbl| lbl.symbol}
    @CSVlabels= Labels.map{|lbl| lbl.label}
  end

  def index
    if params[:prefix]
      @FindOption = {:conditions => "name like '#{params[:prefix]}%'" } #,params[:prefix] ]    }
    end
    super
  end

  def show ;
    @model = @Model.find(params[:id])
    @assosiations = @model.waku_blocks
    @AssosiationLabels = AssosiationLabels
    @WallLabels = Ubr::WallController::Labels
    @PillarLabels = Ubr::PillarController::Labels
    @model = @Model.find(params[:id])

  end

  def show_floor
    floor = @Model.find(params[:id])
    floor.show
    send_file Rails.root+"tmp/ubr/Floor%d.gif"%params[:id], :type => 'image/pdf', :disposition => 'inline'
  end

  def delete_bind_from(id,bind_id)
    model = @Model.find(id)
      model.waku_blocks.delete(bind_id)
  end
end
