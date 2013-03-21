module Hashmake

# Determine if a class includes the HashMakeable module.
def self.hash_makeable? klass
  klass.included_modules.include?(HashMakeable)
end

# This module should be included for any class that wants to be 'hash-makeable',
# which means that a new object instance expects all its arguments to come in a
# single Hash. See the hash_make method in this module and the ArgSpec class for
# more details.
module HashMakeable
  
  # Use the included hook to also extend the including class with HashMake
  # class methods
  def self.included(base)
    base.extend(ClassMethods)
  end

  # Process a hash that contains 'hashed args'. Each hashed arg is intended to
  # be used in initializing an object instance. 
  #
  # @param [Enumerable] arg_specs An enumerable of ArgSpec objects. Each object
  #                               details an arg key that might be expected in the
  #                               args hash.
  # @param [Hash] hashed_args A hash that should contain at least all the required
  #                           keys and valid values, according to the arg_specs passed in.
  #                           Nonrequired keys can be given as well, but if they are
  #                           not then a default value is assigned (again, according to
  #                           arg_specs passed in).
  def hash_make arg_specs, hashed_args, assign_args = true
    arg_specs.each do |key, arg_spec|
      raise ArgumentError, "arg_specs item #{arg_spec} is not a ArgSpec" unless arg_spec.is_a?(ArgSpec)
    end
    raise ArgumentError, "hashed_args is not a Hash" unless hashed_args.is_a?(Hash)

    arg_specs.each do |key, arg_spec|
      if hashed_args.has_key?(key)
        val = hashed_args[key]

        if Hashmake::hash_makeable?(arg_spec.type)
          # If the val is not of the right type, but is a Hash, attempt to
          # make an object of the right type if it is hash-makeable
          if arg_spec.container == Array && val.is_a?(Array)
            val.each_index do |i|
              item = val[i]
              if !item.is_a?(arg_spec.type) && item.is_a?(Hash)
                val[i] = arg_spec.type.new item
              end
            end
          elsif arg_spec.container == Hash && val.is_a?(Hash)
            val.each_key do |item_key|
              item = val[item_key]
              if !item.is_a?(arg_spec.type) && item.is_a?(Hash)
                val[item_key] = arg_spec.type.new item
              end
            end
          else
            if !val.is_a?(arg_spec.type) && val.is_a?(Hash)
              val = arg_spec.type.new val
            end
          end
        end
      else
        if arg_spec.reqd
          raise ArgumentError, "hashed_args does not have required key #{key}"
        else
          if arg_spec.default.is_a?(Proc) && arg_spec.type != Proc
            val = arg_spec.default.call
          else
            val = arg_spec.default
          end
        end
      end
      
      validate_arg arg_spec, val
      if assign_args
        self.instance_variable_set("@#{key.to_s}".to_sym, val)
      end        
    end
  end
  
  def validate_arg arg_spec, val
    if arg_spec.container == Array
      raise ArgumentError, "val #{val} is not an array" unless val.is_a?(Array)
      val.each do |item|
        raise ArgumentError, "array item #{item} is not a #{arg_spec.type}" unless item.is_a?(arg_spec.type)
        raise ArgumentError, "array item #{item} is not valid" unless arg_spec.validator.call(item)      
      end
    elsif arg_spec.container == Hash
      raise ArgumentError, "val #{val} is not a hash" unless val.is_a?(Hash)
      val.values.each do |item|
        raise ArgumentError, "hash item #{item} is not a #{arg_spec.type}" unless item.is_a?(arg_spec.type)
        raise ArgumentError, "hash item #{item} is not valid" unless arg_spec.validator.call(item)      
      end
    elsif arg_spec.container.nil?
      raise ArgumentError, "val #{val} is not a #{arg_spec.type}" unless val.is_a?(arg_spec.type)
      raise ArgumentError, "val #{val} is not valid" unless arg_spec.validator.call(val)      
    else
      raise ArgumentError, "arg_spec.container #{arg_spec.container} is not valid"
    end
    
    return true
  end
  
  # Look in the current class for a constant that is a Hash containing (only)
  # ArgSpec objects. Returns the first constant matching this criteria, or nil
  # if none was found.
  def find_arg_specs
    self.class.constants.each do |constant|
      val = self.class.const_get(constant)
      if val.is_a? Hash
        all_arg_specs = true
        val.each do |key,value|
          unless value.is_a? ArgSpec
            all_arg_specs = false
            break
          end
        end
        
        if all_arg_specs
          return val
        end
      end
    end
    
    return nil
  end

  # Produce a hash that contains 'hashed args'. Each hashed arg is intended to
  # be used in initializing an object instance. 
  #
  # @param [Enumerable] arg_specs An enumerable of ArgSpec objects. Each one
  #                               details an arg key that might be expected in the
  #                               args hash. This param is nil by default. If the param
  #                               is nil, this method will attempt to locate arg specs
  #                               using find_arg_specs.
  #                               
  def make_hash arg_specs = nil
    if arg_specs.nil?
      arg_specs = self.find_arg_specs
      raise "No arg specs given, and no class constant that is a Hash containing only ArgSpec objects was found" if arg_specs.nil?
    end
    
    arg_specs.each do |key, arg_spec|
      raise ArgumentError, "arg_specs item #{arg_spec} is not a ArgSpec" unless arg_spec.is_a?(ArgSpec)
    end

    hash = {}
    
    arg_specs.each do |key, arg_spec|
      sym = "@#{key}".to_sym
      raise ArgumentError, "current obj #{self} does not include instance variable #{sym}" if !self.instance_variables.include?(sym)
      val = self.instance_variable_get(sym)
      
      if Hashmake::hash_makeable?(val.class)
        val = val.make_hash
      end
      
      if arg_spec.reqd || (val != arg_spec.default)
        hash[key] = val
      elsif arg_spec.default.is_a?(Proc) && val != arg_spec.default.call
        hash[key] = val
      elsif val != arg_spec.default
        hash[key] = val
      end
    end    
    
    return hash
  end
  
  # Contains class methods to be added to a class that includes the
  # HashMakeable module.
  module ClassMethods
    def arg_spec args
      ArgSpec.new args
    end
    
    def arg_spec_array args
      args = { :container => Array, :default => ->(){Array.new} }.merge(args)
      ArgSpec.new args
    end

    def arg_spec_hash args
      args = { :container => Hash, :default => ->(){Hash.new} }.merge(args)
      ArgSpec.new args
    end
  end

end
end
