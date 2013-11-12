# -*- coding: utf-8 -*-

# csvrow(1行)にlabelにリストされた項目があればその位置を返す
# return は [ {label => index},[labelのおのおのがある位置]
# なければ nil
def label2idx(csvrow,label)
  csv0 = csvrow.map{|c| c.strip if c }
  lbl_idxes = label.map{|l| lbl = l.strip
    [lbl,csv0.index(lbl)] if csv0.index(lbl)
  }.compact
  lbl2idx = Hash[*lbl_idxes.flatten]
  idxes   = lbl_idxes.map{|l,i| i}
  lbl2idx.size ==0 ? nil : [lbl2idx,idxes]
end

# csvの複数行の配列から項目名のある行を探す。
# 完全に揃っていたら label2idx　の戻り値をそのまま返す
# 足りなかったら、足りない項目名を返す
# 
def serch_label_line(csvrows,label)
  #pp ["serchLabelLine",label,csv]
  while c=csvrows.shift
    #pp c
    l2i,idxes=label2idx(c,label)
    next  unless l2i
    return l2i.size == label.size ? [l2i,idxes] : [nil,*(label-l2i.keys)]
  end
  return nil
end
