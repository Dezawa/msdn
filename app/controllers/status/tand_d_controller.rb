# -*- coding: utf-8 -*-
class Status::TandDController < CommonController#ApplicationController
  include Actions
  before_action :set_instanse_variable
  Labels =
    [HtmlText.new(:serial                ,"serial", :ro => true),
     HtmlText.new(:base_name                ,"Base", :ro => true),
       HtmlText.new(:group_name               ,"Group", :ro => true),
       HtmlText.new( :group_remote_name       ,"Remote", :ro => true),
       HtmlText.new(:group_remote_ch_name     ,"Ch"  , :ro => true),
       HtmlSelect.new(:group_remote_ch_record_type,"型", :ro => true,
                      :correction =>  Ondotori::TypeName             ),
       HtmlDate.new(:group_remote_ch_unix_time,"日時" ,:ro => true,:tform =>"%Y/%m/%d %H:%M" ),
       HtmlText.new( :group_remote_rssi       ,"電波" , :ro => true), 
       HtmlText.new(:group_remote_ch_current_batt ,"電池残量", :ro => true),
      ]

  def set_instanse_variable
    super
    @Model= Status::TandD
    @Links = Shimada::Controller::Links
    @Domain= @Model.name.underscore
    @TYTLE = "おんどとり Currentデータ"
    @Delete=true
    @FindOrder = "group_remote_ch_unix_time"
  end

  def list
    @models =
      @Model.select_each_one_from_every_group_by([:base_name, :group_name, :group_remote_name],
                                                 "group_remote_ch_unix_time DESC")
    @labels = Labels
    @Delete = false
    render  :file => 'application/index',:layout => 'application'
  end

  def index
    @labels = Labels
    super
  end

  def load_local_file
    @Model.load_xml params[:uploadfile]
    redirect_to :action => :index
  end
end
