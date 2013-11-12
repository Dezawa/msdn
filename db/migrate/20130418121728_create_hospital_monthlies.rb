class CreateHospitalMonthlies < ActiveRecord::Migration
  def self.up

    create_table "hospital_monthlies", :force => true do |t|
      t.date    "month"
      t.integer "day00"
      t.integer "day01"
      t.integer "day02"
      t.integer "day03"
      t.integer "day04"
      t.integer "day05"
      t.integer "day06"
      t.integer "day07"
      t.integer "day08"
      t.integer "day09"
      t.integer "day10"
      t.integer "day11"
      t.integer "day12"
      t.integer "day13"
      t.integer "day14"
      t.integer "day15"
      t.integer "day16"
      t.integer "day17"
      t.integer "day18"
      t.integer "day19"
      t.integer "day20"
      t.integer "day21"
      t.integer "day22"
      t.integer "day23"
      t.integer "day24"
      t.integer "day25"
      t.integer "day26"
      t.integer "day27"
      t.integer "day28"
      t.integer "day29"
      t.integer "day30"
      t.integer "day31"
      t.integer "nurce_id"
    end
  end

  def self.down
  end
end
