# -*- coding: utf-8 -*-
module CustumInitializers
  def self.hash_initializer(*attr_names)
    define_method(:initialize) do |*args|
      data = args.first || {}
      attr_names.each do | attr_name|
        instance_variable_set "@#{attr_name}",data[attr_name]
      end
    end
  end
  def set_variable_by_hash(hash)
    hash.each{|key,value|
      instance_variable_set "@#{key}",value
    }
  end
end
