require 'yaml'
class ToYaml
def self.toYaml(object,path)
    objects = case object
         when Class
    	    object.all
	 else
            [object]
         end
   open(path,"w"){|fp|
    fp.puts "---"
     objects.each_with_index{|obj,idx|
       yml=YAML.dump(obj).sub(/\A.*attributes:\n/m,"").
                gsub(/^.*:\s*('')?s*$\n/,"")
       fp.puts "obj#{idx+1}:"
       fp.print yml
     }
  }
end
end
