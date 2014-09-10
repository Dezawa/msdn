# -*- coding: utf-8 -*-
class Hospital::Form9Controller < Hospital::Controller
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
    @LabelsDefine = [ HtmlText.new(:name,"項目",:ro=>true),HtmlHidden.new(:attri,"隠し",:ro=>true),
                     HtmlText.new(:value,"値",:ro=>true) ,HtmlText.new(:comment,"コメント",:ro=>true)
                   ]
    @ItemsDefine =
      [HtmlText.new(:hospital_name ,"保険医療機関名"),
       HtmlText.new(:hospital_bed_num ,"病床数"     ),
       HtmlText.new(:kubun          ,"届出区分"      ,:size =>3, :comment => "対１入院基本料"),
       HtmlSelect.new(:KangoHaichi_addition,"看護配置加算の有無" ,  :correction => %w(有 無),:include_blank=> true),
       HtmlSelect.new(:Kyuuseiki_addition  ,"急性期看護補助体制加算の届出区分",:correction => %w(25 50 75),:include_blank=> true),
       HtmlSelect.new(:Yakan_Kyuuseiki_addition,"夜間急性期看護補助体制加算の届出区分",:correction => %w(50 100),:include_blank=> true),
       HtmlSelect.new(:night_addition  ,"看護職員夜間配置加算の有無"  ,  :correction => %w(有 無),:include_blank=> true),
       HtmlSelect.new(:KangoHojo_additon   ,"看護補助加算の届出区分",:correction => %w(30 50 75),:include_blank=> true)
      ]
end

  def index
  end

  def calc
    #items = params[:hospital_form9]
    items={ }
    form9 = Hospital::Form9.new(@month)
    form9.calc(items)
    send_file(Hospital::Form9::Sheet9nsNew, :filename => "様式9-#{@month.strftime('%Y-%m')}.xls")
  end


end
