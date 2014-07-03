require 'yaml'

def dump_yaml(objects)
  id = 0
  objects.map{ |obj|
    id += 1
    yml = YAML.dump( obj ).#ub(/---/,"    id: #{id}").
    split(/\n/). delete_if{ |l|  /(ruby\/object:)|(attributes)/ =~ l  }.sort
    yml.unshift("  id: #{id}").unshift("id#{id}:")
  }.unshift("---\n")
end
