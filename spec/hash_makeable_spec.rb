require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::HashMakeable do
  class MyTestClass
    include HashMakeable
    
    HASHED_ARG_SPECS = [
      ArgSpec.new(:reqd => true, :key => :reqd_string, :type => String, :validator => ->(a){ a.length < 10 }),
      ArgSpec.new(:reqd => false, :key => :not_reqd_float, :type => Float, :default => 0.0, :validator => ->(a){ a.between?(0.0,1.0) }),
    ]
    
    attr_reader :reqd_string, :not_reqd_float
    
    def initialize hashed_args = {}
      hash_make MyTestClass::HASHED_ARG_SPECS, hashed_args
    end
  end
  
  describe '#hash_make' do
    context 'for a reqd arg' do
      it 'should raise an ArgumentError if not given in the hash' do
        lambda { MyTestClass.new }.should raise_error(ArgumentError)
      end
    end
    
    context 'for a not reqd arg' do
      it 'should not raise an ArgumentError if not given in the hash' do
        lambda { MyTestClass.new( :reqd_string => "okedoke" ) }.should_not raise_error(ArgumentError)
      end      
    end
    
    context 'any arg' do
      it 'should not raise an ArgumentError if validator returns true' do
        lambda { MyTestClass.new( :reqd_string => "okedoke" ) }.should_not raise_error(ArgumentError)
        lambda { MyTestClass.new( :reqd_string => "okedoke", :not_reqd_float => 0.5 ) }.should_not raise_error(ArgumentError)
      end
      
      it 'should raise an ArgumentError if validator returns false' do
        lambda { MyTestClass.new( :reqd_string => "okedokedokedoke" ) }.should raise_error(ArgumentError)
        lambda { MyTestClass.new( :reqd_string => "okedoke", :not_reqd_float => 1.1 ) }.should raise_error(ArgumentError)
      end

      it 'should raise an ArgumentError if arg of incorrect type is given' do
        lambda { MyTestClass.new( :reqd_string => 1.1 ) }.should raise_error(ArgumentError)
        lambda { MyTestClass.new( :reqd_string => "okedoke", :not_reqd_float => "" ) }.should raise_error(ArgumentError)
      end
      
      it 'should set instance variables to correspond with each hashed arg' do
        a = MyTestClass.new :reqd_string => "goodstuff", :not_reqd_float => 0.321
        a.instance_variables.include?("@#{:reqd_string.to_s}".to_sym).should be_true
        a.instance_variables.include?("@#{:not_reqd_float.to_s}".to_sym).should be_true
        a.reqd_string.should eq("goodstuff")
        a.not_reqd_float.should eq(0.321)
      end
    end
  end  
end
