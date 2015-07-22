# -*- coding: utf-8 -*-
require 'test_helper'

class Model
  attr_accessor :date,:temp,:width,:id
  def initialize(*arg)
    @id,@date,@temp,@width = arg
  end
end

class HtmlCellTest < ActiveSupport::TestCase
 def setup
   HtmlCell
   @model = Model.new(1,Date.new(2015,5,6),20.3,123)
 end
 
  must "HtmlLink key,params,固定params全部なし" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies'})
    assert_equal "<a href='/shimada/daylies/1' >05/06</a>", htmlcell.disp(@model)
  end

  must "HtmlLink key付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',key: :date,key_val: :date})
    assert_equal "<a href='/shimada/daylies?date=2015-05-06' >05/06</a>", htmlcell.disp(@model)
  end
  must "HtmlLink key,固定params付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',key: :date,key_val: :date,graph: :jpeg})
    assert_equal "<a href='/shimada/daylies?date=2015-05-06&graph=jpeg' >05/06</a>", htmlcell.disp(@model)
  end
  must "HtmlLink key,固定params 2つ付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',key: :date,key_val: :date,
                                   graph: :jpeg,dir: "/test/"})
    assert_equal "<a href='/shimada/daylies?date=2015-05-06&graph=jpeg&dir=/test/' >05/06</a>",
      htmlcell.disp(@model)
  end
  must "HtmlLink params付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',params: [:temp]})
    assert_equal "<a href='/shimada/daylies/1?temp=20.3' >05/06</a>", htmlcell.disp(@model)
  end
  must "HtmlLink params 2つ付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',params: [:temp,:width]})
    assert_equal "<a href='/shimada/daylies/1?temp=20.3&width=123' >05/06</a>", htmlcell.disp(@model)
  end
  must "HtmlLink key,params付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',key: :date,key_val: :date,params: [:temp]})
    assert_equal "<a href='/shimada/daylies?date=2015-05-06&temp=20.3' >05/06</a>", htmlcell.disp(@model)
  end
  must "HtmlLink 固定params付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',graph: :jpeg})
    assert_equal "<a href='/shimada/daylies/1?graph=jpeg' >05/06</a>", htmlcell.disp(@model)
  end
  must "HtmlLink key,params,固定params付き" do
    htmlcell = HtmlLink.new(:date,"月日",ro: true,tform: "%m/%d",
                            link: {url: '/shimada/daylies',key: :date,key_val: :date,params: [:temp],graph: :jpeg})
    assert_equal "<a href='/shimada/daylies?date=2015-05-06&graph=jpeg&temp=20.3' >05/06</a>", htmlcell.disp(@model)
  end
end
