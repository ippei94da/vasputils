#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/erroranalyzer/encuttotenfitterexp32.rb"

class TC_EncutTotenFitterExp32 < Test::Unit::TestCase
  TOLERANCE = 1.0E-10

  def setup
    data_pairs = [
      [ 0.0, 100.0 + 3.0* 2.0**(-2.0 *  0    )],
      [ 1.0, 100.0 + 3.0* 2.0**(-2.0 * 1.0  ) ],
      [ 2.0, 100.0 + 3.0* 2.0**(-2.0 * (2.0**(3.0/2.0)))],
      [ 3.0, 100.0           ],
    ]
    @etf00 = VaspUtils::ErrorAnalyzer::EncutTotenFitterExp32.new(data_pairs)

    data_pairs = [
      [ 0.0, 100.0 + 3.0* 2.0**(-2.0 *  0    )],
      [ 1.0, 100.0 - 3.0* 2.0**(-2.0 * 1.0  ) ],
      [ 2.0, 100.0 + 3.0* 2.0**(-2.0 * (2.0**(3.0/2.0)))],
      [ 3.0, 100.0           ],
    ]
    @etf01 = VaspUtils::ErrorAnalyzer::EncutTotenFitterExp32.new(data_pairs)
  end

  def test_fit
    results = @etf00.fit
    assert_equal(   2, results.size)
    assert_in_delta( 3.0, results[0], TOLERANCE)
    assert_in_delta( - 2.0*Math::log(2.0), results[1], TOLERANCE)

    results = @etf01.fit
    assert_equal(   2, results.size)
    assert_in_delta( 3.0, results[0], TOLERANCE)
    assert_in_delta( - 2.0*Math::log(2.0), results[1], TOLERANCE)

  end

  def test_expected_errors
    results = @etf00.expected_errors
    assert_equal(4, results.size)
    assert_equal(0, results[0][0])
    assert_equal(1, results[1][0])
    assert_equal(2, results[2][0])
    assert_in_delta( 3.0* 2.0**(-2.0 *  0    ), results[0][1], TOLERANCE)
    assert_in_delta( 3.0* 2.0**(-2.0 * 1.0  ) , results[1][1], TOLERANCE)
    assert_in_delta( 3.0* 2.0**(-2.0 * (2.0**(3.0/2.0))), results[2][1], TOLERANCE)

    results = @etf01.expected_errors
    assert_equal(4, results.size)
    assert_equal(0, results[0][0])
    assert_equal(1, results[1][0])
    assert_equal(2, results[2][0])
    assert_in_delta( 3.0* 2.0**(-2.0 *  0    ), results[0][1], TOLERANCE)
    assert_in_delta( 3.0* 2.0**(-2.0 * 1.0  ) , results[1][1], TOLERANCE)
    assert_in_delta( 3.0* 2.0**(-2.0 * (2.0**(3.0/2.0))), results[2][1], TOLERANCE)

  end

end


