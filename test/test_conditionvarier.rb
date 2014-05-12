#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"
#

#class VaspUtils::ConditionVarier
#end
class VaspUtils::ConditionVarier
    attr_accessor :options
end

class TC_ConditionVarier < Test::Unit::TestCase
    def setup
        dir = "test/conditionvarier/standard"
        options = { :ka => "1,2", :kbc => "1,2,4", :encut => "400,500"}
        @cv00 = VaspUtils::ConditionVarier.new(dir, options)
    end

    def test_initialize
        #standard_vaspdir が VaspDir でなかったら例外。
        assert_raise(VaspUtils::VaspDir::InitializeError){
            VaspUtils::ConditionVarier.new("", [])
        }

        assert_equal([1,2], @cv00.options[:ka])
        assert_equal([1,2,4], @cv00.options[:kbc])
        assert_equal([400.0,500.0], @cv00.options[:encut])
    end

    def test_self_integers
        assert_equal([1, 2], VaspUtils::ConditionVarier.integers("1,2"))
        assert_equal([1, 2], VaspUtils::ConditionVarier.integers("1, 2"))
        assert_equal([1, 2], VaspUtils::ConditionVarier.integers("1,2 "))
        assert_equal([1, 2], VaspUtils::ConditionVarier.integers(" 1,2 "))

        assert_equal([1], VaspUtils::ConditionVarier.integers("1"))
    end

    def test_self_floats
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats("1.0,2.0"))
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats("1.0, 2.0"))
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats("1.0,2.0 "))
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats(" 1.0,2.0 "))

        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats("1,2"))
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats("1, 2"))
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats("1,2 "))
        assert_equal([1.0, 2.0], VaspUtils::ConditionVarier.floats(" 1,2 "))

        assert_equal([1.0]     , VaspUtils::ConditionVarier.floats("1.0"))
    end

    def test_self_check_sanity_options
        options = {
            :ka => "1,2",
            :kab => "1,2",
        }
        assert_raise(VaspUtils::ConditionVarier::InvalidOptionError){
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }

        options = {
            :kab => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::ConditionVarier::InvalidOptionError){
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }

        options = {
            :ka => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::ConditionVarier::InvalidOptionError){
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }

        options = {
            :kb => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::ConditionVarier::InvalidOptionError){
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }

        options = {
            :kc => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::ConditionVarier::InvalidOptionError){
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }

        options = {
            :ka => "1,2",
            :kbc => "1,2",
        }
        assert_nothing_raised{
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }

        options = {
            :ka => "1,2",
        }
        assert_nothing_raised{
            VaspUtils::ConditionVarier.check_sanity_options(options)
        }
    end

    def test_selfnth_combination
        ary = [2,2,3]
        results = VaspUtils::ConditionVarier.nth_combination(ary)
        corrects = [
            [0,0,0],
            [0,0,1],
            [0,0,2],
            [0,1,0],
            [0,1,1],
            [0,1,2],
            [1,0,0],
            [1,0,1],
            [1,0,2],
            [1,1,0],
            [1,1,1],
            [1,1,2],
        ]
        assert_equal(corrects, results)
    end

    def test_generate
        @cv00.generate
        TODO
    end


end

