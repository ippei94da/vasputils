#! /usr/bin/env ruby
# coding: utf-8

require "helper"
#require "test/unit"
#require "pkg/klass.rb"

class TC_ErrorFitter < Test::Unit::TestCase

  def test_self_fit
    data = [
      {:ka => 1, :toten => - 6.0},
      {:ka => 2, :toten => - 8.0},
      {:ka => 4, :toten => - 9.0},
      {:ka => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:kb => 1, :toten => - 6.0},
      {:kb => 2, :toten => - 8.0},
      {:kb => 4, :toten => - 9.0},
      {:kb => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:kc => 1, :toten => - 6.0},
      {:kc => 2, :toten => - 8.0},
      {:kc => 4, :toten => - 9.0},
      {:kc => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:kab => 1, :toten =>   6.0},
      {:kab => 2, :toten => - 6.0},
      {:kab => 4, :toten => - 9.0},
      {:kab => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv2.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:kbc => 1, :toten =>   6.0},
      {:kbc => 2, :toten => - 6.0},
      {:kbc => 4, :toten => - 9.0},
      {:kbc => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv2.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:kca => 1, :toten =>   6.0},
      {:kca => 2, :toten => - 6.0},
      {:kca => 4, :toten => - 9.0},
      {:kca => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv2.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:kabc => 1, :toten =>  54.0},
      {:kabc => 2, :toten => - 2.0},
      {:kabc => 4, :toten => - 9.0},
      {:kabc => 8, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv3.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:encut => 100, :toten => - 3.0},
      {:encut => 200, :toten => - 7.0},
      {:encut => 300, :toten => - 9.0},
      {:encut => 400, :toten => -10.0},
    ]
    result = VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    correct = Malge::ErrorFittedFunction::AXInv3.new(data)
    assert_equal(correct.coefficients  , results.coefficients  )
    assert_equal(correct.raw_pairs     , results.raw_pairs     )
    assert_equal(correct.diff_abs_pairs, results.diff_abs_pairs)

    data = [
      {:encut => 100, :toten => - 3.0},
      {:encut => 200, :toten => - 7.0},
    ]
    assert_raise(Malge::ErrorFittedFunction::InitializeError){
      VaspUtils::ConditionAnalyzer::ErrorFitter.fit(data)
    }

  end

end

