#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils.rb"

class TC_VaspUtils < Test::Unit::TestCase
    #def setup
    #    @k = VaspUtils.new
    #end

    #def test_generate_kmeshes
    #    results = VaspUtils::generate_kmeshes([1.0, 1.0, 1.0], 5.0)
    #    corrects = [
    #        [1,1,1],
    #        [2,2,2],
    #        [4,4,4],
    #        [8,8,8],
    #    ]
    #    assert_equal(corrects, results)

    #    results = VaspUtils::generate_kmeshes([1.0, 1.0, 2.0], 5.0)
    #    corrects = [
    #        [1,1,1],
    #        [2,2,1],
    #        [4,4,2],
    #        [8,8,4],
    #    ]
    #    assert_equal(corrects, results)

    #    results = VaspUtils::generate_kmeshes([1.0, 1.0, 3.0], 5.0)
    #    corrects = [
    #        [1,1,1], #1.0, 1.0, 3.0
    #        [2,2,1], #2.0, 2.0, 3.0
    #        [4,4,1], #4.0, 4.0, 3.0
    #        [4,4,2], #4.0, 4.0, 6.0
    #        [8,8,2], #8.0, 8.0, 6.0
    #    ]
    #    assert_equal(corrects, results)

    #    # check condition of equal
    #    results = VaspUtils::generate_kmeshes([1.0, 1.0, 1.0], 2.0)
    #    corrects = [
    #        [1,1,1],
    #        [2,2,2],
    #    ]
    #    assert_equal(corrects, results)

    #    assert_raise(VaspUtils::ArgumentError,
    #        VaspUtils::generate_kmeshes([1.0, 2.0, 2.0, 0.0], 5.0)
    #    )
    #end

    #def test_generate_wavelengths
    #    results = VaspUtils::generate_wavelengths([2.0, 2.0, 3.0], 5.0)
    #    corrects = [2.0, 3.0, 4.0, 6.0]
    #    assert_equal(corrects, results)

    #    results = VaspUtils::generate_wavelengths([1.0, 1.0, 1.0], 2.0)
    #    corrects = [1.0, 2.0]
    #    assert_equal(corrects, results)
    #end

end

