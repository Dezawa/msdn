# -*- coding: utf-8 -*-
#!/usr/bin/ruby
require 'test/unit'
require 'test_helper'
require 'postscript'
require 'ps_ube_skd'
require 'pp'

class PostscriptTest < Test::Unit::TestCase

  GraphArg = {
  :origin => Pos.new(100 , 150),
  :width   => Pos.new( 12,55),
  :x_label_pos => --5 ,:y_label_pos => -30,
  :label_pos => Pos.new(-60 , -30),
  #:y_axis0 => 0.0,
  :scale=> Pos.new(30.0,10.0),
  :axis0 => Pos.new(0.0,0.5),
  #:x_labels => earialist.map(&:label),  :y_axis_format => "%4d",
  :axis_format => Pos.new(nil,"%4d"),
  :labels => Pos.new(["111","222","333"],nil),
  :grid0 => Pos.new(1,0),:dgrid => Pos.new(1.0,10.0),
  :x_label_option => {:tilt => -90},
  :x_title=>"場所",:y_title => "経過時間/分",
  :x_title_point=>12 ,:y_title_point =>15,
  :x_title_pos => Pos.new(50,-65) ,
  :y_title_pos => Pos.new(-25,50)
}
must "boxandline" do
    pdf=Postscript.new
    pdf.boxandline( [ [ 100, 200 ,10, 20] ,[ 150, 200 ,10 ,30], [ 200 ,100 ,10, 90]])
    assert_equal ["\n",
                   "/boxandline { \n   dup 0 get aload pop pop  pop 3 2 roll\n   %  100 200 [ [ 100 200 10 20] [ 150 200 10 30] [ 200 100 10 90]]\n  { gsave 0.0 setlinewidth\n    aload  7 1 roll pop 0.5 mul 3 -1 roll  add exch\n    %  [100 200 10 20] 100 200 100 200\n     moveto lineto stroke\n    %  [100 200 10 20]\n     aload 5 1 roll\n    % [100 200 10 20] 100 200 10 20 \n    re stroke\n     % [100 200 10 20]\n    aload pop   exch 0.5 mul 3 1 roll add  3 1 roll add exch\n    % 100 200 10 20\n    %           100 200 20 5     100 5 220     220 105 105 220\n    grestore\n  } forall pop pop\n} def",
                   "\n",
                  "[[100 200 10 20] [150 200 10 30] [200 100 10 90]]",
                  "boxandline"] , pdf.page

end

must "ruby_array_to_ps_array" do
    pdf=Postscript.new
    assert_equal "[1 2 3]",pdf.ruby_array_to_ps_array([1,2,3])
  end
must "ruby_array_to_ps_array_doubl" do
    pdf=Postscript.new
    assert_equal "[[0.5 2 3] [(a) (b) (c) (d)]]",pdf.ruby_array_to_ps_array_doubl([[1/2.0,2,3],%w(a b c d)])
  end
must "label" do
    pdf=Postscript.new
    graph=Graph.new(GraphArg.merge(:pdf=>pdf))
    hash = {0=>["111", "222", "333"],
 :x=>["111", "222", "333"],
 1=>["   0", "  10", "  20", "  30", "  40", "  50"],
 :y=>["   0", "  10", "  20", "  30", "  40", "  50"]}
    assert_equal hash, graph.labels
end

must "対角線の箱" do
    pdf=Postscript.new
    pdf.box(100,200,30,40).box_diagonal(100,200,130,240)
    assert_equal pdf.page[0],pdf.page[1]
end

must "close_preanble" do
    pdf=Postscript.new
    pdf.define(:GGG){ pdf.line_width(2)}.close_preamble
    assert_equal [["/GGG { ", "2 setlinewidth ", " } def\n"]],pdf.pages
end

must "gsave" do
    pdf=Postscript.new.gsave
    assert_equal ["gsave"],pdf.page
end

