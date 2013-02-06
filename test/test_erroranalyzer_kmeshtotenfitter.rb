#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer/kmeshtotenfitter.rb"

class TC_KmeshTotenFitter < Test::Unit::TestCase
  def setup
    data_pairs = [
      [[1,1,1], 164.0],
      [[2,2,2], 108.0],
      [[4,4,4], 101.0],
    ]
    @ktf00 = VaspUtils::ErrorAnalyzer::KmeshTotenFitter.new(data_pairs)

    data_pairs = [
      [[1,1,1], 164.0],
      [[2,2,2],  94.0],
      [[4,4,4], 101.0],
    ]
    @ktf01 = VaspUtils::ErrorAnalyzer::KmeshTotenFitter.new(data_pairs)
  end

  def test_fit
    assert_equal([100.0, 64.0], @ktf00.fit)
    assert_equal([100.0, 64.0], @ktf01.fit)
  end

  def test_expected_errors
    correct = [
      [[1,1,1], 64.0],
      [[2,2,2],  8.0],
      [[4,4,4],  1.0],
    ]
    assert_equal(correct, @ktf00.expected_errors)

    assert_equal(correct, @ktf01.expected_errors)
  end


end

