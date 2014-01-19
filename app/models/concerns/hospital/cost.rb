# -*- coding: utf-8 -*-
module Hospital::Cost

  Cost = [
   [], # dumy  2    3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20
   [ nil, 106, 80, 71, 61, 50, 46, 41, 36, 27.6,25.6,22.6,20.6,18.6,16.6,14.6,12.6,10.6, 8.6, 5.6, 2],
   [ nil, 204,135,105, 94, 70, 60, 45, 40, 35  ,27.5,25.5,22.5,20.5,18.5,16.5,14.5,12.5,10.5, 8.5, 5.5],
   [ nil, 300,206,150,120,104, 69, 59, 44, 39  ,34.4,27.4,25.4,22.4,20.4,18.4,16.4,14.4,12.4,10.4, 8.4],
   [ nil, 400,266,208,163,133, 93, 68, 58, 43  ,38  ,33,  27.3,25.3,22.3,20.3,18.3,16.3,14.3,12.3,10.3],
   [ nil, 500,334,250,210,162,132,102, 92, 67  ,57  ,42  ,37  ,27.2,25.2,22.2,20.2,18.2,16.2,14.2,12.2],
   [ nil, 600,400,300,250,212,161,131,101, 91  ,66  ,56  ,41  ,36  ,31  ,27.1,25.1,22.1,20.1,18.1,14.1],
   [ nil, 700,466,350,280,244,200,160,130,100  ,90  ,65  ,55  ,40  ,35  ,30  ,27  ,25  ,22  ,20  ,18]
   ]

  Cost2 = [
   [], # dumy  2    3   4   5   6   7   8   9   10   11   12   13   14   15   16   17   18   19   20
   [ nil, 106, 80, 71, 61, 50, 46, 41, 36, 27.6,25.6,22.6,20.6,18.6,16.6,14.6,12.6,10.6, 8.6, 5.6, 2],
   [ nil, 400,266,208,163,133, 93, 68, 58, 43  ,38  ,33,  27.3,25.3,22.3,20.3,18.3,16.3,14.3,12.3,10.3],
   [ nil, 700,466,350,280,244,200,160,130,100  ,90  ,65  ,55  ,40  ,35  ,30  ,27  ,25  ,22  ,20  ,18]
   ]

  def self.cost_table
    @@Cost ||= make_cost_table
  end
  def self.make_cost_table
    cost = Hash.new{|h,k| h[k]=Hash.new{|hh,kk| hh[kk] = 0 }}
     
    Hospital::Need.combination3.
      each{|cmb| c0,c1,c2 = cmb
        cost[cmb] = Hash.new{|h,k| h[k] = 0 }
        cost[cmb][[c0,c1,c2].sort] = Cost[7]
        cost[cmb][[c0,c1].sort]    = Cost[6]
        cost[cmb][[c0,c2].sort]    = Cost[5]
        cost[cmb][[c1,c2].sort]    = Cost[4]
        cost[cmb][[c0]]       = Cost[3]
        cost[cmb][[c1]]       = Cost[2]
        cost[cmb][[c2]]       = Cost[1]
    }
    cost
  end

  def self.cost_table2
    @@Cost2 ||= make_cost_table2
  end
  def self.make_cost_table2
    cost = Hash.new{|h,k| h[k]=Hash.new{|hh,kk| hh[kk] = 0 }}
     
    Hospital::Need.combination2.
      each{|cmb| c0,c1 = cmb
        cost[cmb] = Hash.new{|h,k| h[k] = 0 }
        cost[cmb][[c0,c1].sort] = Cost[3]
        cost[cmb][[c0]]       = Cost[2]
        cost[cmb][[c1]]       = Cost[1]
    }
    cost
  end

  def cost(sft_str,tight)
    case tight.size
    when 3 ;self.class.cost_table[tight][(tight & role_ids).sort][shift_remain[sft_str]]
    when 2 ;self.class.cost_table2[tight][(tight & role_ids).sort][shift_remain[sft_str]]
    else
      dbgout("Nurce#cost sft_str #{sft_str} tight #{tight}")
      raise
    end
  end
 
end
