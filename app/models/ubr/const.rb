# -*- coding: utf-8 -*-
WithoutPull = true
WithPull    = false
StatFont = [[Postscript::Gothic,1.4],[Postscript::Bold,1.8],[Postscript::Gothic,1.4]]


module Ubr::Const

  SCM_stock_stat_FILEBASE = File.join(RAILS_ROOT,"tmp","ubr","SCM_stock_stat")

  Suuro2Retu = %w(2C2Z 2D1Z 1B4Z 1B2Z 1A2Z)
  @dir= File.dirname(__FILE__)
  if /www/ =~ @dir
    $LOAD_PATH << @dir
    MasterDir =  @dir
  else
    $LOAD_PATH << File.join(File.dirname(__FILE__),"../System") << "~/lib/ruby"
    MasterDir =  File.join(@dir,"../System/Master")
  end

  Oneways = %w(G123DC700V------F7 G123DC6061------F7 
               G123DC820------F7 G123DC830------F7 
               G123DC720------F7 G123DZ691------F7)

Converator = [[80.7,30.5],[80.7,32.5],[83.7,32.5],[83.7,30.5],[80.7,30.5]]


end
__END__
require 'pp'
Ubr::Const::SP.each{ |h| pp [[h[:name],h[:offset],h[:stat_offset]],h[:stat_names],h[:stat_reg]]}
$Floors.keys.sort
k.each{ |souko| f=$Floors[souko]; f.contents.each_with_index{|c,i| pp [souko,c,f.sufix[i],f.max[i],f.base_points[i][0],f.base_points[i][1],f.label_pos[i][0],f.label_pos[i][1]] }}
