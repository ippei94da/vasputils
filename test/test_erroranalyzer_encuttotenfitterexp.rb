#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer/encuttotenfitterexp.rb"

class TC_EncutTotenFitterExp < Test::Unit::TestCase
  def setup
    data_pairs = [
      [ 1, 104.0],
      [ 2, 102.0],
      [ 3, 101.0],
    ]
    @etf00 = VaspUtils::ErrorAnalyzer::EncutTotenFitterExp.new(data_pairs)

    data_pairs = [
      [ 1, 104.0],
      [ 2, 100.0],
      [ 3, 101.0],
    ]
    @etf01 = VaspUtils::ErrorAnalyzer::EncutTotenFitterExp.new(data_pairs)
  end

  def test_fit
    assert_equal([100.0, Math::log(2.0)], @etf00.fit)
    assert_equal([100.0, Math::log(2.0)], @etf01.fit)
  end

  def test_expected_errors
    correct = [
      [ 1,  4.0],
      [ 2,  2.0],
      [ 3,  1.0],
    ]
    assert_equal(correct, @etf00.expected_errors)
    assert_equal(correct, @etf01.expected_errors)
  end


end

