#!/usr/bin/ruby
# -*- coding: utf-8 -*-

dmydatafile = File.dirname( __FILE__ ) +"/../../../tmp/shimada/dmydata"
Hours = ("hour01".."hour24").to_a

while true
  sleep 10
  next unless File.exist?(dmydatafile)

  date,power = File.read(dmydatafile).split("\n")
  date = Time.local(*date.split).strftime("%Y-%m-%d")
  pw = power.split.map{ |p| p.to_f }

Hours.each_with_index{ |h,idx|
`echo "update shimada_powers set #{h}=#{pw[idx]} where date='2014-7-17' ; " |/usr/bin/mysql -u msdn --password=msdnpass msdn_develop_test `
sleep 10
}
File.delete(dmydatafile)
end
