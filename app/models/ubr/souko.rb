#!/usr/bin/ruby1.9
# -*- coding: utf-8 -*-
require 'pp'
require 'ubr/waku'
require 'ubr/lot'
require 'ubr/meigara'
require 'ubr/const'
require 'csv'

#Inv3 = 1.0/3.0
#$MasterDir = File.join(File.dirname(__FILE__),"Master")

def round3(num);  ((num + 2.999)*Inv3).to_i ;end

class Souko
  attr_accessor :places,:lot

  def initialize
    #Waku.load_by_define
    Waku.load_from_master
    Meigara.load
    @lot = LotList.new
  end

  def load_lot(file,option = {:headers => :first_row})
    @lot.load(file,option)
  end
  
  def waku_match
    ret = []
#pp @lot.list
    @lot.list.each_pair{|lot_id,lot| 
      lot.segments.
      each{|segment|
        ret << segment.waku if segment.waku.class == String 
      }
    }
    ret.sort  
  end

  def find_lot_by_meigara_name(meigara_name)
    @lots.values.select{|lot| lot.meigara.name == meigara_name}
  end


def lot_by_code_lotNo
  self.lot.id_list_by_code_lotNo #list.to_a.map{|id,lot| [id[0] ,id[1]]}.uniq
end

def lot_by_code_lotNo_garde; self.lot; end

def lot_same_code_lotNo_wak_pulled
  lot.has_mult_segments_for_same_waku.
    select{|id,lot| lot.segments.select{|seg| seg.pull == "" }.size <=1}
end
def lot_same_code_lotNo_wak_not_pulled
  lot.has_mult_segments_for_same_waku.
    select{|id,lot| lot.segments.select{|seg| seg.pull == "" }.size >1}
end
def lot_same_code_lotNo
  self.lot.has_mult_segments #list.select{|id,lot| lot.segments.size>1 }
end

def lot_without_pul
 
