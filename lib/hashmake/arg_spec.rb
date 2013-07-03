require 'set'
require 'pry'

module Hashmake

# Provides a specification of how a hashed arg is to be processed by the
# hash_make method. 
# 
# @author James Tunnell
# 
class ArgSpec

  # Defines default key/value pairs to use in initializing an instance.
  # The :reqd key is set to true by default.
  # The :validator key is set to a Proc that always returns true.
  DEFAULT_ARGS = {
    :reqd => true,
    :validator => ->(a){true},
    :type => Object,
    :allow_nil => false
  }
  
  attr_reader :type, :validator, :reqd, :default
  
  # A new instance of ArgSpec. 
  # 
  # @param [Hash] hashed_args Hash to use in initializing an instance. Optional keys
  #                           are :type, :reqd, :validator, and :default.
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
  def initialize hashed_args
    new_args = DEFAULT_ARGS.merge(hashed_args)
    
    @type = new_args[:type]
    raise ArgumentError, "#{@type} is not a Class" unless @type.is_a?(Class)
    
    @validator = new_args[:validator]
    @reqd = new_args[:reqd]
    
    unless @reqd
      msg = "if hashed arg is not required, a default value or value generator (proc) must be defined via :default key"
      raise ArgumentError, msg unless new_args.has_key?(:default)
      @default = new_args[:default]
    end
  end
    
  # If the val is not of the right type, but is a Hash, attempt to
  # make an object of the right type if it is hash-makeable
  def hash_make_if_needed val
    if Hashmake.hash_makeable?(@type) and val.is_a?(Hash)
      val = @type.new val
    end
    return val
  end
  
  # Check the given value, and raise ArgumentError it is not valid.
  def validate_value val
    raise ArgumentError, "val #{val} is not a #{@type}" unless val.is_a?(@type)
    raise ArgumentError, "val #{val} is not valid" unless @validator.call(val)
  end
  
  def make_hash_if_possible val
    if Hashmake::hash_makeable?(val.class) and val.class.is_a?(@type)
      val = val.make_hash
    end
    return val
  end
end
end