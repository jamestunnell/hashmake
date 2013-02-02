module HashMake
module HashMakeable
  
  # Use the included hook to also extend the including class with HashMake
  # class methods
  def self.included(base)
    base.extend(ClassMethods)
  end

  def hash_make arg_specs, hashed_args, assign_args = true
    arg_specs.each do |arg_spec|
      raise ArgumentError, "arg_specs item #{arg_spec} is not a HashedArg" unless arg_spec.is_a?(HashedArg)
    end
    raise ArgumentError, "hashed_args is not a Hash" unless hashed_args.is_a?(Hash)

    arg_specs.each do |arg_spec|
      
      key = arg_spec.key
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
      
      if arg_spec.array
        raise "val #{val} is not an array" unless val.is_a?(Array)
        val.each do |item|
          raise "array item #{item} is not a #{arg_spec.type}" unless item.is_a?(arg_spec.type)
        end
      else
        raise "val #{val} is not a #{arg_spec.type}" unless val.is_a?(arg_spec.type)
      end
      
      if assign_args
        raise ArgumentError, "value #{val} is not valid" unless arg_spec.validator.call(val)
        self.instance_variable_set("@#{key.to_s}".to_sym, val)
      end
    end
  end

  module ClassMethods
    # none right now, maybe later
  end

end
end
