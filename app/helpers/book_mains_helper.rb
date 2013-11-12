# -*- coding: utf-8 -*-
module BookMainsHelper
  def dsp_kamoku(kamoku,data)
    if kamoku
      "<td>" + link_to(kamoku.kamoku,
                       :controller=> :book_main,:action => :book_make,
                       :kamoku_id=>kamoku.id,:kamoku => kamoku.kamoku
                       ) + "</td><td>" +
        ("%7d" % data[0][kamoku.bunrui]) + "</td><td>" + 
        ("%7d" % data[1][kamoku.bunrui]) +"</td>"
    else 
      "<td></td><td></td><td></td>"
    end
  end

  def dsp_kamoku_line(kamoku)
    if kamoku 
      if Book::Kamoku.kamokus.assoc(kamoku)
      kamoku_id = Book::Kamoku.kamokus.assoc(kamoku)[1]
      link_to(kamoku,
              :controller=> :book_main,:action => :book_make,
              :kamoku_id=>kamoku_id,:kamoku => kamoku
              ) 
      else
        kamoku
      end
    else 
      ""
    end
    
  end
  
end
