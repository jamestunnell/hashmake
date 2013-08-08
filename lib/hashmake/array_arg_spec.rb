
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
  
  def validate_value val
    val.each do |item|
      @arg_spec.validate_value item
    end
  end  
end

end
