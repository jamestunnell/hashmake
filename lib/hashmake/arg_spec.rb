module Hashmake

# Provides a specification of how a hashed arg is to be processed by the
# hash_make method. 
# 
# @author James Tunnell
# 
class ArgSpec
  
  # Defines default key/value pairs to use in initializing an instance.
  DEFAULT_ARGS = {
    :reqd => true,
    :validator => ->(a){true},
    :array => false,
  }
  
  attr_reader :key, :type, :validator, :reqd, :default, :array
  
  # A new instance of ArgSpec. 
  # 
  # @param [Hash] hashed_args Hash to use in initializing an instance. Required
  #                           keys are :key and :type. Optional keys are :reqd,
  #                           :validator, :array, and :default.
  #                           :key => the key used to identify a hashed arg.
  #                           :type => the type of object expected to be paired
  #                                    with the key.
  #                           :reqd => If true, the arg key must be in the hash
  #                                    passed to #initialize. If false, then a
  #                                    default must be specified with :default
  #                                    key. Set to true by default.
  #                           :default => If reqd is false, this must be specified.
  #                                       This can be any object reference. If it
  #                                       is a Proc, then the Proc will be called,
  #                                       expecting it to produce the default.
  #                           :validator => a Proc used to check the validity of
  #                                         whatever value is paired with an arg key.
  #                           :array => indicates the arg key will be paired with
  #                                     an array containing objects of the type
  #                                     specified by :type.
  def initialize hashed_args
    new_args = DEFAULT_ARGS.merge(hashed_args)
    
    @key = new_args[:key]
    @type = new_args[:type]
    raise ArgumentError, "args[:type] #{@type} is not a Class" unless @type.is_a?(Class)
    
    @validator = new_args[:validator]
    @reqd = new_args[:reqd]
    @array = new_args[:array]
    
    unless @reqd
      msg = "if hashed arg is not required, a default value or value generator (proc) must be defined via :default key"
      raise ArgumentError, msg unless new_args.has_key?(:default)
      @default = new_args[:default]
    end
  end

end
end