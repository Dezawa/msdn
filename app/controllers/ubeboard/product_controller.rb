# -*- coding: utf-8 -*-
class Ubeboard::ProductController < ApplicationController
  include Actions
  before_action :authenticate_user! 
  #before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable
  skip_before_filter :verify_authenticity_token

require 'nkf'
require 'csv'


  Labels = [HtmlText.new(:id,"ID",:ro=>true),
            HtmlText.new(:proname ,"製品名",:size =>15),
            HtmlSelect.new(:hozen ,"保守",:align => :center,:correction =>[["",false],["○",true]]),
            HtmlSelect.new(:shozo ,"抄造機",:include_blank=>true,:correction => %w(西抄造 東抄造)),
            HtmlSelect.new(:dryer ,"乾燥機",:include_blank=>true,:correction =>%w(原乾燥 新乾燥)),
            HtmlText.new(:lot_size,"基準製造量",:align => :right,:size =>5),
            HtmlText.new(:roundsize,"ラウンド最大製造量",:align => :right,:size =>5),
            HtmlText.new(:defect_rate,"不良率",:align => :right,:size =>5),
            HtmlText.new(:ope_condition,"品種",:size =>6),
            HtmlText.new(:color,"表示色",:size =>6)
           ]

  def set_instanse_variable
    @Model= Ubeboard::Product
    @TYTLE = "製造条件"
    #@TYTLEpost = "#{@year}年度"
    @labels=Labels
    #@Links=BookKeepingController::Labels
    @FindOption = {}
    @errors=Proc.new{@Model.error_check.join("<br>")}
    @TableEdit = true
    #@Edit = true
    @Delete=true
    @Domain= @Model.name.underscore
    #@Refresh = :kamokus
    #@SortBy   = :bunrui
    @CSVatrs = Ubeboard::Product::CSVatrs; @CSVlabels = Ubeboard::Product::CSVlabels
    @pageSession="UBpro_perpage"
    @Pagenation =  session[@PageSession] || (session[@PageSession] = 20)
    #@New = {:no => no, :date => Time.now}
    #@Create = {:owner => current_user.login }
    #@PostMessage = BookMainController::Comment
  end

  def destroy
    if Ubeboard::Plan.find_by_ube_product_id(params[:id])
      flash[:message] = "この製品は使われているので削除できません"
      redirect_to :action => :index 
    else
      @product = Ubeboard::Product.find(params[:id])
      @product.destroy
      
      Ubeboard::Product.products true
      
      respond_to do |format|
        format.html { redirect_to :action => :index }
        format.xml  { head :ok }
      end
    end
  end

end

__END__
$Id: ube_product_controller.rb,v 2.19 2012-10-05 05:46:10 dezawa Exp $
