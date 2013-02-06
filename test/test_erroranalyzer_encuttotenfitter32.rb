#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer/encuttotenfitter32.rb"

class TC_EncutTotenFitter32 < Test::Unit::TestCase
  def setup
    data_pairs = [
      [ 1, 164.0],
      [ 4, 108.0],
      [16, 101.0],
    ]
    @etf00 = VaspUtils::ErrorAnalyzer::EncutTotenFitter32.new(data_pairs)

    data_pairs = [
      [ 1, 164.0],
      [ 4,  94.0],
      [16, 101.0],
    ]
    @etf01 = VaspUtils::ErrorAnalyzer::EncutTotenFitter32.new(data_pairs)
  end

  def test_fit
    assert_equal([100.0, 64.0], @etf00.fit)
    assert_equal([100.0, 64.0], @etf01.fit)
  end

  def test_expected_errors
    correct = [
      [ 1, 64.0],
      [ 4,  8.0],
      [16,  1.0],
    ]
    assert_equal(correct, @etf00.expected_errors)
    assert_equal(correct, @etf01.expected_errors)
  end


end

