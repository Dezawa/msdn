# -*- coding: utf-8 -*-
#==製造条件:UbeOpelation
#製品の各工程の生産速度、保守の所要時間を定義する。
#
#工程をイメージしていたが、最終的には品種の登録になった。
# 
#製品の製造速度
#- 1枚あたり製造秒数を定義する。nullな項目は、その工程がないことを意味する。
#- 東西抄造で　null な場合はその工程は使えない品種である
#- 原新乾燥で　null な場合はその工程は使えない品種である
#- 東西抄造のどちらか一つ、原新乾燥のどちらか一つは null で有ってはならない。
#- 加工がnullの場合は、加工なしで完成とみなす。
#  なお例外があり、型板 は乾燥がない
#
#保守の所要時間
#- 所要時間を 分 で定義し、対応する工程にのみ時間が定義される。
#
#======カラム
#ope_name  :: 工程条件名。Ubeboard::Product から参照される
#west  :: 西抄造を使う場合の速度
#east  :: 東抄造を使う場合の速度
#old  :: 原乾燥を使う場合の速度
#new  :: 新乾燥を使う場合の速度
#kakou  :: 加工工程の速度
#
#当初は記名切り替えもここに登録が必要かと思っていたが、切り替え時間は
#Ubeboard::ChangeTime に登録されており、それを参照しているので不要であった。
class Ubeboard::Operation < ActiveRecord::Base
  extend CsvIo
  self.table_name = 'ube_operations'
  #attr_accessible :id ,:ope_name ,:west ,:east ,:old ,:new ,:kakou

  # DB column名のリスト
  Fields = ["west", "east", "old", "new", "kakou"]
  # 実工程SymbolとDB column名との対応。
  #   命名の統一をし損なった
  Real2Field = Hash[*([:shozow,:shozoe,:dryo,:dryn,:kakou].zip(Fields).flatten)]
  # 実工程名とDBcolumn名との対応
  Ope2Fiels  = Hash[*(%w(西抄造 東抄造 原乾燥 新乾燥 加工).zip(Fields).flatten)]

  # 選択肢入力のための choise を返す。
  #   今は使われていない。
  # DB変更時にダイナミックに追随させるために、Ubeboard::OpeartionController にて
  # create,update,csv_upload のときに更新される
  # @openames が　nil か、read がtrueのときにDBから読み直される
  def self.names(read=nil)
    if !@openames || read
      @openames ||= Ubeboard::Operation.all(:conditions => "ope_name not like 'A%'",:order => "ope_name"
                                 ).map{ |p| [p.ope_name,p.id]}
    end
    @openames 
  end
  def self.hozen_periad  # k = hozen_code == [28, "A02", :shozow]
    @hozen_periad ||= Hash.new{|h,k|
      uo = Ubeboard::Operation.find_by(ope_name: k[1])
      h[k] = uo[Ubeboard::Operation::Real2Field[k[2]]].minute rescue 0
    }
  end

  # 値ゼロは未定義とみなす。プログラム中での処理を簡便にするために、変換しておく。
  def after_find
    ["west", "east", "old", "new", "kakou"].each{|ope| self[ope]=nil if self[ope]==0.0 }
    #check_pro
  end

  # Ubeboard::ChangeTimeも含めたデータの整合性をチェックする。
  # Ubeboard::OperationController#index から呼ばれ、エラーが会ったら表示する。
  # チェック内容
  #   東西抄造のどちらかに時産が入力されているか
  #   原新乾燥のどちらかに乾燥炉滞留時間が入力されているか（型板のときは無くてもよい）
  #   切り替え時間が定義されて居るか
  #     抄造、乾燥、加工の計５ライン毎に、時産、滞留時間が入っている品種の一覧をみて、
  #     全組み合わせで切替時間が定義されていること
  def self.error_check
    error = []
    count = Hash.new{|h,k| h[k]=[]}
    opes = self.all
    kinds = opes.select{|ope| ope.ope_name !~ /^A\d\d/}
    hoshus= opes.select{|ope| ope.ope_name =~ /^A\d\d/}
    opes.each{|ope|  error += ope.check   }
    kinds.each{|ope| count[ope.ope_name] << ope }
    count.map{|k,v| v if v.size>1}.compact.each{|v|
      error << "品種:「#{v[0].ope_name}」が重複しています。ID=[#{v.map(&:id).join(',')}]"
    }
    [[:west,"西抄造"],[:east,"東抄造"],[:old,"原乾燥"],[:new,"新乾燥"],[:kakou,"加工"]].each{|sym,name|
      kind_list = kinds.select{|k| k[sym] && k[sym]>0}.map(&:ope_name)
      error += Ubeboard::ChangeTime.check(name,kind_list)
    }
    error.uniq
  end

  # Ubeboard::Operation.error_check の下請け。
  # 抄造、乾燥はどちらかのラインに値が入っているか
  # 
  def check
    error = []
    west && west > 0 || east && east > 0 ||  /^A\d\d/ =~ ope_name ||
      error << "工程：#{ope_name} は東西抄造どちらにも時産が入って居ません"
    old && old  > 0 || new && new  > 0 ||  ope_name == "型板" || /^A\d\d/ =~ ope_name ||
      error << "工程：#{ope_name} は原新乾燥どちらにも滞留時間が入って居ません"
  error
  end
end

