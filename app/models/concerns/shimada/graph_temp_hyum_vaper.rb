# -*- coding: utf-8 -*-
class Shimada::GraphTempHyumVaper    < Graph::Ondotori::TempHumidity
  # 親のGraph::Ondotori::TempHumidityに渡す daylies は温度だけあれば良い
  # 親の親の Graph::Ondotori::Base#multi_days を over ride して湿度、水蒸気圧 を取り寄せる
  def initialize(daylies,opt={})
    dayly = 
        if daylies.kind_of?(ActiveRecord::Relation) ||dayly.class == Array
          daylies.first
        else        ; daylies
        end
    super(daylies,
          {title_post: "ー#{dayly.instrument.base_name} " +
            dayly.instrument.ch_name +
            dayly.date.strftime(" %m月%d日")}.merge(opt)
          )
  end
  
  def multi_days(daylies)
    dayly_class = daylies.first.class
    daylies.map{|dayly| dayly.time_and_converted_value_with_vaper
    }.flatten(1).sort_by{|arry| arry.first }
  end

end
