# -*- coding: utf-8 -*-
require 'html_cell'
require 'menu'
# 一覧表示系のヘルプメソッドを多く追加した
# menue_table  Ubeboard や BookKeeping のメイン画面にあるような
# メニュー一覧表を書き出す
#
# ======メニュー用
# menue_table             :: メニューの表を出力する
# ======一覧表用
# label_line              :: 一覧表のタイトル行を書き出す
# add_links_update_delete :: 一覧表のインスタンス毎に、編集、削除のボタンを表示する
# disp_field              :: 一覧表のインスタンスの各cellの値をobjectの型に従って表示する。
# edit_field              :: インスタンスの各cellの値をobjectの型に従って編集モードで表示する。
#                         :: １画面１インスタンス向き
#
# ======その他
# links                    :: 関連するページへのlink行を返す

# disp_errors              :: 
# error_messages           :: 
# t                        :: I18n 変換
module ApplicationHelper
  include IndexTableHelper
  include HtmlSafeTableItems
  # Ubeboard や BookKeeping のメイン画面にあるような
  # メニュー一覧表を書き出す
  # 
  #  ラベル(リンク付)｜[CSV-upload]　｜csv-download｜
  #
  # これらは利用者の権限によって以下の見せ方ができる
  # 1. 見えるが実行できない行
  # 2. 全員に見せる行                 
  # 3. ユーザサイド管理者に見せる行  editor
  # 4. システム管理者に見せる行      admin
  #
  # CSV-IO にも上の区別ができる。
  #
  # このために、以下のコントロールデータを用意する
  #  　書式 [表示文字列,model,action,csv-up method,csv_down url]
  # [表示文字列] リンクにつくラベル
  #          [String] この行は常に表示。
  #          [Array]  → [String,symbol] self.controller.send(symbol)がtrueならこの行表示。
  # [model]      リンクのモデル部分
  # [action]     リンクのアクション部分
  # [csv-up method] CSVアップロードの有無、可否。アクションのdefaultは csv_upload。
  #          [true] 常に可能
  #          [nil,false] 常に不可能
  #          [Symbol]   self.controller.send(symbol)の結果による。
  #                 式が実行される時のレシーバーはActionViewのインスタンスなので
  #                 その呼び出し元の controllerを得るには self.controller 経由
  #          [Array] => [Symbol,permission] permission による。OKなら　Symbolがアクション。
  # [csv_down url]  csvダウンロードのURL
  #
  
  def raw(str);str;end

  def help(url_name) # LiPS#cvsupdate_form => LiPS.html#cvsupdate_form
    return "" if url_name.blank?
    url,name = url_name.split("#")
    ("<a href='/Help/#{url}.html" + (name ? "##{name}" : "") +
      "'><img src='/images/help.png' width=10 height=12 ></a>"
     ).html_safe
  end

  def memu_line
    names_free     = [["線形計画法","/lips/member"],["複式簿記","/book_keeping"]]
    names_login    = [["ログイン","/login"]]
    names_loggedin = []
    names_logout   = [["ログアウト","/logout"],["パスワード変更","/change_password"]]
    begin ;@login = current_user;rescue ;@login=nil;end

    urls  = %w(/lips/free /lips/member /login /logout /change_password)
    names = %w(線形計画法(無償版) 線形計画法(会員版) ログイン ログアウト パスワード変更).
      zip(urls)
    if @login && @login.login != "guest"
      if option=@login.user_options.sort_by{|o| o.order
	}.select{|opt| opt.order>0}.map{|opt| [opt.label,opt.url]}
        names = names_free + names_loggedin + option + names_logout
      end
    else
      names =  names_free +  names_login
    end
    "<table border=0 bordercolor='#FFFFFF' width='100%' bgcolor='#e0d0Ff'>" +
      "<tr><td><table border=1 cellspacing=0><tr>" +
      names.map{|name,url| 
      "<td width='90' align='center' ><font size=1>" + 
      link_to_unless_current(name,url) + "</td> "
    }.join("\n")+
      "</tr></table></td></tr></table>"
  end


  # 関連するページへのlink行を返す。
  # * 現ページへのリンクは不活性
  #   labels :: [[ラベル、model、アクション],[ ],[ ],[  ] ]
  def links(menus)
    #labels = BookKeepingController::Labels.select{|l| l[2] != :new }
    menus.map{|menu| 
      next if menu.disable && !controller.send(menu.disable)
      link_to_unless_current(menu.label,:controller => menu.model,:action => menu.action)
    }.join("　")
  end

  def links_table(menus)
    td="<td width=\"90\" align=\"center\" bgcolor=\"#c0f0f0\">".html_safe
    tdtd = safe_join([TDend,TD])
    table_body = menus.map{|menu|
      next if !menu || menu.disable && !controller.send(menu.disable)
      "<font size=1>" +
      link_to_unless_current(menu.label,
                             { :controller => menu.model, :action => menu.action}.
                             merge( menu.option || {} ),menu.html_option
                             )
    }.compact.join(tdtd).html_safe
    safe_join [TR , td ,table_body,TDend , TRend ] 
  end

  PopupHead =  %Q!<form action="/%s/%s">
  <input name="authenticity_token" type="hidden" value="%s" />
  <input name="commit" type="submit"  value="%s" style='margin-top: -12px; left;' 
!
  PopupWithOUTModel = %Q! onclick="window.open('/%s/%s', '%s', 'width=500,height=400 %s'); target='%s'">
!
  PopupWithModel = %Q!  onclick="window.open('/%s/%s?id=%d', '%s', 'width=500,height=400 %s'); target='%s'">
  <input id="%s_id" name="%s[id]" type="hidden" value="%d" />
