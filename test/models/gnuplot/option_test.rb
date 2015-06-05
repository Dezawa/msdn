# -*- coding: utf-8 -*-
require 'test_helper'
require "gnuplot_helper"

class Gnuplot::OptionTest < ActiveSupport::TestCase
   DefaultOptionST = Graph::Base::DefaultOptionST


   expect_opt =
     {:common=>       {:type=>"scatter", :data_file=>"data000", :xy=>[[[1, 2]]],
                       :set_key=>"set key outside autotitle columnheader"},
      :dumy=>{:a=>10,:type=>"scatter", :data_file=>"data000", :xy=>[[[1, 2]]],
              :set_key=>"set key outside autotitle columnheader",
              base_path: Pathname.new(RailsData.to_s)
             }
     }
   dumy = Gnuplot::OptionST.new({ dumy: 10})


   ## delete のテスト ##
   must "DefaultOptionST から size を deleteする" do
     opt = Gnuplot::DefaultOptionST.dup
     size = opt.delete(:header,:size)
     assert_equal "600,400",size
     assert_equal nil,opt[:header][:size]
   end

   ## dup,merge したときの object再利用していないことのテスト ##
   must "DefaultOptionST dupすると header,body,commonは異なるobject_id " do
     opt = Gnuplot::DefaultOptionST.dup
     assert Gnuplot::DefaultOptionST[:header].object_id != opt[:header].object_id,"header"
     assert Gnuplot::DefaultOptionST[:body].object_id != opt[:body].object_id,"body"
     assert Gnuplot::DefaultOptionST[:body][:common].object_id != opt[:body][:common].object_id,"body,common"
   end
   must "DefaultOptionST.merge headerにdumyをマージすると:header,:bodyは別object" do
     opt = Gnuplot::DefaultOptionST.merge(dumy)
     assert Gnuplot::DefaultOptionST[:header].object_id != opt[:header].object_id,"header"
     assert Gnuplot::DefaultOptionST[:body].object_id != opt[:body].object_id,"body"
     assert Gnuplot::DefaultOptionST[:body][:common].object_id != opt[:body][:common].object_id,"body,common"
   end
     
   must "DefaultOptionST.merge commonはmergeすると元とは別のobject" do
     option = Gnuplot::OptionST.new({},{ dumy: {a: 10}})
     opt = Gnuplot::DefaultOptionST.merge(option)
     #merge(Gnuplot::OptionST.new({},{ dumy: {a: 10}}))
     assert  opt.object_id != Gnuplot::DefaultOptionST.object_id
   end
              
   must "DefaultOptionST.merge commonはmerge!すると元と同じobject" do
     option = Gnuplot::OptionST.new({},{ dumy: {a: 10}})
     orig = Gnuplot::DefaultOptionST.merge(Gnuplot::OptionST.new)
     opt = orig.merge!(option)
     assert  opt.object_id == orig.object_id
   end
                      
   ## merge のテスト ##
   must "DefaultOptionsST.merge headerに新しいkey-valueの組み合わせがsetされるか" do
     opt = Gnuplot::DefaultOptionST.merge(Gnuplot::OptionST.new({ dumy: 10}))
     assert_equal "600,400",opt[:header][:size]
     assert_equal 10,opt[:header][:dumy]
   end

   must "DefaultOptionST.merge headerにdumyをマージするとheaderのkeyは6個" do
     opt = Gnuplot::DefaultOptionST.merge(dumy)
     assert_equal 6, opt[:header].keys.size,"headerのkeyは6個"
   end
  

   must "DefaultOptionST.merge commonはmergeされるか" do
     option = Gnuplot::OptionST.new({},{ dumy: {a: 10}})
     opt = Gnuplot::DefaultOptionST.merge(option)
     #merge(Gnuplot::OptionST.new({},{ dumy: {a: 10}}))
     assert_equal expect_opt[:dumy],opt[:body][:dumy]
   end

   ## key指定merge ##
   must "DefaultOptionSTのkey指定merge" do
     opt = Gnuplot::DefaultOptionST.dup.
       merge({xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"']},[:header])
     assert_equal [ 'timefmt "%Y-%m-%d %H:%M"'],opt[:header][:xdata_time]
   end
   must "DefaultOptionSTの2階層のkey指定merge" do
     opt = Gnuplot::DefaultOptionST.dup.
       merge({title_post: "2階層のkey"},[:body,:common])
     assert_equal "2階層のkey",opt[:body][:common][:title_post]
   end

   must "set_timerange すると common にxdata_timeが追加 " do
     opt = Gnuplot::DefaultOptionST.dup
     opt.set_timerange
     assert_equal [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%H:%M'"   ],
       opt[:body][:common][:xdata_time]
   end

   must "time_range があると set_timerange すると common にxdata_time の値が変わる " do
     opt = Gnuplot::DefaultOptionST.dup.merge({time_range: :monthly},[:header])
     opt.set_timerange
     assert_equal [ 'timefmt "%Y-%m-%d %H:%M"',"format x '%m/%d'"   ],
       opt[:body][:common][:xdata_time]
   end

    
end
