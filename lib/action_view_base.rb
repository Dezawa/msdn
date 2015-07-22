# -*- coding: utf-8 -*-
# ActionView::Helpers::UrlHelper #class  ActionView::Base
#   def memu_line
#     names_free     = [["線形計画法","/lips/member"],["複式簿記","/book_keeping"]]
#     names_login    = [["ログイン","/login"]]
#     names_loggedin = []
#     names_logout   = [["ログアウト","/logout"],["パスワード変更","/change_password"]]
#     begin ;@login = current_user;rescue ;@login=nil;end

#     urls  = %w(/lips/free /lips/member /login /logout /change_password)
#     names = %w(線形計画法(無償版) 線形計画法(会員版) ログイン ログアウト パスワード変更).
#       zip(urls)
#     if @login && @login.login != "guest"
#       if option=@login.user_options.sort_by{|o| o.order
# 	}.select{|opt| opt.order>0}.map{|opt| [opt.label,opt.url]}
#         names = names_free + names_loggedin + option + names_logout
#       end
#     else
#       names =  names_free +  names_login
#     end
#     "<table border=0 bordercolor='#FFFFFF' width='100%' bgcolor='#e0d0Ff'>" +
#       "<tr><td><table border=1 cellspacing=0><tr>" +
#       names.map{|name,url| 
#       "<td width='90' align='center' ><font size=1>" + 
#       link_to_unless_current(name,url) + "</td> "
#     }.join("\n")+
#       "</tr></table></td></tr></table>"
#   end
#end
