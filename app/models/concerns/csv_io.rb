# -*- coding: utf-8 -*-
require 'csv'
require 'nkf'
module Function

#CSVでUpload、Download するためのhelper 
#* Uploadは総とっかえ csv_upload と 有るなら更新無ければ作成 csv_update とがある
module CsvIo

  # モデルの全columnの CSV文字列を返す。
  # models　検索結果
  # header default nil ヘッダーを出すか否か
  #  Nil の時   ヘッダー無し
  #  Hashの時
  #   :columns => column名のArry あればそのカラムを出力。無ければModelの全column
  #   :labels  => ラベルのArry。あればヘッダーにそれを使う。
  #                             :columnsが無いときは無視する。
  #  以外     colums をラベルに使う
  #  modelsがArrayのArrayであるときは、ヘッダーも入っていると見なし、無視する
  def csvstr(models,header=nil)
    if models[0].class == Array
      models.map{|model| CSV.generate_line( model) }.join("\n")
    else
      colmns = labels = self.column_names
      head = if header.nil?
               ""
             else
               if header.class == Hash
                 colmns = header[:columns] || colmns
                 labels = header[:labels]  || colmns
               end
               CSV.generate_line(labels) + "\n"
             end
      head + 
        models.map{|model| CSV.generate_line(colmns.map{|n| model[n]}) 
      }.join("\n" )
    end
  end

  # 検索結果 models のCSV結果をTempfileに書き出す。
  # models　検索結果
  # header default nil ヘッダーを出すか否か
  #  Nil の時   ヘッダー無し
  #  Hashの時
  #   :columns => column名のArry あればそのカラムを出力。無ければModelの全column
  #   :labels  => ラベルのArry。あればヘッダーにそれを使う。
  #                             :columnsが無いときは無視する。
  #  以外     colums をラベルに使う
  #  modelsがArrayのArrayであるときは、ヘッダーも入っていると見なし、無視する
  # 戻り値 Tempfile の path
  def csv_out(models,header=nil)
    csvdata = NKF.nkf("-s",self.csvstr(models,header))
    csv_file = Tempfile.new(self.name)
    csv_file.puts csvdata
    csv_file.close
    csv_file.path
  end

  # csvfileから読んだデータで総とっかえする。
  # csvfile : csvfileのstream
  # labels csvファイルのラベル行のラベルのうち、取り込むべきもの
  # columns それに対応する column名
  # "id" を含む場合は、 attr_accessible でなければ結果はわからん
  def csv_upload(csvfile,labels,columns)
    error = [nil,"ファイルが指定されて居ないか、空か、フォーマットが違います"]
    begin
      csvrows = CSV.parse(NKF.nkf("-w",csvfile.read))
      lbl2idx,indexes = serchLabelLine(csvrows,labels)
      return error unless lbl2idx
    rescue
      return error
    end

    self.delete_all
    errors = [true,""]
    idx_id = lbl2idx["id"] || lbl2idx["ID"]
    csvrows.each{|row|
      model= self.new(Hash[*columns.zip(indexes.map{|idx| row[idx]}).flatten])
      if model.valid? ;  
        model[:id]=row[idx_id]  if idx_id
        model.save
      else
        errors[1]  += "\n行「"+row.join(',')+"」"+model.errors.to_a.join("|")
      end
    }
    return errors
  end  


  # csvfileから読んだデータで置き換える
  # idで探して、あるものはupdate、無いものはcreate。
  #     編集権がない場合はcreate
  # csvfile : csvfileのstream
  # labels    csvファイルのラベル行のラベルのうち、取り込むべきもの
  # columns0 それに対応する column名
  # option
  #   :condition 編集権を評価して返すメソッド
  #              model に用意されている bool を返すmethod名のSymbol
  # "id" を含まない場合は結果はわからん
  def csv_update(csvfile,labels,columns0,option)
    condition = option.delete(:condition) || :true
    csvrows = CSV.parse(NKF.nkf("-w",csvfile.read))
    lbl2idx,indexes = serchLabelLine(csvrows,labels)
    return ["CSVファイルのフォーマットが違う様です"] unless lbl2idx
    
    #self.delete_all
    idx_id = lbl2idx.delete("id") || lbl2idx.delete("ID") 
    columns = columns0.dup
    columns.delete_at(idx_id)
    indexes.delete_at(idx_id)
    error = []
    csvrows.each{|row|
      model_hash= Hash[*columns.zip(indexes.map{|idx| row[idx]}).flatten]
      #logger.debug("UPDATE: #{model_hash.to_a.join(' ')}")
      new_model = self.new(model_hash.merge option )
      if new_model.valid?
        begin
          model = self.find(row[idx_id])
          if model.send(condition)
            model.update_attributes(model_hash)
          else
            logger.debug("CSV_UPDATE: condition NG #{row.join(',')}")
            error <<  "行「"+row.join(',')+"」編集権がありません"
          end
        rescue
          logger.debug("CSV_UPDATE: rescue #{row.join(',')}")
          new_model.save
        end
      else
        logger.debug("CSV_UPDATE: valid NG #{row.join(',')}")
        error <<   "行「"+row.join(',')+"」"+ new_model.errors.to_a.join("|")
      end
    }
    return error
  end


  ##################################
  # ヘッダー行(候補)を調べ、各ラベルが何列にあるか調べる
  # 戻り  Hash と Array の Array
  #         Hash ラベルが何列にあるか
  #         Array その列だけ抜きだし
  #         [ {label0 => 3,lbel1 => 2},[3,2] ]
  # csvrow 入力データの行のARRY
  # label  ヘッダーとして必要な項目名の配列
  def label2idx(csvrow,label)
    #arryのデータから、前後の空白を削除する
    csv0 = csvrow.map{|c| c.strip if c }
    labels = label.map{|l| lbl = l.strip }
    # csvの何列目にあるかを知る
    lbl_idxes = labels.map{|lbl| 
      [lbl,csv0.index(lbl)] if csv0.index(lbl)
    }.compact
#logger.debug("label2idx:lbl_idxes #{lbl_idxes} ")
    # Hashし、Hash と indexのArrayを返す
    lbl2idx = Hash[*lbl_idxes.flatten]
    idxes   = lbl_idxes.map{|l,i| i}
#logger.debug("idxes #{idxes} ")
    lbl2idx.size ==0 ? nil : [lbl2idx,idxes]
  end

  # csvの複数行の配列から項目名のある行を探す。
  # 完全に揃っていたら label2idx　の戻り値をそのまま返す
  # 足りなかったら、足りない項目名を返す
  # みつから無かったら　nil
  # 副作用
  #    csvrows はヘッダー行まで削除されている
  def serchLabelLine(csvrows,label)
#logger.debug("label: #{label.join(', ')}")
#logger.debug("csvrows: #{csvrows.first.join(', ')}")
    #pp ["serchLabelLine",label,csv]
    while c=csvrows.shift
     # pp c[0..10]
      l2i,idxes=label2idx(c,label)
#      logger.debug("CSV l2i #{l2i.to_a.join(', ')},#{l2i.size} idxes #{idxes.join(', ')},  #{idxes.size}, label #{label.size}")
      next  unless l2i
      return l2i.size == label.size ? [l2i,idxes] : [nil,*(label-l2i.keys)]
    end
    return nil
  end

  # csv_update のdefaultの編集権確認処理。
  def true; true; end



end
end
