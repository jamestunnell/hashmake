require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::ArgSpec do
  context ':reqd is false' do
    context 'no default value is given' do
      it 'should raise error' do
        hash = { :reqd => false, :key => :some_variable, :type => String }
        expect { Hashmake::ArgSpec.new hash }.to raise_error
      end
    end

    context 'default value is given' do
      it 'should not raise error' do
        hash = { :reqd => false, :key => :some_variable, :type => String, :default => "" }
        expect { Hashmake::ArgSpec.new hash }.not_to raise_error
      end
    end

  end

  context '#validate_value' do
    context 'single type given' do
      before :all do
        @arg_spec = ArgSpec.new(:reqd => true, :type => Fixnum, :validator => ->(a){ a > 0})
      end
      
      context 'value given is correct type' do
        context 'value given is valid' do
          it 'should not raise ArgumentError' do
            lambda { @arg_spec.validate_value 1 }.should_not raise_error
          end
        end
        
        context 'value given is not valid' do
          it 'should raise ArgumentError' do
            lambda { @arg_spec.validate_value 0 }.should raise_error(ArgumentError)
          end
        end
      end
      
      context 'value given is not correct type' do
        context 'value given is valid' do
          it 'should raise ArgumentError' do
            lambda { @arg_spec.validate_value 1.0 }.should raise_error(ArgumentError)
          end
        end
        
        context 'value given is not valid' do
          it 'should raise ArgumentError' do
            lambda { @arg_spec.validate_value 0.0 }.should raise_error(ArgumentError)
          end
        end
      end
    end

    context 'multiple types given' do
      before :all do
        @arg_spec = ArgSpec.new(:reqd => true, :type => [FalseClass, TrueClass])
      end
      
      context 'value given is one of the correct types' do
        it 'should not raise ArgumentError' do
          expect { @arg_spec.validate_value false }.not_to raise_error
          expect { @arg_spec.validate_value true }.not_to raise_error
        end
      end
      
      context 'value given is not one of the correct types' do
        it 'should raise ArgumentError' do
          expect { @arg_spec.validate_value 1 }.to raise_error
          expect { @arg_spec.validate_value 0 }.to raise_error
        end
      end
    end
  end
end
