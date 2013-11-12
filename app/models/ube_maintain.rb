# -*- coding: utf-8 -*-
# 自動割り付けされない、臨時の保守など、工程が止まる期間を登録する。
class UbeMaintain < ActiveRecord::Base
  extend Function::CsvIo
  attr_accessible :ope_name, :plan_time_start, :plan_time_end,:maintain_no ,:maintain   ,      :memo
end
