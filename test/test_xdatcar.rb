#! /usr/bin/env ruby
# coding: utf-8

require "pp"
require "helper"

class TC_Xdatcar < Test::Unit::TestCase
  def setup
    @x00 = VaspUtils::Xdatcar.load_file('test/xdatcar/XDATCAR')
  end

  def test_load_file
    assert_equal('Untitled                                ', @x00.comment)
    assert_equal(1.0, @x00.scale)
    assert_equal( [
        [3.212500 ,  0.000000 ,  0.000000],  
        [-1.606250,   2.782107,   0.000000], 
        [0.000000 ,  0.000000 ,  5.213200],  
      ], @x00.axes
    )

    assert_equal(['Mg'] , @x00.elements)
    assert_equal([2]    , @x00.nums_elements)
    assert_equal(
      [
        [
          [0.33333334, 0.66666669, 0.25000000],
          [0.66666663, 0.33333331, 0.75000000],
        ], [
          [0.33333334, 0.66666669, 0.25000000],
          [0.66666663, 0.33333331, 0.75000000],
        ]
      ], @x00.steps_positions)
  end

end

