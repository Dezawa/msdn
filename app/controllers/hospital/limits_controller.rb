# -*- coding: utf-8 -*-
class Hospital::LimitsController < Hospital::Controller
  before_filter :set_instanse_variable

  def set_instanse_variable
    super
    @Model= Hospital::Limit
    @TYTLE = "部署登録"
    @Domain= @Model.name.underscore
    @TableEdit = true
    @labels= [HtmlText.new(:id,"部署名"),
              HtmlText.new(:code0,"部署名"),
              HtmlText.new(:code1,"部署名"),
              HtmlText.new(:code2,"部署名"),
              HtmlText.new(:code3,"部署名"),
              HtmlText.new(:coden,"部署名")]
                  #
                  #             ]
end
end
