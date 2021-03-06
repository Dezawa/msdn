# -*- coding: utf-8 -*-
# アプリメイン画面などで、メニュー一覧を出すときの、
# メニューアイテム
# arg_label :: ラベル。これに modelのactionへのリンクが付く
# arg_model :: model
# option
#   :disable :: nil ：trueのとき、このメニューは出力しない
#                      :: 　　　Symbolの場合は、controller#symbolの実行結果
#   :action  :: :index：このメニューのリンク先。
#   :enable_csv_upload :: nil ：CSVでのデータ更新(通常は総とっかえ)が可能か
#                      :: 　　　Procの場合は、controller#symbolの実行結果
#   :csv_upload_action :: nil ：CSVでのデータ更新する場合の action
#   :csv_download_url  :: nil ：CSVでデータを取得する時の url または action
#   :comm              :: nil ：メニューのコメント。実装していない
#
# メニュー一覧の外観はいまオプションなし。
class Menu < ActionView::Base
  Attr_names = [:disable,:model,:label,:action,
                :enable_csv_upload,:csv_upload_action,:buttonlabel,
                :csv_download_url,:comment,:help]
  attr_accessor( *Attr_names)
  attr_accessor :controller,:option,:html_option

#  def self.hash_initializer(*attr_names)

  def initialize(arg_label,arg_model,args={},htmlopt ={ })
    data = {:action => :index}.merge(args)
    Attr_names.each do | attr_name|
      instance_variable_set "@#{attr_name}",data.delete(attr_name)
    end
    @html_option = htmlopt
    @model  = arg_model
    @label  = arg_label
    @option = data # || { }
    @buttonlabel =  "CSV登録" #if @buttonlabel.blank? 
      #@action= arg_action
  end

  def  buttonlabel;  @buttonlabel || "CSVで登録" ;end

#  end
#  hash_initializer *Attr_names

  def self.menue_table(view,menus)
    @@controller = view.controller
    "<table border=1 cellspacing=0>".html_safe
    menus.inject( "<table border=1 cellspacing=0>".html_safe){|html,menu|
      html + menu.show(view) } +
     "</table>".html_safe
  end

  def show( view )
    @controller = view.controller
    return "".html_safe if disable && !view.controller.send(disable)
    safe_join([
               tag(:tr,id: "#{model}_#{action}"),
               tag(:td),label_and_link(view) ,
               (help ? view.help(help) : "".html_safe) ,
               tag("/td") ,"\n".html_safe,
               csv_upload_link(view) ,
               tag(:td),"\n".html_safe,
               csv_dwonload_link(view) ,
              "</td></tr>\n".html_safe
              ])
  end

  def label_and_link(view)
    view.link_to(label,{:controller=>model,:action=> action},:id => "/#{model}/#{action}")
    #action == :index ? "<a href='/#{model}'>#{label}</a>" : "<a href='/#{model}/#{action}'>#{label}</a>"
  end

  def csv_upload_link(view)
    return "<td>　</td>".html_safe unless case enable_csv_upload
                       when Proc ; controller.send enable_csv_upload
                       when nil,false ; false
                       else enable_csv_upload
                       end
    size = (@option[:size] rescue 30)
    tag_id = "upload_#{model}_#{action}"
    @buttonlabel ||= "CSVで登録"
    #safe_join( [view.form_tag( "/#{model}/#{csv_upload_action}",
    safe_join( [view.form_tag( {:controller=>model,:action=> csv_upload_action}, 
                              :multipart => true,:method => :post,:id => tag_id),
               "\n <td><input name='commit' type='submit' value='#{@buttonlabel}' />\n".html_safe ,
                " <input size=#{size} name='csvfile' type='file' id='#{tag_id}'></td></form>".html_safe
              ])
  end

  def csv_dwonload_link(view)
    #return "　" unless csv_download_url
    case csv_download_url
    when String ;   "<a href='#{csv_download_url}' id='#{model}_#{action}'>CSVダウンロード</a>"
    when Symbol ;   view.link_to("CSVダウンロード",{:controller=>model,:action=> csv_download_url}, :id => "#{model}_#{action}")
    else "　"
    end.html_safe
  end
end

# class Menuとの違い
# 以下のオプションのdefault値が設定されている
#   :enable_csv_upload :: :true ：CSVでのデータ更新(通常は総とっかえ)が可能か
#   :csv_upload_action :: :csv_upload nil ：CSVでのデータ更新する場合の action
#   :csv_download_url  :: :csv_out ：CSVでデータを取得する時の url または action
#
class MenuCsv < Menu
  def initialize(arg_label,arg_model,args={})
      data = {
      :action => :index,
      :csv_upload_action=> :csv_upload,
      :enable_csv_upload=>true,
      :csv_download_url=> :csv_out
    }.merge(args)
      Attr_names.each do | attr_name|
        instance_variable_set "@#{attr_name}",data[attr_name]
      end
      @model = arg_model
      @label = arg_label
      #@action= arg_action
  end
end
