
module Hashmake

class ArrayArgSpec
  
  attr_reader :arg_spec
  
  def initialize hashed_args = {}
    hashed_args = { :default => ->(){ [] } }.merge hashed_args
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
    val.each_index do |i|
      item = val[i]
      val[i] = @arg_spec.hash_make_if_needed item
    end
  end
  
  def validate_value val
    val.each do |item|
      @arg_spec.validate_value item
    end
  end
  
  def make_hash_if_possible ary
    ary.each_index do |i|
      ary[i] = @arg_spec.make_hash_if_possible ary[i]
    end
  end
end

end
