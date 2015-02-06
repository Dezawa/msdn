
  def nurce(id,month = nil); 
    n = Hospital::Nurce.find id
    @month  = Date.new(*month) if month
    n.monthly(@month)
    n
  end

  def nurce_set(ids)
    ids.map{ |id| Hospital::Nurce.find id}
  end

  def set_code(nurce,day,code)
    nurce.monthly.day10 = code
    nurce.monthly.shift = nil
    nurce.monthly.store_days
  end


  def extract_set_shifts(string)
    nurces=[]
    string.each_line{|line|
      hp,assign,id,data,dmy = line.split(nil,5)
      case id
      when /^\d+$/
        nurce = Hospital::Nurce.find(id.to_i)
        nurce.monthly(@month)
        nurce.set_shift_days(1,data[1..-1].chop)
        #nurce.refresh
        nurces.push nurce
      when  /ENTRY/
      end
    }
    nurces.compact
  end
  def nurce_by_id(id,nurces)
    nurces.select{ |n| n.id == id}[0]
  end


  def nurce_select(*ids)
    ids.map{|id| @nurces.select{|nurce| nurce.id == id }.first}
  end

class Hospital::Nurce < ActiveRecord::Base
  # [0,0,0,1,3,0.....]
  def day_store(shift_list)
    shift_list.each_with_index{|shift,day|  set_shift(day+1,shift.to_s)}
  end
end

class Array
  def add(other) ;  self.zip(other).map{ |a,b| a+b } ;end
  def mult(other) ;  self.zip(other).map{ |a,b| a*b } ;end
  def times(other) ;  self.map{ |a| a*other } ;end
end

  Log2_3 = 
"  HP ASSIGN 34 _1_1__11_____________1______1
  HP ASSIGN 35 _110___250330_0______________
  HP ASSIGN 36 _2503300_______0____________0
  HP ASSIGN 37 _200_______________________10
  HP ASSIGN 38 _1____0______________________
  HP ASSIGN 39 _112_________________________
  HP ASSIGN 40 _311__1_____________12____1__
  HP ASSIGN 41 __330________________________
  HP ASSIGN 42 ________0_______________0____
  HP ASSIGN 43 _1_______00____1_0_1__1_2__1_
  HP ASSIGN 44 _12_______1______0____3______
  HP ASSIGN 45 _311_____________0________2__
  HP ASSIGN 46 _1_2203300_____________0_____
  HP ASSIGN 47 _011________1__00___1________
  HP ASSIGN 48 __01________________1________
  HP ASSIGN 49 _12__________________10______
  HP ASSIGN 50 __11_2______2___00____0_33_1_
  HP ASSIGN 51 _103___________00____________
  HP ASSIGN 52 __300____0_0___________0_____
"

  Log2_4 = 
"
  HP ASSIGN 34 _220330_______________________
  HP ASSIGN 35 _220330______________________ 4 9
  HP ASSIGN 36 _220330______________________ 4 10
  HP ASSIGN 37 _____________________________ 4 9
  HP ASSIGN 38 _2___________________________ 3 4 9
  HP ASSIGN 39 _3___________________________ 3 4 9
  HP ASSIGN 40 _22__________________________ 3 4 9
  HP ASSIGN 41 ___33________________________ 3 4 9
  HP ASSIGN 42 _____2203____________________ 4 9 10
  HP ASSIGN 43 _____2203____________________ 4 9 10
  HP ASSIGN 44 _____3302____________________ 4 9 10
  HP ASSIGN 45 _22033_______________________ 4 9 10
  HP ASSIGN 46 _22033022____________________ 4   10
  HP ASSIGN 47 _22033022____________________ 3 4   10
  HP ASSIGN 48 _2203303303__________________ 3 4   10
  HP ASSIGN 49 _2203302203__________________ 3 4   10
  HP ASSIGN 50 _220330220330________________ 4 10
  HP ASSIGN 51 _220330220330________________ 4 10
  HP ASSIGN 52 __300____0_0___________0_____ 4 10
"
Log2_5 = "
assign_by_re_entrant
  HP ASSIGN  1 ________________________________   4
  HP ASSIGN  2 ________________________________   4
  HP ASSIGN  3 ________________________________   4
  HP ASSIGN  4 ________________________________  349
  HP ASSIGN  5 _______220330___________________  349  2533    3
  HP ASSIGN  6 _____220330_____________________  349  2533    3
  HP ASSIGN  7 ___220330_______________________  349  2533    3
  HP ASSIGN  8 _30220330_______________________   49            0
  HP ASSIGN  9 _220330______2__________________   49            0
  HP ASSIGN 10 _____________220330_____________ 34910        3
  HP ASSIGN 11 _220330_________________________ 3410   2786   3
  HP ASSIGN 12 __330____220330_________________ 3410   2786   3
  HP ASSIGN 13 _30________220330_______________  410          3
  HP ASSIGN 14 __220_________220330____________  410        4
  HP ASSIGN 15 _2__________220330______________  410           2
               .1...+...*...+
  HP ASSIGN 16 ________220330__________________ 3410   2786   3
  HP ASSIGN 17 ________________________________  410   2474    2
  HP ASSIGN 18 _330220_________________________  410   1903   3
  HP ASSIGN 19 ____220330______________________  410   1903   3
  HP ASSIGN 20 ______220330____________________  410   1903   3
  HP ASSIGN 21 __220330________________________  410   1903   3
  HP ASSIGN 22 _______220330___________________  410   1903   3  
  HP ASSIGN 23 _2__________220_________________  410         2
  HP ASSIGN 24 _________220330_________________  4910  1730   3
  HP ASSIGN 25 __________220___________________  4910  1730   3
  HP ASSIGN 26 ________220_____________________  4910  1730   3
  HP ASSIGN 27 ___________220330_______________  49           3
  HP ASSIGN 28 __________220030________________  49             3
  HP ASSIGN 29 ___330220_____220330____________  49               1
  HP ASSIGN 30 __330220330___220_______________  49               1
  HP ASSIGN 31 ________________________________  49
  HP ASSIGN 32 ________________________________  49
  HP ASSIGN 33 ________________________________  49
HP   5                                           
"                                                
