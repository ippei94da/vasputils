#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "crystalcell"
#require "test/unit"
#require "pkg/klass.rb"

class TC_CellOptimizer < Test::Unit::TestCase
    #def setup
    #    @c00 = VaspUtils::VaspCellOptimizer.new
    #end
    
    $tolerance = 1.0E-10


    def test_finished?
        @c00 = VaspUtils::VaspCellOptimizer.new("test/vaspcelloptimizer/00-after")
        assert_equal(false, @c00.finished?)
    end

    def test_distorted_axes
        #axes = CrystalCell::LatticeAxes.new( [
        axes = [
            [1.0, 1.0, 1.0],
            [0.0, 1.0, 1.0],
            [0.0, 0.0, 1.0],
        ]
        strain = [
            [1.1, 0.1, 0.2],
            [0.1, 1.2, 0.3],
            [0.2, 0.3, 1.3],
        ]
        #correct = CrystalCell::LatticeAxes.new( [
        correct = [
            [1.4, 1.6, 1.8],
            [0.3, 1.5, 1.6],
            [0.2, 0.3, 1.3],
        ]
        result = VaspUtils::VaspCellOptimizer.distort_axes(strain, axes)
        #assert_equal(correct, result)
        assert_in_delta(correct[0][0], result[0][0], $tolerance)
        assert_in_delta(correct[0][1], result[0][1], $tolerance)
        assert_in_delta(correct[0][2], result[0][2], $tolerance)
        assert_in_delta(correct[1][0], result[1][0], $tolerance)
        assert_in_delta(correct[1][1], result[1][1], $tolerance)
        assert_in_delta(correct[1][2], result[1][2], $tolerance)
        assert_in_delta(correct[2][0], result[2][0], $tolerance)
        assert_in_delta(correct[2][1], result[2][1], $tolerance)
        assert_in_delta(correct[2][2], result[2][2], $tolerance)
    end

    #def test_prepare_next
    #    c10 = VaspUtils::VaspCellOptimizer.new("test/vaspcelloptimizer/00-after")
    #    #c10.prepare_next
    #end

    def test_line_through_two_points
        p1 = [1.0, 3.0]
        p2 = [3.0, 1.0]

        results = VaspUtils::VaspCellOptimizer.line_through_two_points(p1, p2)
        assert_equal([1.0/4.0, 1.0/4.0], results)
    end

end

