class Pos < Hash
  #attr_accessor :x,:y
  def initialize(*xy)
    super()
    case xy.size
    when 1 #Array,Pos
      self[:x]=xy[0][0]; self[:y]=xy[0][1]
    else
      self[:x]=xy[0]; self[:y]=xy[1]
    end
    self[0] =self[:x] ; self[1] =self[:y]
    
  end

  def self.[](*args)
    self.new(args)
  end

  def to_f ; self[:x] = self[:x].to_f; self[:y] = self[:y].to_f; self;end
  def x ; self[:x];end
  def y ; self[:y];end
  def *(other)
    ret = case other
    when Integer,Float ; self.class.new(x*other,y*other);
    when Pos,Array     ; self.class.new(x*other[0],y*other[1]);
    end
    ret
  end

  def +(other)
#pp self
#pp other
    self[:x]=self[0] = self.x + other[0]
    self[:y]=self[1] = self.y + other[1]
    self
  end
  def +(other)
#pp self
#pp other
    #self[:x]=self[0] = 
    #self[:y]=self[1] = self.y + other[1]
    #self
    self.class.new(self.x + other[0],self.y + other[1])
  end
end
