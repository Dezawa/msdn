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

  def set_instanse_variable
    @labels= Labels
    #TableHeaderMulti = [3,[2,"倉庫書き出し"],[4,"集計書き出し"],1]
    @Model = Ubr::SoukoFloor
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :name
    @Delete = @editor
    @Edit =   @editor
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


end