!

  def select_box
    form_tag({ :action => :index},method: :get) +
      text_field(@Domain,:select_box,:value => @Select) +
      submit_tag("検索")
  end

  def option_tags(tags)
    safe_join( tags.map{|tag,domain,action,opt|
      send(tag,domain,action,opt)
    })
  end

  def popup(url,opt = { })
    opt.merge!({ :target => 'pop',:scroll => true, :width => 300,:height => 300})
    {"onClick" => "window.open('error_disp','_error_disp','width=#{opt[:width]},height=#{opt[:height]},scrollbars=#{opt[:scroll] ? "yes" : "no"}');",:target => '_error_disp'}
  end

  def pagenation(models)
    unless @Pagenation
      ""
    else
      will_page_options = {  :previous_label=>'前へ', :next_label=>'次へ',:page_gap => "..."}
      unless controller.session[controller.class.name+"_per_page"]
        will_paginate(models,will_page_options  )
      else
        safe_join([form_tag(:action => :change_per_page),
                   will_paginate(models,will_page_options.merge(:container => false)  ),
                   "　",
                       hidden_field_tag('page',@page),
                       text_field_tag('line_per_page',@Pagenation,:size => 1),
                       "件/ページ".html_safe,
                       help("Common#perpage"),
                       "</form>".html_safe
                      ]
                  )
      end
    end
  end


  #<b>表示モードでobjectの値を表示する</b>
  #obj   :: Model のインスタンス
  #html_cell :: ControllerのLabelsの1行。1欄の表示内容を定義している。
  #         内容 ［symbol, ラベル,align , type, size or choise, 表示用symbol］
  #
  #<b>sy_mbol</b>
  #typeの型 :: symbolに指定するもの
  #通常    :: Modelのcolumn、もしくはModelのattr_accessibleをSymbolにしたもの。
  #:belongs_to ::  foreign_key(のSymbol)
  #:proname    ::  ':ube_product_id'。基本は:belongs_toである
  #<b>align</b>
  #:right :: 右詰め
  #:center :: 中央
  #それ以外 :: 無指定(左詰め)
  #<b>size or choise</b>
  #typeの型 :: size or choiseに指定するもの ||
  #通常    :: 入力編集モードのときのinput_fieldの幅|| text、date系
  #select系 :: 選択肢の配列、もしくはそれを返すProc|| select(_allow_blank),belongs_to(_allow_blank),proname
  #
  #choiseの場合、二つの形式に対応している。いずれもArrayだが、要素の型が異なる
  #[値と表示が同じ場合] 要素は値その物とする。例［"西抄造","東抄造"］
  #[値と表示が異なる場合] 要素は表示内容と値の配列。例［［"型板",34］,［"コタタキ",12］］
  #
  #choiseにProcを用いる場合
  #- blockパラメータはゼロまたは一つ。
  #- パラメーターには 表示対象のobjectが渡される
  #<b>表示用symbol</b>
  #typeの型 :: 表示用symbolに指定するもの 
  #通常    :: なし
  #:belongs_to,:proname :: 表示するためのmethod(のSymbol)
  #<b>type の意味</b>
  #type    ::         ||  表示モード            ||           編集モード
  #:ro     :: ReadOnly||  obj.symbol を表示する。    ||      obj.symbol を表示する。hiddenで値を持つ
  #:text   :: テキスト||  obj.symbol を表示する。     ||     text_field
  #:number :: テキスト||  obj.symbol を右詰めで表示する。||  text_field
  #:date   :: 年月日  ||  yyyy-mm-dd で表示する         ||  text_field
  #:dtime  :: 日時分  ||  dd HH:MM で表示する        ||  text_field
  #:datetime     ::  月日時分 ||  mm/dd HH:MM        ||  text_field
  #:ydatetime    ::  年月日時分 ||  yyyy/mm/dd HH:MM        ||  text_field
  #:bool         ::  Bool       ||  "○" : ""                 ||  select。結果は true,false
  #:select       :: 選択入力    || obj.symbolの値を持つ choiceの .first || select
  #:belongs_to   :: 関連から選択 || obj.表示用symbol を表示する || select
  #:proname      :: 製品名専用   || obj.表示用symbol を表示する || select
  #

  def error_messages(errors)
    return "" if errors.size == 0
    fullmsg="<div  align=left id='errorExplanation'><table>" ; count =0
    errors.each{|attr,msg| 
      #if attr.to_s == "base"
      fullmsg += "<tr><td><font color=Red>　○#{msg}</td></tr>".html_safe
      count += 1
      #end
    } 
    (fullmsg+"</table></div>\n").html_safe
  end

  def disp_errors(objects)
    # [ AR.Error, AR.Error ,,,]
    
    "<font color=Red>".html_safe +
      safe_join( objects.map{|obj|
                   next if obj.errors.size == 0
                   "ID=#{obj.id}:#{obj.errors.full_messages}" 
                 }.compact,"<br>\n".html_safe)+"</font>".html_safe
    end

  def t(sym,lang=nil)
    I18n.locale(lang) if lang
    I18n.t sym
  end

  def periodically_call_remote_with_timerID(options = {})
    frequency = options[:frequency] || 10 # every ten seconds by default
    timerid= "timerID_#{options.delete(:update)}".classify
    code = "#{timerid} = new PeriodicalExecuter(function() {#{remote_function(options)}}, #{frequency});
"
   javascript_tag(code)
  end

  def on_cell_edit(option={ })
  end

  def error_messages_for a_r
    return "" unless a_r.errors.any? 
    ( "<ul>"+
      a_r.errors.full_messages.map do |msg| %>
      "<li>#{msg}</li>"
      end +"</ul>"
      ).html_safe
  end
end

__END__
$Id: application_helper.rb,v 2.51.2.11 2013-09-12 04:41:13 dezawa Exp $
