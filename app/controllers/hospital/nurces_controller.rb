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
      HtmlSelectWithBlank.new(:shokui_id,"職位",:correction => Hospital::Role.shokui),
      HtmlSelect.new(:shokushu_id,"職種",:correction => Hospital::Role.shokushu),
      HtmlSelect.new(:kinmukubun_id,"勤務区分",   :correction => Hospital::Role.kinmukubun),
      HtmlDate.new(:assign_date,"配属年月日",:tform=>"%Y-%m-%d",:size =>8),
      HtmlSelectWithBlank.new(:idou,"異動" ,          :correction => Hospital::Const::Idou),
      HtmlSelectWithBlank.new(:pre_busho_id,"前部署", :correction => Hospital::Busho.names),
      HtmlSelectWithBlank.new(:pre_shokui_id,"前職位",:correction => Hospital::Role.shokui),
      HtmlSelectWithBlank.new(:pre_shokushu_id,"前職種",
                              :correction => Hospital::Role.shokushu),
      HtmlSelectWithBlank.new(:pre_kinmukubun_id,"前勤務区分",
                              :correction => Hospital::Role.kinmukubun)
    ]

  def set_instanse_variable
    super
    @Model= Hospital::Nurce
    @TYTLE = "個人登録"
    #@TYTLEpost = 
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption = {:conditions => ["busho_id = ?",@current_busho_id] }
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
    #@Create = {:owner => current_user.login }
    #@on_cell_edit = true
  end
  def csv_out(filename=nil)
    models = Hospital::Nurce.all
    csv_out_comm(models,filename)
  end

  def update
    shokui_id     = params[@Domain][:shokui_id]
    shokushu_id   = params[@Domain][:shokushu_id]
    kinmukubun_id = params[@Domain][:kinmukubun_id]
    model = @Model.find(params[:id])
    model.shokui   = [ Hospital::Role.find(shokui_id)]
    model.shokushu = [Hospital::Role.find(shokushu_id)]
    model.kinmukubun = [Hospital::Role.find(kinmukubun_id)]
    super
  end

  def update_on_table
    @page = params[:page] || 1
    @models = [] 
    @models= @PagenatTbl ? find_and : find #@Model.all(@conditions)#@PagenatTbl
    @maxid    = @Model.count == 0 ? 0 : @Model.maximum(:id)
    @modelList = params[@Domain]
    kanren_list = Hash.new{ |h,k| h[k]={ }}
    @modelList.keys.each{ |idstr|
      [:shokui_id,:shokushu_id,:kinmukubun_id].
      each{ |sym| kanren_list[idstr.to_i][sym] = @modelList[idstr].delete(sym)}
      }
    update_on

    @models.each{ |model|
      shokui_id         = kanren_list[model.id][:shokui_id].to_i
      shokushu_id       = kanren_list[model.id][:shokushu_id].to_i
      kinmukubun_id     = kanren_list[model.id][:kinmukubun_id].to_i
      if shokui_id > 0 && ( role = Hospital::Role.find(shokui_id))
        model.shokui   = [ role ]
      else
        model.shokui   = []
      end
      model.shokushu = [Hospital::Role.find(shokushu_id)]
      model.kinmukubun = [Hospital::Role.find(kinmukubun_id)]
    }
    if @result
      #UbeMeigara.meigaras true
      @Model.send(@Refresh,true) if @refresh #BookKamoku.kamokus true
      option = {:action =>  :index ,:page => @page}
      option.merge!(@option) if @option
      redirect_to option
    else
      @models.sort!{|a,b| a[@SortBy]<=>b[@SortBy]} if @SortBy
      @models += @new_models.sort{|a,b| a[:id]<=>b[:id]}
      render  :file => 'application/edit_on_table',:layout => 'application'
    end
  end
end
