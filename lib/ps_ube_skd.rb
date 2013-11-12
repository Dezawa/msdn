require 'postscript'
class PsUbeSkd < PsGraph
Macro = "/q { gsave } bind def
/Q { grestore } bind def
/cm { 6 array astore concat } bind def
/w { setlinewidth } bind def
/J { setlinecap } bind def
/j { setlinejoin } bind def
/M { setmiterlimit } bind def
/d { setdash } bind def
/m { moveto } bind def
/l { lineto } bind def
/c { curveto } bind def
/h { closepath } bind def
/re { exch dup neg 3 1 roll 5 3 roll moveto 0 rlineto
      0 exch rlineto 0 rlineto closepath } bind def
/S { stroke } bind def
/f { fill } bind def
/f* { eofill } bind def
/B { fill stroke } bind def
/B* { eofill stroke } bind def
/n { newpath } bind def
/W { clip } bind def
"
  def initialize(args={})
    super
    add_macroMacro
  end
  def puts(str)
    @page << str+"\n"; self
  end
  def print(str)
    @page << str; self
  end
  def printf(format,*arry)
    @page << format % arry; self
  end
  def add_macroMacro
    add_macro(Macro)
  end
  
  
end
