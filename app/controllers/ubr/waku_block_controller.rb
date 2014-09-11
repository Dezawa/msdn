# -*- coding: utf-8 -*-
class Ubr::WakuBlockController <  Ubr::Controller
  include ExcelToCsv
  before_filter :authenticate_user! 


   Labels = [
             HtmlText.new(:content  ,"枠名前半",:size =>3),
             HtmlText.new(:sufix,"開始文字",:size => 3),
             HtmlText.new(:max,"最終文字",:size => 3),
             HtmlText.new(:base_point_x,"X",:align=>:right,:size => 5),
             HtmlText.new(:base_point_y,"Y",:align=>:right,:size => 5),
             HtmlText.new(:label_pos_x ,"X",:align=>:right,:size => 5),
             HtmlText.new(:label_pos_y ,"Y",:align=>:right,:size => 5)
            ]

  def set_instanse_variable
    @labels= Labels
    @TableHeaderDouble = 
      [1,[2,"枠名後半"],[2,"対倉庫相対位置"],[2,"ブロック名相対位置対ブロック"] ]

    # @TableHeader = :waku_block_header
    @Model = Ubr::WakuBlock
    @TYTLE = "UBR：枠ブロック"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :souko
    @Delete = @editor
    @Edit =   @editor
    @TableEdit  =  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table,"編集"],
                    [:form,:csv_out,"CSVダウンロード"],
                    [:csv_up_buttom,:dmy,:dmy]] 
    @FindOrder =  "souko,content,max"
    @CSVatrs = Labels.map{|lbl| lbl.symbol}
    @CSVlabels= Labels.map{|lbl| lbl.symbol}
    super
  end

  def index
    if params[:prefix]
      @FindOption = {:conditions => "name like '#{params[:prefix]}%'" } #,params[:prefix] ]    }
      @FindWhere = "name like '#{params[:prefix]}%'" 
    end
    super
  end


end
