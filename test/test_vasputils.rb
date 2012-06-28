#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils.rb"

class TC_VaspUtils < Test::Unit::TestCase
  #def setup
  #  @k = VaspUtils.new
  #end

  def test_generate_kmeshes
    results = VaspUtils::generate_kmeshes([1.0, 2.0, 2.0], 5.0)
    corrects = [
      
    ]
    assert_equal
  end

end

