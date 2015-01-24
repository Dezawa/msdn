# -*- coding: utf-8 -*-
class Hospital::BushosController < Hospital::Controller
  before_filter :set_instanse_variable

  def set_instanse_variable
    super
    @Model= Hospital::Busho
    @TYTLE = "部署登録"
    @Domain= @Model.name.underscore
    @TableEdit = true
    @labels= [HtmlText.new(:name,"部署名")
             ]
    @AfterIndex = :hospital_define
    @LabelsDefine = [ HtmlText.new(:name,"項目",:ro=>true),HtmlText.new(:value,"値") ,
                      HtmlText.new(:comment,"コメント",:ro=>true),HtmlHidden.new(:attri,"隠し",:ro=>true),
                      HtmlText.new(:nil,"",:ro=>true),
                      HtmlText.new(:nil,"項目",:ro=>true),HtmlText.new(:nil,"値",:ro=>true)
                   ]
 
end

  def index
    @instances = Hospital::Define.find_or_create_all.
      map{ |model| [model.attri.to_sym,model]}.to_h
    super
  end

  def top
    @month = session[:hospital_year] || 
      Time.now.beginning_of_month.next_month.strftime("%Y/%m")
    @label = @labels.first
    @correction = (@models = @Model.all).pluck(:name)
    #@current_busho_id = session[:hospital_busho] || @models.first.id
    @current_busho_id = session[:hospital].busho_id
    @model  = @Model.find(@current_busho_id)
  end

  def edit_on_table
    @instances = Hash[*Hospital::Define.all.map{ |model| [model.attri.to_sym,model]}.flatten]
    super
  end
  def add_on_table
    @instances = Hash[*Hospital::Define.all.map{ |model| [model.attri.to_sym,model]}.flatten]
    super
  end

  def update_on_table
    defines = params[:hospital_define]
    defines.each{|i,hospital_define| id=i.to_i
      value  = hospital_define
      define = Hospital::Define.find(id)
      define.update_attributes(:value => value[:value])
    }
    super
  end


end
