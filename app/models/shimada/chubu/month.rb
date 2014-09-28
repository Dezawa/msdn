# -*- coding: utf-8 -*-
require 'csv'
require 'nkf'
class Shimada::Chubu::Month < Shimada::Month
  self.table_name = 'shimada_months'
  has_many :shimada_powers ,class_name: "Shimada::Chubu::Power" ,dependent: :delete_all
  include PowerGraph #::MonthlyGraph
  extend PowerGraphScatter
  extend PowerGraphGraph
  #extend ::Power::Scatter
  #extend ::Power::Graph

  class << self
    def csv_upload(csvfile,factory)
      csvtable = parse_csvfile_ommit_header(csvfile)
      create_month_and_powers_by_csvtable( csvtable ,factory)
    end

    def parse_csvfile_ommit_header(csvfile)
      
      filedata = case csvfile
                 when String,Pathname
                   File.read( csvfile,encoding: "shift_jis" ,undef: :replace, replace: '*')#.
                 when ActionDispatch::Http::UploadedFile
                   csvfile.read#( encoding: "shift_jis" ,undef: :replace, replace: '*')#.
                 end
      utf8data = NKF.nkf("-w",filedata)
#        split(/[\r\n]+/)
      #filedata.shift # skip header
      rows =  CSV.parse(utf8data,:headers => true)
    end

    def  create_all_monthis_by_csvtable( csvtable ,factory)
      return nil unless csvtable["お客さま番号"].first == "650-2508-1"
      monthis = csvtable.values_at("日付").map{ |days| days.first}.uniq.
        map{ |date| Time.parse(date).beginning_of_month.to_date}.
        uniq.map{ |day|
        self.find_or_create_by(month: day.beginning_of_month.to_date,shimada_factory_id: factory.id)
      }
    end

    def  create_month_and_powers_by_csvtable( csvtable ,factory)
      monthes = create_all_monthis_by_csvtable( csvtable ,factory)
      Shimada::Chubu::Power.create_month_and_powers_by_csvtable(csvtable,factory)
      monthes
    end

    def extract_hour_data(clmns)
      date = Time.parse(clmns["日付"])
      hour,min = clmns["開始時間"].split(":")
      hour = "%02d"%hour.to_i + ( min == "00" ? "0" : "5")
      pw =  clmns["最大電力(kW)"].to_f
      [date.beginning_of_month.to_date,date.to_date,"hour#{hour}".to_sym,pw]
    end

    def target_powers(opt={ })
      factory_id = opt.delete(:factory_id)
      objects = 
        if year = opt["year"] 
          opt[:by_date] = "%m"  
          self.where("shimada_factory_id = #{factory_id}").select{ |m| m.month.year == year.to_i}
        elsif month = opt["month"]
          opt[:by_date] = "%d"
          self.where("shimada_factory_id = #{factory_id}").select{ |m| m.month == Time.parse(month)}
        else
          self.where("shimada_factory_id = #{factory_id}")
        end.map(&:powers).flatten
      objects = objects.select{ |pw| eval opt['select'] } if opt["select"]
      objects
    end

    def test
      file="/home/dezawa/MSDN/Custamer/しまだや/中部/平成２５年９月分.csv"
      csv_upload("/home/dezawa/MSDN/Custamer/しまだや/中部/平成２５年９月分.csv",1)
    end


  end
end
# Shimada::Chubu::Month.test
