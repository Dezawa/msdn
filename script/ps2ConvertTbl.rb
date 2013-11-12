#!/usr/bin/ruby1.8
require 'pp'
require 'pstore'

def readPS
  db = PStore.new("/opt/MSDN/PStoreDB/PSuni2ps")
  db.transaction do ; db["PSuni2ps"] ;end
end


def restorePS
  dict = []
  code2val = Hash.new(["/f-2-0","01"])
  until gets =~ /%%EndComments/;end
  while gets
    break  if $_ =~ /^%%Page: /
    dict << $_
    fontname = $_.split[1] if $_ =~ /\/FontName/
    if $_ =~ /^\s*Encoding/ 
      dmy,val,code = $_.split
      code2val[code.split("uni")[1].to_i(16)] = [fontname,sprintf("%02x",val.to_i)]
    end
  end

  code2val

  header = "%%!PS-Adobe-3.0
%%%%Creator: cairo 1.8.10 (http://cairographics.org)
%%%%CreationDate: Thu Jun  2 14:59:20 2011
%%%%Orientation: %s
%%%%Pages: %d
%%%%BoundingBox: 0 0 %d %d
%%%%DocumentPaperSizes: %s
%%%%DocumentData: Clean7Bit
%%%%LanguageLevel: 2
%%%%EndComments
"
  pageheader = "%%%%Page: %d %d
%%%%BeginPageSetup
%%%%PageOrientation: %s
%%%%PageBoundingBox: 0 0 %d %d%s
%%%%EndPageSetup
"
  pagetrailer = "
 showpage
%%Trailer
%%EOF
"
  db = PStore.new("/opt/MSDN/PStoreDB/PSuni2ps")
  db.transaction do ; 
    db["PSuni2ps"]={
      :howto => ":headerFMT , pages,boundigBoxX,Y
:pageheaderFMT,page,page,boundigBoxX,Y
:pagetrailer
psstr = str.unpack(\"U*\").map{|c| :table[c][1]}.join

",
      :headerFMT => header,
      :dict      => dict.join ,
      :pageheaderFMT => pageheader,
      :trailer => pagetrailer, 
      :table => code2val
    }
  end
end

if ARGV[0] =~ /^-/
  opt = ARGV.shift
  case opt
  when "-s" ; restorePS
  when "-r"; 
    pp readPS[ARGV.shift.to_sym]
  end
  #printf pageheader,2,2,800,900
  #__END__

end
