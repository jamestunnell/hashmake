require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::ArrayArgSpec do
  it 'should not raise ArgumentError if :reqd is false and a :default value is given' do
    hash = {
      :reqd => false, :key => :some_variable, :type => String, :default => ""
    }
    
    lambda { Hashmake::ArrayArgSpec.new hash }.should_not raise_error(ArgumentError)
  end
  
  context '#validate_value' do
    before :each do
      @arg_spec = ArrayArgSpec.new(:reqd => true, :type => Fixnum, :validator => ->(a){ a > 0})
    end
    
    context 'value given is correct type' do
      context 'value given is valid' do
        it 'should not raise ArgumentError' do
          lambda { @arg_spec.validate_value([1, 2]) }.should_not raise_error
        end
      end
      
      context 'value given is not valid' do
        it 'should raise ArgumentError' do
          lambda { @arg_spec.validate_value([0, 2]) }.should raise_error(ArgumentError)
        end
      end
    end
    
    context 'value given is not correct type' do
      context 'value given is valid' do
        it 'should raise ArgumentError' do
          lambda { @arg_spec.validate_value([1.0, 2]) }.should raise_error(ArgumentError)
        end
      end
      
      context 'value given is not valid' do
        it 'should raise ArgumentError' do
          lambda { @arg_spec.validate_value([0.0, 2]) }.should raise_error(ArgumentError)
        end
      end
    end
  end
end
