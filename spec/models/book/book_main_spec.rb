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
    it "最後の伝票の日付は2012,5,31" do
      book_this_year.last.date.should == Date.new(2012,5,31)
    end
    it "最後の伝票のnoは100" do
      book_this_year.last.no.should == 100
    end

    it "renumber すると最後の伝票の日付は2012,6,29" do
      Book::Main.renumber("dezawa",Date.new(2012,1,1))
      book_this_year.last.date.should == Date.new(2012,6,29)
    end     
  end

  describe "振替伝票の一覧を印刷用のCSVにする" do
    fixtures "book/mains", "book/kamokus"
    before(:all) do
      @output = Book::Main.set_to_array_for_print("dezawa",Date.new(2012,1,1))      
    end
    it("表題含めて101ある"){ @output.should have(101).items  }
    it("表題は"){ @output.first.should =~ %w(番号 日付 貸方 借方 備考 メモ 金額)}
  end

  describe "dezawaの文書を参照・編集可能か" do
    fixtures "book/mains","book/permissions"
    before(:all) do
      @book = Book::Main.find(545)
    end
    %w(dezawa  aaron  quentin  ubeboard guest).zip([true,true,false,nil,nil]).
      each{ |user,editable|
      it "#{user}は編集 #{editable}" do
        expect(@book.editable?(user)).to eq editable 
      end
    }

    %w(dezawa  aaron  quentin  ubeboard guest).zip([true,true,true,nil,nil]).
      each{  |user,editable|
      it "#{user}は参照#{editable}" do
        expect(@book.readable?(user)).to eq editable
      end
    } 
  end
end
