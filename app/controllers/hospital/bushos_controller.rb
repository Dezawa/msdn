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
    @ItemsDefine =
      [HtmlText.new(:hospital_name ,"保険医療機関名"),
       HtmlSelect.new(:hospital_Koutai ,"交代勤務",  :correction => %w(二交代 三交代)     ),
       HtmlText.new(:hospital_bed_num ,"病床数"    ,:size =>3  ),
       HtmlText.new(:kubun          ,"届出区分"      ,:size =>3, :comment => "対１入院基本料"),
       HtmlSelect.new(:KangoHaichi_addition,"看護配置加算の有無" ,  :correction => %w(有 無),:include_blank=> true),
       HtmlSelect.new(:Kyuuseiki_addition  ,"急性期看護補助体制加算の届出区分",:correction => %w(25 50 75),:include_blank=> true),
       HtmlSelect.new(:Yakan_Kyuuseiki_addition,"夜間急性期看護補助体制加算の届出区分",:correction => %w(50 100),:include_blank=> true),
       HtmlSelect.new(:night_addition  ,"看護職員夜間配置加算の有無"  ,  :correction => %w(有 無),:include_blank=> true),
       HtmlSelect.new(:KangoHojo_additon   ,"看護補助加算の届出区分",:correction => %w(30 50 75),:include_blank=> true),
       HtmlText.new(:weekly_hour,"常勤職員の週所定労働時間",:size => 3)
      ]
    @ItemsDefine2 =
      [[HtmlText.new(:patient_num        ,"届出時入院患者数"  ,:size =>3,:align => :right)],
       [HtmlText.new(:average_patient    ,"１日平均入院患者数",:size =>3,:align => :right)],
       [HtmlText.new(:patient_start_year ,"算出期間 年"       ,:size =>3,:align => :right),
        HtmlText.new(:patient_start_month,"月～"              ,:size =>1,:align => :right),
        HtmlText.new(:patient_stop_year  ,"年"                ,:size =>3,:align => :right),
        HtmlText.new(:patient_stop_month ,"月"                ,:size =>1,:align => :right)],
       [HtmlText.new(:average_Nyuuin     ,"平均在院日数"      ,:size =>3,:align => :right)],
       [HtmlText.new(:Nyuuin_start_year  ,"算出期間 年"       ,:size =>3,:align => :right),
        HtmlText.new(:Nyuuin_start_month ,"月～"              ,:size =>1,:align => :right),
        HtmlText.new(:Nyuuin_stop_year   ,"年"                ,:size =>3,:align => :right),
        HtmlText.new(:Nyuuin_stop_month  ,"月"                ,:size =>1,:align => :right)]
    ]
    @ItemsAll =  (@ItemsDefine + @ItemsDefine2).flatten
end

  def index
<<<<<<< HEAD:app/controllers/hospital/bushos_controller.rb
    @instances = Hospital::Define.all
    regesterd = @instances.map(&:attri)
    need      = @ItemsDefine.map{ |l| l.symbol.to_s }
=======
    instances = Hospital::Define.all
    regesterd = instances.map(&:attri)
    need      =  @ItemsAll .map{ |l| l.symbol.to_s }
>>>>>>> HospitalPower:app/controllers/hospital/busho_controller.rb
    lack = (need - regesterd)
    creeat = @ItemsAll.map{ |label|
      if lack.include?(label.symbol.to_s)
         Hospital::Define.create( :name => label.label,
                                  :attri => label.symbol.to_s,
                                  :comment   => label.comment
                                  )
      end
    }.compact
    @instances = Hash[*(instances+creeat).map{ |model| [model.attri.to_sym,model]}.flatten]
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
