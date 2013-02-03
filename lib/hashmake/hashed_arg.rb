module Hashmake
class HashedArg
  
  DEFAULT_ARGS = {
    :reqd => true,
    :validator => ->(a){true},
    :array => false,
  }
  
  attr_reader :key, :type, :validator, :reqd, :default, :array
  
  def initialize args
    new_args = DEFAULT_ARGS.merge(args)
    
    @key = new_args[:key]
    @type = new_args[:type]
    raise ArgumentError, "args[:type] #{@type} is not a Class" unless @type.is_a?(Class)
    
    @validator = new_args[:validator]
    @reqd = new_args[:reqd]
    @array = new_args[:array]
    
    unless @reqd
      msg = "if hashed arg is not required, a default value or value generator (proc) must be defined via :default key"
      raise ArgumentError, msg unless args.has_key?(:default)
      @default = new_args[:default]
    end
  end

end
end