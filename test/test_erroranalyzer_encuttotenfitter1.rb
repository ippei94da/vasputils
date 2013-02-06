#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer/encuttotenfitter1.rb"

class TC_EncutTotenFitter1 < Test::Unit::TestCase
  def setup
    data_pairs = [
      [ 1, 116.0],
      [ 4, 104.0],
      [16, 101.0],
    ]
    @etf00 = VaspUtils::ErrorAnalyzer::EncutTotenFitter1.new(data_pairs)

    data_pairs = [
      [ 1, 116.0],
      [ 4,  98.0],
      [16, 101.0],
    ]
    @etf01 = VaspUtils::ErrorAnalyzer::EncutTotenFitter1.new(data_pairs)
  end

  def test_fit
    assert_equal([100.0, 16.0], @etf00.fit)
    assert_equal([100.0, 16.0], @etf01.fit)
  end

  def test_expected_errors
    correct = [
      [ 1, 16.0],
      [ 4,  4.0],
      [16,  1.0],
    ]
    assert_equal(correct, @etf00.expected_errors)
    assert_equal(correct, @etf01.expected_errors)
  end


end

