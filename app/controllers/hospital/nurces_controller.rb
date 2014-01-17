# -*- coding: utf-8 -*-
class Hospital::NurcesController <  Hospital::Controller
  before_filter :set_instanse_variable
  # GET /nurces
  # GET /nurces.xml

  Labels = 
    [ HtmlText.new(:id,"ID",:align =>:right,:ro=>true,:size =>4),
      HtmlText.new(:number,"番号",:align =>:right,:size =>3),
      HtmlText.new(:name,"氏名",:align =>:right,:size =>3),
      HtmlSelect.new(:busho_id,"部署",   :correction => Hospital::Busho.names),
      HtmlSelectWithBlank.new(:shokui_id,"職位",:correction => Hospital::Const::Shokui),
      HtmlSelect.new(:shokushu_id,"職種",:correction => Hospital::Const::Shokushu),
      HtmlSelect.new(:kinmukubun_id,"勤務区分",   :correction => Hospital::Const::Kinmukubun),
    ]

  def set_instanse_variable
    super
    @Model= Hospital::Nurce
    @TYTLE = "個人登録"
    #@TYTLEpost = 
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption =["busho_id = ?",@current_busho_id] 
    #@errors=Proc.new{@Model.error_check.join("<br>")}
    @TableEdit = 
    @TableEdit = _TableAddEditChangeBusho
    @Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    @CSVatrs   = Labels.map{|html| html.symbol}
    #@CSVlabels = Labels.map{|html| html.label}
    #@Pagenation = 20
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.username }
    #@on_cell_edit = true
  end
  def csv_out(filename=nil)
    models = Hospital::Nurce.all
    csv_out_comm(models,filename)

    

  end
end
