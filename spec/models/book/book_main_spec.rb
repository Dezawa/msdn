# -*- coding: utf-8 -*-
require 'spec_helper'
require 'book_helper'
require 'pp'

#extend Book

describe Book::Main do
  describe "伝票作成するとき"  do
    context "必須項目がそろっている" do
      let (:book_sutisfied) {book_create}
      it{ book_sutisfied.errors.should be_empty,"エラーはない"}
    end
    context "必須項目から借方が足りないとき" do
      let (:book_without_karikata) {book_create(karikata: nil)}
      it {book_without_karikata.errors.should_not be_empty}
      it {book_without_karikata.errors.should have(1).items }
      it {book_without_karikata.errors[:karikata].should have(1).items }      
    end
    context "項目全てないときエラーは" do
      let (:book_without_all_columns) {Book::Main.create}
      it {book_without_all_columns.errors.should_not be_empty,"エラーがある"}
      it {book_without_all_columns.errors.should have(5).items }
      it {book_without_all_columns.errors[:no].should be_empty }
    end

    context "金額にあるカンマは削除される" do
      let (:book_amount_with_comma) {book_create(amount: "1,234")}
      it { book_amount_with_comma.amount.should  == 1234 }
    end
  end

  describe "所有者、日付を指定して伝票を読む" do
      fixtures "book/mains"
    it "dezawa,2012で100ある" do
      book_this_year.should have(100).items
    end
    it "最後の伝票の日付は2012,4,2" do
      book_this_year.last.date.should == Date.new(2012,4,2)
    end
    it "最後の伝票のnoは100" do
      book_this_year.last.no.should == 100
    end

    it "renumber すると最後の伝票の日付は2012,6,29" do
      Book::Main.renumber("dezawa",Date.new(2012,1,1))
      book_this_year.last.date.should == Date.new(2012,6,29)
    end     
  end
end




