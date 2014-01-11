# -*- coding: utf-8 -*-
require 'spec_helper'
require 'book_helper'
require 'pp'

def create_kamoku(opt={})
  params = {
    code: "資産", bunrui: 500, kamoku: "テスト課目"
  }
  Book::Kamoku.create( params.merge opt)
end

describe  "課目一覧"  do
  fixtures "book/kamokus"
  it { Book::Kamoku.count.should eq 29 }

  let (:kamokus) {Book::Kamoku.find_with_main("dezawa").
    map{|k| [k.id,k.code,k.bunrui,k.kamoku,k.no,k.book_id]}}
  it { expect( kamokus - Kamoku ).to  eq [] }
end

describe  "select用一覧" do
  fixtures "book/kamokus"
    #puts Book::Kamoku.kamokus.map{|k| "["+k.join(",")+"],"}
  it "最初の並び順" do
     assert_equal KamokuChoise,Book::Kamoku.kamokus("dezawa")
  end

  it "雑費のy表示順を 2 から6に変更" do
    zappi = Book::Kamoku.find_by(kamoku: "雑費")
    zappi.update_attributes(:no => 6,:book_id=> "dezawa")
    new_zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="雑費"}
    assert_equal 6, new_zappi.no
  end

  it "普通預金の表示順を 6 に設定" do
    expect {
      zappi = Book::Kamoku.find_with_main("dezawa").find{|k| k.kamoku =="普通預金"}
      zappi_book = ""
      zappi.update_attributes(:no => 6,:book_id=> "dezawa")
    }.to change{
      Book::Kamoku.order_no_for_display("dezawa",6) #普通預金
    }.from(nil).to(6)
  end
end

describe Book::Kamoku do
  it "一つ増える" do
    expect{ create_kamoku }.to change{ Book::Kamoku.count}.by(1)
  end

  [:bunrui,:code, :kamoku].each{|item|
    it "必須#{item}が足りないと増えない" do
      expect{ @kamoku =create_kamoku(item => nil) }.to change{ Book::Kamoku.count}.by(0)
      expect(@kamoku.errors[item]).not_to be_nil
    end
  }
end
