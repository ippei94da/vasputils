#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils.rb"
require "vasputils/erroranalyzer.rb"

class TC_Collector < Test::Unit::TestCase
  TOLERANCE = 1.0e-10

  def setup
    @c00 = VaspUtils::ErrorAnalyzer::Collector.new("test/erroranalyzer")
  end

  def test_initialize
    c00 = VaspUtils::ErrorAnalyzer::Collector.new("test/erroranalyzer")
  end

  #def test_select
  #  assert_equal(4, @c00.select)
  #  assert_equal(4, @c00.select())
  #  assert_equal(4, @c00.select(nil))
  #  assert_equal(2, @c00.select({:encut => 400}))
  #  assert_equal(2, @c00.select({:encut => 500}))
  #  assert_equal(2, @c00.select({:kmesh => [4,4,4]}))
  #  assert_equal(2, @c00.select({:kmesh => [5,5,5]}))
  #end

  def test_encut_toten_pairs_of_kmesh
    correct = [
      [400, -15.642518],
      [500, -15.642518],
    ]
    assert_equal(correct, @c00.encut_toten_pairs_of_kmesh([4,4,4]))

    correct = [
      [400, -15.642518],
      [500, -15.642518],
    ]
    assert_equal(correct, @c00.encut_toten_pairs_of_kmesh([5,5,5]))
  end

  def test_kmesh_toten_pairs_of_encut
    results = @c00.kmesh_toten_pairs_of_encut(400)
    assert_equal(2, results.size)
    assert_equal([4,4,4], results[0][0])
    assert_equal([5,5,5], results[1][0])
    assert_in_delta(-15.642518, results[0][1], TOLERANCE)
    assert_in_delta(-15.642518, results[1][1], TOLERANCE)

    results = @c00.kmesh_toten_pairs_of_encut(500)
    assert_equal(2, results.size)
    assert_equal([4,4,4], results[0][0])
    assert_equal([5,5,5], results[1][0])
    assert_in_delta(-15.642518, results[0][1], TOLERANCE)
    assert_in_delta(-15.642518, results[1][1], TOLERANCE)
  end

  def test_encuts
    assert_equal([400, 500], @c00.encuts)
    assert_equal([400, 500], @c00.encuts({:kmesh => [4,4,4]}))
  end

  def test_kmeshes
    assert_equal([[4,4,4], [5,5,5]], @c00.kmeshes)
    assert_equal([[4,4,4], [5,5,5]], @c00.kmeshes({:encut => 400}))
  end

end

