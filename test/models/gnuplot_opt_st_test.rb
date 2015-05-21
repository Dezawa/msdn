# -*- coding: utf-8 -*-
require 'test_helper'
require "gnuplot_helper"

class Gnuplot::OptionSTTest < ActiveSupport::TestCase
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
   
   must "DefaultOptionST.merge headerにdumyをマージすると" do
     opt = Gnuplot::DefaultOptionST.merge(dumy)
     assert_equal 10,opt[:header][:dumy],"headerにdumyが追加される"
     assert_equal 6, opt[:header].keys.size,"headerのkeyは6個"

   end

   must "DefaultOptionST.merge commonはmergeされるか" do
     option = Gnuplot::OptionST.new({},{ dumy: {a: 10}})
     opt = Gnuplot::DefaultOptionST.merge(option)
     #merge(Gnuplot::OptionST.new({},{ dumy: {a: 10}}))
     assert_equal expect_opt[:dumy],opt[:body][:dumy]
   end
          
   must "DefaultOptionSTのkey指定merge" do
     opt = Gnuplot::DefaultOptionST.
       merge({xdata_time:  [ 'timefmt "%Y-%m-%d %H:%M"']},[:header])
     assert_equal [ 'timefmt "%Y-%m-%d %H:%M"'],opt[:header][:xdata_time]
   end
   must "DefaultOptionSTの2階層のkey指定merge" do
     opt = Gnuplot::DefaultOptionST.
       merge({title_post: "2階層のkey"},[:body,:common])
     assert_equal "2階層のkey",opt[:body][:common][:title_post]
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
                         

end
