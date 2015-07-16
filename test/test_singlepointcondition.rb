#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"
#

#class VaspUtils::SinglePointCondition
#end
class VaspUtils::SinglePointCondition
    attr_accessor :options
    #public :hash_to_s
end

class TC_SinglePointCondition < Test::Unit::TestCase
    def setup
        dir = "test/conditionvarier/standard"
        options = { :ka => "1,2", :kbc => "1,2,4", :encut => "400,500"}
        @cv00 = VaspUtils::SinglePointCondition.new(dir, options)

        options = { :ka => "1,2", :encut => "400,500"}
        @cv01 = VaspUtils::SinglePointCondition.new(dir, options)
    end

    def test_initialize
        #standard_vaspdir が VaspDir でなかったら例外。
        assert_raise(VaspUtils::VaspDir::InitializeError){
            VaspUtils::SinglePointCondition.new("", [])
        }

        assert_equal([1,2], @cv00.options[:ka])
        assert_equal([1,2,4], @cv00.options[:kbc])
        assert_equal([400.0,500.0], @cv00.options[:encut])
    end

    def test_self_integers
        assert_equal([1, 2], VaspUtils::SinglePointCondition.integers("1,2"))
        assert_equal([1, 2], VaspUtils::SinglePointCondition.integers("1, 2"))
        assert_equal([1, 2], VaspUtils::SinglePointCondition.integers("1,2 "))
        assert_equal([1, 2], VaspUtils::SinglePointCondition.integers(" 1,2 "))

        assert_equal([1], VaspUtils::SinglePointCondition.integers("1"))
    end

    def test_self_floats
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats("1.0,2.0"))
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats("1.0, 2.0"))
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats("1.0,2.0 "))
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats(" 1.0,2.0 "))

        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats("1,2"))
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats("1, 2"))
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats("1,2 "))
        assert_equal([1.0, 2.0], VaspUtils::SinglePointCondition.floats(" 1,2 "))

        assert_equal([1.0]     , VaspUtils::SinglePointCondition.floats("1.0"))
    end

    def test_self_check_sanity_options
        options = {
            :ka => "1,2",
            :kab => "1,2",
        }
        assert_raise(VaspUtils::SinglePointCondition::InvalidOptionError){
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }

        options = {
            :kab => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::SinglePointCondition::InvalidOptionError){
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }

        options = {
            :ka => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::SinglePointCondition::InvalidOptionError){
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }

        options = {
            :kb => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::SinglePointCondition::InvalidOptionError){
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }

        options = {
            :kc => "1,2",
            :kabc => "1,2",
        }
        assert_raise(VaspUtils::SinglePointCondition::InvalidOptionError){
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }

        options = {
            :ka => "1,2",
            :kbc => "1,2",
        }
        assert_nothing_raised{
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }

        options = {
            :ka => "1,2",
        }
        assert_nothing_raised{
            VaspUtils::SinglePointCondition.check_sanity_options(options)
        }
    end

    def test_self_mesh_points
        ary = [3]
        results = VaspUtils::SinglePointCondition.mesh_points(ary)
        corrects = [
            [0],
            [1],
            [2],
        ]
        assert_equal(corrects, results)

        ary = [2,3]
        results = VaspUtils::SinglePointCondition.mesh_points(ary)
        corrects = [
            [0,0],
            [0,1],
            [0,2],
            [1,0],
            [1,1],
            [1,2],
        ]
        assert_equal(corrects, results)

        ary = [2,2,3]
        results = VaspUtils::SinglePointCondition.mesh_points(ary)
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

    def test_generate_condition_dirs
        dirs = [
            "test/conditionvarier/encut_0400.0,ka_1",
            "test/conditionvarier/encut_0400.0,ka_2",
            "test/conditionvarier/encut_0500.0,ka_1",
            "test/conditionvarier/encut_0500.0,ka_2",
        ]
        dirs.each do |dir|
            FileUtils.rm_rf(dir)
        end

        @cv01.generate_condition_dirs("test/conditionvarier")

        vd = VaspUtils::VaspDir.new("test/conditionvarier/encut_0400.0,ka_1")
        assert_equal("400.0", vd.incar.data["ENCUT"])
        assert_equal([1, 5, 5], vd.kpoints.mesh)

        vd = VaspUtils::VaspDir.new("test/conditionvarier/encut_0400.0,ka_2")
        assert_equal("400.0", vd.incar.data["ENCUT"])
        assert_equal([2, 5, 5], vd.kpoints.mesh)

        vd = VaspUtils::VaspDir.new("test/conditionvarier/encut_0500.0,ka_1")
        assert_equal("500.0", vd.incar.data["ENCUT"])
        assert_equal([1, 5, 5], vd.kpoints.mesh)

        vd = VaspUtils::VaspDir.new("test/conditionvarier/encut_0500.0,ka_2")
        assert_equal("500.0", vd.incar.data["ENCUT"])
        assert_equal([2, 5, 5], vd.kpoints.mesh)

        dirs.each do |dir|
            FileUtils.rm_rf(dir)
        end

    end

    def test_self_hash_to_s
        hash = {:encut=>400.0, :ka=>1, :kbc=>2}
        result = VaspUtils::SinglePointCondition.hash_to_s(hash)
        correct = "encut_0400.0,ka_1,kbc_2"
        assert_equal(correct, result)
    end

end

