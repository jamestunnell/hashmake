require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::HashMakeable do
  class AlsoHashMakeable
    include Comparable
    include HashMakeable
    
    ARG_SPECS = {
      :a_number => arg_spec(:reqd => false, :type => Numeric, :default => 1.0)
    }
    
    attr_accessor :a_number
    
    def initialize args = {}
      hash_make ARG_SPECS, args
    end
    
    def <=>(other)
      a_number <=> other.a_number
    end
  end
  
  class MyTestClass
    include HashMakeable
    
    NON_REQD_FLOAT_DEFAULT = 0.0
    
    ARG_SPECS = {
      :reqd_string => arg_spec(:reqd => true, :type => String, :validator => ->(a){ a.length < 10 }),
      :not_reqd_float => arg_spec(:reqd => false, :type => Float, :default => NON_REQD_FLOAT_DEFAULT, :validator => ->(a){ a.between?(0.0,1.0) }),
      :not_reqd_array_of_float => arg_spec_array(:reqd => false, :type => Float,  :validator => ->(a){ a.between?(0.0,1.0) }),
      :not_reqd_hash_of_float => arg_spec_hash(:reqd => false, :type => Float, :validator => ->(a){ a.between?(0.0,1.0) }),
      :also_hash_makeable => arg_spec(:reqd => false, :type => AlsoHashMakeable, :default => ->(){ AlsoHashMakeable.new }),
    }
    
    attr_accessor :not_reqd_float
    attr_reader :reqd_string, :not_reqd_array_of_float, :not_reqd_hash_of_float, :also_hash_makeable
    
    def initialize hashed_args = {}
      hash_make ARG_SPECS, hashed_args
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
    
    context 'array container arg' do
      it 'should be empty by default' do
        a = MyTestClass.new :reqd_string => ""
        a.not_reqd_array_of_float.should be_empty
      end

      it 'should assign array if it contains valid values of correct type' do
        a = MyTestClass.new :reqd_string => "", :not_reqd_array_of_float => [ 0.5, 0.75 ]
        a.not_reqd_array_of_float.should eq([ 0.5, 0.75 ])
      end

      it 'should raise ArgumentError if it contains invalid values of correct type' do
        lambda do
          a = MyTestClass.new :reqd_string => "", :not_reqd_array_of_float => [ -0.5, 2.5 ]
        end.should raise_error(ArgumentError)
      end

      it 'should raise ArgumentError if it contains valid values of incorrect type' do
        lambda do
          a = MyTestClass.new :reqd_string => "", :not_reqd_array_of_float => [ "", 2.5 ]
        end.should raise_error(ArgumentError)
      end
    end

    context 'hash container arg' do
      it 'should be empty by default' do
        a = MyTestClass.new :reqd_string => ""
        a.not_reqd_hash_of_float.should be_empty
      end

      it 'should assign array if it contains valid values of correct type' do
        a = MyTestClass.new :reqd_string => "", :not_reqd_hash_of_float => { :a => 0.5, :b => 0.75 }
        a.not_reqd_hash_of_float.should eq({ :a => 0.5, :b => 0.75 })
      end

      it 'should raise ArgumentError if it contains invalid values of correct type' do
        lambda do
          a = MyTestClass.new :reqd_string => "", :not_reqd_hash_of_float => { :a => -0.5, :b => 1.75 }
        end.should raise_error(ArgumentError)
      end

      it 'should raise ArgumentError if it contains valid values of incorrect type' do
        lambda do
          a = MyTestClass.new :reqd_string => "", :not_reqd_hash_of_float => { :a => "", :b => 0.75 }
        end.should raise_error(ArgumentError)
      end
    end
    
    context 'hash-makeable arg' do
      it 'should construct the hash-makeable arg from just a Hash' do
        a_number = 5
        a = MyTestClass.new(:reqd_string => "ok", :also_hash_makeable => { :a_number => a_number })
        a.also_hash_makeable.a_number.should eq(a_number)
      end
    end
  end
  
  describe '#make_hash' do
    before :each do
      @reqd_string = "okeydoke"
      @obj = MyTestClass.new :reqd_string => @reqd_string, :non_reqd_float => MyTestClass::NON_REQD_FLOAT_DEFAULT
      @hash = @obj.make_hash
    end
    
    it 'should produce a Hash' do
      @hash.should be_a Hash
    end
    
    it "should always include req'd values" do
      @hash.should include(:reqd_string)
      @hash[:reqd_string].should eq(@reqd_string)
    end
    
    it "should never include non-req'd default values" do
      @hash.should_not include(:non_reqd_float)
    end

    it "should always include non-req'd non-default values" do
      @obj.not_reqd_float = 2.0
      hash = @obj.make_hash
      hash.should include(:not_reqd_float)
      hash[:not_reqd_float].should eq(2.0)
    end
    
    it "should turn any hash-makeable objects into Hash objects" do
      @obj.also_hash_makeable.a_number = 2.0
      hash = @obj.make_hash
      hash.should include(:also_hash_makeable)
      hash[:also_hash_makeable].should be_a Hash
      hash[:also_hash_makeable].should include(:a_number)
      hash[:also_hash_makeable][:a_number].should eq(2.0)
    end
  end
end
