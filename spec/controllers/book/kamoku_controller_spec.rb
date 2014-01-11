# -*- coding: utf-8 -*-
require 'spec_helper'
require 'book_helper'
require 'controller_helper'
require 'pp'


URL_index ="/book/kamoku"

describe Book::KamokuController,"一覧画面" do
  fixtures :users,:user_options,:user_options_users
  fixtures "book/mains","book/kamokus"
  
  login = "dezawa"
  result= :success
  it "#{login}では振替伝票一覧は#{result}" do
    login_as( login)
    get :index
    assert_response result
  end
end
