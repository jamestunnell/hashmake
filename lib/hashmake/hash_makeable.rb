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
  # @param [Hash] hashed_args A hash that should contain at least all the required
  #                           keys and valid values, according to the arg_specs passed in.
  #                           Nonrequired keys can be given as well, but if they are
  #                           not then a default value is assigned (again, according to
  #                           arg_specs passed in).
  # @param [Enumerable] arg_specs An enumerable of ArgSpec objects. Each object
  #                               details an arg key that might be expected in the
  #                               args hash. The default value will be the output
  #                               of the find_arg_specs method.
  # @param [true/false] assign_args If true, the hashed args will be assigned to
  #                                 instance variables. If false, the hashed args
  #                                 will still be checked, but not assigned.
  def hash_make hashed_args, arg_specs = find_arg_specs, assign_args = true
    arg_specs.each do |key, arg_spec|
      if hashed_args.has_key?(key)
        val = hashed_args[key]
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
      
      arg_spec.validate_value val
      
      if assign_args
        self.instance_variable_set("@#{key.to_s}".to_sym, val)
      end
    end
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
          unless value.is_a? ArgSpec or value.is_a? ArrayArgSpec or value.is_a?(HashArgSpec)
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
  
  # Contains class methods to be added to a class that includes the
  # HashMakeable module.
  module ClassMethods
    # Helper method to make a generic new ArgSpec object
    def arg_spec args
      ArgSpec.new args
    end
    
    # Helper method to make a ArgSpec object where the container is an Array.
    # Set :default to a Proc that generates an empty array.
    def arg_spec_array args
      ArrayArgSpec.new args
    end

    # Helper method to make a ArgSpec object where the container is an Hash.
    # Set :default to a Proc that generates an empty hash.
    def arg_spec_hash args
      HashArgSpec.new args
    end
  end
end
end
