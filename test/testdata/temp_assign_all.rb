# -*- coding: utf-8 -*-
#

Assign71 =[
           [["06/08-20:54", "06/08-22:54", [45]],
            ["06/08-22:54", "06/09-10:39", "06/08-22:54", "06/09-10:39"]],
           [nil, ["06/09-10:39", "06/11-02:39"]],
           [["06/10-20:31", "06/10-20:36", ["切替"]],
            ["06/11-02:39", "06/11-13:24", "06/11-05:47", "06/11-10:16"]],
           nil
          ].
  each{|maintain,plan| 
  (0..1).each{|idx| maintain[idx] = Time.parse("2012/"+maintain[idx]) if maintain[idx] } if maintain
  (0..3).each{|idx| plan[idx] = Time.parse("2012/"+plan[idx]) if plan[idx] } if plan
}
Assign71_2 =[  [["06/08-20:54", "06/08-22:54", [105]],
                 ["06/08-22:54", "06/09-03:39", "06/08-22:54", "06/09-03:39"]],
                [nil           , ["06/09-04:39", "06/10-20:39"]],
                [["06/10-20:30", "06/10-20:35", ["切替"]],
                 ["06/10-20:49", "06/11-07:19", "06/10-23:58", "06/11-04:10"]],
                nil
            ].
  each{|maintain,plan| 
  (0..1).each{|idx| maintain[idx] = Time.parse("2012/"+maintain[idx]) if maintain[idx] } if maintain
  (0..3).each{|idx| plan[idx] = Time.parse("2012/"+plan[idx]) if plan[idx] } if plan
}

