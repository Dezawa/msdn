# -*- coding: utf-8 -*-

# アクセス権管理のための権限フラグ @configure,@editor,@permitの設定を行う
module Permittion

  #
  # アクセス管理に用いる権限フラグの設定を行う
  # [@configure] システムの状態を変える権限をイメージする。サーバ、システム管理者。
  #              ユーザには公開していないDBの編集や、ユーザには与えない編集権。
  # [@editor] ユーザのうち、一番強い権限。データを変更できる権限をイメージ
  # [@permit] ユーザのうち、弱い権限。参照のみの権限をイメージ
  #
  # <tt>laels</tt> :: 
  #       UserOption#label に登録された label の配列。長さ1..3。
  #       User#option にその値を持つuserOptionがあるとき、それぞれ@parmit、@editor、@configure の権限を与えられる。
  #       長さが3未満の時は、最後のlabelが使われる。
  def set_permit(labels)
    return unless current_user
    if @configure = current_user.option?( labels[2] ?  labels[2] : labels[-1])
      @editor = @permit = true
    elsif @editor = current_user.option?( labels[1] ?  labels[1] : labels[-1])
      @permit = true
    else
      @permit = current_user.option?( labels[0] )
    end
    @permissions = [@permit,@editor,@configure]
  end

  def permit(label=nil)
    @permit ||= current_user.option?(label)  if label
    @permit
  end
  def editor(label=nil)
    @editor ||= current_user.option?(label)  if label
    @editor
  end
  def configure(label=nil)
    @configure ||= current_user.option?(label)  if label
    @configure
  end
  def not_configure ; !configure ; end
  def not_editor ; !editor ;end
  def not_permit ; ! permit;end
  def require_permit_label(label,url="/404.html") 
    redirect_to url unless  permit(label)
    @permit
  end
  def require_permit(url="/404.html") 
    redirect_to url unless  @permit
    @permit
  end
  def require_editor(url="/404.html") 
    redirect_to url unless  @editor
    @editor
  end

  def require_configure(url="/404.html") 
    redirect_to url unless  @configure
  end
end

