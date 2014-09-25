# -*- coding: utf-8 -*-
require 'csv'
class Shimada::Chubu::Month < Shimada::Month
  self.table_name = 'shimada_months'
  class << self
    def csv_upload(csvfile,factory)
      csvtable = parse_csvfile_ommit_header(csvfile)
      create_month_and_powers_by_csvtable( csvtable ,factory)
    end

    def parse_csvfile_ommit_header(csvfile)
      filedata = File.read( csvfile,encoding: "shift_jis" ,undef: :replace, replace: '*')#.
#        split(/[\r\n]+/)
      #filedata.shift # skip header
      rows =  CSV.parse(filedata,:headers => true)
    end

    def  create_all_monthis_by_csvtable( csvtable ,factory)
      return nil unless csvtable["お客さま番号"].first == "650-2508-1"
      monthis = csvtable.values_at("日付").map{ |days| days.first}.uniq.
        map{ |date| Time.parse(date).beginning_of_month.to_date}.
        uniq.each{ |day|
        self.find_or_create_by(month: day.beginning_of_month.to_date,shimada_factory_id: factory.id)
      }
    end

    def  create_month_and_powers_by_csvtable( csvtable ,factory)
      create_all_monthis_by_csvtable( csvtable ,factory)
      Shimada::Chubu::Power.create_by_csvtable_and_make_relation(csvtable,factory)
    end

    def extract_hour_data(clmns)
      date = Time.parse(clmns["日付"])
      hour,min = clmns["開始時間"].split(":")
      hour = "%02d"%hour.to_i + ( min == "00" ? "0" : "5")
      pw =  clmns["最大電力(kW)"].to_f
      [date.beginning_of_month.to_date,date.to_date,"hour#{hour}".to_sym,pw]
    end
    def test
      file="/home/dezawa/MSDN/Custamer/しまだや/中部/平成２５年９月分.csv"
      csv_upload("/home/dezawa/MSDN/Custamer/しまだや/中部/平成２５年９月分.csv",1)
    end

  end
end
# Shimada::Chubu::Month.test
