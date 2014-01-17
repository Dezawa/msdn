# -*- coding: utf-8 -*-
class Holyday < ActiveRecord::Base
  extend CsvIo

  def self.holydays
    @holydays ||= Holyday.all.map(&:day)
  end
  def self.holyday?(day)
    holydays.include?(day)
  end

  def self.create_newyear(arg_year)
    @arg_year = arg_year.to_i
    logger.debug("TimeLocal @arg_year=#{@arg_year}")
    [ [Time.local(@arg_year,1,1),"元旦"],
      [Time.local(@arg_year-1,12,31).next_week(:monday).next_week(:monday),"成人の日"],
      [Time.local(@arg_year,2,11),"建国記念の日"],
      [Time.local(@arg_year,3,20),"＊＊日付確認：春分の日"],
      [Time.local(@arg_year,4,29),"昭和の日"],
      [Time.local(@arg_year,5,3),"憲法記念日"],
      [Time.local(@arg_year,5,4),"みどりの日"],
      [Time.local(@arg_year,5,5),"こどもの日"],
      [Time.local(@arg_year,6,30).next_week(:monday).next_week(:monday).next_week(:monday),"海の日"],
      [Time.local(@arg_year,8,31).next_week(:monday).next_week(:monday).next_week(:monday),"敬老の日"],
      [Time.local(@arg_year,9,23),"＊＊日付確認：秋分の日"],
      [Time.local(@arg_year,9,30).next_week(:monday).next_week(:monday),"体育の日"],
      [Time.local(@arg_year,11,3),"文化の日"],
      [Time.local(@arg_year,11,23),"勤労感謝の日"],
      [Time.local(@arg_year,12,23),"天皇誕生日"]
    ].map{|d,n| Holyday.create(:year =>@arg_year,:day => d,:name => n)}
  end

  def self.year_of(y);
    self.all(:conditions => ["year = ?",y],:order => "day")
  end
end
