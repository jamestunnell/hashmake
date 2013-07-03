
module Hashmake

class HashArgSpec
  
  attr_reader :arg_spec
  
  def initialize hashed_args = {}
    hashed_args = { :default => ->(){ {} } }.merge hashed_args
    @arg_spec = ArgSpec.new hashed_args
  end
  
  def type
    @arg_spec.type
  end
  
  def validator
    @arg_spec.validator
  end
  
  def reqd
    @arg_spec.reqd
  end
  
  def default
    @arg_spec.default
  end
  
  def hash_make_if_needed val
    val.each_key do |item_key|
      item = val[item_key]
      val[item_key] = @arg_spec.hash_make_if_needed item
    end
  end
  
  def validate_value val
    val.each do |key, item|
      @arg_spec.validate_value item
    end
  end
  
  def make_hash_if_possible hash
    hash.each_key do |key|
      hash[key] = @arg_spec.make_hash_if_possible hash[key]
    end
  end
end

end
