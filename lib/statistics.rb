#!/usr/local/bin/ruby
# -*- coding: utf-8 -*-
require 'matrix'
require 'pp'
module Statistics
  def polyfit(xary,yary,level=3)
    level = level.to_i
    raise if level >= xary.size
    raise if yary.size != xary.size

    matrix_xx =  nn_matrix(level,xary)
    vector_yx =  yx_vector(level,xary,yary)
    fit = (vector_yx * matrix_xx.inverse).to_a.first
  end

  def yx_vector(level,xary,yary)
    vector = []
    xpower=yary.dup
    (0..level).each{ |l|
      vector << xpower.inject(0){ |s,e| s + e}
      xary.each_with_index{ |x,idx| xpower[idx] *= x }
    }

    Matrix.rows([vector])
  end

  def nn_matrix(level,xary)
    n = xary.size
    xsums = [n]
    xpower=[1]*n

    (0..level*2).each{ |l| 
      xary.each_with_index{ |x,idx| xpower[idx] *= x }
      xsums << xpower.inject(0){ |s,e| s + e}  
    }
    matrix = (0..level).map{ |i| xsums[i,level+1] }
    Matrix.rows(matrix)
  end
end
class Array
  def average
    compact.inject(0.0) { |sum, i| sum += i } / size
  end

  def variance
    ave = average
    compact.inject(0.0) { |sum, i| sum += (i - ave)**2 } / size
  end

  def standard_devitation
    Math::sqrt(variance)
  end
end

if /multinomial_expression_approximation.rb/ =~ $0
  require 'test/unit'
  require 'test_helper'
  class Resolv 
    include MultExpressApporxi
  end

  class TC_Foo < Test::Unit::TestCase
    def setup
      @obj = Resolv.new
    end

    must "make mat from 1, 2, 3,4,5 level2" do
      assert_equal [[5, 15, 55], [15, 55, 225], [55, 225, 979]],@obj.nn_matrix(2,[1,2,3,4,5]).to_a
    end

    must "make mat from 1, 2, 3,4,5 level 3" do
      assert_equal [[5, 15, 55, 225],
                    [15, 55, 225, 979],
                    [55, 225, 979, 4425],
                    [225, 979, 4425, 20515]],@obj.nn_matrix(3,[1,2,3,4,5]).to_a
    end

    must "make xy vector level 2" do
      xary = [1,2,3,4,5]
      yary = [1,12,13,24,25]
      assert_equal [[75, 285, 1175]],@obj.yx_vector(2,xary,yary).to_a
    end

    must "make xy vector level 3" do
      xary = [1,2,3,4,5]
      yary = [1,12,13,24,25]
      assert_equal [[75, 285, 1175, 5109]],@obj.yx_vector(3,xary,yary).to_a
    end

    # http://www.mathworks.co.jp/jp/help/matlab/math/polynomial-curve-fitting.html
    must "近似" do
      x = [1 ,2 ,3 ,4 ,5]; y = [5.5 ,43.1 ,128 ,290.7 ,498.4];
      assert_equal [35.3400 ,  -60.3262 , 31.5821 ,-0.1917  ],
      @obj.polyfit(x,y,3).to_a.first.map{ |v| v.round(4)}
    end
  end
end




