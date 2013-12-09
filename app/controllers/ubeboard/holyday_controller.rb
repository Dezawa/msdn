# -*- coding: utf-8 -*-
class Ubeboard::HolydayController < ApplicationController
  include Actions
  #hepler  Ubeboard::HolydayHelper
  #before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  #before_filter {|ctrl| ctrl.require_permit}
  before_action :set_instanse_variable
  Labels = %w(西抄造 東抄造 原乾燥 新乾燥 加工).zip([:shozow,:shozoe,:dryo,:dryn,:kakou])
  Wday = %w(日 月 火 水 木 金 土)
  BGcolor =  {"0"=>"White","1"=>"Red","2"=>"#FF5500","3"=>"#FFAA00","4"=>"Yellow"}
  Holyday =  {"0"=>"　","1"=>"休","2"=>"出","3"=>"過","4"=>"運"}
  PerPage = 3

  def set_instanse_variable
    @Pagenation = PerPage
    @Model = Ubeboard::Holyday
    @labels = Labels
    @wday = Wday
    @holy=Holyday
    @choices = Holyday.invert
true
  end

  def index
    @page =  params[:page] || lastpage
    @models = @Model.paginate( :page => @page,
                                   :per_page => @Pagenation,
                                   :order => :month)
p @models
    @color = BGcolor
  end

  def edit_on_table
    @page ||= params[:page] || lastpage
    @models = @Model.paginate( :page => @page,
                                   :per_page => @Pagenation,
                                   :order => :month)

  end

  def add_on_table
    @page =  params[:page] || lastpage
    @title = "休暇"

    if params[:holyday]
      #追加する月度
      @month0 = Time.parse(params[:holyday][:month0]+"/01").beginning_of_month
      @month9 = Time.parse(params[:holyday][:month9]+"/01").beginning_of_month
      
      count = @Model.count
      #@models = @Model.all :order => :month
      #@maxid    = @models.size == 0 ? 1 : @models.map(&:id).sort[-1]+1
      #@new_models = []
      month = @month0 
      #id=1
      while month <= @month9 ;
        unless @Model.find_by_month(month.strftime("%Y/%m"))
          @new_model = @Model.new(:month=>month.strftime("%Y/%m")) ;month=month.next_month
          #lastday = @new_model.month.getlocal.end_of_month.day
          lastday = month.end_of_month.day
          Labels.each{|lbl,sym| @new_model[sym]=["0"]*lastday }
          #@new_model.id = id + @maxid ; id += 1
          #@new_models << @new_model
          @new_model.save
          
        else
          month = month.next_month
        end
      end
      @page = lastpage #count/@Pagenation+1
    end
    @page = params[:page] || lastpage
 
    @models = @Model.paginate( :page =>  @page,
                                   :per_page => @Pagenation,
                                   :order => :month)
    render :action => :edit_on_table
  end
  
  def update_on_table
    @page = params[:page]
    #render :action => :test ; return
    @color = BGcolor
    @page =  params[:page] || lastpage
    @models = @Model.all :order => :month
    @maxid    = @models.size == 0 ? 0 : @models.map(&:id).sort[-1]
    models = params[:ube_holyday]
    @new_models = []
    @models = []

    @result = true
    models.each_pair{|i,model| id=i.to_i
      #model[:month] = Time.parse(model[:month])#.getlocal
      lastday = Time.parse(model[:month]+"/01").end_of_month.day
      Labels.each{|lbl,sym|
        if model[sym]
          model[sym]= (0..lastday-1).map{|d| model[sym][d.to_s] }.join
        else
          model[sym]= "0"*lastday
        end
p model
        if id > @maxid 
          @model=@Model.new(model)
          @model[:id] = id+@maxid
          @new_models << @model
      else
        #  unless Ubeboard::Product.new(product) == products[id]
        @model = @Model.find(id)
        @model.update_attributes(model)
      end
      }
#render :action => :test ;return
      @model.save
    }
    @models = @Model.paginate( :page =>  @page,
                                   :per_page => @Pagenation,
                                   :order => :month)
    render :action => :index
  end

  def update_on_table2
  render :action => :test
  end
 
  def destroy
    @model = @Model.find(params[:id])
    @model.destroy

    respond_to do |format|
      format.html { redirect_to :action => :index }
      format.xml  { head :ok }
    end
  end
end

__END__
$Id: ube_holyday_controller.rb,v 2.11 2012-11-03 08:23:51 dezawa Exp $
$Log: ube_holyday_controller.rb,v $
Revision 2.11  2012-11-03 08:23:51  dezawa
UbeHolydayの休日などに色をつけた

Revision 2.10.2.1  2012-11-02 13:22:04  dezawa
休日、運休などに色をつける

Revision 2.10  2012-10-31 12:26:52  dezawa
*** empty log message ***

Revision 2.9  2012-10-29 08:36:01  dezawa
modelがなにもないとき、page=0でエラーとなる

Revision 2.8  2012-10-29 07:23:01  dezawa
休日と振替伝票は採集ページがでるようにする

Revision 2.7  2012-10-05 05:46:09  dezawa
HtmlCell　子class作成

Revision 1.1.1.1  2012-09-24 03:03:24  dezawa


Revision 1.2  2012-09-18 00:30:36  dezawa
add UserOption#authorized

Revision 1.1  2012-09-17 12:39:53  dezawa
Test change time functional is compleat

Revision 2.5  2012-04-23 23:40:33  dezawa
無効機能も見せるようにした
ユーザオプションの表示順変更

Revision 2.4  2012-04-17 00:43:17  dezawa
UserOptionのlabel間違い

Revision 2.3  2012-04-12 11:56:31  dezawa
ウベボードにユーザの権限チェック入れた

Revision 2.2  2012-03-02 08:34:09  dezawa
ページ送りせずに編集するとページが無いエラー

Revision 2.1  2012-02-27 03:09:34  dezawa
休日管理にページング

Revision 2.0  2012-01-29 23:31:33  dezawa
リリース版：最適化一旦ここまで。
BUG出しに移る

Revision 1.8  2011-12-16 00:44:55  dezawa
ADD Id,Log

