# -*- coding: utf-8 -*-
class Hospital::AvoidCombinationController < Hospital::Controller
  before_filter :set_instanse_variable

  def set_instanse_variable
    super
    @Model= Hospital::AvoidCombination
    @TYTLE = "避ける組み合わせ"
    @Domain= @Model.name.underscore
    #@FindOption = {:conditions => ["busho_id = ?",@current_busho_id] }
    @TableEdit = true
    @Delete=true
    @labels= 
      [ HtmlText.new(:busho_name,"部署",:ro => true),
        HtmlHidden.new(:busho_id,"部署"),
        HtmlSelectWithBlank.new(:nurce1_id,"看護師",:correction => Proc.new{ Hospital::Nurce.correction( @current_busho_id)}),
        HtmlSelectWithBlank.new(:nurce2_id,"看護師",:correction => Proc.new{ Hospital::Nurce.correction( @current_busho_id)}),
        HtmlSelect.new(:weight   ,"重要度",:correction => [1,2,3,4,5])
      ]
                  #
                  #             ]
  end
  def update_on_table
    params[@Domain].each{ |id,model|
     model[:busho_id] = @current_busho_id if model[:busho_id].blank?
    }
    super
  end

end
