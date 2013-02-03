require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::HashedArg do
  it 'should raise ArgumentError if :reqd is false and no :default value is given' do
    hash = {
      :reqd => false, :key => :some_variable, :type => String
    }
    
    lambda { Hashmake::HashedArg.new hash }.should raise_error(ArgumentError)
  end
  
  it 'should not raise ArgumentError if :reqd is false and a :default value is given' do
    hash = {
      :reqd => false, :key => :some_variable, :type => String, :default => ""
    }
    
    lambda { Hashmake::HashedArg.new hash }.should_not raise_error(ArgumentError)
  end
end