must "line" do
    pdf=Postscript.new.line(10,20,30,40)
    assert_equal ["10.0 20.0 moveto 30.0 40.0 lineto stroke  \n"],pdf.page
end
must "line with size" do
    pdf=Postscript.new.line(10,20,30,40,5)
    assert_equal ["5 setlinewidth ", "10.0 20.0 moveto 30.0 40.0 lineto stroke  \n"],pdf.page
end

must "box fill" do
    pdf=Postscript.new.box_fill(10,20,30,40)
    assert_equal ["10.0 20.0 30.0 40.0 re fill"],pdf.page
end
must "box fill with color" do
    pdf=Postscript.new.box_fill(10,20,30,40,"00FF00")
    assert_equal ["gsave",
                  "0.000 1.000 0.000",
                  " setrgbcolor ","10.0 20.0 30.0 40.0 re fill",
                  "grestore"],pdf.page
end
 
must "define " do
    graph = Graph.new( GraphArg )
    pdf=PsGraph.new.box(1,2,3,4)
    str=pdf.define(:defdef){
      pdf.put_labels(graph,:y)
    }
    assert_equal ["newpath 1.0 2.0 3.0 4.0 re ",
 "/defdef { ",
 "gsave",
 "100 150 translate",
 "\n",
 "-30.0 10.0 moveto ",
 "[ (   0) (  10) (  20) (  30) (  40) (  50) ]\n {",
 "left",
 "0.0 100.0 rmoveto ",
 "} forall\n",
 "grestore",
 " } def\n"],pdf.page
  end

  must "  gsave_restore_if true " do
    pdf=Postscript.new
    pdf.gsave_restore_if(true,"RRRRRW"){ pdf.scale(2,3)}
    assert_equal ["gsave", "RRRRRW", "2.0 3.0 scale", "grestore"],pdf.page
  end
  must "  gsave_restore_if false " do
    pdf=Postscript.new
    pdf.gsave_restore_if(false,"RRRRRW"){ pdf.scale(2,3)}
    assert_equal ["2.0 3.0 scale"],pdf.page
  end

  must "gszve_restore" do
    pdf=Postscript.new
    pdf.gsave_restore{ pdf.scale(2,3).box(1,2,3,4)}
    assert_equal ["gsave", "2.0 3.0 scale", "newpath 1.0 2.0 3.0 4.0 re ", "grestore"],pdf.page
  end

  must "set rgb color by Array " do
    pdf=Postscript.new
    assert_equal ["0.004 1.000 0.502", " setrgbcolor "],pdf.set_color_rgb([1,255,128]).page
  end
  must "set rgb color by Int " do
    pdf=Postscript.new
    assert_equal ["0.004 1.000 0.502", " setrgbcolor "],pdf.set_color_rgb(0x1ff80).page
  end
    
  must "set rgb color by String " do
    pdf=Postscript.new
    assert_equal ["0.004 1.000 0.502", " setrgbcolor "],pdf.set_color_rgb("1ff80").page
  end

  must "macro init" do
    pdf=Postscript.new(:macros => [:rectangre])
    assert_equal "/string_show { string show} def\n/re { exch dup neg 3 1 roll 5 3 roll moveto 0 rlineto\n      0 exch rlineto 0 rlineto closepath } bind def\n/left { 1 dict begin /string exch def string_show end } def" ,pdf.send(:macros)
end
    must "macro init macro names" do
    pdf=Postscript.new(:macros => [:rectangre])
    assert_equal [:rectangre, :left] ,pdf.option[:macros]
end
 must "macro init macro names :all" do
    pdf=Postscript.new(:macros => [:all])
    assert_equal %w(boxandline boxandlinefill centering left  rectangre),
    pdf.option[:macros].map(&:to_s).sort
end
   
  must "PsSkd < PsGraph" do
    pdf=PsUbeSkd.new
    pdf.printf("%d %f %s\n",32,50.9,"ormat,arry")
    assert_equal ["32 50.900000 ormat,arry\n"] ,pdf.page
  end
end