end
  def ship(lot,volum=nil)
    volum ||= lot.mass
    rest = lot.ship(volum) 
    @lots.delete(lot.name) if rest == 0
    rest
  end

  def import(lot)
    @lots[[lot.meigara,lot.name]] = lot
    #raise "穴切れ" unless place_list = @places.serch(lot)
    unless place_list = @places.serch(lot)
      migrate_all
      unless place_list = @places.serch(lot)
        puts output_by_lot
        raise "穴切れ" 
      end
    end
    lot.move(Places.new(lot,place_list))    
  end

  def migrate_all( migrate_list=[],min_muda=2)
    migrate_count = 0
    (1..10-min_muda).each{|i| muda = 10-i
      move_kouho_place_list(muda).each{|place|
      # @places.serch(move_kouho(muda),muda)
        migrate_count += @places.migrate( place,muda,migrate_list)
      }
    }
    migrate_count
  end

  def move_kouho_place_list(muda)
    @places.places.select{|place|
      place.sukima >= muda*3
    }
  end

  def migrate30_if_possible(sukima=3,muda=1,migrate_list=[])
    return 0 unless (place_list =  kouho30(sukima)).size>0
    moved_sum = place_list.inject(0){|moved,place| 
      moved += @places.migrate(place,muda,migrate_list) 
    }
  end
    
  def migrate30(sukima=3,muda=1,migrate_list=[])
    moved_sum = migrate30_if_possible(sukima,muda,migrate_list)
    return moved_sum unless (place_list =  kouho30(sukima)).size>0
    moved_sum + migrate_by_push_push(place_list,sukima,muda,migrate_list) 
  end

  def kouho30(muda=3)
    @places.places.select{|place| 
      place.lot && place.volum == 30 && place.current_volum <= 30 - muda*3
 #round3(place.sukima) >= muda 
    }
  end

  def migrate_if_possible(place,muda=1,migrate_list=[])
    return 0 unless place_list = @places.serch(place,muda)
    @places.migrate_to(place,place_list,migrate_list)
  end

  def migrate_by_push_push(place_list,muda=2,diff=1,migrate_list=[]) 
    @places.migrate_by_push_push(place_list,muda,diff,migrate_list) 
  end

  def expected_to_remove(muda=2)
    @places.expected_to_remove(muda)
  end

  def movable(muda=2,diff=1)
    @places.movable(muda,diff)
  end

  def select_from_movable(place,muda=2,diff=1)
    @places.select_from_movable(place,muda,diff)
  end

  # まず、1エリアでぴったりを割り当てる
  # 次に、1余りを割り当てる
  # 次に、1不足を3ton置き場と組んで割り当てる
  # 残ったのを処理する
  def assign(arglots=nil)
    arglots = @lots.values unless arglots
    lots_by_needs = sort_by_need(arglots)
    vacants_by_size = @places.vacantsBySize # vacants[place.acceptable]=[place,place,,,]
    
    return if assign_short_by_one(vacants_by_size,lots_by_needs,0)
    return if assign_short_by_one(vacants_by_size,lots_by_needs,1)
    return if assign_over_by_one(vacants_by_size,lots_by_needs,1) # 3tonを追加
    return if assign_over_by_one(vacants_by_size,lots_by_needs,2) # 6,9tonを追加
    return if assign_short_by_one(vacants_by_size,lots_by_needs,2)
    return if assign_over_by_one(vacants_by_size,lots_by_needs,3)  # 9tonを追加
    return if assign_short_by_one(vacants_by_size,lots_by_needs,3)
    #vacants_comb = vacants_combination(vacants_by_size)
    #return if assign_just_double(vacants_by_size,lots_by_needs)
    return if assign_rest(vacants_by_size,lots_by_needs.values.flatten)
  end

  def  assign_rest(vacants_by_size,lots)
    vacants = vacants_by_size.values.flatten.compact
    #vacants_comb = vacants_combination(vacants_by_size)
    lots.each{|lot| 
      place_list = serch_by_comb(lot,vacants)
      lot.move_by_place_list(place_list)
      #remove_vacants(vacants,place_list)
      vacants -= place_list
    }
  end

  def serch_by_comb(lot,vacants)
    vacants_comb = vacants_combination(vacants)
    (0..9).each{|diff| 
#pp vacants_comb[lot.need+diff].values.size
      next if vacants_comb[lot.need+diff].size == 0
      return vacants_comb[lot.need+diff].values.first.first
    }
    []
  end

  def vacants_combination(vacants)
    comb = Hash.new{|h,k| h[k] = Hash.new{|i,j| i[j]=[]}}
    (1..3).each{|m|
      vacants.combination(m).each{|place_ary|
        volum = place_ary.inject(0){|sum,place| sum += place.acceptable}
        comb[volum][m] << place_ary
      }
    }
    comb
    # (2..10).each{|m|
    #   vacants_by_size.map{|k,v| [k]*v.size }.flatten.combination(m){|arrowables|
    #     volum = arrowables.inject(0){|sum,arrowable| sum += arrowable }
    #     comb[volum][m] << arrowables
    #   }
    # }
    #comb.each{|m,sums| sums.each{|s,a| a.uniq!}}
  end
 
  def assign_short_by_one(vacants_by_size,lots_by_need,diff)
    lots_by_need.each{|need,lots|
      while lots.size > 0 && vacants_by_size[need+diff].size > 0
        lot=lots.shift
        lot.move(Places.new(lot,vacants_by_size[need+diff].shift))
      end
      lots_by_need.delete(need) if lots_by_need[need].size == 0
    }
    lots_by_need.size == 0
  end

  def assign_over_by_one(vacants_by_size,lots_by_need,diff)
    lots_by_need.each{|need,lots|
      while lots.size > 0 && 
          (need-diff == diff ? (vacants_by_size[need-diff].size > 1) :
           need-diff == diff+1 ? (vacants_by_size[need-diff].size > 1) :
          (vacants_by_size[need-diff].size > 0 &&
          (vacants_by_size[diff].size > 0 || vacants_by_size[diff+1].size > 0 )))
        lot=lots.shift
        places = Places.new(lot,
                            [vacants_by_size[need-diff].shift,
                             vacants_by_size[diff].shift || 
                             vacants_by_size[diff+1].shift])
        #pp places
        lot.move(places)
      end
      lots_by_need.delete(need) if lots_by_need[need].size == 0
    }
    lots_by_need.size == 0
  end
  def sort_by_need(arglots)
    ret = Hash.new{|h,k| h[k] = []}
    arglots.each{|lot| ret[lot.need] << lot }
    ret
  end

  def place(name) 
    @places.places.find{|place| place.name == name }
  end

  def get_place(filename)
    @places = Places.new
    File.read(filename).each_line{|line| 
      next if  /^(\s*#.*)|(^\s*)$/ =~ line
      place = Hash[*([:name,:volum,:accessbility,:location,:current_volum].
                     zip(line.split)).flatten]
      
      @places.places << Place.new(place)
    }
     @places
  end

  def get_lot(filename)
    @lots = {}
    Lot.get_lot(filename).each{|lot| #pp lot;
      @lots[[lot.meigara,lot.name]] = lot}
    @lots
  end


  def get_place_by_count(filename)
    @places = Places.new
    File.read(filename).each_line{|line| # size count
      next if  /^(\s*#.*)|(^\s*)$/ =~ line
      size,count = line.split
      size = size.to_i
      (1..count.to_i).each{|c|
        place = { :volum => size, :name => "%02d"%size + "-%03d"%c }
        @places.places << Place.new(place)
      }
    }
    @places
  end

  def get_place_by_hash(hash)
    @places = Places.new
    hash.each{|accept,count|
      size = accept*3
      (1..count.to_i).each{|c|
        place = { :volum => size, :name => "%02d"%size + "-%03d"%c }
        @places.places << Place.new(place)
      }
    }
    @places
  end

  def get_lot_by_count(filename)
    @lots = {}
    File.read(filename).each_line{|line| 
      next if /^(\s*#.*)|(^\s*)$/ =~ line
      size,count = line.split
      size = size.to_i
      (1..count.to_i).each{|c|
        #place = { :volum => size, :name => "%02d"%size + "-%03d"%c }
        name  = "lot-%02d"%size + "-%03d"%c 
        lot = { :mass => size, :name => name }
      @lots[[nil,name]] = Lot.new(lot)
      }
    }
    @lots
  end

  def sukima_count
    @places.places.select{|p| p.sukima? }.count 
  end
  def sukima_vol
    @places.places.inject(0){|sum,p| sum += p.sukima }
  end

  def sukima
    return [sukima_count,sukima_vol]
    cnt = 0
    ret=@places.places.select{|place| place.lot && place.volum != place.current_volum}.
      inject(0){|muda,place| 
      cnt += 1;muda += (place.volum - place.current_volum)}
    [cnt,ret]
  end

  def void(volum=30)
    clear = @places.places.select{|place| !place.lot }.
      each{|place| place.reserved = nil }
    clears = Places.new(nil,clear)
  end

  def void_number(volum=30)
    void(volum).size
  end

  def void30
    clear = @places.places.select{|place| !place.lot }.
      each{|place| place.reserved = nil }
    clears = Places.new(nil,clear)
    clears.void30
  end

  def void30_number
    void30.size
  end

  def output_by_lot
    @lots.sort_by{|name,lot| name.join}.map{|name,lot|
      "#{name} #{lot.mass} #{lot.location ? lot.location.join(',') : 'nil'}"
    }.join("\n")
  end

  def output_by_place
    #pp @places.sort
    @places.places.sort_by{|place| place.name}.map{|place| 
      "#{place.name} #{place.lot ? place.lot.name : '------'} "+
      "#{place.volum} #{place.current_volum} #{place.sukima}"
    }.join("\n")
  end
end

if __FILE__ == "./simu_palett.rb"

  @souko = Souko.new
  if ARGV.first == "-c"
    ARGV.shift
    @souko.get_place_by_count(ARGV.shift)
    @souko.get_lot_by_count(ARGV.shift)

  else
    @souko.get_place(ARGV.shift)
    @souko.get_lot(ARGV.shift)
  end
  @souko.assign
  #puts @souko.output_by_lot
  #puts @souko.output_by_place
  
  puts "一杯ではない置き場数 #{@souko.sukima_count}  その総隙間量 #{@souko.sukima_vol}パレット"
  puts "30ton置き場の空き数 #{@souko.void30_number}"
  puts "置き場の空き数 #{@souko.void_number(1)}"
end
