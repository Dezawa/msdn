#  code   ::             
#  kinmukubun_id   ::  
#  with_mousiokuri   ::  
#  main_daytime   ::  
#  main_nignt   ::  
#  sub_daytime   ::  
#  sub_night   ::  
#  name   ::  
#  color   ::  
#  start   ::  
#  finish   ::  
#  main_next   ::  
#  sub_next   ::  
#  daytime   ::  
#  night   ::  
#  midnight   ::  
#  daytime2   ::  
#  night2   ::  
#  midnight2   ::  
#  nenkyuu"
require 'pp'
class Hospital::KinmucodeNull <  Hospital::Kinmucode
#attr_reader :code
  def initialize
    super
    code = nil 
    [:id,:daytime,:night,:midnight,:nenkyuu,:daytime2,:night2,:midnight2].
      each{|sym| self[sym]=0}
  end


end
