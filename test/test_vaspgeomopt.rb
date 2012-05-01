#! /usr/bin/env ruby
# coding: utf-8

require "test/unit"
require "vasputils/vaspgeomopt.rb"

class TC_VaspGeomOpt < Test::Unit::TestCase
  def setup
    @vgo00 = VaspGeomOpt.new
  end

end

