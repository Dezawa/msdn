# -*- coding: utf-8 -*-
require 'html_cell'

module IndexTableHelper
  include HtmlSafeTableItems
  
  # ラベル定義のArryを元に、一覧表の表題行を出す
  # * (普通は) index.erb から呼ばれる。
  #   
  def label_line_no_tr
    label_line_comcom(0,nil)
  end
  def label_line_comm(size,labels)
    TR+label_line_comcom(size,labels)
  end
  def label_line_comcom(size,labels)
    labels ||= @labels
    labels.map{|label| 
      unless label.class == HtmlHidden || label.class == HtmlPasswd || label.field_disable(controller)
        if label.link
          "<td><nobr><a href='#{label.link}'>#{label.label}</a></nobr>" 
        else
          "<td><nobr>#{label.label}</nobr>" 
        end +  help(label.help) + "</td>"
      end
    }.compact.join.html_safe
  end

  def label_multi_lines(ary_of_list)
    row = "" #<tr>"
    lbl_idx=0
    firstline = true
    #row += #"</tr>\n"
    ary_of_list.each{ |list| 
      row += "<tr>"
      list.each_with_index{|style,idx|
        case style
        when Integer   
          next unless firstline
          (1..style).each{
            row += "<td rowspan=#{ary_of_list.size+1}>#{@labels[lbl_idx].label}</td>"
            lbl_idx += 1
          }
        when  Array; 
          row += "<td colspan=#{style[0]}>#{style[1]}</td>"
          lbl_idx += style[0]
        end
      }
      firstline = false
      row += "</tr>"
    }#.join("</tr><tr>\n")

    row += "<tr>\n"
    lbl_idx=0
    ary_of_list[0].each_with_index{|style,idx|
      case style
      when Integer   ;        lbl_idx += style
      when Array; 
        (1..style[0]).each{
          row += "<td>#{@labels[lbl_idx].label}</td>" if @labels[lbl_idx]
          lbl_idx += 1
        }
      end
    }
    return row.html_safe
  end


  def label_line_option(size=2,labels=nil)
    return label_multi_lines([@TableHeaderDouble]).html_safe if @TableHeaderDouble
    return label_multi_lines(@TableHeaderMulti).html_safe if @TableHeaderMulti
    html = label_line_comm(size,labels)+
      case [ @Show,@Edit,deletable].compact.size
      when 3; "<td>　</td><td>　</td><td>　</td></tr>" 
      when 2; "<td>　</td><td>　</td></tr>"
      when 1; "<td>　</td></tr>"
      else  ; "</tr>"
      end.html_safe
  end

  def label_line(size=2,labels=nil)
    label_line_comm(size,labels) + TRend
  end

  def delete_if_accepted(obj)
    if deletable
      "<td>" + link_to('<nobr>削除</nobr>'.html_safe,obj , "data-confirm" => 'Are you sure?', :method => :delete) + "</td>"
    else
      ""
    end.html_safe
  end

  def delete_connection_if_accepted(obj)
    if connection_deletable
      url = "/#{@Domain}/delete_bind?id=#{@model.id}&bind_id=#{obj.id}"
        "<td>" + link_to('取外し',url,
                         :confirm => '関係付けだけ削除します',
                         :method => :delete) + "</td>"
    else
      ""
    end
  end

  def deletable
    (case @Delete
     when Symbol  ; controller.send(@Delete)
     else         ; @Delete
     end
    ) ? true : nil
  end

  def connection_deletable
    (case @AssosiationDelete
     when Symbol  ; controller.send(@AssosiationDelete)
     else         ; @AssosiationDelete
     end
    ) ? true : nil
  end


  def add_links_update_delete(obj,maxid)
    delete = (obj.id && obj.id < maxid) ? 
    link_to( '<nobr>削除</nobr>',obj , :confirm => 'Are you sure?', :method => :delete) : ""
    "<td>#{delete}<td>"
  end


end

