require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::ArgSpec do
  it 'should raise ArgumentError if :reqd is false and no :default value is given' do
    hash = {
      :reqd => false, :key => :some_variable, :type => String
    }
    
    lambda { Hashmake::ArgSpec.new hash }.should raise_error(ArgumentError)
  end
  
  it 'should not raise ArgumentError if :reqd is false and a :default value is given' do
    hash = {
      :reqd => false, :key => :some_variable, :type => String, :default => ""
    }
    
    lambda { Hashmake::ArgSpec.new hash }.should_not raise_error(ArgumentError)
  end

  it 'should not raise ArgumentError if valid container is given' do
    Hashmake::ArgSpec::CONTAINERS.each do |container|
      hash = {
        :reqd => true, :key => :stuff, :type => String, :container => container
      }
      
      lambda { Hashmake::ArgSpec.new hash }.should_not raise_error(ArgumentError)      
    end
  end
  
  it 'should raise ArgumentError if invalid container is given' do
    hash = {
      :reqd => true, :key => :stuff, :type => String, :container => Fixnum
    }
    
    lambda { Hashmake::ArgSpec.new hash }.should raise_error(ArgumentError)
  end
end
