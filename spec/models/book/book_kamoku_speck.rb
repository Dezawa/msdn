# -*- coding: utf-8 -*-
require 'spec_helper'
require 'book_helper'
require 'pp'

#extend Book

describe Book::Kamoku do
  describe "ユーザー dezawaのselect用一覧" do
      let(:kamoku) {Book::Kamoku.kamokus("dezawa")}
    it{ Book::Kamoku.kamokus("dezawa").should == KamokuChoise }
  end

  describe "dezawaの科目の表示順" do
    fixtures "book/kamokus"
    it "雑費(id=5)の表示順は2" do
      Book::Kamoku.order_no_for_display("dezawa",5).should == 2
    end
    it "工具器具備品(id=7)の表示順はnil" do
      Book::Kamoku.order_no_for_display("dezawa",7).should == nil
    end
    it "雑費(id=5)の表示順を6に変更" do
      Book::Kamoku.change_order_no_for_display("dezawa",5,6)
      Book::Kamoku.order_no_for_display("dezawa",5).should == 6
    end
    it "工具器具備品(id=7)を6に変更" do
      Book::Kamoku.change_order_no_for_display("dezawa",7,6)
      Book::Kamoku.order_no_for_display("dezawa",7).should == 6
    end
  end

  describe "update_attributesで表示順が変えられる" do
    fixtures "book/kamokus","book/mains"
    [{id: 7, from: nil, to: 19},{id:5,from: 2, to:10}].
      each{|arg|
      it "Kamoku id #{arg[:id]}は#{arg[:from]}から#{arg[:to]}へ" do
        kamoku = Book::Kamoku.find arg[:id]
        expect{kamoku.update_attributes( no: arg[:to], book_id: "dezawa" )}.
          to change{  Book::Kamoku.order_no_for_display("dezawa",arg[:id])}.
          from(arg[:from]).to(arg[:to])
      end
    }
    it "Kamoku id 5は 2から10へ" do
      kamoku = Book::Kamoku.find 5
      expect{kamoku.update_attributes( no: 10, book_id: "dezawa" )}.
      to change{  Book::Kamoku.order_no_for_display("dezawa",5)}.
      from(2).to(10)
    end
  end
end
