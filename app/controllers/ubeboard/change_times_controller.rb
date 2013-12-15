# -*- coding: utf-8 -*-
class Ubeboard::ChangeTimesController < ApplicationController
  include Actions
  #before_filter :login_required
  before_filter {|ctrl| ctrl.set_permit %w(生産計画利用 生産計画利用 生産計画メンテ)}
  before_filter {|ctrl| ctrl.require_permit}
  before_filter :set_instanse_variable

  #before_filter {|ctrl| ctrl.require_permit_label "生産計画メイン"}
  Ope = [["東抄造",:east], ["西抄造",:west],["原乾燥",:old],["新乾燥",:new],["加工",:kakou]]
  def set_instanse_variable
    @Model  = Ubeboard::ChangeTime
  end

  def index
    @TYTLE = "切り替え時間一覧"
    @errorse=Ubeboard::Operation.error_check.join("<br>")
    @ope = Ope
    @models =@Model.order "ope_name,ope_from"
    @names = @models.map(&:ope_from).uniq.sort
    @chtimes  = Hash.new{|h,k| h[k] = {} }
    Ope.each{|lbl,sym| 
      @models.select{|model| model.ope_name == lbl 
      }.each{|model| @chtimes[sym][[model.ope_from,model.ope_to]]=[model.change_time,model.id] }
    }
  end

  def edit_on_table
    @TYTLE = "切り替え時間編集"
    @ope = Ope
    @models =@Model.order  "ope_name,ope_from"
    @names = @models.map(&:ope_from).uniq.sort
    @chtimes  = Hash.new{|h,k| h[k] = {} }
    Ope.each{|lbl,sym| 
      @models.select{|model| model.ope_name == lbl 
      }.each{|model| @chtimes[sym][[model.ope_from,model.ope_to]]=[model.change_time,model.id] }
    }
  end


  def update_on_table
    #render :action=>:test; return
    @ope = Ope
    if @models = params["changetime"]
      @models.each{|id,model| @Model.find(id).update_attributes(model)
    }
    end
    redirect_to :action => :index
  end

  def csv_upload
    if params[:csvfile].blank?
      flash[:message]="ファイルが指定されて居ません"
      redirect_to  :controller => :ubeboard,:action=>:top
      return

    end
   @Model.csv_upload(params[:csvfile])
    redirect_to :action => :index
  end

  def csv_out
    csvdata = NKF.nkf("-s",Ubeboard::ChangeTime.csv_out)
    csv_file = Tempfile.new("csvfile","#{Rails.root}/public/tmp")
    csv_file.puts csvdata
    csv_file.close
    filename = current_user.login + "_change_times.csv"
    send_file(csv_file.path, :filename =>filename)
  end
end

__END__
$Id: ube_change_times_controller.rb,v 2.8 2012-10-07 00:21:22 dezawa Exp $
$Log: ube_change_times_controller.rb,v $
Revision 2.8  2012-10-07 00:21:22  dezawa
set_permitをlabel -> authoneicat

Revision 2.7  2012-10-05 05:46:09  dezawa
HtmlCell　子class作成

Revision 1.1.1.1  2012-09-24 03:03:24  dezawa


Revision 1.4  2012-09-22 10:30:02  dezawa
RAILS_ROOT is chaunged

Revision 1.3  2012-09-18 00:30:35  dezawa
add UserOption#authorized

Revision 1.2  2012-09-17 12:39:53  dezawa
Test change time functional is compleat

Revision 2.6  2012-04-23 23:40:33  dezawa
無効機能も見せるようにした
ユーザオプションの表示順変更

Revision 2.5  2012-04-17 00:43:17  dezawa
UserOptionのlabel間違い

Revision 2.4  2012-04-12 11:56:31  dezawa
ウベボードにユーザの権限チェック入れた

Revision 2.3  2012-03-08 03:27:11  dezawa
エラーチェック改善：工程速度にあるが製品に使われていない品種の切り替えもチェックする

Revision 2.2  2012-03-07 08:03:09  dezawa
製造条件、工程速度、切り替え時間関連のエラーチェックをindexに加えたのを作り直し

Revision 2.1  2012-03-07 07:54:54  dezawa
製造条件、工程速度、切り替え時間関連のエラーチェックをindexに加えた

Revision 2.0  2012-01-29 23:31:33  dezawa
リリース版：最適化一旦ここまで。
BUG出しに移る

Revision 1.5  2012-01-08 02:33:41  dezawa
CSV file無指定の時のしょり

Revision 1.4  2011-12-16 00:44:55  dezawa
ADD Id,Log

