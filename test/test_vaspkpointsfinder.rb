#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/vaspkpointsfinder.rb"

class VaspKpointsFinder
end

class TC_VaspKpointsFinder < Test::Unit::TestCase
  def setup
    @vcf00 = VaspKpointsFinder.new "test/vaspkpointsfinder"
  end

  def test_kpoints
    corrects = [1, 2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64]
    #assert_equal(corrects, @vcf00.list_encuts)
  end

end

#  def test_lowest_encut
#    assert_equal(200, @vcf00.lowest_encut)
#  end

