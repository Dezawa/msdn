# -*- coding: utf-8 -*-
require 'test_helper'

class Book::BookMainTest < ActiveSupport::TestCase
 fixtures "book/kamokus","book/mains"

  test "伝票作成" do
    book = create
    assert book.errors[:no].empty?,"noはsave前に追加される"
    [:date, :amount, :karikata, :kasikata,:tytle].each{|sym|
      book = create(sym => nil)
      assert !book.errors[sym].empty?,"#{sym}は必須"
    }
    book = create( memo: nil)
    assert book.errors[:memo].empty?,"めもは必須ではない"
  end

  def create( option = {})
    attr = {
      date: "2012/10/10",   amount: 1010 , karikata: 1, kasikata: 2,
      tytle: "売上"      ,memo: nil
    }.merge(option)
    Book::Main.create attr
  end
end
# -*- coding: utf-8 -*-
