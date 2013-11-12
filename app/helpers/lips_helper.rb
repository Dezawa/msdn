# -*- coding: utf-8 -*-
# LiPSのhelperだが、重要なのはこのソースファイルの最後の方に有る
# lipsoptlink と その下に書かれたmethod。今は to_ube_product
# currentuser.lipstolink がある場合は、それを LiPS画面に表示させるためのしかけ
module LipsHelper
  Cllection_gele = [["以上",">="],["以下","<="]]
  def td_color_size(size=2,span=1,color=nil,opt={}) 
    clr = color ? "bgcolor=#{color}" : ""
    spn = span==1 ? "": " colspan=#{span}"
     nobr = opt[:nobr] ? "<nobr>" : "" 
    "<td #{clr}#{spn}><font size = #{size}>#{nobr}" 
  end
  def label(str,opt = {})
    option = {:size => 2 ,:span =>1}.merge(opt)
    color = option.delete(:color)
    opt_help  = option.delete(:help)
    size  = option.delete(:size)
    span = option.delete(:span)
    td_color_size(size,span,color,opt)+str+
      (opt_help ? help("LiPS##{opt_help}") : "" ) +
      "</td>"
  end 

  def text_fiels(item,range,null_if_zero=true,option=[])
    range.map{|i| 
      "<td><font size = 2>"+ text_field_for_array(item,i,true,'size=5') +"</td>"
    }.join("\n")
  end

  def text_field_for_array(itm,indx,null_if_zero=true,option=[])
    val =  blank_if_zero(@lips.send(itm)[indx])
    id = "lips_#{itm}[#{indx}]" ; name = "lips[#{itm}][#{indx}]"
    option = option.class == Array ? option.join(' ') : option.to_s
    "<input type=text id='#{id}' name='#{name}' value='#{val}' #{option}>"
  end
  def hidden_field_for_array(itm,indx,null_if_zero=true,option=[])
    val =  blank_if_zero(@lips.send(itm)[indx])
    id = "lips_#{itm}[#{indx}]" ; name = "lips[#{itm}][#{indx}]"
    option = option.class == Array ? option.join(' ') : option.to_s
    "<input type=hidden id='#{id}' name='#{name}' value='#{val}' #{option}>"
  end
  def text_field_for_warray(itm,indx,jndx,null_if_zero=true,option=[])
    val =  blank_if_zero(@lips.send(itm)[indx][jndx])
    id = "lips_#{itm}[#{indx}][#{jndx}]" ; name = "lips[#{itm}][#{indx}][#{jndx}]"
    option = option.class == Array ? option.join(' ') : option.to_s
    "<input type=text id='#{id}' name='#{name}' value='#{val}' #{option}>"
  end
  def hidden_field_for_warray(itm,indx,jndx,null_if_zero=true,option=[])
    val =  blank_if_zero(@lips.send(itm)[indx][jndx])
    id = "lips_#{itm}[#{indx}][#{jndx}]" ; name = "lips[#{itm}][#{indx}][#{jndx}]"
    option = option.class == Array ? option.join(' ') : option.to_s
    "<input type=hidden id='#{id}' name='#{name}' value='#{val}' #{option}>"
  end

  def blank_if_zero(f) 
    f = @lips.send(f) if f.class == Symbol
    (f.blank? or f==0.0) ? "" : f.to_s
  end

  def select_gele(indx)
    val = @lips.gele[indx]; #val = val ? val : "<=" 
    id = "lips_gele[#{indx}]" ; name = "lips[gele][#{indx}]"
    le,ge = (  @lips.gele[indx] =~ />=/) ? ["","selected"] : ["selected",""]
    "<select id=\"#{id}\" name=\"#{name}\">
           <option value=\"<=\" #{le}>以下</option><option value=\">=\" #{ge}>以上</option>
           </select>" 
  end

  # def value?(symbol,i=nil,j=nil)
  #   sym = symbol.to_s+ (i ? "_#{i}" : "") + (j ? "_#{j}" : "")
  #   return "" if (val=@lips[sym]).blank?
  #   return "" if val.class == Float and val == 0.0
  #   "value=\"#{val}\""
  # end

  def hiddens
    html=%w(promax  opemax vertical minmax download).map{|sym| 
      hidden_field(:lips,sym.to_sym) 
    }.compact.join

    html_pro = (1..@promax).map{|p| 
      %w(gain min max pro).map{|sym| 
        hidden_field_for_array(sym,p,false) unless @lips.send(sym)[p]==0.0
      }.compact.join + 
      (@lips.proname[p].blank? ? "" : hidden_field_for_array(:proname,p,false))
    }.compact.join
    
    html_ope= (1..@opemax).map{|p| 
      %w(time time ope).map{|sym|
        hidden_field_for_array(sym,p,false) unless  @lips.send(sym)[p]==0.0
      }.compact.join +
      (@lips.opename[p].blank? ? "" : hidden_field_for_array(:opename,p,false)) +
      hidden_field_for_array( :gele,p)
    }.compact.join

    html_rate=(1..@promax).map{|p| (1..@opemax).map{|o|
        hidden_field_for_warray( :rate,p,o,false) unless @lips.rate[p][o]==0.0
      }.compact.join}.compact.join
    [html,html_pro,html_ope,html_rate].join("\n")
  end


  def vertical_or_landscape
    if @lips.vertical == "vertical"
      vertical
    else
      landscape
    end
  end

  def landscape
    html = "<br>\n<table border=1 cellspacing=0>
  <tr>"
    html << label(t(:pro_name),:span =>5,:help =>:pro_name) + text_fiels(:proname,(1..@promax),true,"size=5")
    html << "</tr>\n"
    html << "   <tr>" << label(t(:profit),:color =>"#D0FFFF",:help => :profit) 
    html << "<td  bgcolor=#D0FFFF colspan=2>" +   blank_if_zero(:profit) << "</td>"
    html << label(t(:pro_gain),:span => 2,:size => 1, :help => :pro_gain )
    html <<  text_fiels(:gain,(1..@promax),true,"size=5") << "</tr>\n"
    html << "  <tr>" << label(t(:min),:span =>5,:help => :min_mass) << text_fiels(:min,(1..@promax),true,"size=5") << "</tr>\n"
    html << "  <tr>" << label(t(:max),:span =>5,:help => :max_mass) << text_fiels(:max,(1..@promax),true,"size=5") << "</tr>\n"
    html << "  <tr>" << label(t(:number),:span =>5,:color =>"#D0FFFF") 
    (1..@promax).each{|pro|  html << td_color_size(2,:color =>"#D0FFFF") << blank_if_zero(@lips.pro[pro]) }
    html << "</tr>\n"
    html << "  <tr>"
    html << label(t(:operation)+"",:help => :operation) << 
      label(t(:runtime),:size => 1,:help =>:runtime ) << label("≦≧",:help => :min_max) 
    html << "<td bgcolor=#D0FFFF><font size = 2><nobr>実稼働</nobr>"
    html << "<td bgcolor=#D0FFFF><font size = 2><nobr>稼働率</nobr>" <
      html << label(t(:coment),:span =>@promax,:help => :comment)
    (1..@opemax).each{|ope| 
      html << "  <tr><td><font size = 2>" << text_field_for_array(:opename,ope,false,"size=5")<< "</td>"
      html << "<td><font size = 2>"       << text_field_for_array(:time   ,ope,true,"size=5") << "</td>"
      html << "<td><font size = 2>"       << select_gele(ope) << "</td>"
      html << "<td bgcolor=#D0FFFF><font size = 2>" << blank_if_zero(@lips.send(:ope)[ope])   << "</td>"
      val=@lips.send(:ope)[ope].to_f;
      val = @lips.send(:time)[ope] == 0.0 ? "" : sprintf("%5.1f", val/@lips.send(:time)[ope]*100)
      html << "<td bgcolor=#D0FFFF><font size = 2>" << val.to_s << "</td>"
      (1..@promax).each{|pro| 
        html << "<td><font size = 2>" << text_field_for_warray(:rate,pro,ope,true,"size=5") << "</td>"
      }
      html << "</tr>\n"
    }
    html << "</table>\n"
    html
  end

  def vertical
    html = "<br>\n<table border=1 cellspacing=0>"
    html << "\n   <tr><td  colspan=4>　</td>"+ label(t(:operation)+"",:help => :operation)
    (1..@opemax).each{|ope| 
      html << "<td><font size = 2>" << text_field_for_array(:opename,ope,false,"size=5")<< "</td>"
    }
    html << "</tr>\n"
    html << "  <tr><td  colspan=4>　</td>" + label(t(:runtime),:size => 1,:help =>:runtime,:nobr=>true )
    (1..@opemax).each{|ope| 
      html << "<td><font size = 2>" << text_field_for_array(:time,ope,true,"size=5")<< "</td>"
    }
    html << "</tr>\n"
    html << "   <tr>"+label(t(:profit),:color =>"#D0FFFF",:help => :profit)+
      "<td  colspan=3 bgcolor=#D0FFFF>" << @lips.profit.to_s
    html << "</td>"+label("≦≧",:help => :min_max)
    (1..@opemax).each{|ope| html << "<td><font size = 2>"       << select_gele(ope) << "</td>" }
    html << "</tr>\n"
    html << "  <tr><td colspan=4></td><td bgcolor=#D0FFFF>実稼働</td>"
    (1..@opemax).each{|ope| 
      html << "<td bgcolor=#D0FFFF><font size = 2>" << blank_if_zero(@lips.send(:ope)[ope])   << "</td>"
    }
    html << "</tr>\n"
    html << "  <tr><td colspan=4></td><td bgcolor=#D0FFFF>稼働率</td>"
    (1..@opemax).each{|ope| 
      val=@lips.send(:ope)[ope].to_f;
      val = @lips.send(:time)[ope] == 0.0 ? "" : sprintf("%5.1f", val/@lips.send(:time)[ope]*100)
      html << "<td bgcolor=#D0FFFF><font size = 2>" << val.to_s << "</td>"
    }
    html << "</tr>\n<tr>"
    html << label(t(:pro_name),:help =>:pro_name ) + label(t(:pro_gain),:help => :pro_gain )
    html << label(t(:min),:help => :min_mass) <<
      label(t(:max),:help => :max_mass) << label(t(:number))
    html <<  label(t(:coment),:span =>@opemax,:help => :comment) +"</tr>\n"
    (1..@promax).each{|pro| 
      html << "  <tr><td><font size = 2>" << text_field_for_array(:proname,pro,false,"size=5")<< "</td>"
      [:gain,:min,:max].each{|sym| 
        html << "<td><font size = 2>" << text_field_for_array(sym,pro,false,"size=5")<< "</td>"
      }
      html << td_color_size(2,"#D0FFFF") << blank_if_zero(@lips.pro[pro])
      (1..@opemax).each{|ope|
        html << "<td><font size = 2>" << text_field_for_warray(:rate,pro,ope,true,"size=5") << "</td>"
      }
      html << "</tr>\n"
    }
    html << "</table>\n"
    html
  end

  def cvsupdate_form
    #if @user && @user.lipscsvio
    "<font size = 2><form enctype='multipart/form-data' action='./csv_upload' method='post'>\n" +
      "<input type='submit' value='条件設定CSV Upload'>" +
          help("LiPS#cvsupdate_form") +
      "　<input size=35 name='csvfile' type='file'>\n" +
      if @user && @user.lipscsvio
        "   <a href='/lips/LiPS-CSV100V2.xls'>縦フォーム</a>\n" +
          " <a href='/lips/LiPS-CSV100H2.xls'>横フォーム</a>\n"
      else
        ""
      end +
      hiddens +   "    </form>\n"
    #else
    #  ""
    #end
  end

  def change_disp_form
    #if @user && @user.lipssizeoption
    "<font size = 2><form method='POST' action='./change_form'>\n" +
      "<font size = 2><input type='submit' value='画面フォーム 変更'>" +
      help("LiPS#change_disp_form") + "　" +
      t(:pro_name)+"数(" + @user.lipssizepro.to_s + "以下)　" + text_field(:lips,:promax,:size=>2) +
      t(:operation)+"数(" + @user.lipssizeope.to_s + "以下)　" + text_field(:lips,:opemax,:size=>2) +
      "　"+t(:pro_direct)+
      radioBottom(:lips,:vertical,[['vertical','縦'],['landscape','横']],@lips.vertical) +
      hiddens + "</form>  </td></tr>"
   # else
   #   ""
   # end
  end
  def download_cvs_form
    if @prefix && @csvfile && (file=File.exist?(@prefix+@csvfile)) 
      link_to("結果ダウンロード",:action => :csv_download,:file_name => @prefix+@csvfile)
    else
      "結果ダウンロード"
    end +
      help("LiPS#download_csv")
  end


  ###################################################
  # ログインユーザの lipsoptlink がある場合、LiPSから連携するそのアプリへの
  # リンクをLiPS画面に表示する。
  def lipsoptlink
    if @user && ! @user.lipsoptlink.blank?
      send(@user.lipsoptlink.to_sym)
    end
  end

  def to_ube_product
      label = "製造計画立案へ"
      if @prefix && @csvfile && (file=File.exist?(@prefix+@csvfile)) 
        link_to(label,"/ube_skd/lips_load?csvfile=#{@csvfile}")
      else
        label
      end
  end
end
