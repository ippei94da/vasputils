#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/vaspconditionfinder.rb"

class VaspConditionFinder
  public :lowest_encut, :list_encuts
end

class TC_VaspConditionFinder < Test::Unit::TestCase
  def setup
    @vcf00 = VaspConditionFinder.new "test/vaspconditionfinder"
  end

  def test_lowest_encut
    assert_equal(200, @vcf00.lowest_encut)
  end

  def test_list_encuts
    corrects = [ 200, 300, 400, 500, 600, 700, 800, 900, 1000]
    assert_equal(corrects, @vcf00.list_encuts)
  end

  def test_kpoints
    corrects = [1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64]
    assert_equal(corrects, @vcf00.list_encuts)
  end

end

