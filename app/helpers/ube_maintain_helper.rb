# -*- coding: utf-8 -*-
module UbeMaintainHelper
  def ope_select(obj,option={})
      select_with_id(:ube_maintain,:ope_name,obj,option[:index],
                     %w(西抄造 東抄造 養生 原乾燥 新乾燥 加工)
                     )
  end

  def maintains
    @maintain ||= %w(3×6切替 PF替 S1切替（後） S1切替（前） WF替 原料切替 サラン替)+
      %w(定板替 定期清掃 西抄造酸洗い 東抄造酸洗い 予防保全 16高級切替)
  end
end
