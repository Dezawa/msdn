# -*- coding: utf-8 -*-
module Hospital
  module NurceCost
    module ClassMethods
      HUGE = 99999
      Cost = 
        [
         [], # 残り少なくなると急激にコストが上がる。タイトなroleを持つほどコストが上がる。
         # iランクタイト ＞ 残り1少、2ランクタイト＞残り１少、3ランクタイト<残り１少
         #(0..6).map{|j| ((0..19).map{|i| (1.3**i * 1.1**j*20).to_i}<<nil).reverse}
         [ HUGE,2923, 2249, 1730, 1330, 1023, 787, 605, 465, 358, 275, 212, 163, 125, 96, 74, 57, 43, 33, 26, 20], 
         [ HUGE,3216, 2474, 1903, 1463, 1126, 866, 666, 512, 394, 303, 233, 179, 138, 106, 81, 62, 48, 37, 28, 22], 
         [ HUGE,3537, 2721, 2093, 1610, 1238, 952, 732, 563, 433, 333, 256, 197, 151, 116, 89, 69, 53, 40, 31, 24], 
         [ HUGE,3891, 2993, 2302, 1771, 1362, 1048, 806, 620, 477, 366, 282, 217, 167, 128, 98, 76, 58, 44, 34, 26], 
         [ HUGE,4280, 3292, 2533, 1948, 1498, 1152, 886, 682, 524, 403, 310, 238, 183, 141, 108, 83, 64, 49, 38, 29],
         [ HUGE,4708, 3622, 2786, 2143, 1648, 1268, 975, 750, 577, 444, 341, 262, 202, 155, 119, 91, 70, 54, 41, 32], 
         [ HUGE,5179, 3984, 3064, 2357, 1813, 1395, 1073, 825, 634, 488, 375, 289, 222, 171, 131, 101, 77, 59, 46, 35]
        ]
      def cost_table
        @@Cost ||= make_cost_table
      end
      def make_cost_table
        cost_table = Hash.new{|h,k| h[k]=Hash.new{|hh,kk| hh[kk] = 0 }}
        
        Hospital::Need.combination3.
          each{|cmb| c0,c1,c2 = cmb
          cost_table[cmb] = Hash.new{|h,k| h[k] = 0 }
          cost_table[cmb][[c0,c1,c2].sort] = Cost[7]
          cost_table[cmb][[c0,c1].sort]    = Cost[6]
          cost_table[cmb][[c0,c2].sort]    = Cost[5]
          cost_table[cmb][[c1,c2].sort]    = Cost[4]
          cost_table[cmb][[c0]]       = Cost[3]
          cost_table[cmb][[c1]]       = Cost[2]
          cost_table[cmb][[c2]]       = Cost[1]
        }
        cost_table
      end

      def cost_table2
        @@Cost2 ||= make_cost_table2
      end
      def make_cost_table2
        cost_table = Hash.new{|h,k| h[k]=Hash.new{|hh,kk| hh[kk] = 0 }}
        
        Hospital::Need.combination2.
          each{|cmb| c0,c1 = cmb
          cost_table[cmb] = Hash.new{|h,k| h[k] = 0 }
          cost_table[cmb][[c0,c1].sort] = Cost[3]
          cost_table[cmb][[c0]]       = Cost[2]
          cost_table[cmb][[c1]]       = Cost[1]
        }
        cost_table
      end
    end

    def self.included(base)
       base.extend ClassMethods
    end

    if  Rails.env == "test"
      def rand ; 0 ; end
    end
    def cost(sft_str,tight)
      begin
        case tight.size
        when 3 ;self.class.cost_table[tight][(tight & role_ids).sort][shift_remain[sft_str]] 
        when 2 ;self.class.cost_table2[tight][(tight & role_ids).sort][shift_remain[sft_str]]
        else
          dbgout("Nurce#cost sft_str #{sft_str} tight #{tight}")
          raise
        end
      rescue
        logger.debug("Nurce #{id}, Shift:#{sft_str} tight = #{tight.join(',')} "+
                     "shift_remain=#{shift_remain.to_a.map{ |k,v| '%s=>%d'%[k,v]}.join('/')}")
        HUGE
      end  #+ rand
    end

  def id_and_cost_to_s(sft_str,tight_roles)
    "%d:%d"%[id, cost(sft_str,tight_roles)]
  end 
  end
end
