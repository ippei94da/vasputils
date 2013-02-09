#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer/encuttotenfitterexp.rb"

class TC_EncutTotenFitterExp < Test::Unit::TestCase
  TOLERANCE = 1.0E-10

  def setup
    data_pairs = [
      [ 0.0, 104.0],
      [ 1.0, 102.0],
      [ 2.0, 101.0],
      [ 3.0, 100.0],
    ]
    @etf00 = VaspUtils::ErrorAnalyzer::EncutTotenFitterExp.new(data_pairs)
  end

  def test_fit
    results = @etf00.fit
    assert_equal(   2, results.size)
    assert_in_delta( 4.0, results[0], TOLERANCE)
    assert_in_delta( - Math::log(2.0), results[1], TOLERANCE)

  end

  def test_expected_errors
    results = @etf00.expected_errors
    assert_equal(4, results.size)
    assert_equal(0, results[0][0])
    assert_equal(1, results[1][0])
    assert_equal(2, results[2][0])
    assert_equal(3, results[3][0])
    assert_in_delta(4.0, results[0][1], TOLERANCE)
    assert_in_delta(2.0, results[1][1], TOLERANCE)
    assert_in_delta(1.0, results[2][1], TOLERANCE)
    assert_in_delta(0.5, results[3][1], TOLERANCE)
  end


end

