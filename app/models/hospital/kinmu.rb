# -*- coding: utf-8 -*-

# ARではない
# Monthlyの@days[]の要素として日付分インスタンスが作られる
# kinmucode_id :: その日に割り当てられた　Kinmucode　or nil
# want         :: 強い希望、弱い希望、自動割り当て 2,3,1
# shift        :: 休み、日勤、準夜、深夜 0,1,2,3。その他は nil
class Hospital::Kinmu
  attr_reader  :kinmucode,:kinmucode_id,:want,:shift,:color
delegate :logger, :to=>"ActiveRecord::Base"
  def self.create(id)
   # if id && id%1000 > 0
      self.new(id)
    #else 
    #  Hospital::KinmuNull.new
    #end
  end

  def initialize(id)
    self.kinmucode_id = id
  end

  def kinmucode
    kinmucode_id ? Hospital::Kinmucode.find(kinmucode_id) : nil
  end

  def kinmucode_code
    kinmucode_id ? kinmucode.code : nil
  end

  def kinmucode_id=(id)
    #logger.debug("Kinmu#kinmucode_id id = #{id} ")
    if id && id%1000 > 0
      @kinmucode_id = id % 1000
      @want         = id / 1000
      @kinmucode    = Hospital::Kinmucode.k_code(id%1000)
      @shift        = kinmucode.to_0123 
      @color = ["","bgcolor='orange'","bgcolor='red'"][ @want ]
    else
      @kinmucode_id = 
      @want         = 
      @shift        = nil
      @kinmucode    = nil #Hospital::KinmucodeNull.new
      @color = ""
    end
  end

  def kinmucode_want 
    @kinmucode_id ?  @kinmucode_id +  @want*1000  : 0
  end
end

__END__

１２３勤務は１２３直と直そう
Nurce#kinmus -> Nurce#rounds

          横集計
        1  0.5  0
縦 1    123
集 0.5
計 0
2

