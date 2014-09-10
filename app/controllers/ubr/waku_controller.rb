# -*- coding: utf-8 -*-
class Ubr::WakuController <  Ubr::Controller
  include ExcelToCsv
  before_filter :authenticate_user!  #:authenticate_user! 


   Labels = [HtmlText.new(:name,"枠名",:size =>7),
             HtmlSelect.new(:palette  ,"枠サイズ",:correction =>%w(N 14 11 S)),
             HtmlText.new(:dan3,"3段枡数",:align=>:right,:size => 3),
             HtmlText.new(:dan2,"2段枡数",:align=>:right,:size => 3),
             HtmlText.new(:dan1,"1段枡数",:align=>:right,:size => 3),
             HtmlText.new(:retusu,"列数",:align=>:right,:size => 3),
             HtmlSelect.new(:direct_to,"方向"    ,:correction =>%w(→ ← ↑ ↓)),
             HtmlText.new(:pos_x ,"X位置",:align=>:right,:size => 5),
             HtmlText.new(:pos_y ,"Y位置",:align=>:right,:size => 5)
            ]

  def set_instanse_variable
    @labels= Labels
    @Model = Ubr::Waku
    @TYTLE = "UBR：枠"
    @Links = Links
    @Domain= @Model.name.underscore
    @SortBy    = :name
    @Delete = @editor
    @Edit =   @editor
    @TableEdit  =  [[:add_buttom,:dmy,:dmy],[:form,:edit_on_table,"編集"],
                    [:form,:csv_out,"CSVダウンロード"],
                    [:csv_up_buttom,:dmy,:dmy]] 
    # @Pagenation = 20
    @CSVatrs = Labels.map{|lbl| lbl.symbol}
    @CSVlabels= Labels.map{|lbl| lbl.label}
    @Select = session[@Domain + "_select"] || "1A"
    @FindOption = {:conditions => ["name like ?",@Select] } #,params[:prefix] ]    }
    super
  end

  def index
    select = (params[@Domain] && params[@Domain][:select_box] ) ?  params[@Domain][:select_box] : @Select

    select += "%" unless select =~ /%$/
    @Select = session[@Domain + "_select"] = select      
    @FindOption = {:conditions => ["name like ?",@Select] } #,params[:prefix] ]    }
    super
  end
end
