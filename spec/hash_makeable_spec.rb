require 'pry'
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Hashmake::HashMakeable do
  class MyTestClass
    include HashMakeable
    
    NON_REQD_FLOAT_DEFAULT = 0.0
    
    ARG_SPECS = {
      :reqd_string => arg_spec(:reqd => true, :type => String, :validator => ->(a){ a.length < 10 }),
      :not_reqd_float => arg_spec(:reqd => false, :type => Float, :default => NON_REQD_FLOAT_DEFAULT, :validator => ->(a){ a.between?(0.0,1.0) }),
      :not_reqd_array_of_float => arg_spec_array(:reqd => false, :type => Float,  :validator => ->(a){ a.between?(0.0,1.0) }),
      :not_reqd_hash_of_float => arg_spec_hash(:reqd => false, :type => Float, :validator => ->(a){ a.between?(0.0,1.0) }),
      :string_or_class => arg_spec(:reqd => false, :type => [String, Class], :default => "")
    }
    
    attr_accessor :not_reqd_float
    attr_reader :reqd_string, :not_reqd_array_of_float, :not_reqd_hash_of_float
    
    def initialize hashed_args = {}
      hash_make hashed_args, ARG_SPECS
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

      it 'should not care (raise error) what the hash keys are' do
        expect { MyTestClass.new :reqd_string => "", :not_reqd_hash_of_float => { 0 => 0.5, "abc" => 0.75 } }.not_to raise_error
        expect { MyTestClass.new :reqd_string => "", :not_reqd_hash_of_float => { Class => 0.5, Hashmake => 0.75 } }.not_to raise_error
      end
    end

    context 'multi-type arg' do
      it 'should not raise error if value is one of the allowed types' do
        expect { MyTestClass.new(:reqd_string => "", :string_or_class => "Hello") }.not_to raise_error
        expect { MyTestClass.new(:reqd_string => "", :string_or_class => String) }.not_to raise_error
      end

      it 'should raise error if value is not one of the allowed types' do
        expect { MyTestClass.new(:reqd_string => "", :string_or_class => 1.2) }.to raise_error
      end
    end

    context 'multi-type array container' do
      it 'should not raise error if all values are one of the allowed types' do
        [
          ["String"],
          ["String", String],
          [String, Float, "Fixnum"],
        ].each do |good_values|
          expect { MyTestClass.new(:reqd_string => "", :strings_or_classes => good_values) }.not_to raise_error
        end
      end

      it 'should raise error if any of the values is not one of the allowed types' do
        [
          [1.2],
          ["String", 1.2, String],
          [String, 1.2, "Fixnum"],
        ].each do |good_values|
          expect { MyTestClass.new(:reqd_string => "", :strings_or_classes => good_values) }.not_to raise_error
        end
      end
    end

    context 'multi-type hash container' do
      it 'should not raise error if all values are one of the allowed types' do
        [
          [0 => "String"],
          [0 => "String", 1 => String],
          [0 => String, 1 => Float, 2 => "Fixnum"],
        ].each do |good_values|
          expect { MyTestClass.new(:reqd_string => "", :strings_or_classes => good_values) }.not_to raise_error
        end
      end

      it 'should raise error if any of the values is not one of the allowed types' do
        [
          [0 => 1.2],
          [0 => "String", 1 => 1.2, 2 => String],
          [0 => String, 1 => 1.2, 2 => "Fixnum"],
        ].each do |good_values|
          expect { MyTestClass.new(:reqd_string => "", :strings_or_classes => good_values) }.not_to raise_error
        end
      end
    end
  end
end
