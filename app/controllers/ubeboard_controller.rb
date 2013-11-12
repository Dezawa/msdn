# -*- coding: utf-8 -*-
# TopPage
class UbeboardController < ApplicationController
  before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  skip_before_filter :verify_authenticity_token

   Labels = [MenuCsv.new("LiPS"        ,:lips    ,:action =>:member,:csv_download_url=>"/lips/LiPS-CSV100V2.xls"),
             MenuCsv.new("新規立案準備",:ube_skd ,:action => :new  ,
                         :csv_upload_action=>:lips_load,
                          :csv_download_url=> nil),
             Menu.new(   "生産計画"    ,:ube_skd         ),
             MenuCsv.new("休転計画"    ,:ube_maintain    ),
             Menu.new(   "休日計画"    ,:ube_holyday     ),
             MenuCsv.new("製造条件"    ,:ube_product     ),
             MenuCsv.new("工程速度"    ,:ube_operation   ),
             MenuCsv.new("切替時間"    ,:ube_change_times),
             MenuCsv.new("銘柄管理"    ,:ube_meigara     ),
             MenuCsv.new("銘柄略称"    ,:ube_meigara_shortname ),
             MenuCsv.new("工程管理項目",:ube_constant     ,:disable => :permit),
             MenuCsv.new("記名メンテ"  ,:ube_named_changes,:disable => :configure),
             MenuCsv.new("UbePlan"  ,:ube_plan,:disable => :configure)
            ] 

  def arrowed
    @labels = labels
    user = current_user.login
    #  arrowed_user = %w(dezawa ubeboard)
    # arrowed_user.include?(user)
  end

  def top
    @labels = Labels
    @title = "ウベボードTOP"
  end

  def csv_upload
    csvfile = (params.keys - %w(action controller))[0]
    @title = Labels.assoc(csvfile.to_sym)[1]
@csvfile = csvfile
    action = csvfile#.to_sym
    case csvfile.to_sym
    when :by_lips ; action = :csv_upload 
    when :re_plan ; action = :csv_upload
    when :set_stock ; action = :csv_upload
    when :set_holyday ; action = :csv_upload
    when :ube_product ; action = :index
    when :set_operation ; action = :csv_upload
    end

    redirect_to :controller =>csvfile.to_sym , :action => action
  end

  def by_lips
render :action => :test
  end

  def lips_load
    @plans = UbePlan.make_plans_from_lips(params[:csvfile])
    redirect_to :controller=>:ube_skd, :action => :lips_load_sub
  end
end

__END__
$Id: ubeboard_controller.rb,v 2.21 2012-11-01 13:59:59 dezawa Exp $
